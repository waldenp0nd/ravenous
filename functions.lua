local ADDON_NAME, ns = ...
local L = ns.L

local notes = ns.data.notes
local tabs = ns.data.tabs
local currencies = ns.data.currencies
local reputationColors = ns.data.reputationColors

local small = 6
local medium = 12
local large = 16
local gigantic = 24

local _, class = UnitClass("player")
local covenant = C_Covenants.GetActiveCovenantID()
local faction, _ = UnitFactionGroup("player")
local factionCity = (faction == "Alliance" and "Stormwind" or "Orgrimmar")

local CQL = C_QuestLog

---
-- Local Functions
---

local function commaValue(amount)
    local formatted, i = amount
    while true do
        formatted, i = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if i == 0 then
            break
        end
    end
    return formatted
end

local function contains(table, input)
    for index, value in ipairs(table) do
        if value == input then
            return index
        end
    end
    return false
end

local function HideTooltip()
    GameTooltip:Hide()
end

local function TextColor(text, color)
    color = color and color or "eeeeee"
    return "|cff" .. color .. text .. "|r"
end

local function TextIcon(icon, size)
    size = size and size or 16
    return "|T" .. icon .. ":" .. size .. "|t"
end

local icons = {
    ["Quest"] = TextIcon(132049),
    ["QuestTurnin"] = TextIcon(132048),
    ["QuestIncomplete"] = TextIcon(365195),
    ["Daily"] = TextIcon(368364),
    ["DailyTurnin"] = TextIcon(368577),
    ["LegendaryQuest"] = TextIcon(646980),
    ["LegendaryQuestTurnin"] = TextIcon(646979),
    ["Achievement"] = TextIcon(235415, 20),
    ["Checkmark"] = TextIcon(628564),
    ["Skull"] = TextIcon(137025),
    ["Vendor"] = TextIcon(136452),
    ["Dungeon"] = TextIcon(1502543, 20),
    ["Raid"] = TextIcon(1502548, 20),
}

local function IsLead()
    local name = UnitName("player")
    local fullName = string.format("%1$s-%2$s", name, GetNormalizedRealmName())
    for i = 1, MAX_RAID_MEMBERS do
        local lookup, rank, _ = GetRaidRosterInfo(i)
        if lookup == name or lookup == fullName then
            if rank > 1 then
                return true
            end
        end
    end
    return false
end

local function IsRareDead(rare)
    if type(rare.quest) == "table" then
        -- Faction-check
        if rare.quest[faction:lower()] then
            return CQL.IsQuestFlaggedCompleted(rare.quest[faction:lower()])
        end
        -- Any quest returns true
        if rare.quest.any then
            for _, quest in ipairs(rare.quest) do
                if type(quest) == "number" and CQL.IsQuestFlaggedCompleted(quest) == true then
                    return true
                end
            end
            return false
        end
        -- All quests return true
        for _, quest in ipairs(rare.quest) do
            return CQL.IsQuestFlaggedCompleted(quest)
        end
        return true
    elseif rare.quest then
        return CQL.IsQuestFlaggedCompleted(rare.quest)
    elseif rare.dungeon or rare.raid then
        for i = 1, GetNumSavedInstances(), 1 do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled = GetSavedInstanceInfo(i)
            if rare.heroic == nil or (rare.heroic and string.match(difficultyName:upper(), "HEROIC")) then
                for encounter = 1, numEncounters do
                    local bossName, fileDataID, isKilled, _ = GetSavedInstanceEncounterInfo(i, encounter)
                    if bossName == rare.name then
                        return (locked and isKilled)
                    end
                end
            end
        end
    end
    return false
end

local function GetItemID(item)
    return type(item) == "table" and item[1] or item
end

local function IsItemOwned(item)
    if item.mount then
        return select(11, C_MountJournal.GetMountInfoByID(item.mount))
    elseif item.pet then
        return C_PetJournal.GetNumCollectedInfo(item.pet) > 0
    elseif item.toy then
        return PlayerHasToy(GetItemID(item))
    elseif item.quest then
        return CQL.IsQuestFlaggedCompleted(item.quest)
    elseif item.achievement then
        return select(4, GetAchievementInfo(item.achievement))
    else
        return C_TransmogCollection.PlayerHasTransmog(GetItemID(item))
    end
    return false
end

local function RunsUntilDrop(chance, reasonable, bound)
    reasonable = reasonable and math.max(1, math.min(99, reasonable)) or 95
    bound = bound and math.max(1, math.min(1000, bound)) or 300
    for i = 1, bound do
        local percentage = 1 - ((1 - chance / 100) ^ i)
        if percentage > (reasonable / 100) then
            return i
        end
    end
    return bound
end

local function GetCurrencyData(id)
    for _, currency in ipairs(currencies) do
        if id == currency.id then return currency end
    end
end

local function GetCoordinates(rare)
    local waypoint
    for _, waypoints in pairs(rare.locations) do
        if not waypoints[1] then
            return nil
        end
        waypoint = waypoints[1]
        break
    end
    local coordinates = {}
    for n in tostring(waypoint):gmatch("[0-9][0-9]") do
        tinsert(coordinates, n)
    end
    return coordinates
end

local function GetZoneData(expansion, rare)
    for zoneID, _ in pairs(rare.locations) do
        for _, zone in ipairs(expansion.zones) do
            if zoneID == zone.id then
                return zone
            end
        end
    end
    return nil
end

local cache_tooltip = CreateFrame("GameTooltip", "RavenousCacheTooltip", _G.UIParent, "GameTooltipTemplate")
cache_tooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
local function TextFromHyperlink(link)
    cache_tooltip:ClearLines()
    cache_tooltip:SetHyperlink(link)
    local text = RavenousCacheTooltipTextLeft1:GetText()
    if text and text ~= "" and text ~= UNKNOWN then
        return text
    end
end
local function RenderString(s)
    if type(s) == "function" then s = s() end
	return string.gsub(s, "{(%l+):(%d+):?([^}]*)}", function(variant, id, fallback)
		id = math.floor(id)
		if variant == "item" then
			local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(id)
			if link and icon then
				return TextIcon(icon) .. link
			end
		elseif variant == "spell" then
			local name, _, icon = GetSpellInfo(id)
			if name and icon then
				return TextIcon(icon) .. name
			end
		elseif variant == "quest" then
			local name = C_QuestLog.GetTitleForQuestID(id)
			if not (name and name ~= "") then
				name = tostring(id)
			end
			local completed = C_QuestLog.IsQuestFlaggedCompleted(id)
			return CreateAtlasMarkup("questnormal") .. TextColor(name, completed and "00ff00" or "ff0000")
        elseif variant == "npc" then
            local name = TextFromHyperlink(("unit:Creature-0-0-0-0-%d"):format(id))
			if name and name ~= UNKNOWNOBJECT then
                return name
            end
		-- elseif variant == "questid" then
		-- 	return CreateAtlasMarkup("questnormal") .. (C_QuestLog.IsQuestFlaggedCompleted(id) and "00ff00" or "ff0000"):WrapTextInColorCode(id)
		-- elseif variant == "npc" then
		-- 	local name = self:NameForMob(id)
		-- 	if name then
		-- 		return name
		-- 	end
		-- elseif variant == "currency" then
		-- 	local info = C_CurrencyInfo.GetCurrencyInfo(id)
		-- 	if info then
		-- 		return quick_texture_markup(info.iconFileID) .. info.name
		-- 	end
		end
		return fallback ~= "" and fallback or (variant .. ':' .. id)
	end)
end

---
-- Global Functions
---

function ns:PrettyPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. ns.name .. ":|r " .. message)
end

local hasSeenNoSpaceMessage = false
function ns:EnsureMacro()
    if not UnitAffectingCombat("player") and RAVENOUS_data.options.macro then
        local body = "/" .. ns.command
        local numberOfMacros, _ = GetNumMacros()
        if GetMacroIndexByName(ns.name) > 0 then
            EditMacro(GetMacroIndexByName(ns.name), ns.name, ns.icon, body)
        elseif numberOfMacros < 120 then
            CreateMacro(ns.name, ns.icon, body)
        elseif not hasSeenNoSpaceMessage then
            hasSeenNoSpaceMessage = true
            ns:PrettyPrint(L.NoMacroSpace)
        end
    end
end

function ns:ToggleWindow(frame, force)
    if frame == nil then
        ns:PrettyPrint(_G.LFG_LIST_LOADING)
        ns.waitingForWindow = true
        return
    end
    if (frame:IsVisible() and force ~= "Show") or force == "Hide" then
        UIFrameFadeOut(frame, 0.1, 1, 0)
        C_Timer.After(0.1, function()
            frame:Hide()
        end)
    else
        UIFrameFadeIn(frame, 0.1, 0, 1)
        C_Timer.After(0.1, function()
            frame:Show()
        end)
    end
end

---
-- Data Management
---

local function Register(Key, Value)
    if not Key or not Value then return end
    ns[Key] = ns[Key] or {}
    table.insert(ns[Key], Value)
end

function ns:RefreshCurrencies()
    for _, Currency in ipairs(ns.Currencies) do
        local currency = C_CurrencyInfo.GetCurrencyInfo(Currency.currency.id)
        local quantity = currency.discovered and currency.quantity or 0
        local max = currency.useTotalEarnedForMaxQty and commaValue(currency.maxQuantity - currency.totalEarned + quantity) or commaValue(currency.maxQuantity)
        local add = Currency.add and Currency.add() or 0
        Currency:SetText(TextColor(commaValue(quantity + add) .. (currency.maxQuantity >= currency.quantity and "/" .. max or ""), "ffffff") .. " " .. TextColor(currency.name, Currency.currency.color or "ffffff") .. " " .. TextIcon(currency.iconFileID))
    end
end

function ns:RefreshFactions()
    for _, Faction in ipairs(ns.Factions) do
        local factionName, _, standingID, reputationMin, reputationMax, reputation, _, _, _, _, hasRep, _, _, _, hasBonusRepGain, _ = GetFactionInfoByID(Faction.faction)
        Faction:SetText(TextColor(string.format(L.Faction, TextColor(_G["FACTION_STANDING_LABEL"..standingID], reputationColors[standingID]), TextColor(factionName, Faction.color and Faction.color or "ffffff")), "bbbbbb"))
        Faction.anchor:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM", 0, -small)
            GameTooltip:SetText(TextColor("Reputation with ") .. TextColor(factionName, Faction.color and Faction.color or "ffffff"))
            GameTooltip:AddLine(TextColor(_G["FACTION_STANDING_LABEL"..standingID], reputationColors[standingID]))
            if reputation < reputationMax then
                GameTooltip:AddLine(commaValue(reputation - reputationMin) .. "/" .. commaValue(reputationMax - reputationMin))
            end
            GameTooltip:Show()
        end)
        Faction.anchor:SetScript("OnLeave", HideTooltip)
    end
end

function ns:RefreshRares()
    for _, Rare in ipairs(ns.Rares) do
        local without = Rare:GetText()
        for _, icon in pairs(icons) do
            without = string.gsub(without, icon, "")
        end
        Rare.rare.quest = Rare.rare.quest or (faction == "Alliance" and (Rare.rare.questAlliance or nil) or (Rare.rare.questHorde or nil))
        Rare:SetText((IsRareDead(Rare.rare) and icons.Checkmark or ((type(Rare.rare.quest) == "number" and CQL.IsWorldQuest(Rare.rare.quest))) and icons.LegendaryQuest or (Rare.rare.biweekly or Rare.rare.weekly or Rare.rare.fortnightly) and icons.Daily or Rare.rare.achievement and icons.Achievement or Rare.rare.vendor and icons.Vendor or Rare.rare.dungeon and icons.Dungeon or Rare.rare.raid and icons.Raid or icons.Skull) .. without)
    end
end

function ns:RefreshItems()
    for _, Item in ipairs(ns.Items) do
        local without = Item:GetText()
        for _, icon in pairs(icons) do
            without = string.gsub(without, icon, "")
        end
        Item:SetText(without .. (IsItemOwned(Item.item) and icons.Checkmark or ""))
    end
end

---
-- Item Cache Preloader
---

local function CacheItem(i, itemIDs, callback)
    local Item = Item:CreateFromItemID(itemIDs[i])
    if i < #itemIDs then
        -- Sadly this *must* be rate-limited
        -- 0 = per frame, as fast as we can go
        Item:ContinueOnItemLoad(function()
            C_Timer.After(0, function()
                CacheItem(i + 1, itemIDs, callback)
            end)
        end)
    else
        callback()
    end
end

function ns:CacheAndBuild(callback)
    local worldQuests = {}
    if CQL.GetNumWorldQuestWatches() then
        for i = 1, CQL.GetNumWorldQuestWatches() do
            tinsert(worldQuests, CQL.GetQuestIDForWorldQuestWatchIndex(i))
        end
    end
    local itemIDs = {}
    for _, tab in ipairs(tabs) do
        for _, expansion in ipairs(tab.expansions) do
            for _, rare in pairs(expansion.rares) do
                local isWorldQuest, isAvailable = false, false
                rare.quest = rare.quest or (faction == "Alliance" and (rare.questAlliance or nil) or (rare.questHorde or nil))
                if type(rare.quest) == "number" then
                    if CQL.IsWorldQuest(rare.quest) or rare.worldquest then
                        isWorldQuest = true
                        if contains(worldQuests, rare.quest) or CQL.IsQuestFlaggedCompleted(rare.quest) then
                            isAvailable = true
                        elseif CQL.AddWorldQuestWatch(rare.quest) then
                            isAvailable = true
                            CQL.RemoveWorldQuestWatch(rare.quest)
                        end
                    else
                        isAvailable = CQL.IsQuestFlaggedCompleted(rare.quest) and false or true
                    end
                end
                if rare.hidden or rare.loot == nil or #rare.loot == 0 then
                elseif isWorldQuest and not isAvailable then
                else
                    for _, item in ipairs(rare.loot) do
                        item = type(item) == "table" and item or {item}
                        local itemType, itemSubType, _ = select(6, GetItemInfo(GetItemID(item)))
                        if itemType ~= nil then
                            if item.mount == nil and item.pet == nil and item.toy == nil and itemSubType ~= "Cosmetic" and itemType ~= "Consumable" and itemType ~= "Container" and itemType ~= "Questitem" then
                            elseif RAVENOUS_data.options.showOwned == false and IsItemOwned(item) then
                            elseif RAVENOUS_data.options.showMounts == false and item.mount then
                            elseif RAVENOUS_data.options.showPets == false and item.pet then
                            elseif RAVENOUS_data.options.showToys == false and item.toy then
                            elseif RAVENOUS_data.options.showCosmetics == false and itemSubType == "Cosmetic" then
                            elseif RAVENOUS_data.options.showItems == false and (itemType == "Consumable" or itemType == "Container" or itemType == "Questitem") then
                            elseif RAVENOUS_data.options.showCannotUse == false and item.covenant and item.covenant ~= covenant then
                            elseif RAVENOUS_data.options.showCannotUse == false and item.faction and item.faction:upper() ~= faction:upper() then
                            elseif RAVENOUS_data.options.showCannotUse == false and item.class and item.class:upper() ~= class:upper() then
                            else
                                table.insert(itemIDs, GetItemID(item))
                            end
                        end
                    end
                end
            end
        end
    end
    CacheItem(1, itemIDs, callback)
end

---
-- Waypoints & Sharing
---

-- Sets Map Pin and returns zone.id, x1, x2, y1, y2
function ns:SetWaypoint(zone, rare)
    local c = GetCoordinates(rare)

    -- Add the waypoint to the map and track it
    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(zone.id, "0." .. c[1] .. c[2], "0." .. c[3] .. c[4]))
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)

    return { c[1], c[2], c[3], c[4] }
end

function ns:NewRare(zone, rare, sender)
    local c = GetCoordinates(rare)

    local zoneName = C_Map.GetMapInfo(zone.id).name
    zone.color = zone.color and zone.color or "faea0d"

    if not sender or sender == string.format("%1$s-%2$s", UnitName("player"), GetNormalizedRealmName()) then
        ns:PrettyPrint(rare.name .. "\n|cffffd100|Hworldmap:" .. zone.id .. ":" .. c[1] .. c[2] .. ":" .. c[3] .. c[4] .. "|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a |cff" .. zone.color .. zoneName .. "|r |cffeeeeee" .. c[1] .. "." .. c[2] .. ", " .. c[3] .. "." .. c[4] .. "|r]|h|r")
    else
        local n = random(#L.TargetMessages)
        RaidNotice_AddMessage(RaidBossEmoteFrame, L.TargetMessages[n] .. " " .. rare.name .. " in " .. zoneName .. " " .. c[1] .. "." .. c[2] .. ", " .. c[3] .. "." .. c[4], ChatTypeInfo["RAID_WARNING"])
    end

    ns:SetWaypoint(zone, rare)
end

function ns:ShareRare(zone, rare, rareID)
    local c = GetCoordinates(rare)
    local isLead = IsLead()

    if IsInInstance() or IsInRaid() or IsInGroup() then
        if ns.sendOnCooldown == true then
            ns:PrettyPrint(L.PleaseWait)
            return
        end
        ns.sendOnCooldown = true
        C_Timer.After(10, function()
            ns.sendOnCooldown = false
        end)
    end

    local zoneName = C_Map.GetMapInfo(zone.id).name
    local message = rare.name .. " in " .. zoneName .. " " .. C_Map.GetUserWaypointHyperlink()

    if IsInInstance() then
        SendChatMessage(message, "INSTANCE")
        if isLead then
            C_ChatInfo.SendAddonMessage(ADDON_NAME, rareID, "INSTANCE_CHAT")
        end
    elseif IsInRaid() then
        SendChatMessage(message, "RAID")
        if isLead then
            C_ChatInfo.SendAddonMessage(ADDON_NAME, rareID, "RAID")
        end
    elseif IsInGroup() then
        SendChatMessage(message, "PARTY")
        if isLead then
            C_ChatInfo.SendAddonMessage(ADDON_NAME, rareID, "PARTY")
        end
    else
        -- SendChatMessage(message, "WHISPER", _, UnitName("player")) -- Uncomment for testing
        -- C_ChatInfo.SendAddonMessage(ADDON_NAME, rareID, "WHISPER", UnitName("player")) -- Uncomment for testing
        ns:NewRare(zone, rare)
    end

    ns:SetWaypoint(zone, rare)
end

---
-- UI
---

local function CreateSpacer(Parent, Relative, size)
    size = size and size or 24

    local Spacer = CreateFrame("Frame", nil, Parent)
    Spacer:SetPoint("TOPLEFT", Relative, "BOTTOMLEFT")
    Spacer:SetWidth(Parent:GetWidth())
    Spacer:SetHeight(size)

    return Spacer
end

local function CreateScroller(cfg)
    local Scroller = CreateFrame("ScrollFrame", ADDON_NAME .. "Scroller" .. string.gsub(cfg.label, "%s+", ""), cfg.parent, "UIPanelScrollFrameTemplate")
    Scroller:SetPoint("BOTTOMRIGHT", cfg.parent, "BOTTOMRIGHT", -28, 8)
    Scroller:SetWidth(cfg.width)
    Scroller:SetHeight(cfg.height)
    Scroller.title = cfg.label
    Scroller:Hide()

    local Content = CreateFrame("Frame", ADDON_NAME .. "Scroller" .. string.gsub(cfg.label, "%s+", "") .. "Content", Scroller)
    Content:SetWidth(cfg.width)
    Content:SetHeight(1)
    Content.offset = -large
    Scroller.Content = Content

    Scroller:SetScrollChild(Content)
    Scroller:SetScript("OnShow", function()
        Scroller:SetScrollChild(Content)
    end)

    return Scroller
end

local function CreateTab(cfg)
    local Tab = CreateFrame("Button", ADDON_NAME .. "Tab" .. string.gsub(cfg.label, "%s+", ""), cfg.parent)
    Tab:SetPoint("TOPLEFT", cfg.relativeTo, cfg.relativePoint, cfg.x, cfg.y)
    Tab:SetWidth(48)
    Tab:SetHeight(48)
    Tab:EnableMouse(true)
    Tab.title = cfg.label

    local TabBackground = Tab:CreateTexture(nil, "BACKGROUND")
    TabBackground:SetAllPoints()
    TabBackground:SetTexture(132074)
    TabBackground:SetDesaturated(1)

    local TabIcon = Tab:CreateTexture(nil, "ARTWORK")
    TabIcon:SetWidth(Tab:GetWidth() * 0.6)
    TabIcon:SetHeight(Tab:GetHeight() * 0.6)
    TabIcon:SetPoint("LEFT", Tab, "LEFT", 0, 5)
    TabIcon:SetTexture(cfg.icon)

    Tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetText(TextColor(cfg.label))
        GameTooltip:Show()
        TabBackground:SetDesaturated(nil)
    end)
    Tab:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        TabBackground:SetDesaturated(1)
    end)

    return Tab
end

---
-- Notes
---

function ns:CreateNotes(Parent, Relative, notes, indent)
    notes = type(notes) == "table" and notes or {notes}
    indent = indent and indent or ""
    for i, note in ipairs(notes) do
        local Note = Parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        Note:SetJustifyH("LEFT")
        Note:SetText(indent .. TextColor(RenderString(note), "eeeeee"))
        Note:SetWidth(Parent:GetWidth())
        Note:SetPoint("TOPLEFT", Relative, "BOTTOMLEFT", 0, -medium-(Relative.offset or 0))
        Relative = Note
    end

    return Relative
end

---
-- Zone
---

function ns:CreateZone(Parent, Relative, tab, expansion, zone, worldQuests, relativePoint)
    for _, e in ipairs(ns.data.expansions) do
        if e.name == expansion.name then
            zone.color = zone.color and zone.color or e.color
            break
        end
    end
    zone.color = zone.color and zone.color or "faea0d"
    local mapName = zone.name and zone.name or C_Map.GetMapInfo(zone.id).name
    local Rares = {}

    local ZoneFrame = CreateFrame("Frame", ADDON_NAME .. "ZoneFrame" .. zone.id .. string.gsub(zone.name or "", "[ -']", ""), Parent)
    ZoneFrame:SetPoint("TOPLEFT", Relative, (relativePoint or "BOTTOMLEFT"), 0, -gigantic-(Relative.offset or 0))
    ZoneFrame:SetWidth(Parent:GetWidth())
    ZoneFrame:SetHeight(1)
    Parent = ZoneFrame
    Relative = ZoneFrame

    local Zone = Parent:CreateFontString(ADDON_NAME .. "Zone" .. zone.id .. (string.gsub(zone.name or "", "[ -']", "")), "ARTWORK", "GameFontNormalLarge")
    local ZoneAnchor = CreateFrame("Button", nil, Parent)
    Zone:SetPoint("TOPLEFT", Relative, "TOPLEFT")
    Zone:SetJustifyH("LEFT")
    Zone:SetText((zone.icon and TextIcon(zone.icon) .. "  " or "") .. TextColor(mapName, zone.color))
    ZoneAnchor:SetAllPoints(Zone)
    ZoneAnchor:SetScript("OnClick", function()
        -- TODO How to reliably expand/collapse
        -- fontstring height is not reliable until frame after update
    end)
    Relative = Zone
    Relative.offset = 0
    local LittleRelative = Zone

    if zone.faction then
        local zoneFactions = type(zone.faction) == "table" and zone.faction or {zone.faction}
        for i, faction in ipairs(zoneFactions) do
            local Faction = Parent:CreateFontString(ADDON_NAME .. "Zone" .. zone.id .. (string.gsub(zone.name or "", "[ -']", "")) .. "Faction", "ARTWORK", "GameFontNormal")
            if i > 1 then
                Faction:SetPoint("TOPLEFT", LittleRelative, "BOTTOMLEFT", 0, -medium)
                Relative.offset = Relative.offset + large + small
            else
                Faction:SetPoint("LEFT", LittleRelative, "RIGHT", large, 0)
            end
            Faction:SetJustifyH("LEFT")
            local FactionAnchor = CreateFrame("Frame", nil, Parent)
            FactionAnchor:SetAllPoints(Faction)
            Faction.anchor = FactionAnchor
            Faction.faction = faction
            Faction.color = zone.color
            Register("Factions", Faction)
            ns:RefreshFactions()
            LittleRelative = Faction
        end
    end

    if zone.currency then
        local zoneCurrencies = type(zone.currency) == "table" and zone.currency or {zone.currency}
        for i, currency in ipairs(zoneCurrencies) do
            local Currency = Parent:CreateFontString(ADDON_NAME .. "Zone" .. zone.id .. (string.gsub(zone.name or "", "[ -']", "")) .. "Currency", "ARTWORK", "GameFontNormal")
            if i > 1 or zone.faction then
                Currency:SetPoint("TOPLEFT", LittleRelative, "BOTTOMLEFT", 0, -medium)
                Relative.offset = Relative.offset + large + small
            else
                Currency:SetPoint("LEFT", LittleRelative, "RIGHT", large, 0)
            end
            Currency:SetJustifyH("LEFT")
            Currency.currency = GetCurrencyData(currency)
            Register("Currencies", Currency)
            ns:RefreshCurrencies()
            LittleRelative = Currency
        end
    end

    -- For each Rare in the Zone
    local i = 0
    for rareID, rare in pairs(expansion.rares) do
        local rareZone = GetZoneData(expansion, rare)
        if rareZone and rareZone.id == zone.id then
            local isWorldQuest, isAvailable = false, false
            rare.quest = rare.quest or (faction == "Alliance" and (rare.questAlliance or nil) or (rare.questHorde or nil))
            if type(rare.quest) == "number" then
                if CQL.IsWorldQuest(rare.quest) or rare.worldquest then
                    isWorldQuest = true
                    if contains(worldQuests, rare.quest) or CQL.IsQuestFlaggedCompleted(rare.quest) then
                        isAvailable = true
                    elseif CQL.AddWorldQuestWatch(rare.quest) then
                        isAvailable = true
                        CQL.RemoveWorldQuestWatch(rare.quest)
                    end
                else
                    isAvailable = CQL.IsQuestFlaggedCompleted(rare.quest) and false or true
                end
            end
            if rare.hidden then
            elseif isWorldQuest and not isAvailable then
            else
                local items = {}
                if rare.loot and #rare.loot > 0 then
                    -- For each Item dropped by the Rare
                    for _, item in ipairs(rare.loot) do
                        item = type(item) == "table" and item or {item}
                        local itemType, itemSubType, _ = select(6, GetItemInfo(GetItemID(item)))
                        if itemType ~= nil then
                            if item.mount == nil and item.pet == nil and item.toy == nil and itemSubType ~= "Cosmetic" and itemType ~= "Consumable" and itemType ~= "Container" and itemType ~= "Questitem" then
                            elseif RAVENOUS_data.options.showOwned == false and IsItemOwned(item) then
                            elseif RAVENOUS_data.options.showMounts == false and item.mount then
                            elseif RAVENOUS_data.options.showPets == false and item.pet then
                            elseif RAVENOUS_data.options.showToys == false and item.toy then
                            elseif RAVENOUS_data.options.showCosmetics == false and itemSubType == "Cosmetic" then
                            elseif RAVENOUS_data.options.showItems == false and (itemType == "Consumable" or itemType == "Container" or itemType == "Questitem") then
                            elseif RAVENOUS_data.options.showCannotUse == false and item.covenant and item.covenant ~= covenant then
                            elseif RAVENOUS_data.options.showCannotUse == false and item.faction and item.faction:upper() ~= faction:upper() then
                            elseif RAVENOUS_data.options.showCannotUse == false and item.class and item.class:upper() ~= class:upper() then
                            else
                                -- Insert Item into Items
                                table.insert(items, item)
                            end
                        end
                    end
                end
                if #items == 0 then
                elseif GetCoordinates(rare) == nil then
                elseif RAVENOUS_data.options.showCannotUse == false and rare.faction and rare.faction:upper() ~= faction:upper() then
                else
                    -- Rare
                    i = i + 1
                    local Rare = ns:CreateRare(Parent, Relative, i, tab, zone, rare, rareID, items)
                    table.insert(Rares, Rare)
                    Relative = Rare
                end
            end
        end
    end

    return Relative
end

---
-- Rare
---

function ns:CreateRare(Parent, Relative, i, tab, zone, rare, rareID, items)
    local zoneIcon = zone.icon and zone.icon or nil
    local zoneName = C_Map.GetMapInfo(zone.id).name
    local c = GetCoordinates(rare)

    local lockedIcon = IsRareDead(rare) and icons.Checkmark or ((type(rare.quest) == "number" and CQL.IsWorldQuest(rare.quest))) and icons.LegendaryQuest or (rare.biweekly or rare.weekly or rare.fortnightly) and icons.Daily or rare.achievement and icons.Achievement or rare.vendor and icons.Vendor or rare.dungeon and icons.Dungeon or rare.raid and icons.Raid or icons.Skull

    local rareFaction = rare.faction and "|cff" .. (rare.faction == "Alliance" and "0078ff" or "b30000") .. rare.faction .. "|r" or nil
    local factionOnly = rareFaction and TextColor(L.OnlyFor) .. rareFaction or ""
    local heroicOnly = rare.heroic and TextColor("Heroic") .. " " or ""
    local rareControl = rare.control and "|cff" .. (rare.control == "Alliance" and "0078ff" or "b30000") .. rare.control .. "|r" or nil
    local controlRequired = rareControl and TextColor(string.format(L.ZoneControl, rareControl)) or ""
    local drops = #items > 0 and  " " .. TextColor(rare.vendor and L.Sells or L.Drops, "bbbbbb") or ""

    local Rare = CreateFrame("Button", ADDON_NAME .. "Rare" .. rareID, Parent)
    local RareLabel = Rare:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    RareLabel:SetJustifyH("LEFT")
    RareLabel:SetText(lockedIcon .. " " .. heroicOnly .. rare.name .. controlRequired .. factionOnly .. drops)
    RareLabel:SetHeight(16)
    RareLabel:SetPoint("TOPLEFT", Relative, "BOTTOMLEFT", 0, -gigantic-(Relative.offset or 0))
    Rare:SetAllPoints(RareLabel)
    Rare:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM", 0, -small)
        local isLead = IsLead()
        local prefix = isLead and L.ShareMapPin or L.CreateMapPin
        GameTooltip:SetText(TextColor(prefix .. ":"))
        if isLead then
            GameTooltip:AddLine(TextColor(L.ModifierToShare, "bbbbbb"))
        end
        GameTooltip:AddLine(rare.name .. (IsRareDead(rare) and TextColor(" (" .. _G.DEAD .. ")", "bbbbbb") or ""))
        GameTooltip:AddLine(TextColor(zoneName, zone.color) .. " " .. c[1] .. "." .. c[2] .. ", " .. c[3] .. "." .. c[4])
        if type(rare.quest) == "number" and CQL.IsWorldQuest(rare.quest) then
            GameTooltip:AddLine(icons.Quest .. " World Quest")
        elseif rare.biweekly then
            GameTooltip:AddLine("Bi-weekly")
        elseif rare.weekly then
            GameTooltip:AddLine("Weekly")
        elseif rare.fortnightly then
            GameTooltip:AddLine("Fortnightly")
        elseif rare.achievement then
            GameTooltip:AddLine("Achievement-based")
        end
        GameTooltip:Show()
    end)
    Rare:SetScript("OnLeave", HideTooltip)
    Rare:SetScript("OnClick", function()
        if IsShiftKeyDown() then
            ns:ShareRare(zone, rare, rareID)
        else
            ns:NewRare(zone, rare)
        end
    end)
    RareLabel.rare = rare
    Register("Rares", RareLabel)
    Relative = Rare

    if #items > 0 then
        for _, item in ipairs(items) do
            local Item = ns:CreateItem(Parent, Relative, zone, rare, item)
            Relative = Item
        end
    end

    if rare.notes then

        Relative.offset = -small
        local Notes = ns:CreateNotes(Parent, Relative, rare.notes, "    ")
        Relative = Notes
    end

    return Relative
end

---
-- Item
---

function ns:CreateItem(Parent, Relative, zone, rare, item)
    item = type(item) == "table" and item or {item}

    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(GetItemID(item))
    local chance = item.chance and TextColor(" " .. item.chance .. "%", "bbbbbb") .. (item.chance < 100 and TextColor(" (~" .. RunsUntilDrop(item.chance) .. " runs exp.)", "bbbbbb") or "") or ""
    local achievement = item.achievement and TextColor(L.From) .. GetAchievementLink(item.achievement) or ""
    local itemCovenant = item.covenant and ns.data.covenants[item.covenant] or nil
    local covenantOnly = itemCovenant and TextColor(L.OnlyFor) .. TextColor(itemCovenant.name, itemCovenant.color) or ""
    local itemFaction = item.faction and "|cff" .. (item.faction == "Alliance" and "0078ff" or "b30000") .. item.faction .. "|r" or nil
    local factionOnly = itemFaction and TextColor(L.OnlyFor) .. itemFaction or ""
    local itemClass = item.class and "|c" .. select(4, GetClassColor(string.gsub(item.class, "%s+", ""):upper())) .. item.class .. "s|r" or nil
    local classOnly = item.class and TextColor(L.OnlyFor) .. itemClass or ""
    local owned = IsItemOwned(item) and " " .. icons.Checkmark or ""

    local Item = CreateFrame("Button", ADDON_NAME .. "Item" .. GetItemID(item), Parent)
    local ItemLabel = Item:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ItemLabel:SetJustifyH("LEFT")
    ItemLabel:SetText("    " .. TextIcon(itemTexture) .. "  " .. itemLink .. chance .. achievement .. covenantOnly .. factionOnly .. classOnly .. owned)
    ItemLabel:SetPoint("TOPLEFT", Relative, "BOTTOMLEFT", 0, -small)
    ItemLabel:SetWidth(Parent:GetWidth())
    Item:SetAllPoints(ItemLabel)
    Item:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM", 0, -small)
        GameTooltip:SetHyperlink(itemLink)
        GameTooltip:Show()
    end)
    Item:SetScript("OnLeave", HideTooltip)
    Item:SetScript("OnClick", function()
        if IsShiftKeyDown() then
            if IsInInstance() then
                SendChatMessage(itemLink, "INSTANCE")
            elseif IsInRaid() then
                SendChatMessage(itemLink, "RAID")
            elseif IsInGroup() then
                SendChatMessage(itemLink, "PARTY")
            else
                ns:PrettyPrint(itemLink)
            end
        elseif IsControlKeyDown() then
            DressUpItemLink(itemLink)
        else
            ns:PrettyPrint(itemLink)
        end
    end)
    ItemLabel.item = item
    Register("Items", ItemLabel)

    Relative = ItemLabel
    return Relative
end

---
-- Window
---

function ns:BuildWindow()
    local Scrollers = {}
    local Tabs = {}

    local Window = CreateFrame("Frame", ADDON_NAME .. "Window", UIParent, "UIPanelDialogTemplate")
    Window:SetFrameStrata("MEDIUM")
    Window:SetWidth(RAVENOUS_data.options.windowWidth)
    Window:SetHeight(RAVENOUS_data.options.windowHeight)
    Window:SetScale(RAVENOUS_data.options.scale)
    Window:SetPoint(RAVENOUS_data.options.windowPosition, RAVENOUS_data.options.windowX, RAVENOUS_data.options.windowY)
    Window:EnableMouse(true)
    Window:SetMovable(true)
    Window:SetClampedToScreen(true)
    Window:RegisterForDrag("LeftButton")
    Window:Hide()
    Window:SetScript("OnShow", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    end)
    Window:SetScript("OnHide", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    end)
    tinsert(UISpecialFrames, Window:GetName())
    ns.Window = Window

    local Heading = Window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    Heading:SetPoint("TOP", Window, "TOP")
    Heading:SetPoint("BOTTOM", Window, "TOP", 0, -30)
    Heading:SetText(ns.name .. " " .. "v" .. ns.version)

    local LockButton = CreateFrame("Button", ADDON_NAME .. "LockButton", Window, "UIPanelButtonTemplate")
    LockButton:SetPoint("TOPLEFT", Window, "TOPLEFT", 9, -small)
    LockButton:SetWidth(18)
    LockButton:SetHeight(18)
    LockButton:RegisterForClicks("LeftButton")
    LockButton:SetScript("OnMouseDown", function(self, button)
        RAVENOUS_data.options.locked = not RAVENOUS_data.options.locked
        GameTooltip:SetText(TextColor(RAVENOUS_data.options.locked and "Unlock Window" or "Lock Window"))
    end)
    LockButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM", 0, -small)
        GameTooltip:SetText(TextColor(RAVENOUS_data.options.locked and "Unlock Window" or "Lock Window"))
        GameTooltip:Show()
    end)
    LockButton:SetScript("OnLeave", HideTooltip)
    local LockButtonIcon = LockButton:CreateTexture()
    LockButtonIcon:SetAllPoints(LockButton)
    LockButtonIcon:SetTexture(130944)

    local OptionsButton = CreateFrame("Button", ADDON_NAME .. "OptionsButton", Window, "UIPanelButtonTemplate")
    OptionsButton:SetPoint("TOPLEFT", LockButton, "TOPRIGHT", 2, 0)
    OptionsButton:SetWidth(18)
    OptionsButton:SetHeight(18)
    OptionsButton:RegisterForClicks("LeftButton")
    OptionsButton:SetScript("OnMouseDown", function(self, button)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
    end)
    OptionsButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_BOTTOM", 0, -small)
        GameTooltip:SetText(TextColor("Open Interface Options"))
        GameTooltip:Show()
    end)
    OptionsButton:SetScript("OnLeave", HideTooltip)
    local OptionsButtonIcon = OptionsButton:CreateTexture()
    OptionsButtonIcon:SetAllPoints(OptionsButton)
    OptionsButtonIcon:SetTexture(134063)

    -- TODO Get the resizer attached to Window + Events
    -- local Resizer = CreateFrame("Button", ADDON_NAME .. "Resizer", Window)
    -- Icon/Texture to use: 386862

    local Scroller = CreateScroller({
        label = "General",
        parent = Window,
        width = Window:GetWidth() - 42,
        height = Window:GetHeight() - Heading:GetHeight() - 6,
        current = true,
    })
    Scroller:Show()
    Scrollers["General"] = Scroller
    for _, tab in ipairs(tabs) do
        local Scroller = CreateScroller({
            label = tab.name,
            parent = Window,
            width = Window:GetWidth() - 42,
            height = Window:GetHeight() - Heading:GetHeight() - 6,
        })
        Scrollers[tab.name] = Scroller
    end

    Tabs["General"] = CreateTab({
        label = "General",
        icon = 1542860,
        parent = Window,
        relativeTo = Window,
        relativePoint = "TOPRIGHT",
        x = -3,
        y = -Heading:GetHeight(),
        current = true,
    })
    local previousTab = Tabs["General"]
    for _, tab in ipairs(tabs) do
        local Tab = CreateTab({
            label = tab.name,
            icon = tab.icon,
            parent = Window,
            relativeTo = previousTab,
            relativePoint = "BOTTOMLEFT",
            x = 0,
            y = 0,
        })
        Tabs[tab.name] = Tab
        previousTab = Tab
    end

    local function WindowInteractionStart(self, button)
        if button == "LeftButton" and not RAVENOUS_data.options.locked then
            Window:StartMoving()
            Window.isMoving = true
            Window.hasMoved = false
        end
    end
    local function WindowInteractionEnd(self)
        if Window.isMoving then
            Window:StopMovingOrSizing()
            Window.isMoving = false
            Window.hasMoved = true
            local point, _, _, x, y = Window:GetPoint()
            RAVENOUS_data.options.windowPosition = point
            RAVENOUS_data.options.windowX = x
            RAVENOUS_data.options.windowY = y
        end
    end
    Window:SetScript("OnMouseDown", WindowInteractionStart)
    Window:SetScript("OnMouseUp", WindowInteractionEnd)

    -- Get "Watched" World Quests
    -- What is useful is that the weekly WQ Rare is auto-tracked on login, so we
    -- can use this + quest completion to determine the Weekly WQ Rare
    local worldQuests = {}
    if CQL.GetNumWorldQuestWatches() then
        for i = 1, CQL.GetNumWorldQuestWatches() do
            tinsert(worldQuests, CQL.GetQuestIDForWorldQuestWatchIndex(i))
        end
    end

    -- Set up where to put content of each Scroller
    local Parent = Scrollers["General"].Content
    local Relative = Parent

    -- Global Notes
    local NoteHeading = Parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    NoteHeading:SetJustifyH("LEFT")
    NoteHeading:SetText(TextIcon(1506451) .. "  " .. "Welcome!")
    NoteHeading:SetPoint("TOPLEFT", Relative, "BOTTOMLEFT", 0, -gigantic-(Relative.offset or 0))
    Relative = NoteHeading
    local Notes = ns:CreateNotes(Parent, Relative, notes)
    Relative = Notes
    local Spacer = CreateSpacer(Parent, Relative)

    for _, tab in ipairs(tabs) do
        Parent = Scrollers[tab.name].Content
        Relative = Parent
        local i = 1
        for _, expansion in ipairs(tab.expansions) do
            if RAVENOUS_data.options["expansion"..expansion.name] == true then
                for _, zone in ipairs(expansion.zones) do
                    if i > 1 then
                        Relative.offset = medium
                    end
                    i = i + 1
                    -- Zone
                    local Zone = ns:CreateZone(Parent, Relative, tab, expansion, zone, worldQuests)
                    Relative = Zone
                end
            end
        end
        -- Notes
        if tab.notes and #tab.notes > 0 then
            local NoteHeading = Parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            NoteHeading:SetJustifyH("LEFT")
            NoteHeading:SetText(TextIcon(1506451) .. "  " .. TextColor("Notes", "eeeeee"))
            NoteHeading:SetPoint("TOPLEFT", Relative, "BOTTOMLEFT", 0, -gigantic-(Relative.offset or 0))
            Relative = NoteHeading
            local Notes = ns:CreateNotes(Parent, Relative, tab.notes)
            Relative = Notes
        end
        local Spacer = CreateSpacer(Parent, Relative)
    end

    for title, Tab in pairs(Tabs) do
        Tab:SetScript("OnClick", function()
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            for lookup, Scroller in pairs(Scrollers) do
                if title == lookup then
                    Scroller:Show()
                else
                    Scroller:Hide()
                end
            end
        end)
    end
end

---
-- Minimap Button
-- Thanks to Leatrix for the gist of this code!
---

function ns:CreateMinimapButton()
    if RAVENOUS_data.options.minimapButton ~= true then
        if ns.MinimapButton then ns.MinimapButton:Hide() end
        return
    end

    local Button = CreateFrame("Button", nil, Minimap)
    Button:SetFrameStrata("MEDIUM")
    Button:SetFrameLevel(8)
    Button:SetSize(31, 31)
    Button:EnableMouse(true)
    Button:SetMovable(true)
    Button:ClearAllPoints()

    Button:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    local overlay = Button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
    overlay:SetPoint("TOPLEFT")
    local background = Button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
    background:SetPoint("TOPLEFT", 7, -5)
    local icon = Button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(23, 23)
    icon:SetTexture("Interface/AddOns/rav/rav.tga")
    icon:SetPoint("TOPLEFT", 6, -6)

    local minimapShapes = {
        ["ROUND"] = {true, true, true, true},
        ["SQUARE"] = {false, false, false, false},
        ["CORNER-TOPLEFT"] = {false, false, false, true},
        ["CORNER-TOPRIGHT"] = {false, false, true, false},
        ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
        ["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
        ["SIDE-LEFT"] = {false, true, false, true},
        ["SIDE-RIGHT"] = {true, false, true, false},
        ["SIDE-TOP"] = {false, false, true, true},
        ["SIDE-BOTTOM"] = {true, true, false, false},
        ["TRICORNER-TOPLEFT"] = {false, true, true, true},
        ["TRICORNER-TOPRIGHT"] = {true, false, true, true},
        ["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
        ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
    }

    local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
    function updatePosition(button, position)
        local angle = rad(position or 225)
        local x, y, q = cos(angle), sin(angle), 1
        if x < 0 then q = q + 1 end
        if y > 0 then q = q + 2 end
        local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
        local quadTable = minimapShapes[minimapShape]
        local w = (Minimap:GetWidth() / 2) + 5
        local h = (Minimap:GetHeight() / 2) + 5
        if quadTable[q] then
            x, y = x*w, y*h
        else
            local diagRadiusW = sqrt(2*(w)^2)-10
            local diagRadiusH = sqrt(2*(h)^2)-10
            x = max(-w, min(x*diagRadiusW, w))
            y = max(-h, min(y*diagRadiusH, h))
        end
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
    updatePosition(Button, RAV_data.options.minimapPosition)

    local deg, atan2 = math.deg, math.atan2
    local function onUpdate(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        local pos = 225
        if self.db then
            pos = deg(atan2(py - my, px - mx)) % 360
            self.db.minimapPos = pos
        else
            pos = deg(atan2(py - my, px - mx)) % 360
            self.minimapPos = pos
        end
        updatePosition(self, pos)
        RAV_data.options.minimapPosition = pos
    end

    Button:RegisterForDrag("LeftButton")
    Button:SetScript("OnDragStart", function()
        Button:StartMoving()
        Button.isMoving = true
        Button:SetScript("OnUpdate", onUpdate)
    end)

    Button:SetScript("OnDragStop", function()
        Button:StopMovingOrSizing()
        Button.isMoving = false
        Button:SetScript("OnUpdate", nil)
    end)

    Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent, "ANCHOR_CURSOR")
        GameTooltip:SetText(TextColor(ns.name))
        GameTooltip:AddLine(L.MinimapLClick)
        GameTooltip:AddLine(L.MinimapRClick)
        GameTooltip:Show()
    end)
    Button:SetScript("OnLeave", HideTooltip)

    Button:SetScript("OnMouseUp", function(self, button)
        if not self.isMoving then
            if button == "RightButton" then
                ns.waitingForOptions = true
                ns:PrettyPrint(_G.LFG_LIST_LOADING)
            else
                ns:ToggleWindow(ns.Window)
            end
        end
    end)

    ns.MinimapButton = Button
end
