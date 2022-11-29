local settings, panel = ...

SLASH_ASGRE1 = "/asgre"

local function ShowCurrentStatus()
        DEFAULT_CHAT_FRAME:AddMessage("Guild repairs enabled: "..tostring(useGuildFunds))
end

local function Usage()
        DEFAULT_CHAT_FRAME:AddMessage("Usage: \n/asgre guild - Toggle guild repairs to enable/disable\n/asgre status - Show the current status of guild repairs")
end

SlashCmdList["ASGRE"] = function(msg)
        if string.len(msg) > 0 then
                -- '/asgre guild' will enable or disable guild repairs depending on current
                -- state
                if msg == "guild" then
                    ToggleGuildRepairs()
                -- '/asgre status' will show the current status of guild repairs
                elseif msg == "status" then
                    ShowCurrentStatus()
                else
                    -- No command was given, give them a hint
                    Usage()
                end
        else
                Usage()
        end
end

local settingsPanel = CreateFrame("Frame")
settingsPanel.name = "Auto Sell Grey & Repair"
InterfaceOptions_AddCategory(settingsPanel)

local title = settingsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText(settingsPanel.name)

local guildRepairCheckButton = CreateFrame("CheckButton", "guildRepairCheckButton_GlobalName", settingsPanel, "ChatConfigCheckButtonTemplate")
guildRepairCheckButton:SetPoint("TOPLEFT", 100, -65)
guildRepairCheckButton_GlobalNameText:SetText("Guild repairs enabled")
guildRepairCheckButton:tooltip = "Enable guild repairs, if available"

local function ToggleGuildRepairs()
        if useGuildFunds then
                useGuildFunds = false
                guildRepairCheckButton:SetChecked(useGuildFunds)
                DEFAULT_CHAT_FRAME:AddMessage("Guild repairs are now disabled.")
        else
                useGuildFunds = true
                guildRepairCheckButton:SetChecked(useGuildFunds)
                DEFAULT_CHAT_FRAME:AddMessage("Guild repairs are now enabled.")
        end
end

guildRepairCheckButton:SetScript("OnClick", ToggleGuildRepairs)
panel.checkButton = guildRepairCheckButton
