local Helper = require("utils.Helper")

local Deck = {
    objective = {
        uprisingObjective = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133399065/31449D20F329E25D1674B822346A5A8EEE052D71/", 3, 2 },
    },
    imperium = {
        -- starter without dune planet
        starter = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141323392/D25AA65312D89EB7CEED36D451618E731A674BED/", 4, 2 },
        starterImperium_emperor = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141287197/6C2EBDBB0DA2CBC4EBE3C91970F4A6C66C4225FD/", 5, 2 },
        starterImperium_muadDib = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141287800/56225166A2ED9BD37EF06E0F83EEC329A35DB1CD/", 5, 2 },
        -- dune planet
        starterDunePlanet = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141327771/98F5861E28F3167495D3F2890879072BF3A84E60/", 2, 2 },
        -- base without foldspace, nor liasion, nor the spice must flow, but with Jessica of Arrakis and Duncan Loyal Blade
        imperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141321326/CC2D301CA075930201B3883D82F4C6E1A0837273/", 10, 7 },
        imperiumFoldedSpace = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141324507/AE481C2ED19B085E2669F22420FD282982FD11A9/", 3, 2 },
        -- ix without control the spice, but with Boundless Ambition
        ixImperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141329061/C54BCAB79869547E728509123AC47EDB32E79BF5/", 6, 6 },
        ixImperiumControlTheSpice = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141323266/DD5ED3E5FD12F0A1C4F42750E766E83564248E07/", 1, 1 },
        -- tleilax without experimentation
        immortalityImperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141325387/142F50245296C2EE1F5ABAD8CE93982AC0592110/", 6, 5 },
        immortalityImperiumExperimentation = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141324061/BF6DF4E8EF5B8C8F5BB6952166C559694A61BA04/", 2, 2 },
        -- tleilax without reclaimed forces
        tleilaxResearch = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141328012/2399494577B270989873BC3A2002B8D99E33E001/", 4, 5 },
        -- reclaimed forces
        tleilaxResearchReclaimedForces = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141323085/60812AEA733FF5558BA9190E47CBD474EBF38C94/", 1, 1 },
        uprisingImperium = { "https://steamusercontent-a.akamaihd.net/ugc/2499024154440743964/4AFB30174B6A6A4A46E5CE946B8731403F267041/", 10, 7 },
        uprisingImperium_contract = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141289668/F29889245831593A62B3E914EAD5DBC4904BCEE7/", 2, 2 },
        uprisingImperium_prepareTheWay = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141286826/72A71863DE41003FCC454F212FE183937C72C50F/", 1, 1 },
        uprisingImperium_theSpiceMustFlow = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141288717/35C76D798308EEA5D9BF50DB3F8B2E3159B14AF9/", 5, 2 },
        -- bloodlines
        bloodlinesImperium = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497409/EF8C20D262C03052C7964EC0F6AF7B18A4D72DB9/", 7, 3 },
        bloodlinesImperium_contract = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497753/24D25A48FACF73A89AB9C67782BB7FFE9C3E698A/", 4, 1 },
        bloodlinesImperium_tech = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497701/55378EA6DF305432157B5825DCA00FAD97785A26/", 1, 1 },
        bloodlinesImperium_ruthlessLeadership = { "https://steamusercontent-a.akamaihd.net/ugc/28805470176783647/0956E619DCEC23DD0A666F9C1BCC7F7DC1FAF78E/", 1, 1 },
    },
    intrigue = {
        intrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342723/13659DD01D152A8B8055B894B247CB1D254D3752/", 8, 5 },
        ixIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342152/3D33B3E59811CEDC64A53F104D31190E76676C64/", 5, 4 },
        immortalityIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141343779/83BA634F05FC7A14933153A18B7AEF83E07E3C14/", 6, 3 },
        uprisingIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133407442/099FFE5EDD43C0E39212970D0A4FDBA12CC729BF/", 10, 4 },
        uprisingIntrigue_contract = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141307385/BFDA5F7ABDF2A97F17019C1715DE0F41BF2BF649/", 2 , 2 },
        bloodlinesIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498407/D0132734BCCE0BF5993374E4874F2191B52D0D0B/", 5, 3 },
        bloodlinesIntrigue_contract = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498551/B84BE5BD050553F6C9F53AD10369DEE5E5D614F0/", 1, 1 },
        bloodlinesIntrigue_tech = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498478/1CFA02E34CA2BD1F589446898E33B56046DE8419/", 2, 1 },
        bloodlinesIntrigue_twisted = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498295/5066A94AD636A81E811A99B4FAE7E697818392B6/", 4, 3 },
    },
    conflict1 = {
        uprisingConflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141315604/288CBFF505CD4CE7E283BF2158A816517DD365C1/", 2, 2 },
        bloodlinesConflict = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498896/C3A9F89FF02CF78D920CAD43D2811986B1D5B120/", 1, 1 },
    },
    conflict2 = {
        uprisingConflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141315846/D5CD3A18CBB9DCE0C305AE999213B504F5F3890D/", 5, 2 },
        bloodlinesConflict = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498851/4E2DBCBC573D130238E9B81A877D878EC485D2C9/", 1, 1 },
    },
    conflict3 = {
        conflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365294/F1BEAE6266E75B7A2F5DE511DB4FEB25A2CD486B/", 3, 2 },
        uprisingConflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141315039/AB1D6A865796D30CD1035C9DEB28002091881B14/", 2, 2 },
    },
    hagal = {
        base = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341414524/BB90DF7F9C97680FE16C4D91A1AF0871B2462CB9/", 5, 5 },
        reshuffle = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141333398/66020C11E4FEA2D22744020D27465DCC2BB02BBE/", 7, 2 },
        ix = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341435538/E181DED96F81A27405E57F0CF398575C20D73D12/", 2, 3 },
        immortality = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341433170/56E0015597F27AB50451E026A8BD95512FA1CE27/", 2, 2 },
        bloodlinesTuek = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498113/3575301D6E9BEAAD0BFFFE890347B17EBFAD23BB/", 1, 1 },
        bloodlinesTech = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498164/DB9D1FB875AB0FB2CF41C29011AAF8CE1144D2BB/", 1, 1 },
    },
    tech = {
        windtraps = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361305/4AD548281EE3633601185ECDE6461BD5E6E67D12/", 1, 1 },
        flagship = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361634/0A8A2BF9A00EE031BB25411F4DED2DD448E68CF2/", 1, 1 },
        sonicSnoopers = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363918/41B99AA2EE39B0218D1A7F101E2F7651B69C81B6/", 1, 1 },
        artillery = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362932/444069DB894789E582661E502BB46024C0220882/", 1, 1 },
        troopTransports = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363383/47909FA9F172C5C52DC364CF7DB461FF74578CD0/", 1, 1 },
        spySatellites = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361398/9E219D6303009CCF196AB048CE9C0E259178D23B/", 1, 1 },
        invasionShips = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141360120/B3D102F7337E8D490A6F3F215D9D07ADB0F596A3/", 1, 1 },
        chaumurky = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141364445/4C4AB77E05C060BFF8AFC4BD83F196584D26786F/", 1, 1 },
        detonationDevices = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362536/425FF99976AF8F554B0BE54C32BCAFFAF61FB673/", 1, 1 },
        spaceport = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141360547/40F797128394D598A460BD9C0CDA5ED2060635B5/", 1, 1 },
        minimicFilm = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362245/EB6795F95B5EB16A3771985483452A16C03E4F85/", 1, 1 },
        holoprojectors = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363278/BAE44C5A75C26C3D4021FCB1893B88C56A0C1799/", 1, 1 },
        memocorders = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133863964/D2E97A26B1DDC4A451FD11678415ECD7DE990450/", 1, 1 },
        disposalFacility = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362000/6B8306BA918834279302EC16185756C49F852964/", 1, 1 },
        holtzmanEngine = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141360423/9069E14122F06892E95192C8E91C4792AA04FB33/", 1, 1 },
        trainingDrones = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141364887/CC314BFCA03F938FD40AA091A22BB0AD050CECCF/", 1, 1 },
        shuttleFleet = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361030/270E363DDF544F9A8B14AC269C193741258FCE41/", 1, 1 },
        restrictedOrdnance = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363646/80CE99F45AED6EF9A249C9BF13E03458D633E8E4/", 1, 1 },
        -- bloodlines = { "...", 3, 6 },
        forbiddenWeapons = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795052/AAF0647BAD97BD2A2DD7E51102C4BC59ABA386A8/", 1, 1 },
        servoReceivers = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795104/5A2A2C98F21C70F1C49E54C71030ADFC52D54358/", 1, 1 },
        spyDrones = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795151/50FFCB01358E22D907A27F5BDC8999DF81805023/", 1, 1 },
        ornithopterFleet = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795167/166D0A8DC11753B5FB463757691233D88065CC18/", 1, 1 },
        sardaukarHighCommand = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795215/F4078F350F8D1A2AD786749BFED303109A279DC6/", 1, 1 },
        glowglobes = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795272/96F4779D8C1E1D8A9DF60F2AE18B1B4F379C45A7/", 1, 1 },
        choamTransports = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795329/B36764BB00D7BC78D0D613EA76F3C894507B7A2E/", 1, 1 },
        selfDestroyingMessages = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795379/53FF0A4C0ECD69FC4002957EFA36CE74290F2A9D/", 1, 1 },
        navigationChamber = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795420/C8E34C5BA34745E9861B3FBB4E378BB09B0212C1/", 1, 1 },
        rapidDropships = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795449/3E2105D21B2C60C71BD10A30D1A6D527C292FC8B/", 1, 1 },
        plasteelBlades = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795490/1FDE74C66AE34AACB33FF00568A6D963946D2366/", 1, 1 },
        deliveryBay = { "https://steamusercontent-a.akamaihd.net/ugc/28806919573531945/AFB31EDE9A52ED18C0A68A97DF540F50F4D817D3/", 1, 1 },
        trainingDepot = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795628/1D1164CA7619EABEB0C99C221AB92B528AA0F7D2/", 1, 1 },
        planetaryArray = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795672/BDDC19CA2B50EECC6D55C010440D07EEC294F63C/", 1, 1 },
        panopticon = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795722/B28013149235122FD53634DF1142AABB8248E072/", 1, 1 },
        geneLockedVault = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795792/4E41339D17C6788AA8F3D05CD220FE37667304DE/", 1, 1 },
        suspensorSuits = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569794993/D482F043F31F7DBEC24A0E7F83E405A553FCEA4D/", 1, 1 },
        advancedDataAnalysis = { "https://steamusercontent-a.akamaihd.net/ugc/28806919569795980/6E4DA015618C463517288440F270330E4147CE5D/", 1, 1 },
    },
    -- Unusued as cards.
    contract = {
        spiceRefineryWater = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141301711/094E866AD56F70903A03DA8673CD337038C79406/", 1, 1 },
        spiceRefineryCard = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133402000/48DCDFDFFBECF417A7562F821120BD76364C1416/", 1, 1 },
        researchStationSpy = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133405740/11C7E095B6267C4BE875B47AA7D214FC058F62FF/", 1, 1 },
        researchStationSolari = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141299807/456BEE0AA5AC91508396967BDF090D6380611B57/", 1, 1 },
        arrakeenSpy = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133404029/4CB29CF8FC8D0BF9A5B575B3E05B31774E59F3CD/", 1, 1 },
        arrakeenWater = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141302127/926CFC63532C4D7BC6AA6B9151AFF0221A553B44/", 1, 1 },
        espionage = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141302966/48A8C33B4ABEB9C61E8C5EF82218E15368DAC56B/", 1, 1 },
        sardaukarRecall = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141301335/E5463C7FFA3426E57F5B07A0DE91602798170C69/", 1, 1 },
        sardaukarCard = { "https://steamusercontent-a.akamaihd.net/ugc/28806104144609890/1711DFB19987B48883EF6B53E1CD62739D70E1A2/", 1, 1 },
        highCouncilSolari = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141299253/1C0C3DEEFFF62306A3988CE9128E2A283BDE03DF/", 1, 1 },
        highCouncilInfluence = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141300682/59973420C9AAB73BA6EBA1984C259A600832B340/", 1, 1 },
        immediate = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141299433/42A2FE5E39D5EF977BFDF5B9783ED57000DB3F8D/", 1, 1 },
        heighlinerTroop = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141299064/FCCBB86CF2E3C36A3C09B5A1635B7557A803BCFB/", 1, 1 },
        heighlinerWater = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141299969/C608732CF394D877A424416273FDD34CB1F0387D/", 1, 1 },
        deliverSupplies = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133405549/AE2085FF98F6A4384DA2213AD1F555D9E341B203/", 1, 1 },
        acquire = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141302298/6D085EC459F3C659F3B43376C96B1CB607448136/", 1, 1 },
        harvest = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141303217/BADC52B8C0982FFA0DFF095040D3973436AA3149/", 1, 1 },
        harvestMore = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133406086/1E5DF874101D6B6A70DE17B2E1A1DB4119290AAA/", 1, 1 },
    },
    leader = {
        glossuRabban = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141318082/68A9DE7E06DA5857EE51ECB978E13E3921A15B1A/", 1, 1 },
        vladimirHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141320749/6F682C5E5C1ADE0B9B1B8FAC80B9525A6748C351/", 1, 1 },
        memnonThorvald = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141318361/36DB26EE194B780C9C879C74FC634C15433CE06A/", 1, 1 },
        arianaThorvald = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141318498/3C1CA2B3506FB7AD8B1B40DB1414F7461F6974C8/", 1, 1 },
        paulAtreides = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141319736/008429F21B2898E4C2982EC7FB1AF422FDD85E24/", 1, 1 },
        letoAtreides = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141317105/152B626A2D773B224CFFF878E35CEFDBB6F67505/", 1, 1 },
        ilbanRichese = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141317254/F0F052CCAB7005F4D30879BF639AFACEDFF70A80/", 1, 1 },
        helenaRichese = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141319602/A069B3ECF1B4E9C42D2453E28EA13257F397B3F3/", 1, 1 },
        -- Ix
        yunaMoritani = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141320605/CDAED205706CD8E32700B8A56C9BD387C5D72696/", 1, 1 },
        hundroMoritani = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141317391/A64F2D77C6F482F31B12EC97C2DEEBBDF45AF3F9/", 1, 1 },
        ilesaEcaz = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141320907/7A0FCC4CA1D0CAF19C8066776DC23A9631000997/", 1, 1 },
        armandEcaz = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141319231/98401D1D00D15DB3512E48BBD63B9922EE17EF71/", 1, 1 },
        tessiaVernius = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141317697/6C34345ADF23EBD567DE0EE662B4920906F721F0/", 1, 1 },
        rhomburVernius = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141316740/58A6CF3EB6EBDEAC4B5826C0D21408A3CC02E678/", 1, 1 },
        -- uprising
        stabanTuek = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141281600/C1C83545F676ACDC3C63577BED070BD80ABADEED/", 1, 1 },
        amberMetulli = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141281768/CD03E06EFC734492D344B04C385FEF43DC2DF173/", 1, 1 },
        gurneyHalleck = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141284803/09C5E2F178B9F48ED577C7E74FC58C53D7698D7D/", 1, 1 },
        margotFenring = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141283726/A3381C2EF2869950BD00E6AE7ADB5B662F883764/", 1, 1 },
        irulanCorrino = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141284991/5D95D6143B4407029C8665AF8E10B20634FEE3A3/", 1, 1 },
        jessica = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141282389/4CB1D17A9AA19831A1C2925FB431DCFDA1EE10B8/", 1, 1, Vector(1.12, 1, 1.12),
            "https://steamusercontent-a.akamaihd.net/ugc/2502404390141283297/171F9173728A3E031830C1AF989B9B0BAFAA5DAF/" },
        feydRauthaHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141284619/996AAC7E5AC098A6804153865E8116754B19DDDB/", 1, 1 },
        shaddamCorrino = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141282162/D307B7C2139EC0E0B999900940DC6F5827EB68A8/", 1, 1 },
        muadDib = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141281959/BA1804DF868BF77175777B0FB5B1D109B46E13A9/", 1, 1 },
        -- bloodlines
        chani = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497192/D71661A3571B0AD352BAC2B0EC042A74F2C449BD/", 1, 1 },
        duncanIdaho = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896496946/3279B2A26C2346C4CCED58E032F7515696F1EC55/", 1, 1 },
        esmarTuek = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896496485/14011EB052D02BE770A5E15CD12EACEDC03EB12B/", 1, 1 },
        gaiusHelenMohiam = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896496630/25B79FD5FFF0A4C8580935B794B5EAB6C4FAEBC8/", 1, 1 },
        hasimirFenring = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497254/142C59D454BCEE3581C54C67ABCCCEC2DC52C8CF/", 1, 1 },
        lietKynes = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896496818/7C39C2CDC433858375E02699A00810BC0C7D0752/", 1, 1 },
        piterDeVries = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497318/2D2F666442F6E80FC358908728E243A4FD753128/", 1, 1 },
        yrkoon = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497017/46E0D31CCBD1C2237CCC9F83E1D9CBB69A106949/", 1, 1 },
        kotaOdax = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497133/7821DCA1F54A5501DD192FB8E77C867500A4FCDB/", 1, 1 },
    },
    rivalLeader = {
        uprising = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341168508/811BF7142774932C8C2FAD7C10BA104F8DAD4299/", 4, 3 },
        bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896497833/3EA98B4739ED652C8B34CE13B53BCD94647FEA50/", 3, 2 },
    },
    navigation = {
        bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/28804925896498665/A7CA60333F021CC224CE59E553EF3D0C63052498/", 5, 2 },
    },
    sardaukarCommanderSkill = {
        bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/28804925903402701/2950BB8750427F403492D5C3D8139532291A4D02/", 4, 2 },
    },
}

function Deck.load(loader, cards, category, customDeckName, startLuaIndex, cardNames)
    assert(Deck[category], "Unknown category: " .. category)
    local desc = Deck[category][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local customDeck
    if desc[5] then
        customDeck = loader.createCustomDeck(desc[5], desc[1], desc[2], desc[3], desc[4])
    else
        local functionName = Helper.toCamelCase("create", category, "CustomDeck")
        assert(loader[functionName], "No loader for: " .. functionName )
        customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    end
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

function Deck.loadWithSubCategory(loader, cards, category, subCategory, customDeckName, startLuaIndex, cardNames)
    assert(Deck[category], "No category: " .. category)
    assert(Deck[category][subCategory], "No sub category: " .. category .. "." .. subCategory)
    local desc = Deck[category][subCategory][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local functionName = Helper.toCamelCase("create", category, "CustomDeck")
    assert(loader[functionName], "No loader for: " .. functionName )
    local customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

function Deck.loadCustomDecks(loader)
    local cards = {
        objective = {},
        imperium = {},
        special = {},
        tleilaxu = {},
        intrigue = {},
        conflict = {},
        hagal = {},
        tech = {},
        leaders = {},
        rivalLeaders = {},
        navigation = {},
        sardaukarCommanderSkills = {},
    }

    Deck.load(loader, cards.objective, "objective", "uprisingObjective", 1, {
        "ornithopter1to3p",
        "muadDibFirstPlayer",
        "crysknife",
        "muadDib4to6p",
        "crysknife4to6p",
    })

    Deck.load(loader, cards.imperium, "imperium", "starter", 1, {
        "seekAllies",
        "signetRing",
        "diplomacy",
        "reconnaissance",
        "convincingArgument", "",
        "dagger", "",
    })
    Deck.load(loader, cards.imperium, "imperium", "starterDunePlanet", 1, {
        "duneTheDesertPlanet",
    })
    Deck.load(loader, cards.imperium, "imperium", "starterImperium_emperor", 1, {
        "emperorConvincingArgument",
        "emperorCorrinoMight",
        "emperorCriticalShipments",
        "emperorDemandResults",
        "emperorDevastatingAssault",
        "emperorImperialOrnithopter", "",
        "emperorSignetRing",
        "emperorSeekAllies",
        "emperorImperialTent",
    })
    Deck.load(loader, cards.imperium, "imperium", "starterImperium_muadDib", 1, {
        "muadDibCommandRespect",
        "muadDibConvincingArgument",
        "muadDibDemandAttention",
        "muadDibDesertCall",
        "muadDibLimitedLandsraadAccess", "",
        "muadDibSeekAllies",
        "muadDibUsul",
        "muadDibThreatenSpiceProduction",
        "muadDibSignetRing",
    })
    Deck.load(loader, cards.imperium, "imperium", "imperium", 1, {
        "opulence",
        "firmGrip",
        "guildAmbassador",
        "guildBankers",
        "otherMemory",
        "ladyJessica",
        "jessicaOfArrakis",
        "kwisatzHaderach",
        "reverendMotherMohiam",
        "sietchReverendMother",
        "testOfHumanity",
        "lietKynes",
        "chani",
        "crysknife",
        "stilgar",
        "choamDirectorship",
        "duncanIdaho",
        "drYueh",
        "gurneyHalleck",
        "piterDeVries",
        "carryall",
        "thufirHawat",
        "beneGesseritSister", "", "",
        "powerPlay", "", "",
        "imperialSpy", "",
        "sardaukarInfantry", "",
        "sardaukarLegion", "",
        "guildAdministrator", "",
        "spiceSmugglers", "",
        "smugglersThopter", "",
        "spaceTravel", "",
        "beneGesseritInitiate", "",
        "theVoice", "",
        "geneManipulation", "",
        "missionariaProtectiva", "",
        "fremenCamp", "",
        "spiceHunter", "",
        "wormRiders", "",
        "fedaykinDeathCommando", "",
        "shiftingAllegiances", "",
        "scout", "",
        "assassinationMission", "",
        "gunThopter", "",
        "arrakisRecruiter", "",
        "duncanLoyalBlade",
    })
    Deck.load(loader, cards.imperium, "imperium", "ixImperium", 1, {
        "appropriate",
        "imperialBashar",
        "courtIntrigue",
        "fullScaleAssault",
        "imperialShockTrooper",
        "guildAccord",
        "guildChiefAdministrator",
        "ixGuildCompact",
        "landingRights",
        "esmarTuek",
        "embeddedAgent",
        "weirdingWay",
        "webOfPower",
        "spiceTrader",
        "desertAmbush",
        "satelliteBan",
        "jamis",
        "sayyadina",
        "shaiHulud",
        "boundlessAmbition",
        "bountyHunter",
        "choamDelegate",
        "waterPeddler",
        "localFence",
        "truthsayer", "",
        "inTheShadows", "",
        "freighterFleet", "",
        "ixianEngineer", "",
        "negotiatedWithdrawal", "",
        "treachery", "",
    })
    Deck.load(loader, cards.imperium, "imperium", "ixImperiumControlTheSpice", 1, {
        "controlTheSpice",
    })
    Deck.load(loader, cards.imperium, "imperium", "immortalityImperium", 1, {
        "beneTleilaxLab",
        "beneTleilaxResearcher",
        "blankSlate",
        "clandestineMeeting",
        "corruptSmuggler",
        "dissectingKit", "",
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
        "tleilaxuSurgeon",
        -- +4
    })
    Deck.load(loader, cards.imperium, "imperium", "immortalityImperiumExperimentation", 1, {
        "experimentation",
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
        "piterGeniusAdvisor",
        "scientificBreakthrough",
        "sligFarmer",
        "stitchedHorror",
        "subjectX137",
        "tleilaxuInfiltrator",
        "twistedMentat",
        "unnaturalReflexes",
        "usurp",
    })

    Deck.load(loader, cards.imperium, "imperium", "uprisingImperium", 1, {
        "unswervingLoyalty", "",
        "spaceTimeFolding",
        "weirdingWoman", "",
        "sardaukarSoldier",
        "smugglerHarvester", "",
        "makerKeeper", "",
        "reliableInformant",
        "hiddenMissive",
        "wheelsWithinWheels",
        "fedaykinStilltent",
        "imperialSpymaster",
        "spyNetwork",
        "desertSurvival", "",
        "undercoverAsset",
        "beneGesseritOperative", "",
        "maulaPistol", "",
        "thumper",
        "nothernWatermaster",
        "covertOperation",
        "doubleAgent", "",
        "guildEnvoy",
        "rebelSupplier", "",
        "calculusOfPower", "",
        "guildSpy",
        "dangerousRhetoric",
        "branchingPath",
        "ecologicalTestingStation",
        "theBeastSpoils",
        "smugglerHaven",
        "shishakli",
        "paracompass",
        "sardaukarCoordination", "",
        "truthtrance", "",
        "publicSpectable", "",
        "southernElders",
        "treadInDarkness", "",
        "spacingGuildFavor", "",
        "capturedMentat",
        "subversiveAdvisor",
        "leadership",
        "inHighPlaces",
        "strikeFleet",
        "trecherousManeuver",
        "chaniCleverTactician",
        "junctionHeadquarters",
        "corrinthCity",
        "stilgarTheDevoted",
        "desertPower",
        "arrakisRevolt",
        "priceIsNoObject",
        "longLiveTheFighters",
        "overthrow",
        "steersman",
    })
    Deck.load(loader, cards.imperium, "imperium", "uprisingImperium_contract", 1, {
        "cargoRunner",
        "deliveryAgreement",
        "priorityContracts",
        "interstellarTrade",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium", 1, {
        "fremenWarName",
        "sardaukarStandard",
        "quashRebellion",
        "southernFaith",
        "imperialThroneship",
        "possibleFutures",
        "arrakisObserver",
        "eliminateAllies",
        "holyWar",
        "intelligenceTraining",
        "bombast",
        "pointingTheWay",
        "shroudedCounsel",
        "sandwalk",
        "disruptionTactics",
        "urgentShigawire",
        "commandCenter",
        "engineeredMiracle",
        "iBelieve",
        "litanyAgainstFear",
        "eliteForces",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium_contract", 1, {
        "deliveryLogistics",
        "corruptBureaucrat",
        "mercantileAffairs",
        "choamDemands",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium_tech", 1, {
        "ixianAmbassador",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium_ruthlessLeadership", 1, {
        "ruthlessLeadership",
    })
    Deck.load(loader, cards.special, "imperium", "imperiumFoldedSpace", 1, {
        "foldspace",
        -- +5
    })
    Deck.load(loader, cards.special, "imperium", "uprisingImperium_prepareTheWay", 8, {
        "prepareTheWay",
    })
    Deck.load(loader, cards.special, "imperium", "uprisingImperium_theSpiceMustFlow", 10, {
        "theSpiceMustFlow",
    })
    Deck.load(loader, cards.special, "imperium", "tleilaxResearchReclaimedForces", 11, {
        "reclaimedForces",
    })

    Deck.load(loader, cards.intrigue, "intrigue", "intrigue", 1, {
        "masterTactician", "", "",
        "privateArmy", "",
        "ambush","",
        "dispatchAnEnvoy", "",
        "poisonSnooper", "",
        "favoredSubject",
        "knowTheirWays",
        "secretOfTheSisterhood",
        "guildAuthorization",
        "stagedIncident",
        "theSleeperMustAwaken",
        "choamShares",
        "cornerTheMarket",
        "plansWithinPlans",
        "windfall",
        "waterPeddlersUnion",
        "councilorsDispensation",
        "doubleCross",
        "rapidMobilization",
        "reinforcements",
        "recruitmentMission",
        "charisma",
        "bypassProtocol",
        "infiltrate",
        "urgentMission",
        "calculatedHire",
        "binduSuspension",
        "waterOfLife",
        "refocus",
        "bribery",
        "toTheVictor",
        "demandRespect",
        "alliedArmada",
        "tiebreaker",
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
        "quidProQuo",
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
        "viciousTalents",
        -- +4
    })
    Deck.load(loader, cards.intrigue, "intrigue", "uprisingIntrigue", 1, {
        "sietchRitual",
        "mercenaries",
        "councilorAmbition",
        "strategicStockpiling",
        "detonation", "",
        "departForArrakis",
        "cunning",
        "opportunism",
        "changeAllegiances",
        "specialMission", "",
        "unexpectedAllies",
        "callToArms",
        "buyAccess",
        "imperiumPolitics",
        "shaddamFavor",
        "intelligenceReport",
        "manipulate",
        "distraction", "",
        "marketOpportunity",
        "goToGround",
        "contingencyPlan", "", "",
        "inspireAwe",
        "findWeakness",
        "spiceIsPower",
        "devour",
        "impress",
        "springTheTrap",
        "weirdingCombat",
        "tacticalOption",
        "questionableMethods",
        "desertMouse",
        "ornithopter",
        "crysknife",
        "shadowAlliance",
        "secureSpiceTrade",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "uprisingIntrigue_contract", 1, {
        "leverage",
        "backedByChoam",
        "reachAgreement",
        "choamProfits",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "bloodlinesIntrigue", 1, {
        "adaptiveTactics",
        "desertSupport",
        "emperorInvitation",
        "honorGuard",
        "returnTheFavor",
        "sacredPools",
        "seizeProduction",
        "theStrongSurvive",
        "tenuousBound",
        "withdrawalAgreement",
        "falseOrder",
        "graspArrakis",
        "insiderInformation",
        "ripplesInTheSand",
        "sleeperUnit",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "bloodlinesIntrigue_contract", 1, {
        "coerciveNegotiation",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "bloodlinesIntrigue_tech", 1, {
        "battlefieldResearch",
        "rapidEngineering",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "bloodlinesIntrigue_twisted", 1, {
        "ambitious",
        "calculating",
        "controlled",
        "devious",
        "discerning",
        "insidious",
        "resourceful",
        "sadistic",
        "shrewd",
        "sinister",
        "unnatural",
        "withdrawn",
    })

    Deck.load(loader, cards.conflict, "conflict1", "uprisingConflict", 1, {
        "skirmishA",
        "skirmishB",
        "skirmishC",
    })
    Deck.load(loader, cards.conflict, "conflict1", "bloodlinesConflict", 1, {
        "skirmishD",
    })
    Deck.load(loader, cards.conflict, "conflict2", "uprisingConflict", 1, {
        "choamSecurity",
        "spiceFreighters",
        "siegeOfArrakeen",
        "seizeSpiceRefinery",
        "testOfLoyalty",
        "shadowContest",
        "secureImperialBasin",
        "protectTheSietches",
        "tradeDispute",
        ""
    })
    Deck.load(loader, cards.conflict, "conflict2", "bloodlinesConflict", 1, {
        "stormsInTheSouth"
    })
    Deck.load(loader, cards.conflict, "conflict3", "conflict", 5, {
        "economicSupremacy"
    })
    Deck.load(loader, cards.conflict, "conflict3", "uprisingConflict", 1, {
        "propaganda",
        "battleForImperialBasin",
        "battleForArrakeen",
        "battleForSpiceRefinery",
    })

    Deck.load(loader, cards.hagal, "hagal", "base", 1, {
        "churn",
        "placeSpyYellow",
        "placeSpyBlue",
        "placeSpyGreen",
        "sardaukar",
        "dutifulService",
        "heighliner",
        "deliverSuppliesAndHeighliner",
        "espionage",
        "secrets",
        "desertTactics",
        "fremkit",
        "assemblyHall",
        "gatherSupport1",
        "gatherSupport2",
        "acceptContractAndShipping1",
        "acceptContractAndShipping2",
        "researchStation",
        "spiceRefinery",
        "arrakeen",
        "sietchTabr",
        "haggaBasinAndImperialBasin",
        "deepDesert",
    })
    Deck.load(loader, cards.hagal, "hagal", "reshuffle", 10, {
        "reshuffle"
    })
    Deck.load(loader, cards.hagal, "hagal", "ix", 1, {
        "interstellarShipping",
        "deliverSuppliesAndInterstellarShipping",
        "smugglingAndInterstellarShipping",
        "techNegotiation",
        "dreadnought1p",
        "dreadnought2p",
    })
    Deck.load(loader, cards.hagal, "hagal", "immortality", 1, {
        "researchStationImmortality",
        "tleilaxuBonus1",
        "tleilaxuBonus2",
        "tleilaxuBonus3",
    })
    Deck.load(loader, cards.hagal, "hagal", "bloodlinesTuek", 1, {
        "tuekSietch",
    })
    Deck.load(loader, cards.hagal, "hagal", "bloodlinesTech", 1, {
        "acquireTech",
    })

    -- One tech per custom deck.
    for techName, _ in pairs(Deck.tech) do
        if techName ~= "bloodlines" then
            Deck.load(loader, cards.tech, "tech", techName, 1, { techName })
        end
    end
    if false then
        -- But a single image for Bloodlines.
        Deck.load(loader, cards.tech, "tech", "bloodlines", 1, {
            "trainingDepot",
            "geneLockedVault",
            "glowglobes",
            "planetaryArray",
            "servoReceivers",
            "deliveryBay",
            "plasteelBlades",
            "suspensorSuits",
            "rapidDropships",
            "selfDestroyingMessages",
            "navigationChamber",
            "sardaukarHighCommand",
            "forbiddenWeapons",
            "advancedDataAnalysis",
            "ornithopterFleet",
            "panopticon",
            "spyDrones",
            "choamTransports",
        })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.leader) do
        Deck.load(loader, cards.leaders, "leader", leaderName, 1, { leaderName })
    end

    Deck.load(loader, cards.rivalLeaders, "rivalLeader", "uprising", 1, {
        "vladimirHarkonnen",
        "muadDib",
        "jessica",
        "feydRauthaHarkonnen",
        "margotFenring",
        "stabanTuek",
        "amberMetulli",
        "irulanCorrino",
        "gurneyHalleck",
        "glossuRabban",
    })
    Deck.load(loader, cards.rivalLeaders, "rivalLeader", "bloodlines", 1, {
        "duncanIdaho",
        "piterDeVries",
        "chani",
        "hasimirFenring",
        "gaiusHelenMohiam",
        "kotaOdax",
    })

    Deck.load(loader, cards.navigation, "navigation", "bloodlines", 1, {
        "solarisAndPermanentPersuasion",
        "spiceIfTrash",
        "waterThenSpiceIfSpacingGuildInfluence",
        "spiceOrInfluenceIfSolaris",
        "spiceOrTSMFIfWater",
        "spiceThenIntrigueIfAlliance",
        "influenceIfInfluence",
        "drawOrVpIfSpice",
        "troopOrMoreTroopIfSolaris",
        "spyOrIntrigueAndSpiceIfSpy",
    })

    Deck.load(loader, cards.sardaukarCommanderSkills, "sardaukarCommanderSkill", "bloodlines", 1, {
        "charismatic",
        "desperate",
        "fierce",
        "canny",
        "driven",
        "loyal",
        "hardy",
    })

    return cards
end

return Deck
