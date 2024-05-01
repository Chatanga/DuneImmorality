local Helper = require("utils.Helper")

local Deck = {
    imperium = {
        -- starter without dune planet
        starter = { "http://cloud-3.steamusercontent.com/ugc/2093667512238503531/D25AA65312D89EB7CEED36D451618E731A674BED/", 4, 2 },
        -- dune planet
        starterDunePlanet = { "http://cloud-3.steamusercontent.com/ugc/2093667512238502926/98F5861E28F3167495D3F2890879072BF3A84E60/", 2, 2 },
        -- base without foldspace, nor liasion, nor the spice must flow, but with Jessica of Arrakis and Duncan Loyal Blade
        imperium = { "http://cloud-3.steamusercontent.com/ugc/2093667512238504179/CC2D301CA075930201B3883D82F4C6E1A0837273/", 10, 7 },
        imperiumFoldedSpace = { "http://cloud-3.steamusercontent.com/ugc/2093667512238503304/AE481C2ED19B085E2669F22420FD282982FD11A9/", 3, 2 },
        imperiumArrakisLiasion = { "http://cloud-3.steamusercontent.com/ugc/2093667512238504363/D7411DB495E6EB13D6B64F5E46CCF69FF322039F/", 4, 2 },
        imperiumTheSpiceMustFlow = { "http://cloud-3.steamusercontent.com/ugc/2093667512238504759/B6E08F8328DB699C60A8F058E88AA6443BA2F716/", 5, 2 },
        -- ix without control the spice, but with Boundless Ambition
        ixImperium = { "http://cloud-3.steamusercontent.com/ugc/2093667512238503692/C54BCAB79869547E728509123AC47EDB32E79BF5/", 6, 6 },
        ixImperiumControlTheSpice = { "http://cloud-3.steamusercontent.com/ugc/2093667512238505114/DD5ED3E5FD12F0A1C4F42750E766E83564248E07/", 1, 1 },
        -- tleilax without experimentation
        immortalityImperium = { "http://cloud-3.steamusercontent.com/ugc/2093667512238503969/142F50245296C2EE1F5ABAD8CE93982AC0592110/", 6, 5 },
        immortalityImperiumExperimentation = { "http://cloud-3.steamusercontent.com/ugc/2093667512238504928/BF6DF4E8EF5B8C8F5BB6952166C559694A61BA04/", 2, 2 },
        -- tleilax without reclaimed forces
        tleilaxResearch = { "http://cloud-3.steamusercontent.com/ugc/2093667512238501306/639814906915DFA557375A3F7963C9DE53301D57/", 4, 5 },
        -- reclaimed forces
        tleilaxResearchReclaimedForces = { "http://cloud-3.steamusercontent.com/ugc/2093667512238501804/60812AEA733FF5558BA9190E47CBD474EBF38C94/", 1, 1 },
    },
    intrigue = {
        intrigue = { "http://cloud-3.steamusercontent.com/ugc/2093667512238521654/13659DD01D152A8B8055B894B247CB1D254D3752/", 8, 5 },
        ixIntrigue = { "http://cloud-3.steamusercontent.com/ugc/2093667512238520112/3D33B3E59811CEDC64A53F104D31190E76676C64/", 5, 4 },
        immortalityIntrigue = { "http://cloud-3.steamusercontent.com/ugc/2093667512238520919/83BA634F05FC7A14933153A18B7AEF83E07E3C14/", 6, 3 },
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
        hagal = { "http://cloud-3.steamusercontent.com/ugc/2492254803030883138/1BC00878E1A3E3B3007D0B30A33EE0E09D343ABE/", 5, 5 },
    },
    tech = {
        windtraps = { "http://cloud-3.steamusercontent.com/ugc/2093667512238535499/4AD548281EE3633601185ECDE6461BD5E6E67D12/", 1, 1 },
        flagship = { "http://cloud-3.steamusercontent.com/ugc/2093667512238532547/0A8A2BF9A00EE031BB25411F4DED2DD448E68CF2/", 1, 1 },
        sonicSnoopers = { "http://cloud-3.steamusercontent.com/ugc/2093667512238532395/41B99AA2EE39B0218D1A7F101E2F7651B69C81B6/", 1, 1 },
        artillery = { "http://cloud-3.steamusercontent.com/ugc/2093667512238535341/444069DB894789E582661E502BB46024C0220882/", 1, 1 },
        troopTransports = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531299/47909FA9F172C5C52DC364CF7DB461FF74578CD0/", 1, 1 },
        spySatellites = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531198/9E219D6303009CCF196AB048CE9C0E259178D23B/", 1, 1 },
        invasionShips = { "http://cloud-3.steamusercontent.com/ugc/2093667512238532087/B3D102F7337E8D490A6F3F215D9D07ADB0F596A3/", 1, 1 },
        chaumurky = { "http://cloud-3.steamusercontent.com/ugc/2093667512238532242/4C4AB77E05C060BFF8AFC4BD83F196584D26786F/", 1, 1 },
        detonationDevices = { "http://cloud-3.steamusercontent.com/ugc/2093667512238536270/425FF99976AF8F554B0BE54C32BCAFFAF61FB673/", 1, 1 },
        spaceport = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531566/40F797128394D598A460BD9C0CDA5ED2060635B5/", 1, 1 },
        minimicFilm = { "http://cloud-3.steamusercontent.com/ugc/2093667512238536779/EB6795F95B5EB16A3771985483452A16C03E4F85/", 1, 1 },
        holoprojectors = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533483/BAE44C5A75C26C3D4021FCB1893B88C56A0C1799/", 1, 1 },
        memocorders = { "http://cloud-3.steamusercontent.com/ugc/2093667512238534021/D2E97A26B1DDC4A451FD11678415ECD7DE990450/", 1, 1 },
        disposalFacility = { "http://cloud-3.steamusercontent.com/ugc/2093667512238533054/6B8306BA918834279302EC16185756C49F852964/", 1, 1 },
        holtzmanEngine = { "http://cloud-3.steamusercontent.com/ugc/2093667512238534141/9069E14122F06892E95192C8E91C4792AA04FB33/", 1, 1 },
        trainingDrones = { "http://cloud-3.steamusercontent.com/ugc/2093667512238531952/CC314BFCA03F938FD40AA091A22BB0AD050CECCF/", 1, 1 },
        shuttleFleet = { "http://cloud-3.steamusercontent.com/ugc/2093667512238535170/270E363DDF544F9A8B14AC269C193741258FCE41/", 1, 1 },
        restrictedOrdnance = { "http://cloud-3.steamusercontent.com/ugc/2093667512238535614/80CE99F45AED6EF9A249C9BF13E03458D633E8E4/", 1, 1 },
    },
    leader = {
        glossuRabban = { "http://cloud-3.steamusercontent.com/ugc/2093667512238498462/68A9DE7E06DA5857EE51ECB978E13E3921A15B1A/", 1, 1 },
        vladimirHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093667512238497473/6F682C5E5C1ADE0B9B1B8FAC80B9525A6748C351/", 1, 1 },
        memnonThorvald = { "http://cloud-3.steamusercontent.com/ugc/2093667512238496955/36DB26EE194B780C9C879C74FC634C15433CE06A/", 1, 1 },
        arianaThorvald = { "http://cloud-3.steamusercontent.com/ugc/2093667512238497102/3C1CA2B3506FB7AD8B1B40DB1414F7461F6974C8/", 1, 1 },
        paulAtreides = { "http://cloud-3.steamusercontent.com/ugc/2093667512238499852/008429F21B2898E4C2982EC7FB1AF422FDD85E24/", 1, 1 },
        letoAtreides = { "http://cloud-3.steamusercontent.com/ugc/2093667512238500640/152B626A2D773B224CFFF878E35CEFDBB6F67505/", 1, 1 },
        ilbanRichese = { "http://cloud-3.steamusercontent.com/ugc/2093667512238498742/F0F052CCAB7005F4D30879BF639AFACEDFF70A80/", 1, 1 },
        helenaRichese = { "http://cloud-3.steamusercontent.com/ugc/2093667512238499726/A069B3ECF1B4E9C42D2453E28EA13257F397B3F3/", 1, 1 },
        -- Ix
        yunaMoritani = { "http://cloud-3.steamusercontent.com/ugc/2093667512238500769/CDAED205706CD8E32700B8A56C9BD387C5D72696/", 1, 1 },
        hundroMoritani = { "http://cloud-3.steamusercontent.com/ugc/2093667512238499395/A64F2D77C6F482F31B12EC97C2DEEBBDF45AF3F9/", 1, 1 },
        ilesaEcaz = { "http://cloud-3.steamusercontent.com/ugc/2093667512238497232/7A0FCC4CA1D0CAF19C8066776DC23A9631000997/", 1, 1 },
        armandEcaz = { "http://cloud-3.steamusercontent.com/ugc/2093667512238498599/98401D1D00D15DB3512E48BBD63B9922EE17EF71/", 1, 1 },
        tessiaVernius = { "http://cloud-3.steamusercontent.com/ugc/2093667512238499203/6C34345ADF23EBD567DE0EE662B4920906F721F0/", 1, 1 },
        rhomburVernius = { "http://cloud-3.steamusercontent.com/ugc/2093667512238497351/58A6CF3EB6EBDEAC4B5826C0D21408A3CC02E678/", 1, 1 },
    },
    fanmadeLeader = {
        arkhane = {
            abulurdHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093668799785647987/40B8A2B4F6F5DA9A0C2D7738A3F5BFD925167438/", 1, 1 },
            xavierHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648901/43E90624D39B5A904FF112BD5A0B7C3D8AA21502/", 1, 1 },
            feydRauthaHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648769/D80761B2286A313A11939E3D45DEBCF24F7D30CC/", 1, 1 },
            hasimirFenring = { "http://cloud-3.steamusercontent.com/ugc/2093668799785651246/3657671646912D7026E790B8DE187B49975CBD0E/", 1, 1 },
            margotFenring = { "http://cloud-3.steamusercontent.com/ugc/2093668799785649044/1964022795283817F32D219C1C38050A9B5303AD/", 1, 1 },
            lietKynes = { "http://cloud-3.steamusercontent.com/ugc/2093668799785651664/DC956CB7ACBD2370DC3D86484765E413F36DBBFF/", 1, 1 },
            hwiNoree = { "http://cloud-3.steamusercontent.com/ugc/2093668799785651374/D3BB757794FCB5B9CF5D58798A697B354BD34EEA/", 1, 1 },
            metulli = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648115/09663A73D24AF2DB6A9315D87C5953614C0B0F32/", 1, 1 },
            milesTeg = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648620/299ECFBED3CD8F16774C5C69F8A957768CBBB66D/", 1, 1 },
            normaCenvas = { "http://cloud-3.steamusercontent.com/ugc/2093668799785650099/4E8FC979A8689926A3A02EA748F402E7D76570BA/", 1, 1 },
            irulanCorrino = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648228/4C33FE97C3EFCABF776DF966B59D2AF15401D07E/", 1, 1 },
            wencisiaCorrino = { "http://cloud-3.steamusercontent.com/ugc/2093668799785649921/C3D5184AD0F809A3F1F38BB16096AF5DD4437FA5/", 1, 1 },
            vorianAtreides = { "http://cloud-3.steamusercontent.com/ugc/2093668799785650977/DFDB8318608D8F7B39273B40EBB4120FCEE56B3E/", 1, 1 },
            serenaButler = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648387/C4934E0587D33E2F1BB051D746A7EB30D2A6DEA7/", 1, 1 },
            whitmoreBluud = { "http://cloud-3.steamusercontent.com/ugc/2093668799785649622/FEB8F943C50DFB711640347C6397243D71F9780A/", 1, 1 },
            executrixOrdos = { "http://cloud-3.steamusercontent.com/ugc/2093668799785651526/69C591C92ED7FBA903ECDAD9C2CCC2B99EBBC5B0/", 1, 1 },
            torgTheYoung = { "http://cloud-3.steamusercontent.com/ugc/2093668799785649467/66DCBBE36459C57FD8F631D8576F2CF01DFDC092/", 1, 1 },
            twylwythWaff = { "http://cloud-3.steamusercontent.com/ugc/2093668799785648508/A7741DFFE841114BDDB8B6F8A2A57D2C59CDDEEB/", 1, 1 },
            scytale = { "http://cloud-3.steamusercontent.com/ugc/2093668799785650538/BFA284BBABA15A609401208F4D834FE916EA960E/", 1, 1 },
            stabanTuek = { "http://cloud-3.steamusercontent.com/ugc/2093668799785650746/1FCB42B17A8F7F711758BF5869CD3B7328E4542F/", 1, 1 },
            esmarTuek = { "http://cloud-3.steamusercontent.com/ugc/2093668799785650381/EDAF5084889AA22C19B915DFADDFEADAB97F440F/", 1, 1 },
            drisk = { "http://cloud-3.steamusercontent.com/ugc/2093668799785651117/2F2F3CF34B2737B7CAEF26433B3ECEE9FE41B3AF/", 1, 1 },
            arkhane = { "http://cloud-3.steamusercontent.com/ugc/2093668799785649294/43F98BF29B58C81D6C1FABDC6D166BC0ED122953/", 1, 1 },
        },
        retienne = {
            horatioDelta = { "http://cloud-3.steamusercontent.com/ugc/2488878371133586723/A5EC6C2D6540C450E5A88250E11177D28C74C1D2/", 1, 1 },
            horatioFive = { "http://cloud-3.steamusercontent.com/ugc/2488878371133599596/3993C542CC0A5764E981F03759B7A0AA2623A95E/", 1, 1 },
            sionaAtreides = { "http://cloud-3.steamusercontent.com/ugc/2488878371133599777/B59925EFADED6E2F319D2DDFF6DBF209DB07BEA7/", 1, 1 },
            almaMavisTaraza = { "http://cloud-3.steamusercontent.com/ugc/2488878371133587074/0500E7617A9853B2BE2F7E7AE791B361218250DC/", 1, 1 },
            dukeJenhaestraDrevMeos = { "http://cloud-3.steamusercontent.com/ugc/2488878371133595329/B7C33A61A918C6750601B4B781BA88988478DB02/", 1, 1 },
            horatioPrime = { "http://cloud-3.steamusercontent.com/ugc/2488878371133588642/5ECF73D730CBC697C45C78D823D5D63EEB8F6717/", 1, 1 },
        }
    },
    arrakeenScouts = {
        committee = {
            appropriations = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601025/F69DF9C9F34598DC456A51C1996247B0FBF93483/", 1, 1 },
            development = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601393/D59C1D80B198715305C5D17652E2A174733FD196/", 1, 1 },
            information = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602002/7BBC97BDD0EE0DD2C53B571875117304ADDA3E8F/", 1, 1 },
            investigation = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601859/C9604B54BDF9A78B8785166211A91C070824D5F0/", 1, 1 },
            joinForces = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601568/16FD82C4D9424774DE741F231103CDEC17D80B36/", 1, 1 },
            politicalAffairs = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601706/05E920F75AF0DCEFB5190120D9082D6C9EC4F570/", 1, 1 },
            preparation = { "http://cloud-3.steamusercontent.com/ugc/2488878371133600884/DD38BE5DC44CE962443EC2EC6867FCE5EC75FA24/", 1, 1 },
            relations = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601265/E8613A1508F44750D3A1F38076A557D870741D04/", 1, 1 },
            supervision = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602263/A7276A42FADE5448D77D925C7AA6A3FD1E27DB58/", 1, 1 },
            dataAnalysis = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602426/DC9FA31A74F63551F7C17E31051757C2272565E3/", 1, 1 },
            developmentProject = { "http://cloud-3.steamusercontent.com/ugc/2488878371133601138/17CF50CCFA8DBC0724B360A8F99A12099E574EE2/", 1, 1 },
            tleilaxuRelations = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602125/2D869B2CB2341BA989D90EFA561AC2B169198799/", 1, 1 },
        },
        auction = {
            mentat1 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603377/F72AA83BB6AB9F2F08941BCDAE3241C00F596EBE/", 1, 1 },
            mentat2 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602898/4F5C9891DC2471D1C256328D0E38BA796A7621F3/", 1, 1 },
            mercenaries1 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603204/8E001F53191201BFF1C53464DE3A1FE63A4815A2/", 1, 1 },
            mercenaries2 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603204/8E001F53191201BFF1C53464DE3A1FE63A4815A2/", 1, 1 },
            treachery1 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602730/E3F630F9688D32DD7F55851E58484019FD469C15/", 1, 1 },
            treachery2 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603063/808827CB65B9DABC4591175D0BA5D84C06187C59/", 1, 1 },
            toTheHighestBidder1 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603869/5901005F3C640E694572FABE2320DB27019285F8/", 1, 1 },
            toTheHighestBidder2 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603684/8F9B48106FE3B9517589B2309C818862F9D06C1D/", 1, 1 },
            competitiveStudy1 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133602600/7A8F9E67C3383F7C40EBAB2B33CB86031F8E402F/", 1, 1 },
            competitiveStudy2 = { "http://cloud-3.steamusercontent.com/ugc/2488878371133603539/89B52FB52FD9E855C7D8BE12205E9925A4BEAB76/", 1, 1 },
        },
        event = {
            changeOfPlans = { "http://cloud-3.steamusercontent.com/ugc/2488878371133605963/095FC496010C59907F3E3F7457DC57433D8BD939/", 1, 1 },
            covertOperation = { "http://cloud-3.steamusercontent.com/ugc/2488878371133604374/99F8211476D8882E452445BDAE4447EE659A8698/", 1, 1 },
            covertOperationReward = { "http://cloud-3.steamusercontent.com/ugc/2488878371133606149/4F515898E7866999F4DD37435D94A13125E93267/", 1, 1 },
            giftOfWater = { "http://cloud-3.steamusercontent.com/ugc/2488878371133605105/69A9152B3C0DC6DC76FAE3A94008151289107031/", 1, 1 },
            desertGift = { "http://cloud-3.steamusercontent.com/ugc/2488878371133605826/7CB69E34EE048D16A3BFF7913E392AEB0DCEC6C2/", 1, 1 },
            guildNegotiation = { "http://cloud-3.steamusercontent.com/ugc/2488878371133605678/51D0668485DE3EAE70B687F29331FD0470145E83/", 1, 1 },
            intriguingGift = { "http://cloud-3.steamusercontent.com/ugc/2488878371133607512/5EE0DE8384E4778B8B70A6613897A2B47CCDE2CE/", 1, 1 },
            testOfLoyalty = { "http://cloud-3.steamusercontent.com/ugc/2488878371133606903/DFEB7C0670D75E7307AF7C1BD6941A5710F63B4D/", 1, 1 },
            beneGesseritTreachery = { "http://cloud-3.steamusercontent.com/ugc/2488878371133608152/5D1B8E37D7B6C7C888AD65603639507F20276ED2/", 1, 1 },
            emperorsTax = { "http://cloud-3.steamusercontent.com/ugc/2488878371133607129/C06E17FFF29E8DBBF85D7738F1D59191790E0334/", 1, 1 },
            fremenExchange = { "http://cloud-3.steamusercontent.com/ugc/2488878371133604551/5892F8D10C622D85C62B7010CE36F8E67BC51E02/", 1, 1 },
            politicalEquilibrium = { "http://cloud-3.steamusercontent.com/ugc/2488878371133606383/69577FA7291D25BF0CF68B9ED3B9CCAC7051BFC2/", 1, 1 },
            waterForSpiceSmugglers = { "http://cloud-3.steamusercontent.com/ugc/2488878371133607724/58CC591E25E2F4C3404CB4310394BC37D9334D11/", 1, 1 },
            rotationgDoors = { "http://cloud-3.steamusercontent.com/ugc/2488878371133607347/CDA4044F9F38C5AD1D17C0C7437E879E61B57059/", 1, 1 },
            secretsForSale = { "http://cloud-3.steamusercontent.com/ugc/2488878371133604011/7D1F9302858882EE7A1980BAD4DD2C1980B91215/", 1, 1 },
            noComingBack = { "http://cloud-3.steamusercontent.com/ugc/2488878371133607913/236D806E8A5B9B943B1F7E01BC37644921B064AB/", 1, 1 },
            tapIntoSpiceReserves = { "http://cloud-3.steamusercontent.com/ugc/2488878371133605252/07F7EA8B9B3C6641847A1E03A2BE0BE076553A51/", 1, 1 },
            getBackInTheGoodGraces = { "http://cloud-3.steamusercontent.com/ugc/2488878371133606749/B2F82AEC2D3EFC2855E035653C998C5DC4F302D2/", 1, 1 },
            treachery = { "http://cloud-3.steamusercontent.com/ugc/2488878371133605491/63CF6C40B08EB44793C699112DC3F722A2512085/", 1, 1 },
            newInnovations = { "http://cloud-3.steamusercontent.com/ugc/2488878371133604729/EB1D1100B923F7FB0126314B693B941BD652BEAF/", 1, 1 },
            offWordOperation = { "http://cloud-3.steamusercontent.com/ugc/2488878371133604177/85D8885DDB7CFAF791E69F414975E7483EF9C8A8/", 1, 1 },
            offWordOperationReward = { "http://cloud-3.steamusercontent.com/ugc/2488878371133604925/79790D0CA5F55D9AA802CCA504223295034CB5FE/", 1, 1 },
            ceaseAndDesistRequest = { "http://cloud-3.steamusercontent.com/ugc/2488878371133606592/92AE163525F91F672B4A13DB175CF453CB7D9E1E/", 1, 1 },
        },
        mission = {
            secretsInTheDesert = { "http://cloud-3.steamusercontent.com/ugc/2488878371133609339/F90746EC8C7E2025CE04B2A1D5E6176E4A913254/", 1, 1 },
            stationedSupport = { "http://cloud-3.steamusercontent.com/ugc/2488878371133610003/1CDA34747EE9FD2937CF1DCF960478F6A179A96D/", 1, 1 },
            secretsInTheDesert_immortality = { "http://cloud-3.steamusercontent.com/ugc/2488878371133612176/9A3D529D36E4F125BA3DC6D88CE849EBD9BEF40A/", 1, 1 },
            stationedSupport_immortality = { "http://cloud-3.steamusercontent.com/ugc/2488878371133611104/1B31F6F097D6057948E82BFAC15355C90432A311/", 1, 1 },
            geneticResearch = { "http://cloud-3.steamusercontent.com/ugc/2488878371133608964/6F312387525E60BED13B71E10757045D14B93F76/", 1, 1 },
            guildManipulations = { "http://cloud-3.steamusercontent.com/ugc/2488878371133610374/3E560A1E8D7D99EBE8C8711CB7812492590C953C/", 1, 1 },
            spiceIncentive = { "http://cloud-3.steamusercontent.com/ugc/2488878371133611787/D0B774822EE0CCCB032DC9B57BF7EFB199A116CA/", 1, 1 },
            strongarmedAlliance = { "http://cloud-3.steamusercontent.com/ugc/2488878371133608773/768796FE3D06DAA11955D5FF91D38EB76151B8EB/", 1, 1 },
            saphoJuice = { "http://cloud-3.steamusercontent.com/ugc/2488878371133609154/94F6C934FF41366B5600EA166717E82E2DEEC2FF/", 1, 1 },
            spaceTravelDeal = { "http://cloud-3.steamusercontent.com/ugc/2488878371133609829/3B1CA18A133799F335F66899E12A21B7963E41CB/", 1, 1 },
            armedEscort = { "http://cloud-3.steamusercontent.com/ugc/2488878371133611609/E8A3B5CFCF2F1CDD30C5CB6B7145E2E358C5B608/", 1, 1 },
            secretStash = { "http://cloud-3.steamusercontent.com/ugc/2488878371133611973/26652FA770CB303BC0C43AC6C9FA869B681D2DBF/", 1, 1 },
            stowaway = { "http://cloud-3.steamusercontent.com/ugc/2488878371133610171/58AB8846F503BCC0F1931EA9C9CB9613BFB2EF01/", 1, 1 },
            backstageAgreement = { "http://cloud-3.steamusercontent.com/ugc/2488878371133609486/68674FFD485956CFC3A803CD854BD97AE16EB4FB/", 1, 1 },
            coordinationWithTheEmperor = { "http://cloud-3.steamusercontent.com/ugc/2488878371133610611/642A795F33F35DC662D73536A9E27D2067875B65/", 1, 1 },
            sponsoredResearch = { "http://cloud-3.steamusercontent.com/ugc/2488878371133611451/D0969541E9391570AE70C72B75D2AE8EFE7A5818/", 1, 1 },
            tleilaxuOffering = { "http://cloud-3.steamusercontent.com/ugc/2488878371133609663/4FAC1C1E5D15FE6C814D6F48EE5124EA7C98A66F/", 1, 1 },
        },
        sale = {
            fremenMercenaries = { "http://cloud-3.steamusercontent.com/ugc/2488878371133608326/46AD72BB93A35A122778BB78BDCDD922490E24D2/", 1, 1 },
            revealTheFuture = { "http://cloud-3.steamusercontent.com/ugc/2488878371133608654/243F6620B8960AC7DBB0571BF72437729A7B3B6E/", 1, 1 },
            sooSooSookWaterPeddlers = { "http://cloud-3.steamusercontent.com/ugc/2488878371133608479/C6C6AD8F57D00FD1B6AA07606962D6DEB63E8B52/", 1, 1 },
        }
    }
}

---
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

---
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
        leaders = {},
        arrakeenScouts = {},
    }

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

    Deck.load(loader, cards.special, "imperium", "imperiumFoldedSpace", 1, {
        "foldspace",
        -- +5
    })
    Deck.load(loader, cards.special, "imperium", "imperiumArrakisLiasion", 1, {
        "arrakisLiaison",
        -- +7
    })
    Deck.load(loader, cards.special, "imperium", "imperiumTheSpiceMustFlow", 1, {
        "theSpiceMustFlow",
        -- +9
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
        "arrakeen1p",
        "arrakeen2p",
        "carthag",
        "conspire",
        "foldspace",
        "hallOfOratory",
        "hardyWarriors",
        "heighliner",
        "rallyTroops",
        "secrets",
        "selectiveBreeding",
        "stillsuits",
        "wealth",
        "harvestSpice",
        "reshuffle",
        "dreadnought1p",
        "dreadnought2p",
        "foldspaceAndInterstellarShipping",
        "interstellarShipping",
        "smugglingAndInterstellarShipping",
        "techNegotiation",
        "carthag1",
        "carthag2",
        "carthag3",
        "researchStation",
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
    for leaderName, _ in pairs(Deck.fanmadeLeader.arkhane) do
        Deck.loadWithSubCategory(loader, cards.leaders, "fanmadeLeader", "arkhane", leaderName, 1, { leaderName })
    end
    for leaderName, _ in pairs(Deck.fanmadeLeader.retienne) do
        Deck.loadWithSubCategory(loader, cards.leaders, "fanmadeLeader", "retienne", leaderName, 1, { leaderName })
    end

    for category, cardNames in pairs(Deck.arrakeenScouts) do
        if category ~= "committee" then
            for cardName, _ in pairs(cardNames) do
                Deck.loadWithSubCategory(loader, cards.arrakeenScouts, "arrakeenScouts", category, cardName, 1, { cardName })
            end
        end
    end

    return cards
end

return Deck
