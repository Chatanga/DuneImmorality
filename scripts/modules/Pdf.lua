local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Pdf = {
    books = {
        base = "dc6297",
        ix = "2ed556",
        immortality = "e2ef02",
        bloodlines = "86496f",
        faq = "43fd49",
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

    for bookName, guid in pairs(Pdf.books) do
        local url = Pdf[locale][bookName]
        Helper.onceFramesPassed(1).doAfter(function ()
            -- FIXME Name clash with localized mixin modules (e.g. modules[|.fr|.en].Board)..
            ---@cast url unknown
            Pdf._mututateBook(bookName, guid, url)
        end)
    end
end

---@param bookName string
---@param guid GUID
---@param url string
function Pdf._mututateBook(bookName, guid, url)
    --- We cannot create PDF ex nihilo, but need an existing PDF to be mutated.
    local book = getObjectFromGUID(guid)
    assert(book, bookName)
    local data = book.getData()
    data.CustomPDF.PDFUrl = url
    book.destruct()
    spawnObjectData({ data = data })
end

return Pdf
