local ADDON_NAME, ns = ...
local L = ns.L

function ravenous_OnLoad(self)
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHAT_MSG_CURRENCY")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("UPDATE_FACTION")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED")
    self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
    self:RegisterEvent("NEW_TOY_ADDED")
end

function ravenous_OnEvent(self, event, arg, ...)
    if event == "CHAT_MSG_ADDON" and arg == ADDON_NAME then
        if ns.chatOnCooldown == true then return end
        ns.chatOnCooldown = true
        C_Timer.After(10, function()
            ns.chatOnCooldown = false
        end)
        local message, channel, sender, _ = ...
        local rareID = math.floor(message)
        local bubbleBreak = false
        for _, tab in ipairs(ns.data.tabs) do
            for _, expansion in ipairs(tab.expansions) do
                for id, rare in pairs(expansion.rares) do
                    if id == rareID then
                        ns:NewRare(getZoneData(expansion, rare), rare, sender)
                        bubbleBreak = true
                        break
                    end
                end
                if bubbleBreak then break end
            end
            if bubbleBreak then break end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Prepare AddOn data, window, options
        ns:SetDefaultOptions()
        InterfaceOptions_AddCategory(ns.Options)
        ns:CreateMinimapButton()
        ns:EnsureMacro()
        C_Timer.After(0, function()
            -- Loop through SilverDragon data
            for _, expansion in ipairs(ns.data.tabs[1].expansions) do
                if RAVENOUS_data.options["expansion"..expansion.name] == true then
                    for k, v in pairs(SilverDragon.datasources[expansion.name]) do
                        expansion.rares[k] = v
                    end
                end
            end
            -- Cache data, set up window and options
            ns:CacheAndBuild(function()
                -- These happen once all Items have been cached
                if RAVENOUS_data.options.allowSharing then
                    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_NAME)
                else
                    self:UnregisterEvent("CHAT_MSG_ADDON")
                end
                ns:BuildWindow()
                if ns.waitingForWindow or not RAVENOUS_version then
                    ns:ToggleWindow(ns.Window, "Show")
                end
                if ns.waitingForOptions then
                    InterfaceOptionsFrame_OpenToCategory(ns.Options)
                    InterfaceOptionsFrame_OpenToCategory(ns.Options)
                end
                if ns.MinimapButton then
                    ns.MinimapButton:SetScript("OnMouseUp", function(self, button)
                        if button == "RightButton" then
                            InterfaceOptionsFrame_OpenToCategory(ns.Options)
                            InterfaceOptionsFrame_OpenToCategory(ns.Options)
                        else
                            ns:ToggleWindow(ns.Window)
                        end
                    end)
                end
            end)
        end)
        -- Mute annoying sounds
        for _, sound in pairs(ns.data.annoyingSounds) do
            MuteSoundFile(sound)
        end
        -- Version check
        if not RAVENOUS_version then
            ns:PrettyPrint(string.format(L.Install, ns.color, ns.version, ns.command))
        elseif RAVENOUS_version ~= ns.version then
            ns:PrettyPrint(string.format(L.Update, ns.color, ns.version, ns.command))
        end
        RAVENOUS_version = ns.version
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "CHAT_MSG_CURRENCY" or event == "CURRENCY_DISPLAY_UPDATE" then
        if ns.Currencies then
            ns:RefreshCurrencies()
        end
    elseif event == "UPDATE_FACTION" then
        if ns.Factions then
            ns:RefreshFactions()
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subtype = CombatLogGetCurrentEventInfo()
        if subtype == "UNIT_DIED" or subtype == "UNIT_DESTROYED" then
            if ns.Rares then
                ns:RefreshRares()
            end
        end
    elseif event == "UPDATE_ALL_UI_WIDGETS" then
        if ns.Rares then
            ns:RefreshRares()
        end
    elseif event == "MOUNT_JOURNAL_SEARCH_UPDATED" or event == "PET_JOURNAL_LIST_UPDATE" or event == "NEW_TOY_ADDED" then
        if ns.Items then
            ns:RefreshItems()
        end
    end
end

SlashCmdList["RAV"] = function(message, editbox)
    if message == "version" or message == "v" then
        ns:PrettyPrint(string.format(L.Version, ns.version))
    elseif message == "c" or string.match(message, "con") or message == "h" or string.match(message, "help") or message == "o" or string.match(message, "opt") or message == "s" or string.match(message, "sett") or string.match(message, "togg") then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
    else
        ns:ToggleWindow(ns.Window)
    end
end
SLASH_RAV1 = "/" .. ns.command
SLASH_RAV2 = "/r4"
