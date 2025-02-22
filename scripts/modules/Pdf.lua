local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

---@alias BookInfo {
--- guid: GUID,
--- position: Vector,
--- scale: Vector }

local Pdf = {
    books = {
        base = { guid = "dc6297", position = Vector(-13, 0.61, -29), scale = Vector(1.67, 1, 1.67) },
        guide = { guid = "43fd49", position = Vector(-5, 0.61, -29), scale = Vector(1.59, 1, 1.59) },
        --riseOfIx = { guid = "xxxxxx", position = Vector(5, 0.61, -29), scale = Vector(1.5, 1, 1.5) },
        --immortality = { guid = "xxxxxx", position = Vector(13, 0.61, -29), scale = Vector(1.1, 1, 1.1) },
        --bloodlines = { guid = "xxxxxx", position = Vector(14, 0.61, -29), scale = Vector(1.5, 1, 1.5) },
    }
}

function Pdf.onLoad(_)
    Pdf.fr = require("fr.Pdf")
    Pdf.en = require("en.Pdf")
end

function Pdf.setUp()
    local locale = I18N.getLocale()

    if locale == "en" then
        -- Bail out since the starting PDFs are in english.
        return
    end

    for bookName, bookInfo in pairs(Pdf.books) do
        local url = Pdf[locale][bookName]
        Helper.onceFramesPassed(1).doAfter(function ()
            -- FIXME Name clash with localized mixin modules (e.g. modules[|.fr|.en].Board)..
            ---@cast url unknown
            Pdf._mututateBook(bookName, bookInfo, url)
        end)
    end
end

---@param bookName string
---@param info BookInfo
---@param url string
function Pdf._mututateBook(bookName, info, url)
    --- We cannot create PDF ex nihilo, but need an existing PDF to be mutated.
    local book = getObjectFromGUID(info.guid)
    assert(book, bookName)
    local data = book.getData()
    data.CustomPDF.PDFUrl = url
    book.destruct()
    spawnObjectData({ data = data })
end

return Pdf
