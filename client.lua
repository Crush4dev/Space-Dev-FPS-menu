local function applyHigh()
    SetTimecycleModifier('MP_Powerplay_blend')
    SetExtraTimecycleModifier('reflection_correct_ambient')
end

local function applyMed()
    local ped = PlayerPedId()
    SetTimecycleModifier('tunnel')
    ClearAllBrokenGlass()
    ClearAllHelpMessages()
    LeaderboardsReadClearAll()
    ClearBrief()
    ClearGpsFlags()
    ClearPrints()
    ClearSmallPrints()
    ClearReplayStats()
    LeaderboardsClearCacheData()
    ClearFocus()
    ClearHdArea()
    ClearPedBloodDamage(ped)
    ClearPedWetness(ped)
    ClearPedEnvDirt(ped)
    ResetPedVisibleDamage(ped)
    ClearOverrideWeather()
    ClearHdArea()
    DisableScreenblurFade()
    SetRainLevel(0.0)
    SetWindSpeed(0.0)
end

local function applyLow()
    local ped = PlayerPedId()
    SetTimecycleModifier('yell_tunnel_nodirect')
    ClearAllBrokenGlass()
    ClearAllHelpMessages()
    LeaderboardsReadClearAll()
    ClearBrief()
    ClearGpsFlags()
    ClearPrints()
    ClearSmallPrints()
    ClearReplayStats()
    LeaderboardsClearCacheData()
    ClearFocus()
    ClearHdArea()
    ClearPedBloodDamage(ped)
    ClearPedWetness(ped)
    ClearPedEnvDirt(ped)
    ResetPedVisibleDamage(ped)
    ClearOverrideWeather()
    DisableScreenblurFade()
    SetRainLevel(0.0)
    SetWindSpeed(0.0)
end

local function applyReset()
    SetTimecycleModifier()
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
end

local KVP_KEY = 'space_fps_preset'

local function savePreset(preset)
    SetResourceKvp(KVP_KEY, preset or '')
end

local function getSavedPreset()
    return GetResourceKvpString(KVP_KEY) or ''
end

local function applyPreset(preset)
    if preset == 'high' then
        applyHigh()
    elseif preset == 'med' then
        applyMed()
    elseif preset == 'low' then
        applyLow()
    elseif preset == 'reset' or preset == '' then
        applyReset()
    end
end

-- Re-apply saved preset on resource start so your choice stays until you change it
CreateThread(function()
    Wait(1000)
    local saved = getSavedPreset()
    if saved == 'high' or saved == 'med' or saved == 'low' then
        applyPreset(saved)
    end
end)

local function openFpsUI()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

local function closeFpsUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand("fps", function()
    openFpsUI()
end, false)

RegisterNUICallback('close', function(_, cb)
    closeFpsUI()
    cb('ok')
end)

RegisterNUICallback('select', function(data, cb)
    local action = data and data.action
    if action == 'high' then
        savePreset('high')
        applyHigh()
    elseif action == 'med' then
        savePreset('med')
        applyMed()
    elseif action == 'low' then
        savePreset('low')
        applyLow()
    elseif action == 'reset' then
        savePreset(nil)  -- clear so no preset is re-applied on next load
        applyReset()
    end
    closeFpsUI()
    cb('ok')
end)

-- Vehicle repair (unchanged)
local function repairVehicle(vehicle)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
end

local options = {
    {
        name = 'mechanic',
        icon = 'fa-solid fa-wrench',
        label = 'Repair',
        onSelect = function(data)
            local success = lib.progressCircle({
                duration = 10000,
                position = 'bottom',
                label = 'Réparation',
                useWhileDead = false,
                canCancel = true,
                disable = { move = true, combat = true },
            })
            if success then
                repairVehicle(data.entity)
            else
                lib.notify({ title = 'Cancel', description = '', type = 'error' })
            end
        end,
    },
}

exports.ox_target:addGlobalVehicle(options)
