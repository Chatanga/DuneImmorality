local Helper = require("utils.Helper")

local Deck = {
    imperium = {
        -- starter without dune planet
        starter = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141323392/D25AA65312D89EB7CEED36D451618E731A674BED/", 4, 2 },
        -- dune planet
        starterDunePlanet = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141327771/98F5861E28F3167495D3F2890879072BF3A84E60/", 2, 2 },
        -- base without foldspace, nor liasion, nor the spice must flow, but with Jessica of Arrakis and Duncan Loyal Blade
        imperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141321326/CC2D301CA075930201B3883D82F4C6E1A0837273/", 10, 7 },
        imperiumFoldedSpace = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141324507/AE481C2ED19B085E2669F22420FD282982FD11A9/", 3, 2 },
        imperiumArrakisLiasion = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141323769/D7411DB495E6EB13D6B64F5E46CCF69FF322039F/", 4, 2 },
        imperiumTheSpiceMustFlow = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141326034/B6E08F8328DB699C60A8F058E88AA6443BA2F716/", 5, 2 },
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
        -- bloodlines
        bloodlinesImperium = { "https://steamusercontent-a.akamaihd.net/ugc/10166314864823293398/62EEBDDBDD7A8704B044EB7122D5ED946D94CEA1/", 7, 3 },
        bloodlinesImperium_tech = { "https://steamusercontent-a.akamaihd.net/ugc/17867477410729571686/90705D6CE1BCF274DC3AE7787016B466B39C444E/", 1, 1 },
        bloodlinesImperium_ruthlessLeadership = { "https://steamusercontent-a.akamaihd.net/ugc/14005282797966134205/C9125CBE5DC6E0DD79BACC7E05BBF8E256C54D50/", 1, 1 },
        bloodlinesImperium_pivotalGambit = { "https://steamusercontent-a.akamaihd.net/ugc/10189719710396123112/056E8D8881987DC9EDBB1FB594E0C7CA2FC3D3E8/", 1, 1 },
    },
    intrigue = {
        intrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342723/13659DD01D152A8B8055B894B247CB1D254D3752/", 8, 5 },
        ixIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342152/3D33B3E59811CEDC64A53F104D31190E76676C64/", 5, 4 },
        immortalityIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141343779/83BA634F05FC7A14933153A18B7AEF83E07E3C14/", 6, 3 },
        bloodlinesIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/17374972601723332052/704778C880E1CCD94CE62C83B3004011EA6F82B6/", 5, 3 },
        bloodlinesIntrigue_tech = { "https://steamusercontent-a.akamaihd.net/ugc/13582135019322065262/A4C68CE55ED39A1E7B5D0E2EB60BD9AA0E5AC51B/", 2, 1 },
        bloodlinesIntrigue_twisted = { "https://steamusercontent-a.akamaihd.net/ugc/11829347407672977389/AE95793B64E08D865B24CA161D262FC17D26CAFC/", 4, 3 },
    },
    conflict1 = {
        conflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365474/F1C0913A589ADB0A0532DFB8FAA7E9D7942CF6CB/", 3, 2 },
        bloodlinesConflict = { "https://steamusercontent-a.akamaihd.net/ugc/14024931574950023473/9F2F922E391CFEC0BDA61334ACC6A15C1BF54F51/", 1, 1 },
    },
    conflict2 = {
        conflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365792/B1CD3F41933A9DD44522934B5F6CF3C5FF77A51C/", 6, 2 },
        bloodlinesConflict = { "https://steamusercontent-a.akamaihd.net/ugc/11811013448727779607/5B7B37F2C607D06B8A3A8C8D1630A064B32FFF17/", 1, 1 },
    },
    conflict3 = {
        conflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365294/F1BEAE6266E75B7A2F5DE511DB4FEB25A2CD486B/", 3, 2 },
    },
    hagal = {
        base = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141457426/1BC00878E1A3E3B3007D0B30A33EE0E09D343ABE/", 5, 5 },
        bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/14535624094719879014/4E6E7D0438D6C695FB460CDE4978A9222F75A46A/", 2, 1 },
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
        --bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/10973288923341663054/234258C6F169769056E00EB7EF0DC28C7B8D1BB6/", 3, 6 },
        forbiddenWeapons = { "https://steamusercontent-a.akamaihd.net/ugc/16549886529912961809/706C717BFDE2EA9891327761BE5B5B1D1CA40CD4/", 1, 1 },
        servoReceivers = { "https://steamusercontent-a.akamaihd.net/ugc/17243030170230690229/ED105B4406B9930D8AF32B8107A9185F4D7973D9/", 1, 1 },
        sardaukarHighCommand = { "https://steamusercontent-a.akamaihd.net/ugc/15404490943906426113/5859AA96D10B1AC49C932D82687FA8DC8C07DE82/", 1, 1 },
        glowglobes = { "https://steamusercontent-a.akamaihd.net/ugc/12218741996139093793/16A506EC1607EF2836A17BBD376D60286BE5F538/", 1, 1 },
        selfDestroyingMessages = { "https://steamusercontent-a.akamaihd.net/ugc/12010308893796325591/78672DA386D9319DF39C850DB0604B7B7437306F/", 1, 1 },
        navigationChamber = { "https://steamusercontent-a.akamaihd.net/ugc/14379456237042162477/FBDCBECE7701277FC1F8D89BF426809710ACD9DA/", 1, 1 },
        rapidDropships = { "https://steamusercontent-a.akamaihd.net/ugc/12008710218412142224/9EE7F1D0A1CB6C5A3EDD2D90EE5F9AD541E1D638/", 1, 1 },
        plasteelBlades = { "https://steamusercontent-a.akamaihd.net/ugc/10402746974692940988/4F2DD6E5C465534998FE67A56B2E95283A4755E0/", 1, 1 },
        deliveryBay = { "https://steamusercontent-a.akamaihd.net/ugc/13612933406762869906/257BBF8B69D85ECC65B745ACC219E4C6426D0BE8/", 1, 1 },
        trainingDepot = { "https://steamusercontent-a.akamaihd.net/ugc/16840498883514018480/8FBE72F803A53B0A52DA2BCA215FA420CCC7394A/", 1, 1 },
        planetaryArray = { "https://steamusercontent-a.akamaihd.net/ugc/17918227540999801434/06C812467EAACD025C549578BEF04FFDB2185A1F/", 1, 1 },
        geneLockedVault = { "https://steamusercontent-a.akamaihd.net/ugc/12874275231044371573/D8E5B09CD439544AAE932053824C7C6F0C890007/", 1, 1 },
        suspensorSuits = { "https://steamusercontent-a.akamaihd.net/ugc/10488773375535060474/ABF074D1A47823451BDEE6F3F927D594C3D3239A/", 1, 1 },
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
        -- bloodlines
        chani = { "https://steamusercontent-a.akamaihd.net/ugc/13842380678639370326/5C69E12794AF4A94C6ED57290B516B6DC76A1FE1/", 1, 1 },
        duncanIdaho = { "https://steamusercontent-a.akamaihd.net/ugc/13463505432383320270/54FF9A593B9870E13BC8FEF9A18AAA9274E19CBA/", 1, 1 },
        esmarTuek = { "https://steamusercontent-a.akamaihd.net/ugc/11801598958949432845/2556AC0AA102406DCA21A5863AEEE6AA5C75B58F/", 1, 1 },
        piterDeVries = { "https://steamusercontent-a.akamaihd.net/ugc/17567283454269405550/FCA10C6D65F2B37ADE44352A951699B40E8DEC84/", 1, 1 },
        yrkoon = { "https://steamusercontent-a.akamaihd.net/ugc/16706684599292593176/FE470F75A1D0421D6676CF3C902A80632D0F7D7C/", 1, 1 }, -- https://steamusercontent-a.akamaihd.net/ugc/14712941862459164791/B41729A898A2C0DED359E8AC96684D7A29B324E2/
        kotaOdax = { "https://steamusercontent-a.akamaihd.net/ugc/13303538665422276008/E8F6F995587AA4C462C1BB5EBFB7CB115956CB08/", 1, 1 },
    },
    fanmadeLeader = {
        arkhaneAbulurdHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141386629/40B8A2B4F6F5DA9A0C2D7738A3F5BFD925167438/", 1, 1 },
        arkhaneXavierHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141388874/43E90624D39B5A904FF112BD5A0B7C3D8AA21502/", 1, 1 },
        arkhaneFeydRauthaHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141388733/D80761B2286A313A11939E3D45DEBCF24F7D30CC/", 1, 1 },
        arkhaneHasimirFenring = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141387204/3657671646912D7026E790B8DE187B49975CBD0E/", 1, 1 },
        arkhaneMargotFenring = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141386481/1964022795283817F32D219C1C38050A9B5303AD/", 1, 1 },
        arkhaneLietKynes = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141386752/DC956CB7ACBD2370DC3D86484765E413F36DBBFF/", 1, 1 },
        arkhaneHwiNoree = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389416/D3BB757794FCB5B9CF5D58798A697B354BD34EEA/", 1, 1 },
        arkhaneMetulli = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389269/09663A73D24AF2DB6A9315D87C5953614C0B0F32/", 1, 1 },
        arkhaneMilesTeg = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389726/299ECFBED3CD8F16774C5C69F8A957768CBBB66D/", 1, 1 },
        arkhaneNormaCenvas = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141388576/4E8FC979A8689926A3A02EA748F402E7D76570BA/", 1, 1 },
        arkhaneIrulanCorrino = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141387844/4C33FE97C3EFCABF776DF966B59D2AF15401D07E/", 1, 1 },
        arkhaneWencisiaCorrino = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141387530/C3D5184AD0F809A3F1F38BB16096AF5DD4437FA5/", 1, 1 },
        arkhaneVorianAtreides = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141386335/DFDB8318608D8F7B39273B40EBB4120FCEE56B3E/", 1, 1 },
        arkhaneSerenaButler = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141387691/C4934E0587D33E2F1BB051D746A7EB30D2A6DEA7/", 1, 1 },
        arkhaneWhitmoreBluud = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141386193/FEB8F943C50DFB711640347C6397243D71F9780A/", 1, 1 },
        arkhaneExecutrixOrdos = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141388228/69C591C92ED7FBA903ECDAD9C2CCC2B99EBBC5B0/", 1, 1 },
        arkhaneTorgTheYoung = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141387038/66DCBBE36459C57FD8F631D8576F2CF01DFDC092/", 1, 1 },
        arkhaneTwylwythWaff = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141386910/A7741DFFE841114BDDB8B6F8A2A57D2C59CDDEEB/", 1, 1 },
        arkhaneScytale = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389573/BFA284BBABA15A609401208F4D834FE916EA960E/", 1, 1 },
        arkhaneStabanTuek = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141388403/1FCB42B17A8F7F711758BF5869CD3B7328E4542F/", 1, 1 },
        arkhaneEsmarTuek = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141388021/EDAF5084889AA22C19B915DFADDFEADAB97F440F/", 1, 1 },
        arkhaneDrisk = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141387340/2F2F3CF34B2737B7CAEF26433B3ECEE9FE41B3AF/", 1, 1 },
        arkhaneArkhane = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389060/43F98BF29B58C81D6C1FABDC6D166BC0ED122953/", 1, 1 },
        retienneHoratioDelta = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141373239/A5EC6C2D6540C450E5A88250E11177D28C74C1D2/", 1, 1 },
        retienneHoratioFive = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141385834/3993C542CC0A5764E981F03759B7A0AA2623A95E/", 1, 1 },
        retienneSionaAtreides = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141374270/B59925EFADED6E2F319D2DDFF6DBF209DB07BEA7/", 1, 1 },
        retienneAlmaMavisTaraza = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141380076/0500E7617A9853B2BE2F7E7AE791B361218250DC/", 1, 1 },
        retienneDukeJenhaestraDrevMeos = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141372925/B7C33A61A918C6750601B4B781BA88988478DB02/", 1, 1 },
        retienneHoratioPrime = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141383080/5ECF73D730CBC697C45C78D823D5D63EEB8F6717/", 1, 1 },
    },
    arrakeenScouts = {
        committee = {
            appropriations = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133601025/F69DF9C9F34598DC456A51C1996247B0FBF93483/", 1, 1 },
            development = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133601393/D59C1D80B198715305C5D17652E2A174733FD196/", 1, 1 },
            information = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133602002/7BBC97BDD0EE0DD2C53B571875117304ADDA3E8F/", 1, 1 },
            investigation = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133601859/C9604B54BDF9A78B8785166211A91C070824D5F0/", 1, 1 },
            joinForces = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389965/16FD82C4D9424774DE741F231103CDEC17D80B36/", 1, 1 },
            politicalAffairs = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141390450/05E920F75AF0DCEFB5190120D9082D6C9EC4F570/", 1, 1 },
            preparation = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133600884/DD38BE5DC44CE962443EC2EC6867FCE5EC75FA24/", 1, 1 },
            relations = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133601265/E8613A1508F44750D3A1F38076A557D870741D04/", 1, 1 },
            supervision = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133602263/A7276A42FADE5448D77D925C7AA6A3FD1E27DB58/", 1, 1 },
            dataAnalysis = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141390105/DC9FA31A74F63551F7C17E31051757C2272565E3/", 1, 1 },
            developmentProject = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141390264/17CF50CCFA8DBC0724B360A8F99A12099E574EE2/", 1, 1 },
            tleilaxuRelations = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141389850/2D869B2CB2341BA989D90EFA561AC2B169198799/", 1, 1 },
        },
        auction = {
            mentat1 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141391770/F72AA83BB6AB9F2F08941BCDAE3241C00F596EBE/", 1, 1 },
            mentat2 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141391409/4F5C9891DC2471D1C256328D0E38BA796A7621F3/", 1, 1 },
            mercenaries1 = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133603204/8E001F53191201BFF1C53464DE3A1FE63A4815A2/", 1, 1 },
            mercenaries2 = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133603204/8E001F53191201BFF1C53464DE3A1FE63A4815A2/", 1, 1 },
            treachery1 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141391597/E3F630F9688D32DD7F55851E58484019FD469C15/", 1, 1 },
            treachery2 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392348/808827CB65B9DABC4591175D0BA5D84C06187C59/", 1, 1 },
            toTheHighestBidder1 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392184/5901005F3C640E694572FABE2320DB27019285F8/", 1, 1 },
            toTheHighestBidder2 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141390584/8F9B48106FE3B9517589B2309C818862F9D06C1D/", 1, 1 },
            competitiveStudy1 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392006/7A8F9E67C3383F7C40EBAB2B33CB86031F8E402F/", 1, 1 },
            competitiveStudy2 = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141391054/89B52FB52FD9E855C7D8BE12205E9925A4BEAB76/", 1, 1 },
        },
        event = {
            changeOfPlans = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141395879/095FC496010C59907F3E3F7457DC57433D8BD939/", 1, 1 },
            covertOperation = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141394918/99F8211476D8882E452445BDAE4447EE659A8698/", 1, 1 },
            covertOperationReward = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141393107/4F515898E7866999F4DD37435D94A13125E93267/", 1, 1 },
            giftOfWater = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141394636/69A9152B3C0DC6DC76FAE3A94008151289107031/", 1, 1 },
            desertGift = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141395529/7CB69E34EE048D16A3BFF7913E392AEB0DCEC6C2/", 1, 1 },
            guildNegotiation = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141394314/51D0668485DE3EAE70B687F29331FD0470145E83/", 1, 1 },
            intriguingGift = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392486/5EE0DE8384E4778B8B70A6613897A2B47CCDE2CE/", 1, 1 },
            testOfLoyalty = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392786/DFEB7C0670D75E7307AF7C1BD6941A5710F63B4D/", 1, 1 },
            beneGesseritTreachery = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141393746/5D1B8E37D7B6C7C888AD65603639507F20276ED2/", 1, 1 },
            emperorsTax = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392924/C06E17FFF29E8DBBF85D7738F1D59191790E0334/", 1, 1 },
            fremenExchange = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141393472/5892F8D10C622D85C62B7010CE36F8E67BC51E02/", 1, 1 },
            politicalEquilibrium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141395350/69577FA7291D25BF0CF68B9ED3B9CCAC7051BFC2/", 1, 1 },
            waterForSpiceSmugglers = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141393929/58CC591E25E2F4C3404CB4310394BC37D9334D11/", 1, 1 },
            rotationgDoors = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141395679/CDA4044F9F38C5AD1D17C0C7437E879E61B57059/", 1, 1 },
            secretsForSale = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141394763/7D1F9302858882EE7A1980BAD4DD2C1980B91215/", 1, 1 },
            noComingBack = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141393594/236D806E8A5B9B943B1F7E01BC37644921B064AB/", 1, 1 },
            tapIntoSpiceReserves = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141395162/07F7EA8B9B3C6641847A1E03A2BE0BE076553A51/", 1, 1 },
            getBackInTheGoodGraces = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141392628/B2F82AEC2D3EFC2855E035653C998C5DC4F302D2/", 1, 1 },
            treachery = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133605491/63CF6C40B08EB44793C699112DC3F722A2512085/", 1, 1 },
            newInnovations = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141393308/EB1D1100B923F7FB0126314B693B941BD652BEAF/", 1, 1 },
            offWordOperation = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141396560/85D8885DDB7CFAF791E69F414975E7483EF9C8A8/", 1, 1 },
            offWordOperationReward = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141394475/79790D0CA5F55D9AA802CCA504223295034CB5FE/", 1, 1 },
            ceaseAndDesistRequest = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141394135/92AE163525F91F672B4A13DB175CF453CB7D9E1E/", 1, 1 },
        },
        mission = {
            secretsInTheDesert = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141398233/F90746EC8C7E2025CE04B2A1D5E6176E4A913254/", 1, 1 },
            stationedSupport = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399034/1CDA34747EE9FD2937CF1DCF960478F6A179A96D/", 1, 1 },
            secretsInTheDesert_immortality = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399461/9A3D529D36E4F125BA3DC6D88CE849EBD9BEF40A/", 1, 1 },
            stationedSupport_immortality = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141397783/1B31F6F097D6057948E82BFAC15355C90432A311/", 1, 1 },
            geneticResearch = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399973/6F312387525E60BED13B71E10757045D14B93F76/", 1, 1 },
            guildManipulations = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399305/3E560A1E8D7D99EBE8C8711CB7812492590C953C/", 1, 1 },
            spiceIncentive = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399174/D0B774822EE0CCCB032DC9B57BF7EFB199A116CA/", 1, 1 },
            strongarmedAlliance = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141397474/768796FE3D06DAA11955D5FF91D38EB76151B8EB/", 1, 1 },
            saphoJuice = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141398906/94F6C934FF41366B5600EA166717E82E2DEEC2FF/", 1, 1 },
            spaceTravelDeal = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399635/3B1CA18A133799F335F66899E12A21B7963E41CB/", 1, 1 },
            armedEscort = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141398424/E8A3B5CFCF2F1CDD30C5CB6B7145E2E358C5B608/", 1, 1 },
            secretStash = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141400174/26652FA770CB303BC0C43AC6C9FA869B681D2DBF/", 1, 1 },
            stowaway = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133610171/58AB8846F503BCC0F1931EA9C9CB9613BFB2EF01/", 1, 1 },
            backstageAgreement = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141398755/68674FFD485956CFC3A803CD854BD97AE16EB4FB/", 1, 1 },
            coordinationWithTheEmperor = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141398565/642A795F33F35DC662D73536A9E27D2067875B65/", 1, 1 },
            sponsoredResearch = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141397987/D0969541E9391570AE70C72B75D2AE8EFE7A5818/", 1, 1 },
            tleilaxuOffering = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141399815/4FAC1C1E5D15FE6C814D6F48EE5124EA7C98A66F/", 1, 1 },
        },
        sale = {
            fremenMercenaries = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141396804/46AD72BB93A35A122778BB78BDCDD922490E24D2/", 1, 1 },
            revealTheFuture = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141397005/243F6620B8960AC7DBB0571BF72437729A7B3B6E/", 1, 1 },
            sooSooSookWaterPeddlers = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141397220/C6C6AD8F57D00FD1B6AA07606962D6DEB63E8B52/", 1, 1 },
        }
    },
    navigation = {
        bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/14442162264832122569/8F1B004CE8D25A2FCB00B4D60747D3DEB6656898/", 5, 2 },
    },
    sardaukarCommanderSkill = {
        bloodlines = { "https://steamusercontent-a.akamaihd.net/ugc/18064283230023882594/41E082A4120E9D48B130929E9345FC19272373A7/", 4, 2 },
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
        imperium = {},
        special = {},
        tleilaxu = {},
        intrigue = {},
        conflict = {},
        hagal = {},
        tech = {},
        leaders = {},
        arrakeenScouts = {},
        navigation = {},
        sardaukarCommanderSkills = {},
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

    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium", 1, {
        "fremenWarName",
        "sardaukarStandard",
        "quashRebellion",
        "southernFaith",
        "imperialThroneship",
        "possibleFutures",
        "",
        "",
        "",
        "",
        "bombast",
        "",
        "",
        "sandwalk",
        "disruptionTactics",
        "urgentShigawire",
        "commandCenter",
        "engineeredMiracle",
        "iBelieve",
        "litanyAgainstFear",
        "eliteForces",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium_tech", 1, {
        "ixianAmbassador",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium_ruthlessLeadership", 1, {
        "ruthlessLeadership",
    })
    Deck.load(loader, cards.imperium, "imperium", "bloodlinesImperium_pivotalGambit", 1, {
        "pivotalGambit",
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
    Deck.load(loader, cards.intrigue, "intrigue", "bloodlinesIntrigue", 1, {
        "withdrawalAgreement",
        "", -- falseOrders
        "", -- graspArrakis
        "", -- insiderInformation
        "", -- ripplesInTheSand
        "", -- sleeperUnit
        "adaptiveTactics",
        "desertSupport",
        "emperorInvitation",
        "honorGuard",
        "returnTheFavor",
        "sacredPools",
        "seizeProduction",
        "theStrongSurvive",
        "tenuousBound",
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

    Deck.load(loader, cards.hagal, "hagal", "base", 1, {
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
    Deck.load(loader, cards.hagal, "hagal", "bloodlines", 1, {
        "acquireTech",
        "tuekSietch",
    })

    -- One tech per custom deck.
    for techName, _ in pairs(Deck.tech) do
        if techName ~= "bloodlines" then
            Deck.load(loader, cards.tech, "tech", techName, 1, { techName })
        end
    end
    if false then
        -- But a single image for Bloodlines.
        -- (Not the case actually, since we need discrete images for Kota's special UI.)
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
        })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.leader) do
        Deck.load(loader, cards.leaders, "leader", leaderName, 1, { leaderName })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.fanmadeLeader) do
        Deck.load(loader, cards.leaders, "fanmadeLeader", leaderName, 1, { leaderName })
    end

    for category, cardNames in pairs(Deck.arrakeenScouts) do
        if category ~= "committee" then
            for cardName, _ in pairs(cardNames) do
                Deck.loadWithSubCategory(loader, cards.arrakeenScouts, "arrakeenScouts", category, cardName, 1, { cardName })
            end
        end
    end

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
