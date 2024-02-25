i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

players = constants.players

_ = require("Core").registerLoadablePart(function()
    bene_tleilax_board = getObjectFromGUID("d5c2db")
    onLocaleChange()
end)

function onLocaleChange()
    self.createButton({
        click_function = "tleilaxuTroop",
        function_owner = self,
        label = "pay & get →",
        position = {-0.1, 0.2, -0.75},
        scale = {0.3, 0.5, 0.3},
        width = 2200,
        height = 500,
        font_size = 400,
        color = {0.3571, 0.3571, 0.3571, 1},
        font_color = {1, 1, 1, 1}
    })

    self.createButton({
        click_function = "tleilaxuScarab",
        function_owner = self,
        label = "pay & get →",
        position = {-0.1, 0.2, -0.35},
        scale = {0.3, 0.5, 0.3},
        width = 2200,
        height = 500,
        font_size = 400,
        color = {0.3571, 0.3571, 0.3571, 1},
        font_color = {1, 1, 1, 1}
    })
end

function tleilaxuTroop(_, color)

    local leaderName = helperModule.getLeaderName(color)
    if isEnoughSpecimen(_, color) then
        Player[color].showConfirmDialog(i18n("reclaimedForcesTroopsWarning"),
        function(color)
            spendSpecimen(color, 3)
            Wait.time(function()
                helperModule.landTroopsFromOrbit(color, 2)
            end, 2)
            broadcastToAll(leaderName .. i18n("reclaimedForcesTroops"), color)
        end)
    end
end

function tleilaxuScarab(_, color)

    local leaderName = helperModule.getLeaderName(color)
    if isEnoughSpecimen(_, color) then
        Player[color].showConfirmDialog(i18n("reclaimedForcesScarabWarning"),
        function(color)
            spendSpecimen(color, 3)

            Wait.time(function()
                local params = {color = color, silent = true}
                bene_tleilax_board.call("moveTleilaxuCall", params)
                broadcastToAll(leaderName .. i18n("reclaimedForcesScarab"), color)
            end, 1)
        end)
    end

end

function spendSpecimen(color, price)
    Wait.time(function()
        local params = {osef = "", color = color, silent = true}
        bene_tleilax_board.Call("RemoveSpecimenCall", params)
    end, 0.3, price)
end

function isEnoughSpecimen(_, color)
    local testSpecimen = false
    local countSpecimen = 0
    local price = 3
    -- comptage Spécimen
    for _, troop in ipairs(getObjectFromGUID("f5de09").getObjects()) do
        if troop.hasTag("Troop") and troop.hasTag(color) then
            countSpecimen = countSpecimen + 1
        end
    end
    if price > countSpecimen then
        broadcastToColor(i18n("notEnoughSpecimen"), color, "Red")
    else
        testSpecimen = true
    end

    return testSpecimen
end