local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Locale = Module.lazyRequire("Locale")

local Board = {
    allInitialBoards = {
        mainBoard = {
            mainBoard4P = "483a1a",
            mainBoard6P = "21cc52",
        },
        emperorBoard = "4cb9ba",
        fremenBoard = "01c575",
        shippingBoard = "0b9dfe",
        ixBoard = "d75455",
        tleilaxBoard = "d5c2db",
    },
    --[[
        boardLocations[<baseBoardName.locale>] = {
            rootBaseBoardName = <mainBoard for mainBoard4P/6P, otherwise same as baseBoardName>,
            baseBoardName = <idem>,
            object = <the actual object if it exists>,
            active = <is the object alive on the primary table?>,
        }
    ]]
    boardLocations = {}
}

---
function Board.rebuildPreloadAreas()
    Locale.onLoad()

    local prebuildZone = getObjectFromGUID("23f2b5")
    local secondaryTable = getObjectFromGUID("662ced")

    for _, object in ipairs(prebuildZone.getObjects()) do
        -- Preserve the secondary table.
        if object ~= secondaryTable then
            object.destruct()
        end
    end

    for boardName, content in pairs(Board.allInitialBoards) do
        if type(content) == "table" then
            local board = nil
            for _, guid in pairs(content) do
                board = board or getObjectFromGUID(guid)
            end
            assert(board, boardName)
            local height = 0
            for stateBoardName, _ in pairs(content) do
                height = height + Board._cloneBoard(stateBoardName, board, height)
            end
        else
            local board = getObjectFromGUID(content)
            assert(board, boardName)
            Board._cloneBoard(boardName, board, 0)
        end
    end
end

---
function Board._cloneBoard(baseBoardName, board, height)
    local boardName = Helper.getID(board)
    assert(boardName and boardName:len() > 0, "Unidentified board: " .. board.getGUID())

    local baseName = Board._getBaseName(boardName)
    assert(baseName, "Malformed id: " .. tostring(boardName))
    local namedIds = {
        [baseName] = board.getStateId()
    }
    local states = board.getStates()
    if states then
        for _, state in ipairs(states) do
            namedIds[Board._getBaseName(Helper.getID(state))] = state.id
        end
    end

    local allSupports = {
        fr = require("fr.Board"),
        en = require("en.Board"),
    }

    local count = 0
    for locale, boardSet in pairs(allSupports) do
        local expectedBoardName = Board._toBoardName(baseBoardName, locale)
        if boardName ~= expectedBoardName then
            local boardImage = boardSet[baseBoardName]
            if boardImage then
                local clonedBoard = board.clone()
                local finalHeight = (height + count) * 3
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    local continuation = Helper.createContinuation("setState")

                    local expectedStateId = namedIds[baseBoardName]
                    if board.getStateId() ~= expectedStateId then
                        clonedBoard = clonedBoard.setState(expectedStateId)
                        Helper.onceTimeElapsed(0.5).doAfter(function ()
                            continuation.run(clonedBoard)
                        end)
                    else
                        continuation.run(clonedBoard)
                    end

                    continuation.doAfter(function (finalClonedBoard)
                        local parameters = finalClonedBoard.getCustomObject()
                        parameters.image = boardSet[baseBoardName]
                        finalClonedBoard.setCustomObject(parameters)
                        finalClonedBoard = finalClonedBoard.reload()
                        Helper.onceTimeElapsed(0.5).doAfter(function ()
                            finalClonedBoard.setLock(true)
                            finalClonedBoard.setPosition(board.getPosition() + Vector(0, finalHeight, 68))
                            finalClonedBoard.setGMNotes(expectedBoardName)
                        end)
                    end)
                end)
                count = count + 1
            end
        end
    end
    return count
end

---
function Board._getBaseName(id)
    if id then
        local tokens = Helper.splitString(id, '.')
        if #tokens == 2 then
            return tokens[1]
        end
    end
    return nil
end

---
function Board.onLoad()
    local prebuildZone = getObjectFromGUID("23f2b5")

    for _, locale in ipairs(Locale.getAllLocales()) do
        for baseBoardName, content in pairs(Board.allInitialBoards) do
            if type(content) == "table" then
                for subBaseBoardName, _ in pairs(content) do
                    Board.boardLocations[Board._toBoardName(subBaseBoardName, locale)] = {
                        rootBaseBoardName = baseBoardName,
                        baseBoardName = subBaseBoardName,
                    }
                end
            else
                Board.boardLocations[Board._toBoardName(baseBoardName, locale)] = {
                    rootBaseBoardName = baseBoardName,
                    baseBoardName = baseBoardName,
                }
            end
        end
    end

    for _, object in ipairs(getAllObjects()) do
        local id = Helper.getID(object)
        local location = Board.boardLocations[id]
        if location then
            location.object = object
            location.active = true
        end
    end

    for _, object in ipairs(prebuildZone.getObjects()) do
        local id = Helper.getID(object)
        local location = Board.boardLocations[id]
        if location then
            location.active = false
            location.object.setInvisibleTo(Player.getColors())
        end
    end
end

---
function Board.setUp(setting)
    -- NOP
end

---
function Board.selectBoard(baseBoardName, language)
    local boardName = Board._toBoardName(baseBoardName, language)
    local location = Board.boardLocations[boardName]
    assert(location, "No location for board " .. boardName)
    assert(location.object, "No instantiated location for board " .. boardName)

    if not location.active then
        for _, otherLocation in pairs(Board.boardLocations) do
            if otherLocation.rootBaseBoardName == location.rootBaseBoardName and otherLocation.active then
                local otherPosition = otherLocation.object.getPosition()

                -- TODO A simple move (swap) would be enough.
                otherLocation.object.destruct()
                otherLocation.object = nil
                otherLocation.active = false

                location.object.setPosition(otherPosition)
                location.object.setInvisibleTo({})
                location.active = true
                Helper.onceMotionless(location.object).doAfter(function ()
                    Helper.noPhysics(location.object)
                end)

                return location.object
            end
        end
        error("No active location for " .. baseBoardName)
    else
        return location.object
    end
end

---
function Board.destructBoard(baseBoardName)
    for _, location in pairs(Board.boardLocations) do
        if location.baseBoardName == baseBoardName and location.object then
            location.object.destruct()
            location.object = nil
            location.active = false
        end
    end
end

---
function Board.destructInactiveBoards()
    for _, location in pairs(Board.boardLocations) do
        if not location.active and location.object then
            location.object.destruct()
            location.object = nil
        end
    end
end

---
function Board.getBoard(baseBoardName, locale)
    local boardName = Board._toBoardName(baseBoardName, locale or I18N.getLocale())
    local location = Board.boardLocations[boardName]
    if location then
        return location.object
    end
end

---
function Board._toBoardName(baseBoardName, language)
    return baseBoardName .. '.' .. language
end

return Board
