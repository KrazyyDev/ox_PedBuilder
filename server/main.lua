lib.locale()

local pedDatas = {}

-- Verified if the player is authorised
local isAuthorised = function(playerId)    
    local identifiers = GetPlayerIdentifiers(playerId)
    local isAuthoris = false
    for _, id in pairs(identifiers) do
        for _, admin in pairs(Config.OpenAuthorisation) do
            if id == admin then
                isAuthoris = true
                break
            end
        end
    end
    return isAuthoris
end

-- Command to open the ped builder
RegisterCommand(Config.CommandOpenPedBuilderName, function(source, args, rawCommand)
    local src = tonumber(source)
    if isAuthorised(src) then
        TriggerClientEvent("ox_pedbuilder:openPedBuilder", src)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('error'),
            description = locale('noPermission'),
            type = 'error'
        })
    end
end, false)

-- Event pour save le ped dans le json
RegisterNetEvent('ox_pedbuilder:createNewPed')
AddEventHandler('ox_pedbuilder:createNewPed', function(pedInfo, pedCoords)
    local src = source
    if isAuthorised(src) then
        local pedModel = pedInfo[1]
        local pedPosition = pedCoords
        local isFreezed = pedInfo[3]
        local isGodMode = pedInfo[4]
        local ped = {
            pedModel = pedModel,
            pedPosition = pedPosition,
            isFreezed = isFreezed,
            isGodMode = isGodMode
        }
        pedDatas[#pedDatas + 1] = ped
        SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, {indent = true}), -1)
        TriggerClientEvent('ox_pedbuilder:spawnPed', -1, ped)
        print("^2[OX PED BUILDER] ^0Nouveau ped ajouté avec succès")
    else
        print("^1 Cheater detected !", GetPlayerName(src), "ID", src)
    end
end)

-- Event pour remplir la table ped au demarage de de la ressource
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    local data = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    
    if data then
        pedDatas = json.decode(data)
        print("^1[OX PED BUILDER] ^2Les peds ont été chargés avec succès ^0( " .. #pedDatas .. " peds )")
    else
        print("^1[OX PED BUILDER] ^1Impossible de charger les données depuis 'peds.json'")
    end
end)

-- server callback pour renvoyer les peds coter client
lib.callback.register('ox_pedBuilder:getPedsListes', function()
    return pedDatas
end)

