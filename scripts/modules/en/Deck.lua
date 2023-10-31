local Helper = require("utils.Helper")

local Deck = {
    imperium = {
        -- starter with dune the desert planet
        starter = { "http://cloud-3.steamusercontent.com/ugc/2093667512238504518/BF3BA9C253ED953533B90D94DD56D0BAD4021B3C/", 4, 2 },
        -- base with foldspace, liasion, and the spice must flow
        imperium = { "http://cloud-3.steamusercontent.com/ugc/2093667512238501976/6F98BCE051343A3D07D58D6BC62A8FCA2C9AAE1A/", 8, 6 },
        -- new release card
        newImperium = { "http://cloud-3.steamusercontent.com/ugc/2027231506426140597/EED43686A0319F3C194702074F2D2B3E893642F7/", 1 , 1 },
        -- ix with control the spice
        ixImperium = { "http://cloud-3.steamusercontent.com/ugc/2093667512238502753/9DFCC56F20D09D60CF2B9D9050CB9640176F71B6/", 7, 5 },
        -- tleilax with experimentation
        immortalityImperium = { "http://cloud-3.steamusercontent.com/ugc/2093667512238503099/E758512421B5CB27BBA228EF5F1880A7F3DC564D/", 6, 5 },
        -- tleilax with reclaimed forces
        tleilaxResearch = { "http://cloud-3.steamusercontent.com/ugc/2093667512238505265/D9BD273651404E7DE7F0E22B36F2D426D82B07A8/", 4, 5 },
    },
    intrigue = {
        intrigue = { "http://cloud-3.steamusercontent.com/ugc/2093667512238521425/A63AE0E1069DA1279FDA3A5DE6A0E073F45FC8EF/", 7, 5 },
        ixIntrigue = { "http://cloud-3.steamusercontent.com/ugc/2093667512238520522/CE27F1B6D4D455A2D00D6E13FABEB72E6B9F05F1/", 5, 4 },
        immortalityIntrigue = { "http://cloud-3.steamusercontent.com/ugc/2093667512238520324/9FED90CD510F26618717CEB63FDA744CE916C6BA/", 6, 2 },
    },
    conflict1 = {
        conflict = { "http://cloud-3.steamusercontent.com/ugc/2093667512238536892/F1C0913A589ADB0A0532DFB8FAA7E9D7942CF6CB/", 3, 2 },
    },
    conflict2 = {
        conflict = { "http://cloud-3.steamusercontent.com/ugc/2093667512238537279/B1CD3F41933A9DD44522934B5F6CF3C5FF77A51C/", 6, 2 },
    },
    conflict3 = {
        conflict = { "http://cloud-3.steamusercontent.com/ugc/2093667512238537756/F1BEAE6266E75B7A2F5DE511DB4FEB25A2CD486B/", 3, 2 },
    },
    hagal = {
        hagal = { "http://cloud-3.steamusercontent.com/ugc/2093668799785647713/66020C11E4FEA2D22744020D27465DCC2BB02BBE/", 7, 2 },
        hagal_wealth = { "http://cloud-3.steamusercontent.com/ugc/2093668799785647456/46014D79D2E1D2F68F4BF5740A0A9E1FED6E540D/", 1, 1 },
        hagal_arrakeen2p = { "http://cloud-3.steamusercontent.com/ugc/2093668799785647086/8C2F363EFD82AB1A80A01A3E527E6A4ACE369643/", 1, 1 },
        ixHagal_dreadnought1p = { "http://cloud-3.steamusercontent.com/ugc/2093668799785646315/5E6323692811F0530FB83FAE286162BDF6010E47/", 1, 1, Vector(0.88, 1, 0.83) },
        ixHagal_dreadnought2p = { "http://cloud-3.steamusercontent.com/ugc/2093668799785646835/1A8E52049F9853C42DA1D0A2E26AF50F7B503773/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_techNegogiation1p = { "http://cloud-3.steamusercontent.com/ugc/2093668799785646585/5A6FB1D7F4148F22FEF453500A6627132379BD6B/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_interstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/2093668799785646691/E595B3E111F6E8A0C057C99FF03BB18FFA1327B7/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_foldspaceAndInterstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/2093668799785647605/D7FAA1F3EB842A0EB4A2966F134EB58ACD966AFC/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_smugglingAndInterstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/2093668799785646429/978923957A87E0CB3DFAA25DF543FD863DA1EC95/", 1, 1, Vector(0.9, 1, 0.83) },
        imortalityHagal = { "http://cloud-3.steamusercontent.com/ugc/2120691978813601622/36ABA3AD7A540FF6960527C1E77565F10BB2C6CB/", 2, 2 },
        hagal_churn = { "http://cloud-3.steamusercontent.com/ugc/2093668799785647209/43CA7B78F12F01CED26D1B57D3E62CAC912D846C/", 1, 1 },
    },
    tech = {
        windtraps = { "http://cloud-3.steamusercontent.com/ugc/2093667512238534366/1357A12AE8B805DDA4B35054C7A042EB60ED8D93/", 1, 1 },
        flagship = { "http://cloud-3.steamusercontent.com/ugc/2093667512238535739/3D450BD068CF618EB58032CA790EC8CFB512C6ED/", 1, 1 },
        sonicSnoopers = { "http://cloud-3.steamusercontent.com/ugc/2093667512238535891/735DAD89216E331EE1461EEBC94E579B3F65D898/", 1, 1 },
        artillery = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533913/1DD4BAFBF228984A2AE7D7A04C6BD98E5817CB75/", 1, 1 },
        troopTransports = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533788/5F8994647E6BE9B8DFE12775816BA8634DBEF803/", 1, 1 },
        spySatellites = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531420/A4A7827D2C9E2D084FEF39864C901F858DBAC7A0/", 1, 1 },
        invasionShips = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533294/CA3C07205ECEFC22C759E350C47B58052D1CB3EC/", 1, 1 },
        chaumurky = { "http://cloud-3.steamusercontent.com/ugc/2093667512238532706/CC1342B27E230372F8A10A0BD35ADF796F0FF6A5/", 1, 1 },
        detonationDevices = { "http://cloud-3.steamusercontent.com/ugc/2093667512238534249/985702313B721E7343ED01C603AF5C8EFF43C2F4/", 1, 1 },
        spaceport = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531674/A906AB650BF19DEA2E39F86F873940143C2CF814/", 1, 1 },
        minimicFilm = { "http://cloud-3.steamusercontent.com/ugc/2093667512238534489/74A896440084439B2C557D8651EB8125A64E85B1/", 1, 1 },
        holoprojectors = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533168/89575580CD49633CE5473B76CDDFA1A0A2503030/", 1, 1 },
        memocorders = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531030/2644950194120A67CDC6BF7019D951FCF605DBFF/", 1, 1 },
        disposalFacility = { "http://cloud-3.steamusercontent.com/ugc/2093667512238532882/57A51864E207970E7DCB9ACCAE68AFAE48F2CD61/", 1, 1 },
        holtzmanEngine = { "http://cloud-3.steamusercontent.com/ugc/2093667512238536567/B202AC36308C95EF1CA325DAE9318DCB6C5229EE/", 1, 1 },
        trainingDrones = { "http://cloud-3.steamusercontent.com/ugc/2093667512238536116/B877582FA7ECB542E046FB96EB8488D511DEDF1C/", 1, 1 },
        shuttleFleet = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533645/9E39289A6CED8A977E8206E1B5FD1A14F4BA55F8/", 1, 1 },
        restrictedOrdnance = { "http://cloud-3.steamusercontent.com/ugc/2093667512238534629/1F4181A709E103B8807D6D6FBF3C6BA62A4C20F9/", 1, 1 },
    },
    leader = {
        vladimirHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093667512238499582/B5899377296C2BFAC0CF48E18AA3773AA8E998DE/", 1, 1 },
        glossuRabban = { "http://cloud-3.steamusercontent.com/ugc/2093667512238498058/DCF40F0D8C34B14180DC33B369DCC8AA4FD3FB55/", 1, 1 },
        ilbanRichese = { "http://cloud-3.steamusercontent.com/ugc/2120691978822940718/15624E52D08F594943A4A6332CBD68B2A1645441/", 1, 1 },
        helenaRichese = { "http://cloud-3.steamusercontent.com/ugc/2120691978822940558/63750F22F1DFBA9D9544587C0B2B8D65E157EC00/", 1, 1 },
        letoAtreides = { "http://cloud-3.steamusercontent.com/ugc/2093667512238500319/8CBD932BE474529D6C14A3AA8C01BD8503EBEBC6/", 1, 1 },
        paulAtreides = { "http://cloud-3.steamusercontent.com/ugc/2120691978822941103/F597DBF1EB750EA14EA03F231D0EBCF07212A5AC/", 1, 1 },
        arianaThorvald = { "http://cloud-3.steamusercontent.com/ugc/2093667512238500886/2A9043877494A7174A32770C39147FAE941A39A2/", 1, 1 },
        memnonThorvald = { "http://cloud-3.steamusercontent.com/ugc/2120691978822940968/8431F61C545067A4EADC017E6295CB249A2BD813/", 1, 1 },
        armandEcaz = { "http://cloud-3.steamusercontent.com/ugc/2093667512238498308/310C6B6E85920F9FC1A94896A335D34C3CFA6C15/", 1, 1 },
        ilesaEcaz = { "http://cloud-3.steamusercontent.com/ugc/2120691978822941275/94B1575474BEEF1F1E0FE0860051932398F47CA5/", 1, 1 },
        rhomburVernius = { "http://cloud-3.steamusercontent.com/ugc/2093667512238501024/0C06A30D74BD774D9B4F968C00AEC8C0817D4C77/", 1, 1 },
        tessiaVernius = { "http://cloud-3.steamusercontent.com/ugc/2120691978822940841/29817122A32B50C285EE07E0DAC32FDE9A237CEC/", 1, 1 },
        yunaMoritani = { "http://cloud-3.steamusercontent.com/ugc/2093667512238499982/FA54B129B168169E3D58BA61536FCC0BB5AB7D34/", 1, 1 },
        hundroMoritani = { "http://cloud-3.steamusercontent.com/ugc/2093667512238498857/6A89778D9C4BB8AC07FE503D48A4483D13DF6E5B/", 1, 1 },
    },
    fanmadeLeader = {
        retienne = {
            helenaRichese = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946676/4B4D817E4373B58A09CEFBC0C643016FB603BEC0/", 1, 1 },
            farok = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948529/7499936C5425C8978AF8A162E6B862DCEB154192/", 1, 1 },
            ilbanRichese = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947282/EB1466B5CA83E65BF1482F8691C96509C5A8948D/", 1, 1 },
            jopatiKolona = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945556/11159B04990BC87DAA658F5730810361D41F7BC2/", 1, 1 },
            letoAtreidesII = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949434/5F6E2994A70189D660F8FCB4B9407A88CC822EE6/", 1, 1 },
            xavierHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945956/2AA47113DAA90E0B957860C2D3DB38D2875A61F5/", 1, 1 },
            countFenring = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946796/72EBA82ABAADAA4B608569DBF0620FB02A12F061/", 1, 1 },
            drisq = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948646/5F943B1B50312CCB827BB210B9A4A00BC4102613/", 1, 1 },
            executrix = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945195/50ECB2CA57F7A30932FBFF4FE807BC4C87AFA5F5/", 1, 1 },
            mirlat = { "http://cloud-3.steamusercontent.com/ugc/2120691978822952557/92F6E7868CABE5AF4A3817513339DFFDB910B4FA/", 1, 1 },
            dukeMutelli = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948973/579A12C5C405340BF2245A5C9406A3A5A9B1B160/", 1, 1 },
            isyanderTheTraitorShaiad = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946526/9E3C346DD39F50CB53AA4F1A4580E60A57813D93/", 1, 1 },
            swormasterDinari = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946189/34A4B76895F079E24CF05B121DE774B2F7CCA1E8/", 1, 1 },
            koalTraytron = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950039/A6479EE2A5112361AC3E4E8AC40B58DB40301C92/", 1, 1 },
            aliaAtreides = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951312/455E8029819E17DC09284F4744340C86377A6AF6/", 1, 1 },
            princessYunaMoritani = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947811/2073D25F36695681143C9F896ED0BC89FE936BB7/", 1, 1 },
            masterBijaz = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949926/9DED2B6E9899786DE2283C6CA39EA2FD03CC62A3/", 1, 1 },
            tessiaVernius = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951910/97629F50C5BD6819758BEE23413B8C7A65B71DB0/", 1, 1 },
            shaddamIV = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950662/DE985348A1992CD27BB8052600E9C2AEA53A01D0/", 1, 1 },
            captainOtto = { "http://cloud-3.steamusercontent.com/ugc/2120691978822953029/395F45D8BF7EE6E5CDE73F50FB326E4CB2CE8493/", 1, 1 },
            princessWensicia = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947568/58722B7E94519B1DAE28FF39FBDC3E7E145655B1/", 1, 1 },
            generalKlevLagarin = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949305/6AE1F8C93AE8B56D1DAB4968FBB5703C1483DE3E/", 1, 1 },
            masterWaff = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945075/F3B8810D0440B2DCE9B626FD795D0335581427CD/", 1, 1 },
            scytale = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949086/3936E89272B8441C6DE10657046402B5519A0AED/", 1, 1 },
            drLietKynes = { "http://cloud-3.steamusercontent.com/ugc/2120691978822944842/D72A10E5EF3A21D164D8106821617CBBB5F79F4D/", 1, 1 },
            princessIrulan = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950333/1FDD8E596008264190366C577A0D32FCE56C133E/", 1, 1 },
            bannerjee = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949543/49573DEE8FB814EA25120CDA8F791953B54C1B22/", 1, 1 },
            serenaButler = { "http://cloud-3.steamusercontent.com/ugc/2120691978822953341/79A90C795D9C16E9B0D9431728732606EF7F59DB/", 1, 1 },
            shaddamV = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948210/B97E370680476076388F1D46C060F35E1B551B0C/", 1, 1 },
            edric = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950552/0725C99FD0C96DE781D8E3E77AB03E4F49815B85/", 1, 1 },
            shimoon = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948309/E3C4EE1E9EF9EE0EF66E9F7EC3CCD48B0810FA8C/", 1, 1 },
            anirulCorrino = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945830/2B7510F754BD15E9781ED7592ABDF0F141B27674/", 1, 1 },
            omniusPrime = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945438/EB15C3B3BA711B20843DEB3E0880C93E4E16A8F3/", 1, 1 },
            uliet = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947027/3E2BF562926526FD0CBA76E405F56934BD6ABC5C/", 1, 1 },
            pretresseIsyaraStShaiad = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951725/B7E25A79517CCC48E004403837E3CE37C163B3EC/", 1, 1 },
            princeRhomburVernius = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946910/9ADF15588DEAB765A4B6789F089AA7F82A09358C/", 1, 1 },
            memnonThorvald = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950947/4B5986649B3181714AF5D710032CAB02F17C3503/", 1, 1 },
            senatorOthn = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948107/242E670E2E38977B3C0990E79E03B2D0C3EAAD0B/", 1, 1 },
            viscountHundroMoritani = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951093/672A168420F48F51040BE0E8289AC409C7A3EBB6/", 1, 1 },
            vorianAtreides = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949200/40B2657453B0C9AAB7B9A64F8D5C22F932C1F448/", 1, 1 },
            whitmoreBludd = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945308/30645C1902F9DB9D8F034495677C78CB44432E90/", 1, 1 },
            torgTheYoung = { "http://cloud-3.steamusercontent.com/ugc/2120691978822944542/2AAD492B617B38C84C383D2B93EFB42E102CD8E1/", 1, 1 },
            normaCenva = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949797/134FEBD55A10E50D39EA39F4F3C62A6FAF35A876/", 1, 1 },
            senateurMaximilienZelevas = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946307/9E707A019BDEB3C8DA5A386E800D6D37E1BA4764/", 1, 1 },
            stabanTuek = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951207/C2A741AA10DFF9610E0621D5C4DF714CD7CF1885/", 1, 1 },
            dukeLetoAtreides = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947400/B95E8D80B2F3B266817D213CDE93EA3D264A7A5A/", 1, 1 },
            hwiNoree = { "http://cloud-3.steamusercontent.com/ugc/2120691978822945710/D454532FE6E023CF36F0FF7CE4C000340B8D139A/", 1, 1 },
            darwiOdrade = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948866/CB039E93DFA1F6F4A4D5323B99CEFCE6857FE5E1/", 1, 1 },
            ramalloTheSayyadina = { "http://cloud-3.steamusercontent.com/ugc/2120691978822952673/C1D2B049F807591F8619DF259983B3B8699949A0/", 1, 1 },
            glossuTheBeastRabban = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947931/E142005DFCFB258755B2CE6CB9045C6BC731CAB9/", 1, 1 },
            tioHoltzman = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951420/623C75E18F77D34CCC6C30EC379536FC4A11CB19/", 1, 1 },
            baronVladimirHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2120691978822952391/225518FCCE472B12F066D9DF9BC17A308C9AD0E3/", 1, 1 },
            abulurdRabban = { "http://cloud-3.steamusercontent.com/ugc/2120691978822949693/F448B0B5C2F7414D5E04470755FEEF72772714C7/", 1, 1 },
            paulAtreides = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948412/30649E10B9CB63263A7B253FCB30B9EE6E8569A6/", 1, 1 },
            torgTheYounger = { "http://cloud-3.steamusercontent.com/ugc/2120691978822946423/ED5DB6E06B9A87C9851571AFB10181AE7EACFB0E/", 1, 1 },
            chatt = { "http://cloud-3.steamusercontent.com/ugc/2120691978822948758/1D497DEE7E8ECDA065A53C408D9BD6E4295924A3/", 1, 1 },
            abulurdHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2120691978822952276/E2D5D7464843A6DB73158BBA94E6E56E12BB3CFA/", 1, 1 },
            milesTeg = { "http://cloud-3.steamusercontent.com/ugc/2120691978822951563/885BD554B6F01EFE62BE37D3762E4773CEFEB2E5/", 1, 1 },
            capitainYelchinOrdara = { "http://cloud-3.steamusercontent.com/ugc/2120691978822953510/91A4BFAF3363D6BFBEC9E61F6DC98BD3B3B2D10B/", 1, 1 },
            ilesaEcaz = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950444/C72CA57BFF3EEC8B3935B5CEDC1B0386B0385440/", 1, 1 },
            esmarTuek = { "http://cloud-3.steamusercontent.com/ugc/2120691978822950809/B633B6BA2B359E0461AA52099BB665BECC759C64/", 1, 1 },
            countessArianaThorvald = { "http://cloud-3.steamusercontent.com/ugc/2120691978822952147/8FEB00CB2AA244E0D45B9C22E67A3B06BC748FED/", 1, 1 },
            albertoGinaztera = { "http://cloud-3.steamusercontent.com/ugc/2120691978822944390/371E4C1DE7512B54A26F51AF5E772D608C968C23/", 1, 1 },
            feydRautha = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947132/38A1E69BDECACE6F4D6A876379DE7619F14C078A/", 1, 1 },
            ladyMargotFenring = { "http://cloud-3.steamusercontent.com/ugc/2120691978822952038/6A2DE44A477D5E86E2BF850DFB7339A30676253D/", 1, 1 },
            archdukeArmandEcaz = { "http://cloud-3.steamusercontent.com/ugc/2120691978822953173/BCC708B0333A967362DDFEDBF4A2C80E105CDB13/", 1, 1 },
            tylwythWaff = { "http://cloud-3.steamusercontent.com/ugc/2120691978822947690/9C33E4AEC5DB715AD825CC338A21DAB2D2AF7148/", 1, 1 },
        }
    }
}

---
function Deck.load(loader, cards, category, customDeckName, startLuaIndex, cardNames)
    local desc = Deck[category][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local functionName = Helper.toCamelCase("create", category, "CustomDeck")
    assert(loader[functionName], "No loader for: " .. functionName )
    local customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

---
function Deck.loadWithSubCategory(loader, cards, category, subCategory, customDeckName, startLuaIndex, cardNames)
    local desc = Deck[category][subCategory][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local functionName = Helper.toCamelCase("create", category, "CustomDeck")
    assert(loader[functionName], "No loader for: " .. functionName )
    local customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

---
function Deck.loadCustomDecks(loader)
    local cards = {
        imperium = {},
        special = {},
        tleilaxu = {},
        intrigue = {},
        conflict = {},
        hagal = {},
        tech = {},
        leaders = {}
    }

    Deck.load(loader, cards.imperium, "imperium", "starter", 1, {
        "duneTheDesertPlanet",
        "dagger",
        "reconnaissance",
        "convincingArgument",
        "seekAllies",
        "signetRing",
        "diplomacy"
    })
    Deck.load(loader, cards.imperium, "imperium", "imperium", 1, {
        "sardaukarLegion",
        "drYueh",
        "assassinationMission",
        "sardaukarInfantry",
        "", -- foldspace
        "", -- arrakisLiaison
        "", -- theSpiceMustFlow
        "beneGesseritInitiate",
        "guildAdministrator",
        "theVoice",
        "scout",
        "imperialSpy",
        "beneGesseritSister",
        "missionariaProtectiva",
        "spiceHunter",
        "spiceSmugglers",
        "feydakinDeathCommando",
        "geneManipulation",
        "guildBankers",
        "choamDirectorship",
        "crysknife",
        "chani",
        "spaceTravel",
        "duncanIdaho",
        "shiftingAllegiances",
        "kwisatzHaderach",
        "sietchReverendMother",
        "arrakisRecruiter",
        "firmGrip",
        "smugglersThopter",
        "carryall",
        "gunThopter",
        "guildAmbassador",
        "testOfHumanity",
        "fremenCamp",
        "opulence",
        "ladyJessica",
        "stilgar",
        "piterDeVries",
        "gurneyHalleck",
        "thufirHawat",
        "otherMemory",
        "lietKynes",
        "wormRiders",
        "reverendMotherMohiam",
        "powerPlay"
    })
    Deck.load(loader, cards.imperium, "imperium", "newImperium", 1, {
        "thumper"
    })
    Deck.load(loader, cards.imperium, "imperium", "ixImperium", 1, {
        "boundlessAmbition",
        "guildChiefAdministrator",
        "guildAccord",
        "localFence",
        "shaiHulud",
        "ixGuildCompact",
        "choamDelegate",
        "bountyHunter",
        "embeddedAgent",
        "esmarTuek",
        "courtIntrigue",
        "sayyadina",
        "imperialShockTrooper",
        "appropriate",
        "desertAmbush",
        "inTheShadows",
        "satelliteBan",
        "freighterFleet",
        "imperialBashar",
        "jamis",
        "landingRights",
        "waterPeddlersUnion",
        "treachery",
        "truthsayer",
        "spiceTrader",
        "ixianEngineer",
        "webOfPower",
        "weirdingWay",
        "negotiatedWithdrawal",
        "fullScaleAssault",
        "jessicaOfArrakis",
        "missionariaProtectiva",
        "controlTheSpice",
        "duncanLoyalBlade"
    })
    Deck.load(loader, cards.imperium, "imperium", "immortalityImperium", 1, {
        "beneTleilaxLab",
        "beneTleilaxResearcher",
        "blankSlate",
        "clandestineMeeting",
        "corruptSmuggler",
        "dissectingKit",
        "experimentation",
        "forHumanity",
        "highPriorityTravel",
        "imperiumCeremony",
        "interstellarConspiracy",
        "keysToPower",
        "lisanAlGaib",
        "longReach",
        "occupation",
        "organMerchants",
        "plannedCoupling",
        "replacementEyes",
        "sardaukarQuartermaster",
        "shadoutMapes",
        "showOfStrength",
        "spiritualFervor",
        "stillsuitManufacturer",
        "throneRoomPolitics",
        "tleilaxuMaster",
        "tleilaxuSurgeon"
    })
    Deck.load(loader, cards.special, "imperium", "imperium", 5, {
        "foldspace",
        "arrakisLiaison",
        "theSpiceMustFlow",
    })
    Deck.load(loader, cards.special, "imperium", "tleilaxResearch", 11, {
        "reclaimedForces",
    })
    Deck.load(loader, cards.tleilaxu, "imperium", "tleilaxResearch", 1, {
        "beguilingPheromones",
        "chairdog",
        "contaminator",
        "corrinoGenes",
        "faceDancer",
        "faceDancerInitiate",
        "fromTheTanks",
        "ghola",
        "guildImpersonator",
        "industrialEspionage",
        "", -- Reclaimed Forces
        "scientificBreakthrough",
        "sligFarmer",
        "stitchedHorror",
        "subjectX137",
        "tleilaxuInfiltrator",
        "twistedMentat",
        "unnaturalReflexes",
        "usurp",
        "piterGeniusAdvisor"
    })

    Deck.load(loader, cards.intrigue, "intrigue", "intrigue", 1, {
        "bribery",
        "refocus",
        "ambush",
        "alliedArmada",
        "favoredSubject",
        "demandRespect",
        "poisonSnooper",
        "guildAuthorization",
        "dispatchAnEnvoy",
        "infiltrate",
        "knowTheirWays",
        "masterTactician",
        "plansWithinPlans",
        "privateArmy",
        "doubleCross",
        "councilorsDispensation",
        "cornerTheMarket",
        "charisma",
        "calculatedHire",
        "choamShares",
        "bypassProtocol",
        "recruitmentMission",
        "reinforcements",
        "binduSuspension",
        "secretOfTheSisterhood",
        "rapidMobilization",
        "stagedIncident",
        "theSleeperMustAwaken",
        "tiebreaker",
        "toTheVictor",
        "waterPeedlersUnion",
        "windfall",
        "waterOfLife",
        "urgentMission"
    })
    Deck.load(loader, cards.intrigue, "intrigue", "ixIntrigue", 1, {
        "diversion",
        "warChest",
        "advancedWeaponry",
        "secretForces",
        "grandConspiracy",
        "cull",
        "strategicPush",
        "blackmail",
        "machineCulture",
        "cannonTurrets",
        "expedite",
        "ixianProbe",
        "secondWave",
        "glimpseThePath",
        "finesse",
        "strongarm",
        "quidProQuo"
    })
    Deck.load(loader, cards.intrigue, "intrigue", "immortalityIntrigue", 1, {
        "breakthrough",
        "counterattack",
        "disguisedBureaucrat",
        "economicPositioning",
        "gruesomeSacrifice",
        "harvestCells",
        "illicitDealings",
        "shadowyBargain",
        "studyMelange",
        "tleilaxuPuppet",
        "viciousTalents"
    })

    Deck.load(loader, cards.conflict, "conflict1", "conflict", 1, {
        "skirmishA",
        "skirmishB",
        "skirmishC",
        "skirmishD",
        "skirmishE",
        "skirmishF"
    })
    Deck.load(loader, cards.conflict, "conflict2", "conflict", 1, {
        "desertPower",
        "raidStockpiles",
        "cloakAndDagger",
        "machinations",
        "sortThroughTheChaos",
        "terriblePurpose",
        "guildBankRaid",
        "siegeOfArrakeen",
        "siegeOfCarthag",
        "secureImperialBasin",
        "tradeMonopoly"
    })
    Deck.load(loader, cards.conflict, "conflict3", "conflict", 1, {
        "battleForImperialBasin",
        "grandVision",
        "battleForCarthag",
        "battleForArrakeen",
        "economicSupremacy"
    })

    Deck.load(loader, cards.hagal, "hagal", "hagal", 1, {
        "harvestSpice",
        "hardyWarriors",
        "stillsuits",
        "rallyTroops",
        "foldspace",
        "conspire",
        "selectiveBreeding",
        "secrets",
        "heighliner",
        "reshuffle",
        "arrakeen1p",
        "carthag",
        "hallOfOratory",
        "back"
    })
    Deck.load(loader, cards.hagal, "hagal", "hagal_wealth", 1, {
        "wealth"
    })
    Deck.load(loader, cards.hagal, "hagal", "hagal_arrakeen2p", 1, {
        "arrakeen2p"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_dreadnought1p", 1, {
        "dreadnought1p"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_dreadnought2p", 1, {
        "dreadnought2p"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_techNegogiation1p", 1, {
        "techNegotiation"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_interstellarShipping", 1, {
        "interstellarShipping"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_foldspaceAndInterstellarShipping", 1, {
        "foldspaceAndInterstellarShipping"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_smugglingAndInterstellarShipping", 1, {
        "smugglingAndInterstellarShipping"
    })
    Deck.load(loader, cards.hagal, "hagal", "imortalityHagal", 1, {
        "researchStation",
        "carthag1",
        "carthag2",
        "carthag3"
    })
    Deck.load(loader, cards.hagal, "hagal", "hagal_churn", 1, {
        "churn"
    })

    -- One tech per custom deck.
    for techName, _ in pairs(Deck.tech) do
        Deck.load(loader, cards.tech, "tech", techName, 1, { techName })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.leader) do
        Deck.load(loader, cards.leaders, "leader", leaderName, 1, { leaderName })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.fanmadeLeader.retienne) do
        Deck.loadWithSubCategory(loader, cards.leaders, "fanmadeLeader", "retienne", leaderName, 1, { leaderName })
    end

    return cards
end

return Deck
