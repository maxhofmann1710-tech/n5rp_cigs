if Config.Debug then
    print("^2========================================^7")
    print("^2[n5rp_cigs] Server script loaded!^7")
    print("^2[n5rp_cigs] Using inventory:", Config.Inventory)
    print("^2========================================^7")
end

local QBCore = nil
if Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
    QBCore = exports['qb-core']:GetCoreObject()
end

-- Inventory wrapper functions for server
local function GetItemSlot(src, slot)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:GetSlot(src, slot)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return nil end
        return Player.Functions.GetItemBySlot(slot)
    end
end

local function AddItem(src, itemName, amount)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:AddItem(src, itemName, amount)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        Player.Functions.AddItem(itemName, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
        return true
    end
end

local function RemoveItem(src, itemName, amount, metadata, slot)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(src, itemName, amount, metadata, slot)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        Player.Functions.RemoveItem(itemName, amount, slot)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove")
        return true
    end
end

local function SetMetadata(src, slot, metadata)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:SetMetadata(src, slot, metadata)
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local item = Player.Functions.GetItemBySlot(slot)
        if item then
            item.info = metadata
            Player.Functions.SetInventory(Player.PlayerData.items)
            return true
        end
        return false
    end
end

-- Use cigarette pack
RegisterNetEvent('n5rp_cigs:cigarettes:server:UsePack', function(packName, slot, metadata)
    local src = source
    
    if Config.Debug then
        print("^2[n5rp_cigs]^7 Server UsePack received from player:", src)
    end
    
    local item = GetItemSlot(src, slot)
    if not item then return end
    
    if item.name ~= packName then return end
    
    local itemData = Config.Inventory == 'ox_inventory' and item.metadata or item.info
    local currentUses = (itemData and itemData.uses) or Config.DefaultPackUses
    local newUses = currentUses - 1
    
    local success = AddItem(src, 'cigarette', 1)
    if not success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Cigarettes',
            description = 'Your inventory is full',
            type = 'error'
        })
        return
    end
    
    if newUses <= 0 then
        RemoveItem(src, packName, 1, itemData, slot)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Cigarette Pack',
            description = 'The pack is now empty',
            type = 'inform'
        })
    else
        SetMetadata(src, slot, { uses = newUses })
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Cigarette Pack',
            description = newUses .. ' cigarettes remaining',
            type = 'inform'
        })
    end
end)

-- Use cigarette (remove from inventory)
RegisterNetEvent('n5rp_cigs:cigarettes:server:UseCigarette', function(slot)
    local src = source
    local item = GetItemSlot(src, slot)
    if not item or item.name ~= 'cigarette' then return end
    
    local metadata = Config.Inventory == 'ox_inventory' and item.metadata or item.info
    RemoveItem(src, 'cigarette', 1, metadata, slot)
end)

-- Raucheffekt an alle Spieler senden
RegisterNetEvent('n5rp_cigs:server:SyncSmoke', function(netId)
    TriggerClientEvent('sunny-cigs:client:ShowSmoke', -1, netId)
end)