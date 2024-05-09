lib.locale()
local pedDatas = {}
local pedCreate = {}

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
    local pedsGestionsOptions = {}
    
    for name, animation in pairs(Config.AnimationsListes) do
        optionsAnimation[#optionsAnimation + 1] = {label = name, value = name}
    end
    
    for _, ped in pairs(pedDatas) do
        local options = {
            title = ped.model,
            description = string.format("X: %f, Y: %f, Z: %f, H: %f", ped.coords.x, ped.coords.y, ped.coords.z, ped.coords.h),
            icon = "fa fa-user-circle",
            onSelect = function()
                SetEntityCoords(PlayerPedId(), ped.coords.x, ped.coords.y, ped.coords.z)
                local newPedInfo = lib.inputDialog('OX PED BUILDER', {
                    {type = 'input', label = locale('Ped_Options.Ped_Model'), description = locale('Ped_Options.Ped_Model_Description'), required = true, default = ped.model},
                    {type = 'input', label = locale('Ped_Options.Ped_PositionX'), required = true, default = ped.coords.x},
                    {type = 'input', label = locale('Ped_Options.Ped_PositionY'), required = true, default = ped.coords.y},
                    {type = 'input', label = locale('Ped_Options.Ped_PositionZ'), required = true, default = ped.coords.z},
                    {type = 'input', label = locale('Ped_Options.Ped_PositionH'), required = true, default = ped.coords.h},
                    {type = 'checkbox', label = locale('Ped_Options.Ped_Freeze'), description = locale('Ped_Options.Ped_Freeze_Description'), checked = ped.freeze},
                    {type = 'checkbox', label = locale('Ped_Options.Ped_Invincible'), description = locale('Ped_Options.Ped_Invincible_Description'), checked= ped.invincible},
                    {type = 'checkbox', label = locale('Ped_Options.Ped_Non_Temporary_Events'), description = locale('Ped_Options.Ped_Non_Temporary_Events_Description'), checked = ped.temporary},
                    {type = 'select', label = locale('Ped_Options.Ped_Animation'), description = locale('Ped_Options.Ped_Animation_Description'), options = optionsAnimation, required = false},
                })
                
                if newPedInfo then
                    local coordx, coordy, coordz, coordh = splitCoords(newPedInfo[2]..", "..newPedInfo[3]..", "..newPedInfo[4]..", "..newPedInfo[5])
                    local coords = {x = coordx, y = coordy, z = coordz, h = coordh}
                    local data = {
                        model = newPedInfo[1],
                        coords = {
                            x = newPedInfo[2],
                            y = newPedInfo[3],
                            z = newPedInfo[4],
                            h = newPedInfo[5]
                        },
                        freeze = newPedInfo[6],
                        invincible = newPedInfo[7],
                        temporary = newPedInfo[8],
                        animation = Config.AnimationsListes[newPedInfo[9]],
                        index = ped.index
                    }
                    
                    TriggerServerEvent('ox:pedBuilder:UpdatePed', data)
                end
            end,
            metadata = { 
                {label = "Index", value = ped.index },
                {label = "Model", value = ped.model },
            }}
            pedsGestionsOptions[#pedsGestionsOptions + 1] = options
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
                        
                        local pedInfo = lib.inputDialog('OX PED BUILDER', {
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
                {
                    title = locale('Menu.Bouton_Edit_Peds'),
                    description = locale('Menu.Bouton_Edit_Peds_Description'),
                    icon = "fa fa-user-circle",
                    menu = 'gestions_peds',
                }
            }
        })
        
        lib.registerContext({
            id = 'gestions_peds',
            title = locale('Menu.Gestion_Peds_Title'),
            menu = 'ped_builder',
            options = pedsGestionsOptions
        })
        
        lib.showContext('ped_builder')
    end
    
    -- Fonction pour créer les PNJs
    local function LoadPedClient(model, freeze, invincible, temporary, coords, animation)    
        loadModel(model)
        local ped_build = CreatePed(4, model, coords.x, coords.y, coords.z -1, coords.h, false, false)
        SetEntityInvincible(ped_build, invincible)
        FreezeEntityPosition(ped_build, freeze)
        SetBlockingOfNonTemporaryEvents(ped_build, temporary)
        if animation then
            loadAnimDict(animation.dict)
            if DoesAnimDictExist(animation.dict) then
                TaskPlayAnim(ped_build, animation.dict, animation.animation, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
            else
                print("Le dictionnaire d'animation n'existe pas : " .. animation.dict)
            end
        end
        pedCreate[#pedCreate + 1] = ped_build
    end
    
    Citizen.CreateThread(function()
        local peds = LoadResourceFile(GetCurrentResourceName(), 'peds.json')
        if peds then
            pedDatas = json.decode(peds)
            Wait(1000)
            for _, ped in pairs(pedDatas) do
                if ped.animation then
                    LoadPedClient(ped.model, ped.freeze, ped.invincible, ped.temporary, ped.coords, ped.animation)
                else
                    LoadPedClient(ped.model, ped.freeze, ped.invincible, ped.temporary, ped.coords)
                end
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
            if data.animation then
                LoadPedClient(data.model, data.freeze, data.invincible, data.temporary, data.coords, data.animation)
            else
                LoadPedClient(data.model, data.freeze, data.invincible, data.temporary, data.coords)
            end
            pedDatas[#pedDatas + 1] = data
        elseif action == "update" then
            for i, ped in pairs(pedDatas) do
                if ped.index == data.index then
                    local peds = lib.getNearbyPeds(vector3(ped.coords.x, ped.coords.y, ped.coords.z), 1)
                    DeleteEntity(peds[1].ped)
                    if ped.animation then
                        LoadPedClient(data.model, data.freeze, data.invincible, data.temporary, data.coords, data.animation)
                    else
                        LoadPedClient(data.model, data.freeze, data.invincible, data.temporary, data.coords)
                    end
                end
            end
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