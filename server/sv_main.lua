local pedDatas = {}

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

lib.callback.register('ox:pedBuilder:asPermissions', function()
    return isAuthorized(tonumber(source))
end)

RegisterNetEvent('ox:pedBuilder:CreateNewPed')
AddEventHandler('ox:pedBuilder:CreateNewPed', function(pedData)
    local _src = tonumber(source)
    print(json.encode(pedData, { indent = true }))
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
        TriggerClientEvent('ox:pedBuilder:UpdatePed', "add", data)
        SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, { indent = true }))
    else
        DropPlayer(_src, 'Unauthorized')
        print("[OX PED BUILDER] [CHEATER DETECTED] [".._src.."] ["..GetPlayerName(_src).." ]")
    end
end)
