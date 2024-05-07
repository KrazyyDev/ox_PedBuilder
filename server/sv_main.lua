lib.locale()

local pedDatas = {}

-- Generate a unique ped id
local generateUniquePedId = function()
    return lib.string.random("1111111111", 10)
end

-- Verify if the player is authorized
local isAuthorized = function(playerId)    
    local identifiers = GetPlayerIdentifiers(playerId)
    local isAuthorized = false
    for _, id in pairs(identifiers) do
        for _, admin in pairs(Config.OpenAuthorization) do
            if id == admin then
                isAuthorized = true
                break
            end
        end
    end
    return isAuthorized
end

-- Command to open the ped builder
RegisterCommand(Config.CommandOpenPedBuilderName, function(source, args, rawCommand)
    local src = tonumber(source)
    if isAuthorized(src) then
        TriggerClientEvent("ox_pedbuilder:openPedBuilder", src, pedDatas)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('error'),
            description = locale('noPermission'),
            type = 'error'
        })
    end
end, false)

-- Event to save the created ped in the JSON
RegisterNetEvent('ox_pedbuilder:createNewPed')
AddEventHandler('ox_pedbuilder:createNewPed', function(pedInfo, pedCoords)
    local src = source
    if isAuthorized(src) then
        local pedModel = pedInfo[1]
        local pedPosition = pedCoords
        local isFrozen = pedInfo[3]
        local isGodMode = pedInfo[4]
        local ped = {
            pedModel = pedModel,
            pedPosition = pedPosition,
            isFrozen = isFrozen,
            isGodMode = isGodMode,
            uniquePedId = generateUniquePedId()
        }
        pedDatas[ped.uniquePedId] = ped
        SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, {indent = true}), -1)
        TriggerClientEvent('ox_pedbuilder:spawnPed', -1, ped)
        print("^2[OX PED BUILDER] ^0", locale('pedCreated'))
    else
        print("^1[OX PED BUILDER] Cheater detected !", GetPlayerName(src), "ID", src)
    end
end)

RegisterNetEvent('ox_pedbuilder:deleteSelectedPed')
AddEventHandler('ox_pedbuilder:deleteSelectedPed', function(ped)
    local src = source
    if isAuthorized(src) then
        pedDatas[ped.uniquePedId] = nil
        TriggerClientEvent('ox_pedbuilder:deletePed', -1, ped.pedPosition)
        SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, {indent = true}), -1)
        print("^2[OX PED BUILDER] ^0", locale('pedDeleted'))
    else
        print("^1 Cheater detected !", GetPlayerName(src), "ID", src)
    end
end)

-- Load peds when the resource is started
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    local data = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    if data then
        pedDatas = json.decode(data)
        print(string.format(locale('pedsBuilder_Loaded_success'), #pedDatas))
    else
        print(locale("pedsBuilder_Loaded_error"))
    end
end)

-- Register the callback to get the peds list
lib.callback.register('ox_pedBuilder:getPedsList', function()
    return pedDatas
end)
