local ADDON_NAME, ns = ...

local function TableConcat(t1, t2)
    for i=1, #t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local SilverDragonData = {}
-- SilverDragonData = TableConcat(SilverDragonData, SilverDragon.datasources["Vanilla"])
-- SilverDragonData = TableConcat(SilverDragonData, SilverDragon.datasources["BurningCrusade"])
SilverDragonData = TableConcat(SilverDragonData, SilverDragon.datasources["Wrath"])
SilverDragonData = TableConcat(SilverDragonData, SilverDragon.datasources["Shadowlands"])

ns.defaults = {
    locked = false,
    macro = true,
    allowSharing = true,
    showOwned = true,
    showCannotUse = true,
    showMounts = true,
    showPets = true,
    showToys = true,
    showCosmetics = true,
    scale = 1,
    windowPosition = "CENTER",
    windowX = 0,
    windowY = 0,
    windowWidth = 420,
    windowHeight = 360,
}

ns.data = {
    notes = {
        "General notes",
    },
    tabs = {
        {
            name = "World Rares",
            icon = 236702,
            zones = {
                {
                    -- Korthia
                    id = 1961,
                    color = "e5cc80",
                    icon = 3052062,
                    currency = 1931,
                    faction = {2470, 2472}
                },
                {
                    -- The Maw
                    id = 1543,
                    color = "e5cc80",
                    icon = 3743739,
                    currency = 1767,
                    faction = 2432
                },
                {
                    -- Maldraxxus
                    id = 1536,
                    color = "40bf40",
                    faction = 2410
                },
                {
                    -- Revendreth
                    id = 1525,
                    color = "ff4040",
                    faction = {2413, 2439},
                    currency = 1820
                },
                {
                    -- Bastion
                    id = 1533,
                    color = "68ccef",
                    faction = 2407
                },
                {
                    -- Ardenweald
                    id = 1565,
                    color = "8b55d7",
                    faction = {2465, 2464}
                },
                {
                    -- Icecrown
                    id = 118,
                    color = "c7fdfe",
                    icon = 236794,
                },
            },
            rares = SilverDragonData,
        },
        {
            name = "Dungeon Bosses",
            icon = 341221,
            zones = {
                {
                    -- Deadwind Pass → Karazhan
                    id = 42,
                    name = "Karazhan",
                    color = "96a3aa",
                    icon = 1530372,
                },
                {
                    -- Netherstorm → The Eye
                    name = "The Eye",
                    id = 109,
                    color = "e96944",
                    icon = 250117,
                },
                {
                    -- Northern Stranglethorn → Zul'Gurub
                    name = "Zul'Gurub",
                    id = 50,
                    color = "a7eb67",
                    icon = 133067,
                },
                {
                    -- Uldum → The Vortex Pinnacle / Throne of the Four Winds
                    name = "The Vortex Pinnacle / Throne of the Four Winds",
                    id = 249,
                    color = "96a3aa",
                    icon = 468507,
                },
                {
                    -- Mount Hyjal → Firelands
                    name = "Firelands",
                    id = 198,
                    color = "f19d4b",
                    icon = 514278,
                },
                {
                    -- Caverns of Time → Dragon Soul
                    name = "Dragon Soul",
                    id = 75,
                    color = "f9d8fc",
                    icon = 574788,
                },
                {
                    -- Storm Peaks → Ulduar
                    name = "Ulduar",
                    id = 120,
                    color = "9ffcfa",
                    icon = 254113,
                },
                {
                    -- Icecrown → Icecrown Citadel
                    name = "Icecrown Citadel",
                    id = 118,
                    color = "c7fdfe",
                    icon = 236793,
                },
            },
            rares = {
                [16152] = {name="Attumen the Huntsman",locations={[42]={47007700}},loot={{30480,mount=168,chance=1},},encounter=2},
                [19622] = {name="Kael'thas Sunstrider",locations={[109]={74006500}},loot={{32458,mount=183,chance=1.7}},encounter=4},
                [52151] = {name="Bloodlord Mandokir",locations={[50]={72003280}},loot={{68823,mount=410}},encounter=2},
                [52059] = {name="High Priestess Kilnara",locations={[50]={72003280}},loot={{68824,mount=411}},encounter=4},
                [43873] = {name="Altairus",locations={[249]={77008400}},loot={{63040,mount=395}},encounter=2},
                [46753] = {name="Al'Akir",locations={[249]={36008400}},loot={{63041,mount=396}},encounter=2},
                [52530] = {name="Alysrazor",locations={[198]={47007700}},loot={{71665,mount=425}},encounter=4},
                [52409] = {name="Ragnaros",locations={[198]={47007700}},loot={{69224,mount=415}},encounter=7},
                [55294] = {name="Ultraxion",locations={[75]={65005000}},loot={{78919,mount=445}},encounter=5},
                [56173] = {name="Deathwing",locations={[75]={65005000}},loot={{77067,mount=442},{77069,mount=444}},encounter=8},
                [33288] = {name="Yogg-Saron",locations={[120]={41001600}},loot={{45693,mount=304,chance=1}},notes={"Must be done on Hard Mode (Alone in the Dark)."},encounter=13},
                [36597] = {name="The Lich King",locations={[118]={54008500}},loot={{50818,mount=363,chance=1}},encounter=12},
            },
        },
    },
    currencies = {
        {
            id = 1721, -- Prismatic Manapearl
            color = "4db3ea",
            icon = 463858,
        },
        {
            id = 1767, -- Stygia
            color = "e5cc80",
            icon = 3743739,
        },
        {
            id = 1820, -- Infused Ruby
            color = "f04c73",
            icon = 133250,
        },
        {
            id = 1931, -- Cataloged Research
            color = "dfd4ad",
            icon = 1506458,
        },
    },
    reputationColors = {
        "cc2222",
        "ff0000",
        "ee6622",
        "ffff00",
        "00ff00",
        "00ff88",
        "00ffcc",
        "00ffff",
        "00ffff",
    },
}
