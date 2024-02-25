core = require("Core")

i18n = require("i18n")
require("locales")

constants = require("Constants")

boardCommonModule = require("BoardCommonModule")

techZone = constants.techZone

cargo_pos_init = {
    Yellow = core.getHardcodedPositionFromGUID('8fa76f', 8.999581, 0.769945145, 2.850366),
    Green = core.getHardcodedPositionFromGUID('34281d', 8.449573, 0.770712, 2.85037041),
    Blue = core.getHardcodedPositionFromGUID('68e424', 7.34954929, 0.7722466, 2.8544035),
    Red = core.getHardcodedPositionFromGUID('e9096d', 7.89962053, 0.7714795, 2.853223)
}

_ = core.registerLoadablePart(function(saved_data)
    Swordmaster_zone = getObjectFromGUID("6932df")
    Smuggling_zone = getObjectFromGUID("6cc2f8")
    Shipping_zone = getObjectFromGUID("3e7409")

    self.interactable = false
    activateButtons()
end)

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function activateButtons()

    self.createButton({
        click_function = "CommercialMoney",
        function_owner = self,
        label = "get",
        position = {2.5, 0.1, 0.15},
        scale = {0.238, 0.238, 0.238},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "CommercialSpice",
        function_owner = self,
        label = "get",
        position = {2.855, 0.1, 0.15},
        scale = {0.238, 0.238, 0.238},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "CommercialTroop",
        function_owner = self,
        label = "get",
        position = {2.68, 0.1, -0.27},
        scale = {0.238, 0.238, 0.238},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })

    self.createButton({
        click_function = "HighCouncil",
        function_owner = self,
        label = "pay & get",
        position = {-2, 0.1, -0.1},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Mentat",
        function_owner = self,
        label = "pay & get",
        position = {-2, 0.1, 0.72},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Swordmaster",
        function_owner = self,
        label = "pay & get",
        position = {-0.38, 0.1, 0.72},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SmugglingUp",
        function_owner = self,
        label = "get + ↑",
        position = {1.08, 0.1, 0.72},
        scale = {0.238, 0.238, 0.238},
        width = 700,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SmugglingDown",
        function_owner = self,
        label = "get + ↓↓",
        position = {1.08, 0.1, 0.91},
        scale = {0.238, 0.238, 0.238},
        width = 700,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "ShippingUpUp",
        function_owner = self,
        label = "↑ + ↑",
        position = {1.28, 0.1, -0.48},
        scale = {0.238, 0.238, 0.238},
        width = 500,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "ShippingUpDown",
        function_owner = self,
        label = "↑ + ↓↓",
        position = {1.28, 0.1, -0.29},
        scale = {0.238, 0.238, 0.238},
        width = 500,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "ShippingDownUp",
        function_owner = self,
        label = "↓↓ + ↑",
        position = {1.28, 0.1, -0.1},
        scale = {0.238, 0.238, 0.238},
        width = 500,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "CommercialUp",
        function_owner = self,
        label = "↑",
        position = {2.51, 0.1, 0.63},
        scale = {0.5, 0.238, 0.5},
        width = 250,
        height = 250,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "CommercialDown",
        function_owner = self,
        label = "↓↓",
        position = {2.75, 0.1, 0.63},
        scale = {0.5, 0.238, 0.5},
        width = 250,
        height = 250,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
end

function Swordmaster(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.Swordmaster(color, Swordmaster_zone)
end

function Mentat(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.Mentat(color)
end

function HighCouncil(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.HighCouncil(color)
end

function gainSolariFromSmuggling(color)
    local leader = helperModule.getLeader(color)
    local solariIncome = 1
    local solari = "Solari"

    if leader.hasTag("Yuna") then
        solariIncome = 2
        solari = "Solaris"
    end

    Wait.time(function() constants.players[color].solari.call("incrementVal") end, 0.25,
              solariIncome)

    return solariIncome .. " " .. solari
end

function getCargoStep(color)
    local p = constants.players[color].cargo.getPosition()
    return math.floor((p.z - cargo_pos_init[color].z) / 1.1 + 0.5)
end

function setCargoPositionSmooth(color, step)
    local p = cargo_pos_init[color]:copy()
    p:setAt('z', p.z + 1.1 * step)
    constants.players[color].cargo.setPositionSmooth(p, false, true)
end

function cargoUp(color)
    local cargoMoved = false

    local step = getCargoStep(color)
    if step >= 3 then
        broadcastToColor(i18n("nope"), color, "Purple")
    else
        setCargoPositionSmooth(color, step + 1)
        cargoMoved = true
    end

    return cargoMoved
end

function cargoReset(color)
    local cargoMoved = false

    local step = getCargoStep(color)
    if step == 0 then
        broadcastToColor(i18n("nope"), color, "Purple")
    else
        setCargoPositionSmooth(color, 0)
        cargoMoved = true

        if step >= 3 then
            local planetIx = getObjectFromGUID('d75455')
            planetIx.call("callRegisterTechDiscount", {
                color = color,
                source = "cargo",
                amount = 2
            })
        end
    end

    return cargoMoved
end

function SmugglingUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if boardCommonModule.CheckAgentAndPlayer(color, Smuggling_zone) then
        if cargoUp(color) then

            local leaderName = helperModule.getLeaderName(color)
            local solariString = gainSolariFromSmuggling(color)

            broadcastToAll(i18n("smugglingUp"):format(leaderName, solariString),
                           color)
        end
    end
end

function SmugglingDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if boardCommonModule.CheckAgentAndPlayer(color, Smuggling_zone) then
        if cargoReset(color) then
            local leaderName = helperModule.getLeaderName(color)
            local solariString = gainSolariFromSmuggling(color)

            broadcastToAll(
                i18n("smugglingDown"):format(leaderName, solariString), color)
        end
    end
end

function CommercialUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if cargoUp(color) then
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(leaderName .. i18n("commercialUp"), color)
    end
end

function CommercialDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if cargoReset(color) then
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(leaderName .. i18n("commercialDown"), color)
    end
end

function ShippingUpUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if boardCommonModule.CheckAgentAndPlayer(color, Shipping_zone) then
        local reputationLevels = boardCommonModule.getReputationLevels("spacingGuild", color)
        local step = getCargoStep(color)
        if pion_reput.spacingGuild[color].getPosition().z < reputationLevels.friendship then
            broadcastToColor(i18n("notReputation"), color, "Red")
        elseif step >= 2 then
            broadcastToColor(i18n("nope"), color, "Purple")
        else
            cargoUp(color)
            Wait.time(function()
                cargoUp(color)
            end, 0.5)
            local leaderName = helperModule.getLeaderName(color)
            broadcastToAll(leaderName .. i18n("commercialUpUp"), color)
        end
    end
end

function ShippingUpDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if boardCommonModule.CheckAgentAndPlayer(color, Shipping_zone) then
        local reputationLevels = boardCommonModule.getReputationLevels("spacingGuild", color)
        if pion_reput.spacingGuild[color].getPosition().z < reputationLevels.friendship then
            broadcastToColor(i18n("notReputation"), color, "Red")
        elseif cargoUp(color) then
            Wait.time(function()
                cargoReset(color)
            end, 0.5)
            local leaderName = helperModule.getLeaderName(color)
            broadcastToAll(leaderName .. i18n("commercialUpDown"), color)
        end
    end
end

function ShippingDownUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    if boardCommonModule.CheckAgentAndPlayer(color, Shipping_zone) then
        local reputationLevels = boardCommonModule.getReputationLevels("spacingGuild", color)
        if pion_reput.spacingGuild[color].getPosition().z < reputationLevels.friendship then
            broadcastToColor(i18n("notReputation"), color, "Red")
        elseif cargoReset(color) then
            Wait.time(function()
                cargoUp(color)
            end, 0.5)
            local leaderName = helperModule.getLeaderName(color)
            broadcastToAll(leaderName .. i18n("commercialDownUp"), color)
        end
    end
end

function CommercialMoney(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    local leader = helperModule.getLeader(color)
    assert(leader)
    local leaderName = leader.getName()
    local solariIncome = 5

    local t = 0
    local combat = Global.call("getFight")

    if leader.hasTag("Yuna") and combat == 0 then solariIncome = 6 end
    for i = 1, solariIncome - 1, 1 do
        t = t + 0.25
        Wait.time(function() constants.players[color].solari.call("incrementVal") end, t)
    end
    for _, player in pairs(constants.alivePlayers) do
        player.solari.call("incrementVal")
    end
    broadcastToAll(i18n("shippingSolari"):format(leaderName, solariIncome),
                   color)
    broadcastToAll(i18n("dividends"), white)

end

function CommercialSpice(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    local leaderName = helperModule.getLeaderName(color)
    local t = 0
    for i = 1, 2, 1 do
        t = t + 0.25
        Wait.time(function() constants.players[color].spice.call("incrementVal") end, t)

    end
    broadcastToAll(i18n("shippingSpice"):format(leaderName), color)
end

function CommercialTroop(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    local leaderName = helperModule.getLeaderName(color)
    local troopsToGain = 2

    local t = 0
    local troopTransportAvailable = false
    local techs = constants.players[color].techZone.getObjects()
    for _, obj in ipairs(techs) do
        if obj.hasTag("Troop Transports") then
            troopTransportAvailable = true
        end
    end
    if troopTransportAvailable then
        troopsToGain = 3
        broadcastToAll(i18n("troopTransport"):format(leaderName), color)
    else
        broadcastToAll(i18n("shippingTroops"):format(leaderName), color)
    end
    helperModule.landTroopsFromOrbit(color, troopsToGain)
end