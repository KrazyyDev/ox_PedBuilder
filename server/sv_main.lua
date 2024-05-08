lib.locale()
local pedDatas = {}

-- Fonction pour vérifier si un joueur est autorisé
local isAuthorized = function(playerId)    
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in pairs(identifiers) do
        for _, admin in pairs(Config.OpenAuthorization) do
            if id == admin then
                return true
            end
        end
    end
    return false
end

-- Enregistrement de la fonction pour vérifier les autorisations
lib.callback.register('ox:pedBuilder:asPermissions', function()
    return isAuthorized(tonumber(source))
end)

-- Événement pour créer un nouveau ped
RegisterNetEvent('ox:pedBuilder:CreateNewPed')
AddEventHandler('ox:pedBuilder:CreateNewPed', function(pedData)
    local _src = tonumber(source)
    if isAuthorized(_src) then
        local data = {
            model = pedData.model,
            freeze = pedData.freeze,
            coords = pedData.coords,
            invincible = pedData.invincible,
            temporary = pedData.temporary,
            animation = pedData.animation,
            animationDict = pedData.animationDict,
            index = #pedDatas + 1
        }
        pedDatas[#pedDatas + 1] = data
        TriggerClientEvent('ox:pedBuilder:UpdatePed', -1, "add", data)
        SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, { indent = true }))
    else
        DropPlayer(_src, 'Unauthorized')
        print("[OX PED BUILDER] [CHEATER DETECTED] [".._src.."] ["..GetPlayerName(_src).." ]")
    end
end)
