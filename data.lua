local ADDON_NAME, ns = ...

ns.data = {
    notes = {
        "This is Ravenous, a personal AddOn for tracking World, Dungeon, and Raid Bosses which drop noteworthy loot: mounts, pets, toys, cosmetics, and items (consumables, containers, quest items).",
        "To-Do:",
        "- Bubble the check for Items against Rares up to the Zone so it is not shown if there are no Rares shown.",
        "- More investigation into caching and using SilverDragon.",
        "- Consolidate CreateWindow, CreateZone, CreateRare, and CreateItem into a single function to get rid of the headache of passing down data.",
    },
    expansions = {
        -- {
        --     name = "DRAGONZ",
        --     color = "d12a60",
        -- },
        {
            name = "Shadowlands",
            color = "e5cc80",
        },
        {
            name = "BattleForAzeroth",
            title = "Battle for Azeroth",
            color = "5ca0bf",
        },
        {
            name = "Legion",
            color = "aece49",
        },
        {
            name = "Warlords",
            title = "Warlord of Draenor",
            color = "dba53a",
        },
        {
            name = "Mists",
            title = "Mists of Pandaria",
            color = "72aa98",
        },
        {
            name = "Cataclysm",
            color = "e8660a",
        },
        {
            name = "Wrath",
            title = "Wrath of the Lich King",
            color = "afcae6",
        },
        {
            name = "BurningCrusade",
            title = "Burning Crusade",
            color = "accda8",
        },
        {
            name = "Vanilla",
            color = "fff275",
        },
    },
    tabs = {
        {
            name = "World Rares",
            icon = 1354172,
            expansions = {
                {
                    name = "Shadowlands",
                    zones = {
                        -- {
                        --     -- Zereth Mortis
                        --     id = 1961,
                        --     icon = 3052062,
                        --     faction = 2478,
                        -- },
                        {
                            -- Korthia
                            id = 1961,
                            icon = 3052062,
                            faction = {2470, 2472},
                            currency = {1977, 1931},
                        },
                        {
                            -- The Maw
                            id = 1543,
                            icon = 3743739,
                            faction = 2432,
                            currency = 1767,
                        },
                        {
                            -- Maldraxxus
                            id = 1536,
                            icon = 3257749,
                            faction = 2410,
                        },
                        {
                            -- Revendreth
                            id = 1525,
                            icon = 3257751,
                            faction = {2413, 2439},
                            currency = 1820,
                        },
                        {
                            -- Bastion
                            id = 1533,
                            icon = 3257748,
                            faction = 2407,
                        },
                        {
                            -- Ardenweald
                            id = 1565,
                            icon = 3257750,
                            faction = {2465, 2464},
                        },
                    },
                    rares = {},
                },
                {
                    name = "BattleForAzeroth",
                    zones = {
                        {
                            -- Mechagon
                            id = 1462,
                            icon = 2735924
                        },
                        {
                            -- Nazjatar
                            id = 1355,
                            icon = 3012068,
                            currency = 1721
                        },
                        {
                            -- Arathi Highlands
                            id = 14,
                            icon = 236712
                        },
                        {
                            -- Darkshore
                            id = 62,
                            icon = 236739
                        },
                        {
                            -- Uldum
                            id = 1527,
                            icon = 409550
                        },
                        {
                            -- Vol'dun
                            id = 1195,
                            icon = 2125384
                        },
                    },
                    rares = {},
                },
                {
                    name = "Legion",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Warlords",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Mists",
                    zones = {
                        {
                            -- Valley of the Four Winds
                            id = 376,
                            icon = 618317
                        },
                        {
                            -- The Jade Forest
                            id = 371,
                            icon = 617824
                        },
                        {
                            -- Kun-Lai Summit
                            id = 379,
                            icon = 617832
                        },
                        {
                            -- Krasarang Wilds
                            id = 418,
                            icon = 623769
                        },
                        {
                            -- Vale of Eternal Blossoms
                            id = 390,
                            icon = 618798
                        },
                        {
                            -- Dread Wastes
                            id = 422,
                            icon = 624970
                        },
                        {
                            -- Townlong Steppes
                            id = 388,
                            icon = 618796
                        },
                        {
                            -- Isle of Giants
                            id = 507,
                            icon = 236192
                        },
                        {
                            -- Isle of Thunder
                            id = 504,
                            icon = 136014
                        },
                        {
                            -- Darkmoon Island
                            id = 407,
                            icon = 1100023
                        },
                    },
                    rares = {},
                },
                {
                    name = "Cataclysm",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Wrath",
                    zones = {
                        {
                            -- Borean Tundra
                            id = 114,
                            icon = 236722
                        },
                        {
                            -- Howling Fjord
                            id = 117,
                            icon = 236781
                        },
                        {
                            -- Dragonblight
                            id = 115,
                            icon = 236743
                        },
                        {
                            -- Crystalsong Forest
                            id = 127,
                            icon = 236735
                        },
                        {
                            -- Sholazar Basin
                            id = 119,
                            icon = 236817
                        },
                        {
                            -- Grizzly Hills
                            id = 116,
                            icon = 236766
                        },
                        {
                            -- Zul'Drak
                            id = 121,
                            icon = 236858
                        },
                        {
                            -- Storm Peaks
                            id = 120,
                            icon = 236832
                        },
                        {
                            -- Icecrown
                            id = 118,
                            icon = 236793
                        },
                    },
                    rares = {},
                },
                {
                    name = "BurningCrusade",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Vanilla",
                    zones = {},
                    rares = {},
                },
            },
        },
        {
            name = "Dungeons & Raids",
            icon = 341221,
            expansions = {
                {
                    name = "Shadowlands",
                    zones = {},
                    rares = {},
                },
                {
                    name = "BattleForAzeroth",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Legion",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Warlords",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Mists",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Cataclysm",
                    zones = {
                        {
                            -- Northern Stranglethorn → Zul'Gurub
                            name = "Zul'Gurub",
                            id = 50,
                            icon = 133067,
                        },
                        {
                            -- Uldum → The Vortex Pinnacle / Throne of the Four Winds
                            name = "The Vortex Pinnacle / Throne of the Four Winds",
                            id = 249,
                            icon = 468507,
                        },
                        {
                            -- Mount Hyjal → Firelands
                            name = "Firelands",
                            id = 198,
                            icon = 514278,
                        },
                        {
                            -- Caverns of Time → Dragon Soul
                            name = "Dragon Soul",
                            id = 75,
                            icon = 574788,
                        },
                    },
                    rares = {
                        [52151] = {name="Bloodlord Mandokir",locations={[50]={72003280}},loot={{68823,mount=410}},dungeon=true},
                        [52059] = {name="High Priestess Kilnara",locations={[50]={72003280}},loot={{68824,mount=411}},dungeon=true},
                        [43873] = {name="Altairus",locations={[249]={77008400}},loot={{63040,mount=395}},dungeon=true},
                        [46753] = {name="Al'Akir",locations={[249]={36008400}},loot={{63041,mount=396}},raid=true},
                        [52530] = {name="Alysrazor",locations={[198]={47007700}},loot={{71665,mount=425}},raid=true},
                        [52409] = {name="Ragnaros",locations={[198]={47007700}},loot={{69224,mount=415}},raid=true,chance=2.1},
                        [55294] = {name="Ultraxion",locations={[75]={65005000}},loot={{78919,mount=445}},raid=true},
                        [56173] = {name="Madness of Deathwing",locations={[75]={65005000}},loot={{77067,mount=442},{77069,mount=444}},raid=true,heroic=true},
                    },
                },
                {
                    name = "Wrath",
                    zones = {
                        {
                            -- Storm Peaks → Ulduar
                            name = "Ulduar",
                            id = 120,
                            icon = 254113,
                        },
                        {
                            -- Icecrown → Icecrown Citadel
                            name = "Icecrown Citadel",
                            id = 118,
                            icon = 236793,
                        },
                    },
                    rares = {
                        [33288] = {name="Yogg-Saron",locations={[120]={41001600}},loot={{45693,mount=304,chance=1}},notes={"Must be done on Hard Mode (Alone in the Dark)."},raid=true},
                        [36597] = {name="The Lich King",locations={[118]={54008500}},loot={{50818,mount=363,chance=1}},raid=true,heroic=true},
                    },
                },
                {
                    name = "BurningCrusade",
                    zones = {
                        {
                            -- Deadwind Pass → Karazhan
                            name = "Karazhan",
                            id = 42,
                            icon = 1530372,
                        },
                        {
                            -- Netherstorm → The Eye
                            name = "The Eye",
                            id = 109,
                            icon = 250117,
                        },
                        {
                            -- Terokkar Forest → Sethekk Halls
                            name = "Sethekk Halls",
                            id = 108,
                            icon = 236847,
                        },
                        {
                            -- Isle of Quel-Danas → Magisters' Terrace
                            name = "Magisters' Terrace",
                            id = 122,
                            icon = 236806,
                        },
                    },
                    rares = {
                        [16152] = {name="Attumen the Huntsman",locations={[42]={47007700}},loot={{30480,mount=168,chance=1},},raid=true},
                        [19622] = {name="Kael'thas Sunstrider",locations={[109]={74006500}},loot={{32458,mount=183,chance=1.7}},raid=true},
                        [23035] = {name="Anzu",locations={[108]={44606560}},loot={{32768,mount=185}},dungeon=true,heroic=true},
                        [24664] = {name="Kael'thas Sunstrider",locations={[122]={60903070}},loot={{35513,mount=213}},dungeon=true,heroic=true},
                    },
                },
                {
                    name = "Vanilla",
                    zones = {
                        {
                            -- Eastern Plaguelands, Stratholme
                            name = "Stratholme",
                            id = 22,
                            icon = 134554,
                        },
                        {
                            -- Silithus, Ahn'Qiraj
                            name = "Ahn'Qiraj",
                            id = 81,
                            icon = 236829,
                        },
                    },
                    rares = {
                        [45412] = {name="Lord Aurius Rivendare",locations={[22]={43501930}},loot={{13335,mount=69}},dungeon=true},
                        [999999] = {name="Any Trash Mob",locations={[81]={24308720}},loot={{21218,mount=117},{21323,mount=120},{21324,mount=119},{21321,mount=118}},raid=true},
                    },
                },
            },
        },
        {
            name = "Vendor & Misc.",
            icon = 133014,
            expansions = {
                {
                    name = "Shadowlands",
                    zones = {},
                    rares = {},
                },
                {
                    name = "BattleForAzeroth",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Legion",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Warlords",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Mists",
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
                    },
                },
                {
                    name = "Cataclysm",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Wrath",
                    zones = {},
                    rares = {},
                },
                {
                    name = "BurningCrusade",
                    zones = {},
                    rares = {},
                },
                {
                    name = "Vanilla",
                    zones = {},
                    rares = {},
                },
            },
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
        {
            -- Cataloged Research
            id = 1977,
            color = "8bd8ec",
            icon = 636333,
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

ns.defaults = {
    locked = false,
    minimapButton = true,
    minimapPosition = 0,
    macro = true,
    allowSharing = true,
    showOwned = true,
    showCannotUse = true,
    showMounts = true,
    showPets = true,
    showToys = true,
    showCosmetics = true,
    showItems = true,
    scale = 1,
    windowPosition = "CENTER",
    windowX = 0,
    windowY = 0,
    windowWidth = 420,
    windowHeight = 360,
}
for _, expansion in ipairs(ns.data.expansions) do
    ns.defaults["expansion"..expansion.name] = true
end
