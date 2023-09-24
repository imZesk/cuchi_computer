Framework = nil

SetTimeout(0, function()
    local success, result
    if Config.Framework == "esx" then
        success, result = pcall(function()
            if Config.FrameworkOptionalExportName ~= "" then
                return exports[Config.FrameworkResourceName][Config.FrameworkOptionalExportName]()
            end
            return exports[Config.FrameworkResourceName]:getSharedObject()
        end)
    elseif Config.Framework == "qbcore" then
        success, result = pcall(function()
            if Config.FrameworkOptionalExportName ~= "" then
                return exports[Config.FrameworkResourceName][Config.FrameworkOptionalExportName]()
            end
            return exports[Config.FrameworkResourceName]:GetCoreObject()
        end)
    end

    if success then
        Framework = result

        if Config.Framework == "qbcore" then -- standardization of framework functions
            Framework.TriggerServerCallback = Framework.Functions.TriggerCallback
        end
    else
        print("^1Error loading the framework.\n-> Check if you entered the good framework value and its resource name in ^7"..GetCurrentResourceName().."/config.lua")
    end

    TriggerServerEvent("cuchi_computer:getIdentifier")
end)

if #Config.UsablePositions > 0 then
    CreateThread(function()
        while true do
            if UIOpen then
                Wait(500)
                goto skip
            end

            local playerPedId = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPedId)

            local nearestDistance
            local nearestIndex = 0
            for i = 1, #Config.UsablePositions, 1 do
                local currentDistance = #(playerCoords - Config.UsablePositions[i])
                if not nearestDistance or currentDistance < nearestDistance then
                    nearestDistance = currentDistance
                    nearestIndex = i
                end
            end

            if nearestDistance and nearestDistance < 2.0 then
                CustomDrawMarker(Config.UsablePositions[nearestIndex])
                CustomHelpNotification(GetLocale("start_computer"))

                if IsControlJustPressed(0, 51) then
                    OpenUI(Config.UsablePositions[nearestIndex])
                end
                Wait(0)
            else
                Wait(500)
            end

            ::skip::
        end
    end)
end

RegisterNetEvent("cuchi_computer:getIdentifier", function(identifier)
    SendNUIMessage({
        type = "identifier",
        identifier = identifier
    })
end)

local computerDict = "anim@scripted@ulp_missions@computerhack@heeled@"
local computerpName = "hacking_loop"

local laptopDict = "missfam6leadinoutfam_6_mcs_1"
local laptopName = "leadin_loop_c_laptop_girl"
local laptopPropName = joaat("prop_laptop_01a")
local laptopProp = 0

local shouldStop = false

function StartAnimation(laptop)
    local dict = computerDict
    local anim = computerpName

    if laptop then
        dict = laptopDict
        anim = laptopName

        RequestModel(laptopPropName)
        while not HasModelLoaded(laptopPropName) do
            Wait(0)
        end

        laptopProp = CreateObject(laptopPropName, 0, 0, 0, true, true, true)
        SetModelAsNoLongerNeeded(laptopPropName)
        AttachEntityToEntity(laptopProp, PlayerPedId(), 11816, 0.0, 0.42, 0.26, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
    end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    while not shouldStop do
        TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 17, 0, false, false, false)
        Wait(2000)
    end

    RemoveAnimDict(dict)
end

function StopAnimation(laptop)
    shouldStop = true
    local dict = computerDict
    local anim = computerpName

    if laptop then
        dict = laptopDict
        anim = laptopName

        DeleteObject(laptopProp)
    end

    StopEntityAnim(PlayerPedId(), anim, dict, 0)
end
