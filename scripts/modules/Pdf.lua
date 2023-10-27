local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Pdf = {
    books = {
        base = { guid = "dc6297", position = Vector(-13, 0.61, -29), scale = Vector(1.67, 1, 1.67) },
        faq = { guid = "43fd49", position = Vector(-5, 0.61, -29), scale = Vector(1.59, 1, 1.59) },
        riseOfIx = { guid = "2ed556", position = Vector(5, 0.61, -29), scale = Vector(1.5, 1, 1.5) },
        immortality = { guid = "e2ef02", position = Vector(13, 0.61, -29), scale = Vector(1.1, 1, 1.1) },
    }
}

---
function Pdf.onLoad(state)
    Pdf.fr = require("fr.Pdf")
    Pdf.en = require("en.Pdf")
end

---
function Pdf.setUp(settings)
    local locale = I18N.getLocale()

    if locale == "en" then
        -- Bail out since the base PDF are in english.
        return
    end

    for bookName, bookInfo  in pairs(Pdf.books) do
        local bookUrl = Pdf[locale][bookName]
        Helper.onceFramesPassed(1).doAfter(function ()
            Pdf._mututateBook(bookName, bookInfo, bookUrl)
        end)
    end

    -- TODO better?
    if (locale == "fr") then
        getObjectFromGUID("e43180").flip()
    end
end

function Pdf._mututateBook(bookName, info, url)
    --- We cannot create PDF ex nihilo, but need an existing PDF to be mutated.
    getObjectFromGUID(info.guid).destruct()

    local data = {
        GUID = info.guid,
        Name = "Custom_PDF",
        Transform = {
            posX = info.position.x,
            posY = info.position.y,
            posZ = info.position.z,
            rotX = 0,
            rotY = 180,
            rotZ = 0,
            scaleX = info.scale.x,
            scaleY = info.scale.y,
            scaleZ = info.scale.z,
        },
        GMNotes = bookName,
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = true,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = true,
        GridProjection = false,
        HideWhenFaceDown = false,
        Hands = false,
        CustomPDF = {
            PDFUrl = url,
            PDFPassword = "",
            PDFPage = 0,
            PDFPageOffset = 0
        },
    }

    spawnObjectData({ data = data })
end

return Pdf
