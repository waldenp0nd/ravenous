local ADDON_NAME, ns = ...
local L = ns.L

function ravenous_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHAT_MSG_CURRENCY")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("UPDATE_FACTION")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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
        for _, tab in ipairs(ns.data.tabs) do
            for id, rare in pairs(tab.rares) do
                if id == rareID then
                    ns:NewRare(tab, rare, sender)
                    break
                end
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        ns:SetDefaultOptions()
        ns:BuildOptions()
        InterfaceOptions_AddCategory(ns.Options)
        ns:EnsureMacro()
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
        end)
        if not RAVENOUS_version then
            ns:PrettyPrint(string.format(L.Install, ns.color, ns.version, ns.command))
        elseif RAVENOUS_version ~= ns.version then
            ns:PrettyPrint(string.format(L.Update, ns.color, ns.version, ns.command))
        end
        RAVENOUS_version = ns.version
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
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
