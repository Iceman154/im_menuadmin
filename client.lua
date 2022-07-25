ESX = exports.es_extended:getSharedObject()

-- Variabili
local noclip = false

-- Apertura
RegisterCommand('menuadmin', function()
    ESX.TriggerServerCallback('im_menuadmin:permessi', function(bool)
        if bool then
            MenuGenerale()
        else
            ESX.ShowNotification(Lang.no_perms)
        end
    end) 
end)

RegisterKeyMapping('menuadmin', Lang.help_key, 'keyboard', Config.OpenKey) 

-- Funzioni Generali
MenuGenerale = function()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ismannonia', {
        title = Lang.general_name,
        align = Config.MenuAlign,
        elements = {
            {label = Lang.players_list, value = 'lista'},
            {label = Lang.ban_list, value = 'listab'},
            {label = Lang.open_player, value = 'menuid'},
            {label = Lang.personal_actions, value = 'menup'},
        }
    },     function(data, menu)
            local verifica = data.current.value
            if verifica == 'lista' then
                MenuListaPlayer()
            elseif verifica == 'menuid' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_man', {
                   title = Lang.id_player
                }, function(data2, menu2)
                    local id = tonumber(data2.value)
                    ESX.TriggerServerCallback('im_menuadmin:checkonline', function(bool)
                        if bool then
                            MenuGestionePlayer(id)
                            menu2.close()
                        else
                            ESX.ShowNotification(Lang.player_not_online, 'error')
                        end
                    end, id)
                end, function(data2, menu2)
                   menu2.close()
                end)
            elseif verifica == 'menup' then
                MenuPersonale()
            elseif verifica == 'listab' then
                MenuListaBan()
            end

        end, 
        function(data, menu)
            menu.close()
    end)
end

MenuListaBan = function()
    ESX.TriggerServerCallback('im_menuadmin:prendituttiban', function(elements)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'aisman', {
            title = Lang.ban_list_name,
            align = Config.MenuAlign,
            elements = elements
        },     function(data, menu)
                local verifica = data.current.value
    
                if verifica == data.current.identifier then
                    local elementi = {
                        {label = string.format(Lang.bl_steam, data.current.steam)},
                        {label = string.format(Lang.bl_motivation, data.current.motivazione)},
                        {label = string.format(Lang.bl_perma, data.current.perma)},
                        {label = string.format(Lang.bl_date_ban, data.current.data)},
                        {label = string.format(Lang.bl_date, data.current.datas)},
                        {label = Lang.bl_delete, value = 'cancella'},
                    }
                    if data.current.perma == 'si' then
                        elementi = {
                            {label = string.format(Lang.bl_steam, data.current.steam)},
                            {label = string.format(Lang.bl_motivation, data.current.motivazione)},
                            {label = string.format(Lang.bl_perma, data.current.perma)},
                            {label = string.format(Lang.bl_date_ban, data.current.data)},
                            {label = string.format(Lang.bl_date, Lang.never)},
                            {label = Lang.bl_delete, value = 'cancella'},
                        }
                    end
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'im_ban', {
                        title = string.format(Lang.ban_list_p_name, data.current.steam),
                        align = Config.MenuAlign,
                        elements = elementi
                    },     function(data2, menu2)
                            local verifica2 = data2.current.value

                            if verifica2 ~= 'cancella' then
                                ESX.ShowNotification('Script made by Ice_man154 - Flavio#7683')
                            else
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_man_check', {
                                   title = Lang.sure
                                }, function(data3, menu3)
                                    local conferma = data3.value
                                    if conferma == 'conferma' or conferma == 'CONFERMA' then
                                        TriggerServerEvent('im_menuadmin:cancellaban', GetPlayerServerId(PlayerId()), verifica)
                                        ESX.ShowNotification(Lang.bln_ban_deleted)
                                        menu3.close()
                                        menu2.close()
                                    else
                                        ESX.ShowNotification(Lang.no_sure, 'info')
                                    end
                                end, function(data3, menu3)
                                   menu3.close()
                                end)
                            end
                
                        end, 
                        function(data2, menu2)
                            menu2.close()
                    end)
                end
            end, 
            function(data, menu)
                menu.close()
        end)
    end)
end

MenuListaPlayer = function()
    ESX.TriggerServerCallback('im_menuadmin:getplayers', function(elements)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'im', {
            title = Lang.player_list_name,
            align = Config.MenuAlign,
            elements = elements
        },     function(data2, menu2)
                local verifica = data2.current.value
                if verifica ~= nil then
                    MenuGestionePlayer(verifica)
                end

            end, 
            function(data2, menu2)
                menu2.close()
        end)
    end)
end

MenuGestionePlayer = function(id)
    ESX.TriggerServerCallback('im_menuadmin:prendisteam', function(steam)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ismannino', {
            title = string.format(Lang.player_manager_name, steam),
            align = Config.MenuAlign,
            elements = {
                {label = Lang.ban_pm, value = 'ban'},
                {label = Lang.kick_pm, value = 'kick'},
                {label = Lang.give_money_pm, value = 'daisoldi'},
                {label = Lang.revive_pm, value = 'revive'},
                {label = Lang.heal_pm, value = 'heal'},
                {label = Lang.setjob_pm, value = 'setjob'},
            }
        },     function(data, menu)
                local verifica = data.current.value

                if verifica == 'ban' then
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'isman', {
                        title = Lang.choose_ban_name,
                        align = Config.MenuAlign,
                        elements = {
                            {label = 'Ban Personalizzato', value = 'person'},
                            {label = 'Ban 1d', value = '1d'},
                            {label = 'Ban Perma', value = 'perma'},
                        }
                    },     function(data, menu)
                            local verifica = data.current.value
                
                            if verifica == 'person' then
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'robo', {
                                title = Lang.quantity_ban
                                }, function(data3, menu3)
                                    local giorni = tonumber(data3.value) * 3600
                                    if type(giorni) == 'number' then
                                        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_manni', {
                                            title = Lang.motivation
                                        }, function(data2, menu2)
                                            local motivazione = data2.value
                                            if motivation == nil then
                                                TriggerServerEvent('im_menuadmin:ban', id, GetPlayerServerId(PlayerId()), Lang.no_motivation, false, giorni)
                                                menu2.close()
                                            else
                                                TriggerServerEvent('im_menuadmin:ban', id, GetPlayerServerId(PlayerId()), motivazione, false, giorni)
                                                menu2.close()
                                            end
                                        end, function(data2, menu2)
                                            menu2.close()
                                        end)
                                        menu3.close()
                                    else
                                        ESX.ShowNotification(Lang.number)
                                    end
                                    menu3.close()
                                end, function(data3, menu3)
                                menu3.close()
                                end)
                            elseif verifica == '1d' then
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_manni', {
                                title = Lang.motivation
                                }, function(data2, menu2)
                                    local motivazione = data2.value
                                    if motivazione == nil then
                                        TriggerServerEvent('im_menuadmin:ban', id, GetPlayerServerId(PlayerId()), Lang.no_motivation, false, 86400)
                                        menu2.close()
                                    else
                                        TriggerServerEvent('im_menuadmin:ban', id, GetPlayerServerId(PlayerId()), motivazione, false, 86400)
                                        menu2.close()
                                    end
                                end, function(data2, menu2)
                                menu2.close()
                                end)                     
                            elseif verifica == 'perma' then
                                TriggerServerEvent('im_menuadmin:ban', id, GetPlayerServerId(PlayerId()), motivazione, true, 1)
                            end
                
                        end, 
                        function(data, menu)
                            menu.close()
                        end
                    )
                elseif verifica == 'kick' then
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_man', {
                    title = Lang.choose_motivation_pm
                    }, function(data2, menu2)
                        if data2.value == nil then
                            TriggeServerEvent('im_menuadmin:kick', id, GetPlayerServerId(PlayerId()), Lang.no_motivation)
                            menu2.close()
                        else
                            TriggeServerEvent('im_menuadmin:kick', id, GetPlayerServerId(PlayerId()), data2.value)
                            menu2.close()
                        end
                    end, function(data2, menu2)
                    menu2.close()
                    end)
                elseif verifica == 'daisoldi' then
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'icem', {
                        title = Lang.choose_type_money_pms,
                        align = Config.MenuAlign,
                        elements = {
                            {label = Lang.ctm_money_pms, value = 'contanti'},
                            {label = Lang.ctm_bank_pms, value = 'banca'},
                            {label = Lang.ctm_dirty_money_pms, value = 'sporchi'},
                        }
                    },     function(data, menu)
                            local verifica = data.current.value
                
                            if verifica ~= nil then
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_mann', {
                                    title = Lang.quantity
                                }, function(data2, menu2)
                                    local quantity = tonumber(data2.value)
                                    TriggerServerEvent('im_menuadmin:daisoldi', id, GetPlayerServerId(PlayerId()), quantity, verifica)
                                    menu2.close()
                                end, function(data2, menu2)
                                    menu2.close()
                                end)
                            end
                
                        end, 
                        function(data, menu)
                            menu.close()
                    end)
                elseif verifica == 'revive' then
                    TriggerEvent(Config.Triggers.revive, GetPlayerServerId(PlayerId()))
                    ESX.ShowNotification(string.format(Lang.revive_pn, id))
                elseif verifica == 'heal' then
                    TriggerEvent(Config.Triggers.heal, GetPlayerServerId(PlayerId()))
                    ESX.ShowNotification(string.format(Lang.heal_pn, id))
                elseif verifica == 'setjob' then
                    local elementi = {}

                    ESX.TriggerServerCallback('im_menuadmin:jobs', function(menu)
                        elementi = menu
                    end)
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ice', {
                        title = string.fromat(Lang.setjob_pms, GetPlayerName(id)),
                        align = Config.MenuAlign,
                        elements = elementi
                    },     function(data, menu)
                            local verifica = data.current.lavoro
                
                            if verifica ~= nil then
                                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_manno', {
                                title = Lang.choose_grade_pms
                                }, function(data2, menu2)
                                    local grado = tonumber(data2.value)
                                    if grado ~= nil then
                                        TriggerServerEvent('im_menuadmin:setjob', id, GetPlayerServerId(PlayerId()), verifica, grado)
                                        menu2.close()
                                    else
                                        ESX.ShowNotification(Lang.nil_value)
                                        menu2.close()
                                    end
                                end, function(data2, menu2)
                                menu2.close()
                                end) 
                            end
                
                        end, 
                        function(data, menu)
                            menu.close()
                    end)
                end

            end, 
            function(data, menu)
                menu.close()
        end)
    end, id)
end

MenuPersonale = function()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'im', {
        title = Lang.personal_menu_name,
        align = Config.MenuAlign,
        elements = {
            {label = Lang.noclip_plm, value = 'noclip'},
            {label = Lang.revive_plm, value = 'revive'},
            {label = Lang.heal_plm, value = 'heal'},
            {label = Lang.car_plm, value = 'daimacchina'},
        }
    },     function(data, menu)
            local verifica = data.current.value

            if verifica == 'noclip' then
                local ped = PlayerPedId()
                local coordinate = GetEntityCoords(ped)
                if not noclip then
                    SetEntityCoordsNoOffset(ped, coordinate, true, true, true)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetEntityCollision(ped, false, false)

                    SetEntityVisible(ped, false, false)

                    SetEveryoneIgnorePlayer(PlayerId(), true)
                    SetPoliceIgnorePlayer(PlayerId(), true)
                    ESX.ShowNotification(Lang.noclip_on_plm)
                    noclip = true
                else
                    FreezeEntityPosition(ped, false)
                    SetEntityInvincible(ped, false)
                    SetEntityCollision(ped, true, true)

                    SetEntityVisible(ped, true, false)

                    SetEveryoneIgnorePlayer(PlayerId(), false)
                    SetPoliceIgnorePlayer(PlayerId(), false)
                    ESX.ShowNotification(Lang.noclip_off_plm)
                    noclip = false
                end
            elseif verifica == 'revive' then
                TriggerEvent(Config.Triggers.revive, GetPlayerServerId(PlayerId()))
                ESX.ShowNotification(Lang.revived_plm)
            elseif verifica == 'heal' then
                TriggerEvent(Config.Triggers.heal, GetPlayerServerId(PlayerId()))
                ESX.ShowNotification(Lang.healed_plm)
            elseif verifica == 'daimacchina' then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local h = GetEntityHeading(ped)
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ice_man', {
                   title = Lang.choose_veh_plm
                }, function(data2, menu2)
                    local modello = data2.value
                    if type(modello) == 'string' then
                        ESX.Game.SpawnVehicle(modello, pos, h, function(vehicle)
                            SetPedIntoVehicle(ped, vehicle, -1)
                        end)
                        ESX.ShowNotification(string.format(Lang.car_spawned_plmn, modello))
                        menu2.close()
                    else
                        ESX.ShowNotification(Lang.nil_value)
                    end
                end, function(data2, menu2)
                   menu2.close()
                end)

            end

        end, 
        function(data, menu)
            menu.close()
    end)
end

Citizen.CreateThread(function()   
    while true do
        local ped = PlayerPedId()
        local wait = 1000
        if noclip then
            wait = 1
            local coordinate = GetEntityCoords(ped, false)
            local camCoords = DirezioneCam()
            local velocita = 2.0
            SetEntityVelocity(ped, 0.01, 0.01, 0.01)

            if IsControlPressed(0, 21) then
                velocita = 5.0
            end

            if IsControlPressed(0, 32) then
                coordinate = coordinate + (velocita * camCoords)
            end

            if IsControlPressed(0, 269) then
                coordinate = coordinate - (velocita * camCoords)
            end
            SetEntityCoordsNoOffset(ped, coordinate, true, true, true)
        end
        Wait(wait)
    end
end)

function DirezioneCam()
    local ped = PlayerPedId()
	local heading = GetGameplayCamRelativeHeading() + GetEntityPhysicsHeading(ped)
	local pitch = GetGameplayCamRelativePitch()
	local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
	local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

	if len ~= 0 then
		coords = coords / len
	end

	return coords
end