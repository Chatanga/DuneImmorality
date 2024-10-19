-- Tournament Worm by grimnebulin (aka Mark Silverman)
-- marksilverman@gmail.com or grimnebulin#0122
local worm = {}

constants = require("Constants")
resources = constants.ressources
spice = 1
solari = 2
eau = 3
leader = 6
results = {}
startTime = os.time()
game_id = -1
gameWasSubmitted = false
tournament_token = "-1"
tournament_mode = false
worm.streamer_mode = true
worm.vptray = nil
worm.points = nil
worm.pics = nil

function worm.init()
    worm.pics = {}
    worm.pics["Baron Harkonnen"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141345301/58773A049B5EC10CB24DABC66E8DFF5B3B5A7966/"
    worm.pics["Countess Ariana"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344304/0AC41A9B4FF90D7CAD22A0C899532FA3624CD9D3/"
    worm.pics["Archduke Armand"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344924/D7E5F550BBCAF67F7FC6280A9D2C8CBFD357D605/"
    worm.pics["Count Ilban"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344551/68BE1BAD1A7DB2BD87330DD3D97E25D034B03A10/"
    worm.pics["Helena Richese"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344426/B3136F00AE416D6989303FE5A2504A1FC8DA32C2/"
    worm.pics["Tessia Vernius"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344665/38DEC17448EF01FE1D9C4BF402EA5864A07DBF31/"
    worm.pics["Prince Rhombur"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344794/471BF295C71548463E1B1980E933911EA4C620E6/"
    worm.pics["Rabban 'The Beast'"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141345165/541AF590F49C02EB4D75E1188355B504A657E8F2/"
    worm.pics["Ilesa Ecaz"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141345620/2A9487D3C7E3546EC0272001965FBEFAB6F9324E/"
    worm.pics["Duke Leto"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141345758/CC72D93C394CB1ECD456DF514D0746BE252F8D14/"
    worm.pics["Viscount Hundro"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2488878371133860146/E06835C878941E36867616FC354BD9E1CE578B72/"
    worm.pics["Paul Atreides"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141345444/8E702CE9D1470D280C4BA616B41FA9CEB0265EC0/"
    worm.pics["Princess Yuna"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141345030/17C22AFCDBF5ED0B4743D98D4F7CBA2B52D3E133/"
    worm.pics["Earl Memnon"] =
        "https://steamusercontent-a.akamaihd.net/ugc/2502404390141344161/6E26B748A38B5FADF1A719C33E9E8EC591285052/"

    worm.vptray = {}
    worm.vptray["Red"] = getObjectFromGUID("e0ed4b")
    worm.vptray["Green"] = getObjectFromGUID("caaba4")
    worm.vptray["Yellow"] = getObjectFromGUID("99a860")
    worm.vptray["Blue"] = getObjectFromGUID("121bb6")

    worm.points = {}
    worm.points["Blue"] = nil
    worm.points["Red"] = nil
    worm.points["Yellow"] = nil
    worm.points["Green"] = nil

end

local allDefaults = [[
<Defaults>
    <Panel class="Window" color="#222222ff" allowDragging="True"
        returnToOriginalPositionWhenReleased="false" outline="#404040"/>
    <Panel class="header" color="black"/>
    <Panel class="red" color="#aa2222"/>
    <Panel class="green" color="#228822"/>
    <Panel class="yellow" color="#aaaa22"/>
    <Panel class="blue" color="#2222aa"/>
    <Panel class="black" color="black"/>
    <Panel class="white" color="white"/>
    <Panel class="orange" color="orange"/>
    <Text fontSize="16" color="white"/>
    <Button color="blue" textColor="white" fontSize="20"/>
    <InputField onValueChanged="]] .. self.guid ..
                        [[/changeValue" characterValidation="Integer" textColor="black" text="0" fontSize="20" alignment="MiddleCenter"/>
    <InputField class="red2" color="#cc4444"/>
    <InputField class="green2" color="#44aa44"/>
    <InputField class="yellow2" color="#cccc44"/>
    <InputField class="blue2" color="#4444cc"/>
</Defaults>
]]

UI.setXml(allDefaults)

local firstPanel = [[
    <Panel id="firstPanel" class="Window" width="600" height="220">
    <TableLayout padding="10">
    <Row>
    <Cell columnSpan="3"><Panel><Text>This is an official TOURNAMENT game. Enter a valid tournament token, then click continue to begin.</Text></Panel></Cell>
    </Row>
    <Row height="110">
    <Cell height="110"><Panel height="110"><Text>tournament token:</Text></Panel></Cell>
    <Cell><InputField class="green2" id="tournament_token" onValueChanged="]] ..
                       self.guid .. [[/updateTournamentToken"/></Cell>
    <Cell><Button id="continue" color="blue" text="CONTINUE" onClick="]] ..
                       self.guid .. [[/secondStep"/></Cell>
    </Row>
    </TableLayout>
    </Panel>]]

local secondPanel =
    [[<Panel id="secondPanel" class="Window" active="false" width="80" height="80" rectAlignment="LowerRight" offsetXY="-10,60">
<Button id="continue" color="blue" text="Open Submit Screen" onClick="]] ..
        self.guid .. [[/openScoreScreen"/>
</Panel>
]]

local scorePanel = [[
    <Panel id="scorePanel" class="Window" active="false" width="950" height="500" color="#222222ff" allowDragging="True"
        returnToOriginalPositionWhenReleased="false" outline="#404040">
        <TableLayout>
        <Row>
        <Cell columnSpan="7"><Panel class="orange"><Text>NOTE: VP tokens above 12 must be placed on the corresponding player's VP tray to be taken into account.
        This tool tries to resolve ties by looking at Chaumurky, spice, solari, and water, but it's not perfect.
        Double check the ranking, adjust as needed and TAKE A SCREENSHOT before submitting.</Text></Panel></Cell>
        </Row>
            <Row>
                <Cell><Panel><Text>Tournament Token:</Text></Panel></Cell>
                <Cell columnSpan="6"><InputField id="tournament_token" onValueChanged="]] ..
                       self.guid .. [[/updateTournamentToken"/></Cell>
            </Row>
            <Row>
                <Cell><Panel class="header"><Text>PLAYER</Text></Panel></Cell>
                <Cell><Panel class="header"><Text>LEADER</Text></Panel></Cell>
                <Cell><Panel class="header"><Text>RANK</Text></Panel></Cell>
                <Cell><Panel class="header"><Text>VPs</Text></Panel></Cell>
                <Cell><Panel class="header"><Text>SPICE</Text></Panel></Cell>
                <Cell><Panel class="header"><Text>SOLARI</Text></Panel></Cell>
                <Cell><Panel class="header"><Text>WATER</Text></Panel></Cell>
            </Row>
            <Row>
                <Cell><Panel class="red"><Text id="name_red"></Text></Panel></Cell>
                <Cell><Panel class="red"><Text id="leader_red"></Text></Panel></Cell>
                <Cell><InputField class="red2" id="rank_red"/></Cell>
                <Cell><InputField class="red2" id="points_red"/></Cell>
                <Cell><InputField class="red2" id="spice_red"/></Cell>
                <Cell><InputField class="red2" id="solari_red"/></Cell>
                <Cell><InputField class="red2" id="water_red"/></Cell>
            </Row>
            <Row>
                <Cell><Panel class="green"><Text id="name_green"></Text></Panel></Cell>
                <Cell><Panel class="green"><Text id="leader_green"></Text></Panel></Cell>
                <Cell><InputField class="green2" id="rank_green"/></Cell>
                <Cell><InputField class="green2" id="points_green"/></Cell>
                <Cell><InputField class="green2" id="spice_green"/></Cell>
                <Cell><InputField class="green2" id="solari_green"/></Cell>
                <Cell><InputField class="green2" id="water_green"/></Cell>
            </Row>
            <Row>
                <Cell><Panel class="yellow"><Text id="name_yellow"></Text></Panel></Cell>
                <Cell><Panel class="yellow"><Text id="leader_yellow"></Text></Panel></Cell>
                <Cell><InputField class="yellow2" id="rank_yellow"/></Cell>
                <Cell><InputField class="yellow2" id="points_yellow"/></Cell>
                <Cell><InputField class="yellow2" id="spice_yellow"/></Cell>
                <Cell><InputField class="yellow2" id="solari_yellow"/></Cell>
                <Cell><InputField class="yellow2" id="water_yellow"/></Cell>
            </Row>
            <Row>
                <Cell><Panel class="blue"><Text id="name_blue"></Text></Panel></Cell>
                <Cell><Panel class="blue"><Text id="leader_blue"></Text></Panel></Cell>
                <Cell><InputField class="blue2" id="rank_blue"/></Cell>
                <Cell><InputField class="blue2" id="points_blue"/></Cell>
                <Cell><InputField class="blue2" id="spice_blue"/></Cell>
                <Cell><InputField class="blue2" id="solari_blue"/></Cell>
                <Cell><InputField class="blue2" id="water_blue"/></Cell>
            </Row>
            <Row>
                <Cell><Button id="close" text="Close" onClick="]] .. self.guid ..
                       [[/secondStep"/></Cell>
                <Cell><Button id="fetch" text="Refresh Results" onClick="]] ..
                       self.guid .. [[/refreshResults"/></Cell>
                <Cell><Panel color="black"/></Cell>
                <Cell><Panel color="black"/></Cell>
                <Cell><Panel color="black"/></Cell>
                <Cell><Panel textColor="white" color="black"><Text id="reminder"></Text></Panel></Cell>
                <Cell><Button id="submit" onClick="]] .. self.guid ..
                       [[/sendForm"/></Cell>
            </Row>
        </TableLayout>
    </Panel>
    ]]

function worm.firstStep()
    worm.tournament_mode = true
    local existingXml = UI.getXml()
    UI.setXml(existingXml .. firstPanel .. secondPanel .. scorePanel)
end

function updateTournamentToken(player, value, element) tournament_token = value end

function secondStep()
    for _, player in ipairs(Player.getPlayers()) do
        if allGood(player) then
            local color = player.color
            results[color] = {}
            results[color]["color"] = color
            results[color]["name"] = player.steam_name
            results[color]["id"] = player.steam_id
            --UI.setAttribute("agree_" .. color, "text", player.steam_name)
        end
    end
    worm.submitScreenButton()
end

function worm.submitScreenButton()
    UI.hide("firstPanel")
    UI.hide("scorePanel")
    UI.show("secondPanel")
end

function openScoreScreen()

    UI.hide("secondPanel")
    UI.show("scorePanel")

    Wait.frames(refreshResults, 2)
end

function lookForProblems()
    if gameWasSubmitted then return end

    local rankList = {
        UI.getAttribute("rank_red", "text"),
        UI.getAttribute("rank_green", "text"),
        UI.getAttribute("rank_yellow", "text"),
        UI.getAttribute("rank_blue", "text")
    }
    for i = 1, 3 do
        for j = i + 1, 4 do
            if rankList[i] == rankList[j] then
                broadcastToAll(
                    'ERROR: Two or more players are tied in rank. Resolve this before submitting.')
                UI.setAttribute("submit", "interactable", "false")
                UI.setAttribute("submit", "color", "red")
                UI.setAttribute("submit", "textColor", "white")
                UI.setAttribute("submit", "text", "Resolve tie first!")
                return
            end
        end
    end

    vpRed = tonumber(UI.getAttribute("points_red", "text"))
    vpGreen = tonumber(UI.getAttribute("points_green", "text"))
    vpYellow = tonumber(UI.getAttribute("points_yellow", "text"))
    vpBlue = tonumber(UI.getAttribute("points_blue", "text"))
    if vpRed < 10 and vpGreen < 10 and vpYellow < 10 and vpBlue < 10 then
        UI.setAttribute("reminder", "text", "")
        UI.setAttribute("submit", "interactable", "false")
        UI.setAttribute("submit", "color", "red")
        UI.setAttribute("submit", "textColor", "white")
        UI.setAttribute("submit", "text", "Game not finished.")
        return
    end

    UI.setAttribute("reminder", "text", "Take a screenshot!")
    UI.setAttribute("submit", "interactable", "true")
    UI.setAttribute("submit", "color", "blue")
    UI.setAttribute("submit", "textColor", "white")
    UI.setAttribute("submit", "text", "Submit?")
end

function changeValue(player, value, element)
    UI.setAttribute(element, "text", value)
    Wait.frames(lookForProblems, 2)
end

function changeToggle(player, value, element)
    UI.setAttribute(element, "isOn", value)
    Wait.frames(lookForProblems, 2)
end

function disableSubmitButton()
    UI.setAttribute("submit", "interactable", "false")
    UI.setAttribute("submit", "color", "purple")
    UI.setAttribute("submit", "textColor", "yellow")
    UI.setAttribute("submit", "text", "SUCCESS!")
end

function formCallback(request)
    if request.is_error then
        broadcastToAll('There was an error!')
        broadcastToAll(request.text)
        gameWasSubmitted = false
    else
        broadcastToAll(
            'It looks like the game was submitted, but save your screenshot!')
        disableSubmitButton()
    end
end

function sendForm(submitter)
    if gameWasSubmitted then
        broadcastToAll('Results were already submitted.')
        disableSubmitButton()
        return
    end

    UI.setAttribute("submit", "interactable", "false")
    gameWasSubmitted = true

    local conflictCardZone = getObjectFromGUID('07e239')
    local conflictCards = conflictCardZone.getObjects()[1]
    local round = 10
    if conflictCards ~= nil then
        if conflictCards.tag == 'Deck' then
            local cards = conflictCards.getObjects()
            round = 10 - #cards
        elseif conflictCards.tag == 'Card' then
            round = 9
        end
    end

    local infoTable = {
        ["entry.2126893034"] = "0", -- is_ranked
        ["entry.447092407"] = tournament_token, -- game_id
        ["entry.40772176"] = "2", -- carryall_version. Increment this value by 1 each release.
        ["entry.1195859029"] = submitter.steam_id, -- submitter_steam_id
        ["entry.980559040"] = submitter.steam_name, -- submitter_steam_name
        ["entry.779373663"] = startTime, -- game_start_timestamp
        ["entry.234195300"] = round, -- n_rounds

        ["entry.82402215"] = results["Red"]["id"], -- p1_steam_id
        ["entry.1635429235"] = UI.getAttribute("name_red", "text"), -- p1_steam_name
        ["entry.419710564"] = UI.getAttribute("rank_red", "text"), -- p1_placement
        ["entry.1878523358"] = UI.getAttribute("points_red", "text"), -- p1_total_points
        ["entry.1073272736"] = "", -- p1_vps_list
        ["entry.178708796"] = UI.getAttribute("spice_red", "text"), -- p1_spice
        ["entry.312713987"] = UI.getAttribute("solari_red", "text"), -- p1_solari
        ["entry.377801515"] = UI.getAttribute("water_red", "text"), -- p1_water
        ["entry.1566289571"] = "", -- p1_chamurky
        ["entry.220375463"] = "", -- p1_startpos
        ["entry.565786681"] = UI.getAttribute("leader_red", "text"), -- p1_leader

        ["entry.926384740"] = results["Green"]["id"], -- p2_steam_id
        ["entry.8189124"] = UI.getAttribute("name_green", "text"), -- p2_steam_name
        ["entry.829300525"] = UI.getAttribute("rank_green", "text"), -- p2_placement
        ["entry.1498362639"] = UI.getAttribute("points_green", "text"), -- p2_total_points
        ["entry.1338086196"] = "", -- p2_vps_list
        ["entry.2112800604"] = UI.getAttribute("spice_green", "text"), -- p2_spice
        ["entry.97230832"] = UI.getAttribute("solari_green", "text"), -- p2_solari
        ["entry.1615516743"] = UI.getAttribute("water_green", "text"), -- p2_water
        ["entry.431493524"] = "", -- p2_chamurky
        ["entry.516704953"] = "", -- p2_startpos
        ["entry.126177821"] = UI.getAttribute("leader_green", "text"), -- p2_leader

        ["entry.1056344986"] = results["Yellow"]["id"], -- p3_steam_id
        ["entry.1000335964"] = UI.getAttribute("name_yellow", "text"), -- p3_steam_name
        ["entry.1815125303"] = UI.getAttribute("rank_yellow", "text"), -- p3_placement
        ["entry.1006025268"] = UI.getAttribute("points_yellow", "text"), -- p3_total_points
        ["entry.405019323"] = "", -- p3_vps_list
        ["entry.1485294161"] = UI.getAttribute("spice_yellow", "text"), -- p3_spice
        ["entry.1960273034"] = UI.getAttribute("solari_yellow", "text"), -- p3_solari
        ["entry.2103268491"] = UI.getAttribute("water_yellow", "text"), -- p3_water
        ["entry.1546563705"] = "", -- p3_chamurky
        ["entry.1730389595"] = "", -- p3_startpos
        ["entry.555758857"] = UI.getAttribute("leader_yellow", "text"), -- p3_leader

        ["entry.724137382"] = results["Blue"]["id"], -- p4_steam_id
        ["entry.79132597"] = UI.getAttribute("name_blue", "text"), -- p4_steam_name
        ["entry.1095237101"] = UI.getAttribute("rank_blue", "text"), -- p4_placement
        ["entry.1786102321"] = UI.getAttribute("points_blue", "text"), -- p4_total_points
        ["entry.654442789"] = "", -- p4_vps_list
        ["entry.1200193803"] = UI.getAttribute("spice_blue", "text"), -- p4_spice
        ["entry.848733094"] = UI.getAttribute("solari_blue", "text"), -- p4_solari
        ["entry.767203598"] = UI.getAttribute("water_blue", "text"), -- p4_water
        ["entry.2048085041"] = "", -- p4_chamurky
        ["entry.1751147952"] = "", -- p4_startpos
        ["entry.850152509"] = UI.getAttribute("leader_blue", "text"), -- p4_leader

        ["entry.879491944"] = "0", -- immortality
        ["entry.550642770"] = "1" -- tournament2022
    }

    -- post to google forms
    WebRequest.post(
        "https://docs.google.com/forms/u/0/d/e/1FAIpQLScGit6kyKI_5It9aZAM82KNCBQ4RC0dQWxNA4DDwgj3z05zKA/formResponse",
        infoTable, formCallback)
end

function allGood(player)
    if not player.seated then return false end

    local color = player.color
    if color == "Red" or color == "Green" or color == "Yellow" or color ==
        "Blue" then
        return true
    else
        return false
    end
end

function refreshResults()
    if gameWasSubmitted then disableSubmitButton() end

    techZone = constants.techZone

    if worm.vptray == nil then worm.init() end

    if results == nil then results = {} end
    for _, player in pairs(results) do
        local color = player["color"]
        local victoryPoints = worm.vptray[color].call("getScore")

        results[color]["chaumurky"] = 0
        for _, techObj in
            ipairs(techZone[color].getObjects()) do
            if techObj.getGUID() == "3c6492" then
                broadcastToAll(color .. " has Chaumurky", color)
                results[color]["chaumurky"] = 1
                break
            end
        end

        results[color]["rank"] = -1
        results[color]["points"] = victoryPoints
        local leaderObjs = resources[color][leader].getObjects()
        if leaderObjs == nil or #leaderObjs < 1 then
            results[color]["leader"] = "ERROR!"
        else
            results[color]["leader"] = leaderObjs[1].getName()
        end
        results[color]["spice"] = resources[color][spice].call("collectVal")
        results[color]["solari"] = resources[color][solari].call("collectVal")
        results[color]["water"] = resources[color][eau].call("collectVal")
    end

    -- tables can't be sorted so we copy the values into an array
    local sortedResults = {}
    for _, value in pairs(results) do table.insert(sortedResults, value) end

    local tied = false
    table.sort(sortedResults, function(left, right)
        if left["points"] ~= right["points"] then
            return left["points"] > right["points"]
        elseif left["chaumurky"] ~= right["chaumurky"] then
            return left["chaumurky"] > right["chaumurky"]
        elseif left["spice"] ~= right["spice"] then
            return left["spice"] > right["spice"]
        elseif left["solari"] ~= right["solari"] then
            return left["solari"] > right["solari"]
        elseif left["water"] ~= right["water"] then
            return left["water"] > right["water"]
        else
            tied = true
            return false
        end
    end)

    if tied then broadcastToAll("WARNING: Two or more players are tied.") end

    -- now we can extract the rankings
    for rank, value in pairs(sortedResults) do
        results[value["color"]]["rank"] = rank
    end

    UI.setAttribute("tournament_token", "text", tournament_token)

    UI.setAttribute("points_red", "text", results["Red"]["points"])
    UI.setAttribute("name_red", "text", results["Red"]["name"])
    UI.setAttribute("id_red", "text", results["Red"]["id"])
    UI.setAttribute("rank_red", "text", results["Red"]["rank"])
    UI.setAttribute("leader_red", "text", results["Red"]["leader"])
    UI.setAttribute("spice_red", "text", results["Red"]["spice"])
    UI.setAttribute("solari_red", "text", results["Red"]["solari"])
    UI.setAttribute("water_red", "text", results["Red"]["water"])

    UI.setAttribute("points_green", "text", results["Green"]["points"])
    UI.setAttribute("name_green", "text", results["Green"]["name"])
    UI.setAttribute("id_green", "text", results["Green"]["id"])
    UI.setAttribute("rank_green", "text", results["Green"]["rank"])
    UI.setAttribute("leader_green", "text", results["Green"]["leader"])
    UI.setAttribute("spice_green", "text", results["Green"]["spice"])
    UI.setAttribute("solari_green", "text", results["Green"]["solari"])
    UI.setAttribute("water_green", "text", results["Green"]["water"])

    UI.setAttribute("points_yellow", "text", results["Yellow"]["points"])
    UI.setAttribute("name_yellow", "text", results["Yellow"]["name"])
    UI.setAttribute("id_yellow", "text", results["Yellow"]["id"])
    UI.setAttribute("rank_yellow", "text", results["Yellow"]["rank"])
    UI.setAttribute("leader_yellow", "text", results["Yellow"]["leader"])
    UI.setAttribute("spice_yellow", "text", results["Yellow"]["spice"])
    UI.setAttribute("solari_yellow", "text", results["Yellow"]["solari"])
    UI.setAttribute("water_yellow", "text", results["Yellow"]["water"])

    UI.setAttribute("points_blue", "text", results["Blue"]["points"])
    UI.setAttribute("name_blue", "text", results["Blue"]["name"])
    UI.setAttribute("leader_blue", "text", results["Blue"]["leader"])
    UI.setAttribute("id_blue", "text", results["Blue"]["id"])
    UI.setAttribute("rank_blue", "text", results["Blue"]["rank"])
    UI.setAttribute("spice_blue", "text", results["Blue"]["spice"])
    UI.setAttribute("solari_blue", "text", results["Blue"]["solari"])
    UI.setAttribute("water_blue", "text", results["Blue"]["water"])
    Wait.frames(lookForProblems, 2)
end

function worm.setOpenScoreBoard()

    local thirdPanel =
        [[<Panel id="thirdPanel" visibility="Black" class="Window" allowDragging="True"
    returnToOriginalPositionWhenReleased="false" width="80" height="80" rectAlignment="UpperRight" offsetXY="-50,-150">
    <Button id="continue" color="blue" text="Open Score Board" onClick="]] ..
            self.guid .. [[/firstScoreBoardRender"/>
    </Panel>
    ]]

    local existingXml = UI.getXml()

    UI.setXml(existingXml .. thirdPanel)

end

scoreBoardUp = false

function firstScoreBoardRender()
    local composedXml = ''

    if worm.streamer_mode == false then return end
    if worm.vptray == nil then worm.init() end

    local seatedPlayerCount = 0
    for _, thisPlayer in ipairs(Player.getPlayers()) do
        if allGood(thisPlayer) then seatedPlayerCount = seatedPlayerCount + 1 end
    end

    if seatedPlayerCount < 3 then  broadcastToColor('Not enough seated players. Try again with at least 3 players.', 'Black', 'Black') return end

    local panelHeight = 103 * seatedPlayerCount

    composedXml = [[
        <Panel visibility="Black" rectAlignment="UpperRight" class="Window"
        color="black" width="200" height="]] .. panelHeight .. [["
        allowDragging="True" returnToOriginalPositionWhenReleased="false">
        <TableLayout cellSpacing="4" autoCalculateHeight="true" columnWidths="100 100">
        ]]

    local leaderName = ''
    local thisColor = ''
    local leaderObjs = nil
    local points = nil
    local playerCount = 0
    for _, thisPlayer in ipairs(Player.getPlayers()) do
        thisColor = thisPlayer.color
        if worm.vptray[thisColor] == nil then goto continue end

        points = worm.vptray[thisColor].call("getScore")
        if points == nil then points = 0 end
        worm.points[thisColor] = points

        leaderObjs = resources[thisColor][leader].getObjects()
        if leaderObjs == nil or #leaderObjs == 0 then goto continue end
        leaderName = leaderObjs[1].getName()

        composedXml = composedXml .. '<Row preferredHeight="100">'

        if worm.pics[leaderName] then
            pic = worm.pics[leaderName]
        else
            broadcastToAll('missing pic for ' .. leaderName, undefined)
            pic =
                "https://steamusercontent-a.akamaihd.net/ugc/2488878371133861785/862A2819BDA92202E094E955AE465E9B0EBCAD4C/"
        end

        composedXml = composedXml .. [[
                          <Cell width="50"><Panel padding="10" color="]] ..
                          thisColor .. [[">
                           <Image image="]] .. pic .. [["/>
                           </Panel>
                           </Cell>
                           <Cell>
                           <Panel color="white">
                           <Text id="]] .. thisColor ..
                          [[points" fontSize="38" fontStyle="Bold" alignment="MiddleCenter" color="black">]] ..
                          worm.points[thisColor] .. [[</Text></Panel></Cell>
                           </Row> ]]
        playerCount = playerCount + 1
        ::continue::
    end
    composedXml = composedXml .. '</TableLayout></Panel>'
    if playerCount == seatedPlayerCount then
        local existingXml = UI.getXml()
        UI.setXml(existingXml .. composedXml)
        scoreBoardUp = true
        UI.hide("thirdPanel")
    else

        broadcastToColor('Not all seated players selected a leader. Try again after they did.', 'Black', 'Black')

    end



end

function worm.updateScores()

    if scoreBoardUp then

        for _, thisPlayer in ipairs(Player.getPlayers()) do

            thisColor = thisPlayer.color
            if worm.vptray[thisColor] ~= nil then

                points = worm.vptray[thisColor].call("getScore")
                if points == nil then points = 0 end
                worm.points[thisColor] = points

                UI.setValue(thisColor.."points", worm.points[thisColor])

            end

        end

    end

end

return worm
