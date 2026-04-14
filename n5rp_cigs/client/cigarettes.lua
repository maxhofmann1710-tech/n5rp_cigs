local isSmoking = false
local cigaretteProp = nil
local currentPuffs = 0
local nicotineLevel = 0.0
local displayNicotine = 0.0
local isPassedOut = false

-- ==========================================
-- INVENTORY WRAPPER
-- ==========================================
local function HasItem(itemName)
    if Config.Inventory == 'ox_inventory' then
        local count = exports.ox_inventory:Search('count', itemName)
        return (count or 0) >= 1
    elseif Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.items then
            for _, item in pairs(PlayerData.items) do
                if item.name == itemName then return true end
            end
        end
    end
    return false
end

-- ==========================================
-- NIKOTIN LOGIK & HUD
-- ==========================================
CreateThread(function()
    while true do
        local sleep = 1000
        if nicotineLevel > 0 then
            nicotineLevel = nicotineLevel - 0.003 
            if nicotineLevel < 0 then nicotineLevel = 0.0 end
        end

        if displayNicotine > 0.1 or nicotineLevel > 0.1 then
            sleep = 0
            displayNicotine = displayNicotine + (nicotineLevel - displayNicotine) * 0.02
            local x, y = 0.015, 0.985
            local maxWidth = 0.142
            local width = maxWidth * (displayNicotine / 100)
            DrawRect(0.085, y, maxWidth, 0.008, 0, 0, 0, 150)
            DrawRect(x + (width / 2), y, width, 0.008, 255, 200, 0, 200)
        end
        Wait(sleep)
    end
end)

-- ==========================================
-- PASS OUT LOGIK (OHNE RAUSFALLEN)
-- ==========================================
local function PassOut()
    if isPassedOut then return end
    isPassedOut = true
    
    local ped = PlayerPedId()
    if isSmoking then ThrowCigarette() end

    exports.ox_lib:hideTextUI()
    exports.ox_lib:notify({ title = "Nikotin-Schock", description = "Dein Kreislauf sackt ab...", type = "error" })
    
    DoScreenFadeOut(1000)
    Wait(1500)
    
    local inVehicle = IsPedInAnyVehicle(ped, false)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if inVehicle then
        local animDict = "mp_sleep"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Wait(10) end
        TaskPlayAnim(ped, animDict, "sleep_loop", 8.0, -8.0, -1, 49, 0, false, false, false)
    else
        SetPedToRagdoll(ped, 2000, 2000, 0, 0, 0, 0)
    end
    
    DoScreenFadeIn(1000)
    ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.5)
    
    local timer = 20 
    local nextBlackout = GetGameTimer() + 3000

    while timer > 0 do
        Wait(0)
        local gameTimer = GetGameTimer()
        
        if IsPedInAnyVehicle(ped, false) then
            DisableControlAction(0, 71, true) 
            SetVehicleEngineOn(vehicle, true, true, false)
            SetVehicleHandbrake(vehicle, false)
            
            if GetEntitySpeed(vehicle) > 0.1 then
                TaskVehicleTempAction(ped, vehicle, 11, 1000)
            end

            DisableControlAction(0, 75, true)
        else
            if not IsPedRagdoll(ped) then
                SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
            end
        end

        if gameTimer > nextBlackout then
            DoScreenFadeOut(400)
            Wait(600)
            DoScreenFadeIn(400)
            nextBlackout = gameTimer + math.random(3000, 6000)
        end
        
        SetTextFont(4)
        SetTextScale(0.55, 0.55)
        SetTextColour(255, 255, 255, 200)
        SetTextEntry("STRING")
        AddTextComponentString("Erholung: " .. timer .. "s")
        DrawText(0.45, 0.85)
        
        if math.fmod(GetGameTimer(), 1000) < 20 then
            timer = timer - 1
            Wait(20)
        end
    end
    
    StopGameplayCamShaking(true)
    ClearPedTasks(ped)
    isPassedOut = false
    nicotineLevel = 10.0
    displayNicotine = 10.0
    exports.ox_lib:notify({ title = "Erholt", description = "Du stehst wieder fest auf den Beinen.", type = "success" })
end

-- ==========================================
-- HILFSFUNKTIONEN & SYNCHRONISATION
-- ==========================================
function UpdateTextUI()
    if isPassedOut then return end
    local puffsRemaining = Config.MaxPuffs - currentPuffs
    -- Hier wurde der Punkt durch ein einfaches " | " ersetzt
    exports.ox_lib:showTextUI('[E] Rauchen (' .. puffsRemaining .. '/' .. Config.MaxPuffs .. ') | [G] Wegwerfen', {
        position = "left-center",
        icon = 'cigarette',
        style = { borderRadius = 0, backgroundColor = '#141517', color = 'white' }
    })
end

function AttachCigarette()
    if cigaretteProp then return end
    local ped = PlayerPedId()
    local propModel = Config.PropModel
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do Wait(10) end
    local coords = GetEntityCoords(ped)
    cigaretteProp = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(cigaretteProp, ped, GetPedBoneIndex(ped, Config.PropBone), Config.PropOffset.x, Config.PropOffset.y, Config.PropOffset.z, Config.PropRotation.x, Config.PropRotation.y, Config.PropRotation.z, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(propModel)
end

function RemoveCigarette()
    if cigaretteProp then DeleteEntity(cigaretteProp) cigaretteProp = nil end
    isSmoking = false
    currentPuffs = 0
    exports.ox_lib:hideTextUI()
end

-- Synchronisierter Raucheffekt
function CreateSmokeEffect()
    local ped = PlayerPedId()
    local netId = NetworkGetNetworkIdFromEntity(ped)
    TriggerServerEvent('n5rp_cigs:server:SyncSmoke', netId)
end

RegisterNetEvent('n5rp_cigs:client:ShowSmoke', function(targetNetId)
    local targetPed = NetToPed(targetNetId)
    if DoesEntityExist(targetPed) then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do Wait(10) end
        UseParticleFxAssetNextCall("core")
        local particle = StartParticleFxLoopedOnPedBone("exp_grd_bzgas_smoke", targetPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0x796E, 0.4, false, false, false)
        SetTimeout(3000, function() 
            if particle then StopParticleFxLooped(particle, false) end 
        end)
    end
end)

function PuffCigarette()
    if not isSmoking or not cigaretteProp or isPassedOut then return end
    nicotineLevel = nicotineLevel + 12.0 
    currentPuffs = currentPuffs + 1

    if nicotineLevel >= 100 then
        PassOut()
        return
    end

    local ped = PlayerPedId()
    local animDict = IsPedInAnyVehicle(ped, false) and "amb@world_human_smoking@male@male_b@base" or "amb@world_human_aa_smoke@male@idle_a"
    local animName = IsPedInAnyVehicle(ped, false) and "base" or "idle_c"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 3000, 49, 0, false, false, false)

    SetTimeout(1500, function() if isSmoking and not isPassedOut then CreateSmokeEffect() end end)
    Wait(3000)

    if isSmoking and not isPassedOut then
        local idleDict = IsPedInAnyVehicle(ped, false) and "amb@world_human_smoking@male@male_b@idle_a" or "amb@world_human_smoking@male@male_a@idle_a"
        RequestAnimDict(idleDict)
        while not HasAnimDictLoaded(idleDict) do Wait(10) end
        TaskPlayAnim(ped, idleDict, "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)
    end
    
    TriggerServerEvent('hud:server:RelieveStress', math.random(Config.MinStress, Config.MaxStress))
    UpdateTextUI()
    if currentPuffs >= Config.MaxPuffs then RemoveCigarette() end
end

function ThrowCigarette()
    local ped = PlayerPedId()
    if not cigaretteProp then return end
    isSmoking = false
    exports.ox_lib:hideTextUI()
    ClearPedTasks(ped)
    local cigToThrow = cigaretteProp
    cigaretteProp = nil
    DetachEntity(cigToThrow, true, true)
    local pedHeading = GetEntityHeading(ped)
    ApplyForceToEntity(cigToThrow, 1, -math.sin(math.rad(pedHeading)) * 5.0, math.cos(math.rad(pedHeading)) * 5.0, 2.5, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    SetTimeout(5000, function() if DoesEntityExist(cigToThrow) then DeleteEntity(cigToThrow) end end)
end

-- ==========================================
-- EVENTS
-- ==========================================
RegisterNetEvent('n5rp_cigs:cigarettes:client:UseCigarette', function(item)
    if isSmoking or isPassedOut then return end
    if not HasItem('lighter') then
        exports.ox_lib:notify({ title = "Feuerzeug", description = "Du hast kein Feuerzeug!", type = "error" })
        return
    end

    if exports.ox_lib:progressBar({
        duration = Config.LightCigTime * 1000,
        label = "Zigarette anzünden...",
        useWhileDead = false,
        canCancel = true,
        disable = { move = false, car = false, combat = true }
    }) then
        TriggerServerEvent('n5rp_cigs:cigarettes:server:UseCigarette', item.slot or 1)
        AttachCigarette()
        isSmoking = true
        currentPuffs = 0
        local ped = PlayerPedId()
        Wait(100)
        local idleDict = IsPedInAnyVehicle(ped, false) and "amb@world_human_smoking@male@male_b@idle_a" or "amb@world_human_smoking@male@male_a@idle_a"
        RequestAnimDict(idleDict)
        while not HasAnimDictLoaded(idleDict) do Wait(10) end
        TaskPlayAnim(ped, idleDict, "idle_a", 8.0, -8.0, -1, 49, 0, false, false, false)
        UpdateTextUI()

        CreateThread(function()
            while isSmoking and not isPassedOut do
                Wait(0)
                if IsControlJustPressed(0, 38) then PuffCigarette() end
                if IsControlJustPressed(0, 47) then ThrowCigarette() break end
                if not exports.ox_lib:isTextUIOpen() and isSmoking then UpdateTextUI() end
            end
            exports.ox_lib:hideTextUI()
        end)
    end
end)