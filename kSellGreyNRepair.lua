--[[
Name: Auto Sell Grey & Repair
Description: Sells grey items and repairs your items using guild funds if possible

Copyright 2017 Mateusz Kasprzak

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

SLASH_ASGRE1 = "/asgre"

-- Set to disabled by default
-- useGuildFunds is a variable saved by character
if useGuildFunds == nil then
        useGuildFunds = false
end

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
guildRepairCheckButton:SetScript("OnClick", ToggleGuildRepairs)

local function OnEvent(self, event)
    if event == "ADDON_LOADED" then
        guildRepairCheckButton:SetChecked(useGuildFunds)
    elseif event == "MERCHANT_SHOW" then
        -- Auto Sell Grey Items
        totalPrice = 0
        for myBags = 0,4 do
            for bagSlots = 1, GetContainerNumSlots(myBags) do
                CurrentItemLink = GetContainerItemLink(myBags, bagSlots)
                if CurrentItemLink then
                    _, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(CurrentItemLink)
                    _, itemCount = GetContainerItemInfo(myBags, bagSlots)
                    if itemRarity == 0 and itemSellPrice ~= 0 then
                        totalPrice = totalPrice + (itemSellPrice * itemCount)
                        UseContainerItem(myBags, bagSlots)
                        PickupMerchantItem()
                    end
                end
            end
        end
        if totalPrice ~= 0 then
            DEFAULT_CHAT_FRAME:AddMessage("Items were sold for "..GetCoinTextureString(totalPrice), 255, 255, 255)
        end

        -- Auto Repair
        if (CanMerchantRepair()) then
            repairAllCost, canRepair = GetRepairAllCost();
            -- If merchant can repair and there is something to repair
            if (canRepair and repairAllCost > 0) then
                -- Use Guild Bank
                guildRepairedItems = false
                if (IsInGuild() and CanGuildBankRepair() and useGuildFunds) then
                    -- Checks if guild has enough money
                    local amount = GetGuildBankWithdrawMoney()
                    local guildBankMoney = GetGuildBankMoney()
                    amount = amount == -1 and guildBankMoney or min(amount, guildBankMoney)

                    if (amount >= repairAllCost) then
                        RepairAllItems(true);
                        guildRepairedItems = true
                        DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired by your Guild", 255, 255, 255)
                    end
                end

                -- Use own funds
                if (repairAllCost <= GetMoney() and not guildRepairedItems) then
                    RepairAllItems(false);
                    DEFAULT_CHAT_FRAME:AddMessage("Equipment has been repaired for "..GetCoinTextureString(repairAllCost), 255, 255, 255)
                end
            end
        end
    end
end


local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent);
f:RegisterEvent("MERCHANT_SHOW");
f:RegisterEvent("ADDON_LOADED")
