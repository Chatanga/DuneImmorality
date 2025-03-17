local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Pdf = {
    books = {
        base = { guid = "dc6297", position = Vector(-13, 0.61, -29), scale = Vector(1.67, 1, 1.67) },
        guide = { guid = "43fd49", position = Vector(-5, 0.61, -29), scale = Vector(1.59, 1, 1.59) },
        --riseOfIx = { guid = "2ed556", position = Vector(5, 0.61, -29), scale = Vector(1.5, 1, 1.5) },
        --immortality = { guid = "e2ef02", position = Vector(13, 0.61, -29), scale = Vector(1.1, 1, 1.1) },
    },
    bagGUID = "66ac63" -- The bag where PDFs should be placed
}

function Pdf.onLoad()
    Pdf.fr = require("fr.Pdf")
    Pdf.en = require("en.Pdf")
end

function Pdf.setUp()
    local locale = I18N.getLocale()
    local bag = getObjectFromGUID(Pdf.bagGUID)

    if not bag then
        return
    end

    for bookName, bookInfo in pairs(Pdf.books) do
        Helper.onceFramesPassed(1).doAfter(function()
            Pdf._moveOrReplaceBook(bookName, bookInfo, locale, bag)
        end)
    end
end

--- For each book:
--- - In English mode: simply move the object into the bag.
--- - In French mode: update its data with the French URL, destroy the English version, spawn a new object, and then put that in the bag.
function Pdf._moveOrReplaceBook(bookName, info, locale, bag)
    local book = getObjectFromGUID(info.guid)
    if not book then
        return
    end

    if locale == "en" then
        Helper.physicsAndPlay(book)
        bag.putObject(book)
    else
        -- Retrieve the French URL from the French PDF module
        local frenchUrl = Pdf.fr[bookName]
        if not frenchUrl then
            return
        end

        -- Get the existing data, update the PDF URL, then destroy the English book
        local data = book.getData()
        data.CustomPDF.PDFUrl = frenchUrl
        book.destruct()

        -- Wait one frame to ensure the object is destroyed before spawning the new one
        Helper.onceFramesPassed(1).doAfter(function()
            local spawnedBook = spawnObjectData({ data = data })
            if spawnedBook then
                spawnedBook.setScale(info.scale)
                Helper.onceFramesPassed(1).doAfter(function()
                    Helper.physicsAndPlay(spawnedBook)
                    bag.putObject(spawnedBook)
                end)
            else
            end
        end)
    end
end

return Pdf
