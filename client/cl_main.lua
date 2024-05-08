lib.locale()
local pedDatas = {}

local function loadModel(model)
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

local function OpenPedBuilder()
    local optionsAnimation = {}
    
    for name, animation in pairs(Config.AnimationsListes) do
        optionsAnimation[#optionsAnimation + 1] = {label = name, value = name}
    end
    
    lib.registerContext({
        id = 'ped_builder',
        title = locale('Menu.Menu_Tiltle'),
        options = {
            {
                title = locale("Menu.Bouton_Create_Ped"),
                description = locale('Menu.Bouton_Create_Ped_Description'),
                icon = "fa fa-user-circle",
                onSelect = function()
                    local pedCoords = GetEntityCoords(PlayerPedId())
                    local pedHeading = GetEntityHeading(PlayerPedId())
                    local defaultPos = string.format("%f, %f, %f, %f", pedCoords.x, pedCoords.y, pedCoords.z, pedHeading)
                    
                    local pedInfo = lib.inputDialog('OX FARM BUILDER', {
                        {type = 'input', label = locale('Ped_Options.Ped_Model'), description = locale('Ped_Options.Ped_Model_Description'), required = true, default = Config.PlaceHolderPed},
                        {type = 'input', label = locale('Ped_Options.Ped_Position'), description = locale('Ped_Options.Ped_Position_Description') ,required = true, default = defaultPos},
                        {type = 'checkbox', label = locale('Ped_Options.Ped_Freeze'), description = locale('Ped_Options.Ped_Freeze_Description'), checked = true},
                        {type = 'checkbox', label = locale('Ped_Options.Ped_Invincible'), description = locale('Ped_Options.Ped_Invincible_Description'), checked= true},
                        {type = 'checkbox', label = locale('Ped_Options.Ped_Non_Temporary_Events'), description = locale('Ped_Options.Ped_Non_Temporary_Events_Description'), checked = true},
                        {type = 'select', label = locale('Ped_Options.Ped_Animation'), description = locale('Ped_Options.Ped_Animation_Description'), options = optionsAnimation, required = false},
                    })
                    if pedInfo then
                        local coordx, coordy, coordz, coordh = splitCoords(pedInfo[2])
                        local coords = {x = coordx, y = coordy, z = coordz, h = coordh}
                        local data = {
                            model = pedInfo[1],
                            freeze = pedInfo[3],
                            invincible = pedInfo[4],
                            temporary = pedInfo[5],
                            coords = coords,
                            animation = Config.AnimationsListes[pedInfo[6]],
                        }
                        TriggerServerEvent('ox:pedBuilder:CreateNewPed', data)
                    end
                end
            },
        }
    })
    
    lib.showContext('ped_builder')
end

local function CreatePed(data)
    print(data)
    loadModel(data.model)
    local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z, data.coords.h, false, false)
    SetEntityInvincible(ped, data.invincible)
    FreezeEntityPosition(ped, data.freeze)
    SetBlockingOfNonTemporaryEvents(ped, data.temporary)
    if data.animation then
        RequestAnimDict(data.animation.dict)
        TaskPlayAnim(ped, data.animation.dict, data.animation.animation, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
    end
end

Citizen.CreateThread(function()
    local peds = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    if peds then
        pedDatas = json.decode(peds)
        Wait(1000)
        for _, ped in pairs(pedDatas) do
            local data = {
                model = ped.model,
                freeze = ped.freeze,
                invincible = ped.invincible,
                temporary = ped.temporary,
                coords = ped.coords,
                animation = ped.animation,
                index = ped.index
            }
            CreatePed(data)
        end
    else
        lib.notify({
            title = "Erreur",
            description = locale('Menu.Ped_Not_Found'),
            type = 'error'
        })
    end
end)


RegisterNetEvent('ox:pedBuilder:UpdatePed')
AddEventHandler('ox:pedBuilder:UpdatePed', function(action, data)
    if action == "add" then
        CreatePed(data)
    end
end)


RegisterCommand(Config.CommandOpenPedBuilderName, function()
    lib.callback('ox:pedBuilder:asPermissions', false, function(isAuthorised)
        if isAuthorised then
            OpenPedBuilder()
        else
            lib.notify({
                title = "Error",
                description = locale('Menu.Not_Authorized'),
                type = 'error'
            })
        end
    end)
end, false)

