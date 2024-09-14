local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Pdf = {
    books = {
        base = { guid = "dc6297", position = Vector(-13, 0.61, -29), scale = Vector(1.67, 1, 1.67) },
        guide = { guid = "43fd49", position = Vector(-5, 0.61, -29), scale = Vector(1.59, 1, 1.59) },
        --riseOfIx = { guid = "2ed556", position = Vector(5, 0.61, -29), scale = Vector(1.5, 1, 1.5) },
        --immortality = { guid = "e2ef02", position = Vector(13, 0.61, -29), scale = Vector(1.1, 1, 1.1) },
    }
}

---
function Pdf.onLoad()
    Pdf.fr = require("fr.Pdf")
    Pdf.en = require("en.Pdf")
end

---
function Pdf.setUp()
    local locale = I18N.getLocale()

    if locale == "en" then
        -- Bail out since the starting PDFs are in english.
        return
    end

    for bookName, bookInfo  in pairs(Pdf.books) do
        local bookUrl = Pdf[locale][bookName]
        Helper.onceFramesPassed(1).doAfter(function ()
            Pdf._mututateBook(bookName, bookInfo, bookUrl)
        end)
    end
end

function Pdf._mututateBook(_, info, url)
    --- We cannot create PDF ex nihilo, but need an existing PDF to be mutated.
    local book = getObjectFromGUID(info.guid)
    local data = book.getData()
    data.CustomPDF.PDFUrl = url
    book.destruct()
    spawnObjectData({ data = data })
end

return Pdf
