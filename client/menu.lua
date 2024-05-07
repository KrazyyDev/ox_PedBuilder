local selectedPed = nil

local function openPedBuilderMenu(pedData)
    local optionPeds = {}
    
    for _, ped in pairs(pedData) do
        local data = {
            title = ped.pedModel,
            description = ped.pedPosition,
            icon = "fa fa-users",
            onSelect = function()
                selectedPed = ped
                lib.showContext("ped_builder_gestion_selected_ped")
            end,
        }
        optionPeds[#optionPeds + 1] = data
    end
    
    lib.registerContext({
        id = "ped_builder",
        title = locale("menu_title"),
        options = {
            {
                title = locale("bouton_create_ped"),
                description = locale("bouton_create_ped_desc"),
                icon = "fa fa-users",
                onSelect = function()
                    openCreatePedInpute()
                end,
            },
            {
                title = locale("bouton_gestions_peds"),
                description = locale("bouton_gestions_peds_desc"),
                icon = "fa fa-users",
                menu = "ped_builder_gestion_peds",
            }
        }
    })
    
    lib.registerContext({
        id = "ped_builder_gestion_peds",
        title = locale("menu_title"),
        menu = 'ped_builder',
        options = optionPeds
    })
    
    lib.showContext('ped_builder')
end

lib.registerContext({
    id = "ped_builder_gestion_selected_ped",
    title = locale("menu_title"),
    options = {
        {
            title = locale("bouton_teleport_ped"),
            description = locale("bouton_teleport_ped_desc"),
            icon = "fa fa-users",
            onSelect = function()
                if selectedPed then
                    SetEntityCoords(PlayerPedId(), selectedPed.pedPosition.x, selectedPed.pedPosition.y, selectedPed.pedPosition.z)
                end
            end,
        },
        {
            title = locale("bouton_delete_ped"),
            description = locale("bouton_delete_ped_desc"),
            icon = "fa fa-users",
            onSelect = function()
                if selectedPed then
                    TriggerServerEvent('ox_pedbuilder:deleteSelectedPed', selectedPed)
                end
            end,
        }
    }
})

-- Event pour ouvrir le menu
RegisterNetEvent("ox_pedbuilder:openPedBuilder")
AddEventHandler("ox_pedbuilder:openPedBuilder", function(pedData)
    openPedBuilderMenu(pedData)
end)
