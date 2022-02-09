local ADDON_NAME, ns = ...

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
        "TODO",
        "- Figure out how to ensure SilverDragon data is ready when I attempt to cache it—C_Timer is the interim solution. It being a dependency in TOC seems to have no bearing on its loading precedence.",
        "- How to get NPC Name from NPC ID\n  - https://authors.curseforge.com/forums/world-of-warcraft/general-chat/lua-code-discussion/226100-how-to-get-the-unitname-with-only-the-npc-id"
    },
    expansions = {
        "Shadowlands",
        "BattleForAzeroth",
        "Legion",
        "Warlords",
        "Mists",
        "Cataclysm",
        "Wrath",
        "BurningCrusade",
        "Vanilla",
    },
    tabs = {
        {
            name = "World Rares",
            icon = 236702,
            zones = {
                -- {
                --     -- Zereth Mortis
                --     id = 1961,
                --     color = "e5cc80",
                --     icon = 3052062,
                --     faction = 2478,
                -- },
                {
                    -- Korthia
                    id = 1961,
                    color = "e5cc80",
                    icon = 3052062,
                    faction = {2470, 2472},
                    currency = 1931,
                },
                {
                    -- The Maw
                    id = 1543,
                    color = "e5cc80",
                    icon = 3743739,
                    faction = 2432,
                    currency = 1767,
                },
                {
                    -- Maldraxxus
                    id = 1536,
                    color = "40bf40",
                    icon = 3257749,
                    faction = 2410,
                },
                {
                    -- Revendreth
                    id = 1525,
                    color = "ff4040",
                    icon = 3257751,
                    faction = {2413, 2439},
                    currency = 1820,
                },
                {
                    -- Bastion
                    id = 1533,
                    color = "68ccef",
                    icon = 3257748,
                    faction = 2407,
                },
                {
                    -- Ardenweald
                    id = 1565,
                    color = "8b55d7",
                    icon = 3257750,
                    faction = {2465, 2464},
                },

                {
                    -- Mechagon
                    id = 1462,
                    color = "dbd9a9",
                    icon = 2735924
                },
                {
                    -- Nazjatar
                    id = 1355,
                    color = "4db3ea",
                    icon = 3012068,
                    currency = 1721
                },
                {
                    -- Arathi Highlands
                    id = 14,
                    color = "f8f1bd",
                    icon = 236712
                },
                {
                    -- Darkshore
                    id = 62,
                    color = "f8f1bd",
                    icon = 236739
                },
                {
                    -- Uldum
                    id = 1527,
                    color = "f8f1bd",
                    icon = 409550
                },
                {
                    -- Vol'dun
                    id = 1195,
                    color = "d28b68",
                    icon = 2125384
                },
                {
                    -- Vale of Eternal Blossoms
                    id = 1530,
                    color = "b8dab6",
                    icon = 618798
                },
                {
                    -- Borean Tundra
                    id = 114,
                    color = "b4d455",
                    icon = 236724
                },
                {
                    -- Howling Fjord
                    id = 117,
                    color = "b4d455",
                    icon = 236782
                },
                {
                    -- Dragonblight
                    id = 115,
                    color = "b4d455",
                    icon = 236744
                },
                {
                    -- Crystalsong Forest
                    id = 127,
                    color = "b45455",
                    icon = 236744
                },
                {
                    -- Sholazar Basin
                    id = 119,
                    color = "b45455",
                    icon = 236744
                },
                {
                    -- Grizzly Hills
                    id = 116,
                    color = "b4d455",
                    icon = 236762
                },
                {
                    -- Zul'Drak
                    id = 121,
                    color = "b4d455",
                    icon = 236856
                },
                {
                    -- Storm Peaks
                    id = 120,
                    color = "9ffcfa",
                    icon = 236834
                },
                {
                    -- Icecrown
                    id = 118,
                    color = "c7fdfe",
                    icon = 236794
                },
                {
                    -- Darkmoon Island
                    id = 407,
                    color = "bc94db",
                    icon = 1100023
                },
            },
            rares = {},
        },
        {
            name = "Dungeon Bosses",
            icon = 341221,
            zones = {
                {
                    -- Eastern Plaguelands, Stratholme
                    name = "Stratholme",
                    id = 22,
                    icon = 134554,
                },
                {
                    -- Deadwind Pass → Karazhan
                    name = "Karazhan",
                    id = 42,
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
                [45412] = {name="Lord Aurius Rivendare",locations={[22]={43501930}},loot={{13335,mount=69}}},

                -- 87777
                -- 93666
                -- 95059
                -- 104253
                -- 116660
                -- 123890
                -- 45412
            },
        },
        {
            name = "Other",
            icon = 133014,
            zones = {
                {
                    -- Darkmoon Island
                    id = 407,
                    color = "bc94db",
                    icon = 1100023,
                    currency = 515,
                },
            },
            rares = {
                [85484] = {name="Chester",locations={[407]={51507500}},loot={{116139,toy=true},116138,122238,116052,116137,116133,116136,116134},vendor=true},
                [14846] = {name="Lhara",locations={[407]={48206950}},loot={{73903,pet=338},{73905,pet=339},{74981,pet=343},{91003,pet=1061},{73764,pet=330},{73765,pet=335}},vendor=true},
                [55305] = {name="Carl Goodup",locations={[407]={49308040}},loot={{73762,pet=336},{164970,pet=2482},{164971,pet=2483},{164969,pet=2484}},vendor=true},
            }
        },
    },
    currencies = {
        {
            -- Darkmoon Prize Ticket
            id = 515,
            color = "ed6966",
            icon = 134481,
        },
        {
            -- Prismatic Manapearl
            id = 1721,
            color = "4db3ea",
            icon = 463858,
        },
        {
            -- Stygia
            id = 1767,
            color = "e5cc80",
            icon = 3743739,
        },
        {
            -- Infused Ruby
            id = 1820,
            color = "f04c73",
            icon = 133250,
        },
        {
            -- Cataloged Research
            id = 1931,
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
    covenants = {
        [1] = {
            name = "Kyrian",
            color = "68ccef",
            icon = 3257748,
            phrase = "Home of the %s",
        },
        [2] = {
            name = "Venthyr",
            color = "ff4040",
            icon = 3257751,
            phrase = "Court of the %s",
        },
        [3] = {
            name = "Night Fae",
            color = "8b55d7",
            icon = 3257750,
            phrase = "Forest of the %s",
        },
        [4] = {
            name = "Necrolord",
            color = "40bf40",
            icon = 3257749,
            phrase = "Citadel of the %s",
        },
    },
    annoyingSounds = {
        3635292, -- sound/creature/mawshade/mon_mawshade_aggro_00_161095.ogg
        3635290, -- sound/creature/mawshade/mon_mawshade_aggro_01_161095.ogg
        3635288, -- sound/creature/mawshade/mon_mawshade_aggro_02_161095.ogg
        3635286, -- sound/creature/mawshade/mon_mawshade_aggro_03_161095.ogg
        3635284, -- sound/creature/mawshade/mon_mawshade_aggro_04_161095.ogg
        3635416, -- sound/creature/mawshade/mon_mawshade_alert_00_161094.ogg
        3635414, -- sound/creature/mawshade/mon_mawshade_alert_01_161094.ogg
        3635412, -- sound/creature/mawshade/mon_mawshade_alert_02_161094.ogg
        3635330, -- sound/creature/mawshade/mon_mawshade_death_00_161100.ogg
        3635328, -- sound/creature/mawshade/mon_mawshade_death_01_161100.ogg
        3635326, -- sound/creature/mawshade/mon_mawshade_death_02_161100.ogg
        3635324, -- sound/creature/mawshade/mon_mawshade_death_03_161100.ogg
        3635322, -- sound/creature/mawshade/mon_mawshade_death_04_161100.ogg
        3635320, -- sound/creature/mawshade/mon_mawshade_death_05_161100.ogg
        3747229, -- sound/creature/mawsworn/mon_mawsworn_loop_01_171773.ogg
        3747231, -- sound/creature/mawsworn/mon_mawsworn_loop_02_171773.ogg
        3747239, -- sound/creature/mawsworn/mon_mawsworn_loop_03_171773.ogg
    },
}
