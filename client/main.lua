lib.locale()
local pedsCreate = {}

local loadModel = function(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

local splitCoords = function(coords)
    local x, y, z, h = string.match(coords, "(.*), (.*), (.*), (.*)")
    return tonumber(x), tonumber(y), tonumber(z), tonumber(h)
end

local function openPedBuilder()
    lib.registerContext({
        id = 'ped_builder',
        title = locale("menu_title"),
        options = {
            {
                title = locale("bouton_gestions_peds"),
                description = locale("bouton_gestions_peds_desc"),
                icon = "fa fa-users",
                onSelect = function()
                    print("Pressed the button!")
                end,
            }
        }
    })
end

local function openPedBuilderLo()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local pedHeading = GetEntityHeading(PlayerPedId())
    local defaultPos = string.format("%f, %f, %f, %f", pedCoords.x, pedCoords.y, pedCoords.z, pedHeading)
    
    local pedInfo = lib.inputDialog('OX PED BUILDER', {
        {type = 'input', label = locale('pedName'), description = locale('pedModel'), required = true, default = Config.PlaceHolderPed},
        {type = 'input', label = locale('pedPosition'), description = locale('pedPositionDesc'), required = true, default = defaultPos},
        {type = 'checkbox', label = locale('pedFreeze'), description = locale('pedFreezeDesc'), default = false, checked = true},
        {type = 'checkbox', label = locale('pedInvincible'), description = locale('pedInvincibleDesc'), default = false, checked = true},
    })
    local coordx, coordy, coordz, coordh = splitCoords(pedInfo[2])
    local coords = {x = coordx, y = coordy, z = coordz, h = coordh}
    TriggerServerEvent('ox_pedbuilder:createNewPed', pedInfo, coords)
end

if Config.CommandCopyCoords then
    RegisterCommand(Config.CommandCopyCoordsName, function(source, args, rawCommand)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local pedHeading = GetEntityHeading(PlayerPedId())
        lib.setClipboard(string.format("%f, %f, %f, %f", pedCoords.x, pedCoords.y, pedCoords.z, pedHeading))
    end, false)
end

RegisterNetEvent("ox_pedbuilder:openPedBuilder")
AddEventHandler("ox_pedbuilder:openPedBuilder", function(args)
    openPedBuilder()
end)

local function createPed(pedListes)
    for _, ped in pairs(pedListes) do
        loadModel(ped.pedModel)
        local pedId = CreatePed(4, ped.pedModel, ped.pedPosition.x, ped.pedPosition.y, ped.pedPosition.z - 1, ped.pedPosition.h, false, false)
        SetEntityInvincible(pedId, ped.isGodMode)
        FreezeEntityPosition(pedId, ped.isFreezed)
        SetBlockingOfNonTemporaryEvents(pedId, true)
        pedsCreate[#pedsCreate + 1] = pedId
    end 
end

RegisterNetEvent('ox_pedbuilder:spawnPed')
AddEventHandler('ox_pedbuilder:spawnPed', function(ped)
    loadModel(ped.pedModel)
    local pedId = CreatePed(4, ped.pedModel, ped.pedPosition.x, ped.pedPosition.y, ped.pedPosition.z - 1, ped.pedPosition.h, false, false)
    SetEntityInvincible(pedId, ped.isGodMode)
    FreezeEntityPosition(pedId, ped.isFreezed)
    SetBlockingOfNonTemporaryEvents(pedId, true)
    pedsCreate[#pedsCreate + 1] = pedId
end)

-- Create peds when the player loaded
Citizen.CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            Wait(1000)
            lib.callback('ox_pedBuilder:getPedsListes', false, function(pedListes)
                createPed(pedListes)
            end)
            break
        end
        Wait(0)
    end
end)

-- Delete peds when the resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for _, ped in pairs(pedsCreate) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
            DeletePed(ped)
        end
    end
end)
