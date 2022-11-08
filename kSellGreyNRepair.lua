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

localizeMeGuildy = {
    enUS = "Equipment has been repaired by your Guild for",
    enGB = "Equipment has been repaired by your Guild for",
    frFR = "L'équipement a été réparé par votre guilde pendant",
    deDE = "Ausrüstung wurde von deiner Gilde repariert für",
    itIT = "L'equipaggiamento è stato riparato dalla tua gilda per",
    koKR = "길드에서 장비를 수리했습니다",
    zhCN = "您的公会已为您修理了设备",
    zhTW = "你的公會已經修理了設備",
    ruRU = "Оборудование было отремонтировано вашей гильдией за",
    esES = "El equipo ha sido reparado por tu Gremio por",
    esMX = "El equipo ha sido reparado por tu Gremio por",
    ptBR = "O equipamento foi consertado por sua Guilda por",
}

localizeMePersonally = {
    enUS = "Equipment has been repaired for",
    enGB = "Equipment has been repaired for",
    frFR = "L'équipement a été réparé pour",
    deDE = "Gerät wurde für repariert",
    itIT = "L'attrezzatura è stata riparata per",
    koKR = "에 대한 장비가 수리되었습니다",
    zhCN = "设备已修复",
    zhTW = "設備已修復",
    ruRU = "Оборудование было отремонтировано за",
    esES = "El equipo ha sido reparado para",
    esMX = "El equipo ha sido reparado para",
    ptBR = "O equipamento foi reparado para",
}

localizeMeVendor = {
    enUS = "Items were sold for",
    enGB = "Items were sold for",
    frFR = "Les articles ont été vendus pour",
    deDE = "Artikel wurden für verkauft",
    itIT = "Gli articoli sono stati venduti per",
    koKR = "에 대해 판매된 항목",
    zhCN = "物品售价为",
    zhTW = "物品售價為",
    ruRU = "Товары были проданы за",
    esES = "Los artículos se vendieron por",
    esMX = "Los artículos se vendieron por",
    ptBR = "Os itens foram vendidos por",
}

my_locale = GetLocale();

local function OnEvent(self, event)
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
        output = localizeMeVendor[my_locale]
		DEFAULT_CHAT_FRAME:AddMessage(output..GetCoinTextureString(totalPrice), 255, 255, 255)
	end

	-- Auto Repair
	if (CanMerchantRepair()) then	
		repairAllCost, canRepair = GetRepairAllCost();
		-- If merchant can repair and there is something to repair
		if (canRepair and repairAllCost > 0) then
			-- Use Guild Bank
			guildRepairedItems = false
			if (IsInGuild() and CanGuildBankRepair()) then
				-- Checks if guild has enough money
				local amount = GetGuildBankWithdrawMoney()
				local guildBankMoney = GetGuildBankMoney()
				amount = amount == -1 and guildBankMoney or min(amount, guildBankMoney)

				if (amount >= repairAllCost) then
					RepairAllItems(true);
					guildRepairedItems = true
                    output = localizeMeGuildy[my_locale]
					DEFAULT_CHAT_FRAME:AddMessage(output..GetCoinTextureString(repairAllCost), 255, 255, 255)
				end
			end
			
			-- Use own funds
			if (repairAllCost <= GetMoney() and not guildRepairedItems) then
				RepairAllItems(false);
                localizeMePersonally[my_locale]
				DEFAULT_CHAT_FRAME:AddMessage(output..GetCoinTextureString(repairAllCost), 255, 255, 255)
			end
		end
	end
end


local f = CreateFrame("Frame")
f:SetScript("OnEvent", OnEvent);
f:RegisterEvent("MERCHANT_SHOW");
