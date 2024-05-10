lib.locale()
local pedDatas = {}

-- Function to check if a player is authorized
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

-- Registering the function to check permissions
lib.callback.register('ox:pedBuilder:asPermissions', function()
    return isAuthorized(tonumber(source))
end)

-- Event to create a new ped
RegisterNetEvent('ox:pedBuilder:CreateNewPed')
AddEventHandler('ox:pedBuilder:CreateNewPed', function(pedData)
    local _src = tonumber(source)
    local file = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    if file then
        pedDatas = json.decode(file)
    end
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
        TriggerClientEvent('ox:pedBuilder:UpdateTable', -1, pedDatas)
    else
        DropPlayer(_src, 'Unauthorized')
        print("[OX PED BUILDER] [CHEATER DETECTED] [".._src.."] ["..GetPlayerName(_src).." ]")
    end
end)

-- Event pour update un ped
RegisterNetEvent('ox:pedBuilder:UpdatePed')
AddEventHandler('ox:pedBuilder:UpdatePed', function(pedData)
    local _src = tonumber(source)
    local file = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    if file then
        pedDatas = json.decode(file)
    end
    if isAuthorized(_src) then
        local data = {
            model = pedData.model,
            freeze = pedData.freeze,
            coords = pedData.coords,
            invincible = pedData.invincible,
            temporary = pedData.temporary,
            animation = pedData.animation,
            animationDict = pedData.animationDict,
            index = pedData.index
        }
        pedDatas[pedData.index] = data
        TriggerClientEvent('ox:pedBuilder:UpdatePed', -1, "update", data)
        SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, { indent = true }))
        TriggerClientEvent('ox:pedBuilder:UpdateTable', -1, pedDatas)
    else
        DropPlayer(_src, 'Unauthorized')
        print("[OX PED BUILDER] [CHEATER DETECTED] [".._src.."] ["..GetPlayerName(_src).." ]")
    end
end)

-- Event to delete a ped
RegisterNetEvent('ox:pedBuilder:DeletePed')
AddEventHandler('ox:pedBuilder:DeletePed', function(index)
    local _src = tonumber(source)
    local file = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    local pedDatas = {}

    if file then
        pedDatas = json.decode(file)
    end

    if isAuthorized(_src) then
        local foundIndex = nil
        for i, ped in ipairs(pedDatas) do
            if ped.index == index then
                foundIndex = i
                TriggerClientEvent('ox:pedBuilder:UpdatePed', -1, "delete", ped)
                break
            end
        end

        if foundIndex then
            table.remove(pedDatas, foundIndex)
            SaveResourceFile(GetCurrentResourceName(), 'peds.json', json.encode(pedDatas, { indent = true }))
            TriggerClientEvent('ox:pedBuilder:UpdateTable', -1, pedDatas)
        else
            print("[OX PED BUILDER] [ERROR] Ped with index " .. index .. " not found.")
        end
    else
        DropPlayer(_src, 'Unauthorized')
        print("[OX PED BUILDER] [CHEATER DETECTED] [".._src.."] ["..GetPlayerName(_src).." ]")
    end
end)
