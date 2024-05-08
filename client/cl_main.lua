lib.locale()
local pedDatas = {}

local function loadModel(model)
    local modelHash = model
    if type(model) ~= 'number' then
        modelHash = GetHashKey(model)
    end
    while not HasModelLoaded(modelHash) do
        RequestModel(modelHash)
        Citizen.Wait(0)
    end
end

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
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

-- Fonction pour créer les PNJs
local function CreatePedBuilder()    
    for _, ped in pairs(pedDatas) do
        loadModel(ped.model)
        local ped_build = CreatePed(4, ped.model, ped.coords.x, ped.coords.y, ped.coords.z, ped.coords.h, false, false)
        SetEntityInvincible(ped_build, ped.invincible)
        FreezeEntityPosition(ped_build, ped.freeze)
        SetBlockingOfNonTemporaryEvents(ped_build, ped.temporary)
        if ped.animation then
            loadAnimDict(ped.animation.dict)
            if DoesAnimDictExist(ped.animation.dict) then
                TaskPlayAnim(ped_build, ped.animation.dict, ped.animation.animation, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
            else
                print("Le dictionnaire d'animation n'existe pas : " .. ped.animation.dict)
            end
        end
    end
end


Citizen.CreateThread(function()
    local peds = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
    if peds then
        pedDatas = json.decode(peds)
        Wait(1000)
        CreatePedBuilder()
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
        CreatePed(data.model, data.freeze, data.invincible, data.temporary, data.coords, data.animation)
        pedDatas[#pedDatas + 1] = data
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
