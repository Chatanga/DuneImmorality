_ = require("Core").registerLoadablePart(function()
    local button_parameters = {
        click_function = 'blank',
        function_owner = self,
        label = 'First Player',
        position = {0, 0.5, 0},
        rotation = {0, 180, 0},
        width = 1600,
        height = 500,
        font_size = 250
    }
    getObjectFromGUID("d84873").createButton(button_parameters)

    self.setInvisibleTo({
        "White", "Blue", "Red", "Yellow", "Green", "Grey", "Black"
    })
    self.interactable = false
end)

function blank() end
