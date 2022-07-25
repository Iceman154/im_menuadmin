ESX = exports.es_extended:getSharedObject()

-- Variabili
local lavori = {}

-- Generale

CheckPerm = function(id)
    local xPlayer = ESX.GetPlayerFromId(id)

    if xPlayer.getGroup() ~= 'user' then
        return true
    else
        return false
    end
end

ESX.RegisterServerCallback('im_menuadmin:getplayers', function(source, cb)
    local elements = {}
    for k,v in pairs(GetPlayers()) do
        local steam = GetPlayerName(v)
        if steam ~= nil then
            table.insert(elements, {
                label = string.format(Lang.pl_menu_argument, steam, v),
                value = v
            })
        end
    end
    cb(elements)
end)

ESX.RegisterServerCallback('im_menuadmin:permessi', function(source, cb)
    cb(CheckPerm(source))
end)

-- Ban System

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identificativo = RitornamiLicenza(src)
    local steam = GetPlayerName(src)
    deferrals.defer()
    deferrals.update('Stiamo controllando le tue informazioni, attendi...')
    MySQL.Async.fetchAll('SELECT * FROM ban',{}, function(result)
        if result[1] then
            for k,v in pairs(result) do 
                if identificativo == v.identifier then
                    if v.perma ~= 'si' then
                        if v.giorni > os.time() then
                            print('^1ATTENZIONE ^2STEAM ^3'..steam..' ^4ha provato a entrare nel server essendo bannato fino al: '..os.date("%x", v.giorni)..' '..os.date("%X", v.giorni)..'^0')
                            deferrals.done('['..Lang.server_name..'] '..string.format(Lang.you_have_been_banned, v.motivazione, v.data, os.date("%x", v.giorni)..' '..os.date("%X", v.giorni)))
                        else
                            MySQL.Sync.execute('DELETE FROM ban WHERE identifier = @identifier',{
                                ['@identifier'] = v.identifier
                            })
                            print('^1ATTENZIONE ^2STEAM ^3'..steam..' ^4ha terminato il suo ban e sta entrando nel server!^0')
                            deferrals.done()
                        end
                    else
                        print('^1ATTENZIONE ^2STEAM ^3'..steam..' ^4ha provato a entrare nel server essendo bannato permanentemente^0')
                        deferrals.done('['..Lang.server_name..'] '..string.format(Lang.you_have_been_banned_perma, v.motivazione, v.data))
                    end
                end
            end
        else
            deferrals.done()
        end
    end)
end)

RegisterServerEvent('im_menuadmin:ban')
AddEventHandler('im_menuadmin:ban', function(id, idstaffer, motivazione, perma, giorni)
    local xPlayer = ESX.GetPlayerFromId(id)
    local xStaffer = ESX.GetPlayerFromId(idstaffer)
    local identificativo = RitornamiLicenza(xPlayer.source)

    if CheckPerm(idstaffer) then
        if perma then
            MySQL.Async.insert('INSERT INTO ban (identifier, perma, data, motivazione, steam) VALUES (@identifier, @perma, @data, @motivazione, @steam)',{
                ['@identifier'] = identificativo,
                ['@perma'] = 'si',
                ['@data'] = os.date("%x")..' '..os.date("%X"),
                ['@steam'] = GetPlayerName(xPlayer.source),
                ['@motivazione'] = motivazione
            })
            xStaffer.showNotification(string.format(Lang.ban_perma_pn), xPlayer.source, GetPlayerName(xPlayer.source))
            DropPlayer(xPlayer.source, string.format(Lang.been_ban_perma_pn, GetPlayerName(xStaffer.source), motivazione))
        else
            MySQL.Async.insert('INSERT INTO ban (identifier, perma, data, motivazione, giorni, steam) VALUES (@identifier, @perma, @data, @motivazione, @giorni, @steam)',{
                ['@identifier'] = identificativo,
                ['@giorni'] = giorni + os.time(),
                ['@perma'] = 'no',
                ['@data'] = os.date("%x")..' '..os.date("%X"),
                ['@steam'] = GetPlayerName(xPlayer.source),
                ['@motivazione'] = motivazione
            })
            print(xPlayer.source, GetPlayerName(xPlayer.source), xStaffer)
            xStaffer.showNotification(string.format(Lang.ban_pn, xPlayer.source, GetPlayerName(xPlayer.source)))
            DropPlayer(xPlayer.source, string.format(Lang.been_ban_pn, GetPlayerName(xStaffer.source), motivazione))
        end
    else
        DropPlayer(xStaffer.source, 'Bello fra, Ice_man154 - Flavio#7683 non lo inculi, modder di merda')
        print('^1ATTENZIONE ^2ID ^3'..xStaffer.source..' ^2STEAM ^3'..GetPlayerName(xStaffer.source)..' ^4ha provato a triggerare l\'evento im_menuadmin:ban non essendo staffer^0')
    end 
end)

RegisterServerEvent('im_menuadmin:cancellaban')
AddEventHandler('im_menuadmin:cancellaban', function(idstaffer, identifier)
    if CheckPerm(idstaffer) then
        MySQL.Sync.execute('DELETE FROM ban WHERE identifier = @identifier',{
            ['@identifier'] = identifier
        })
    else
        DropPlayer(idstaffer, 'Bello fra, Ice_man154 - Flavio#7683 non lo inculi, modder di merda')
        print('^1ATTENZIONE ^2ID ^3'..idstaffer..' ^2STEAM ^3'..GetPlayerName(idstaffer)..' ^4ha provato a triggerare l\'evento im_menuadmin:cancellaban non essendo staffer^0')
    end
end)

RitornamiLicenza = function(sorgente)
    local license
    for k, v in ipairs(GetPlayerIdentifiers(sorgente)) do
        if string.match(v, "license:") then
           license = v
           break
        end
    end
    return license
end

ESX.RegisterServerCallback('im_menuadmin:prendituttiban', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM ban',{}, function(result)
        if result[1] then
            local ListaBan = {}
            for k,v in pairs(result) do
                table.insert(ListaBan, {
                    label = v.steam..' - '..v.data,
                    steam = v.steam,
                    identifier = v.identifier,
                    perma = v.perma,
                    giorni = v.giorni,
                    data = v.data,
                    datas = os.date("%x", v.giorni)..' '..os.date("%X", v.giorni),
                    motivazione = v.motivazione,
                    value = v.identifier
                })
            end
            cb(ListaBan)
        end
    end)
end)

-- Menu Gestione player

RegisterServerEvent('im_menuadmin:kick')
AddEventHandler('im_menuadmin:kick', function(id, idstaffer, motivazione)
    local xPlayer = ESX.GetPlayerFromId(idstaffer)
    local xTarget = ESX.GetPlayerFromId(id)
    if CheckPerm(idstaffer) then
        if xTarget then
            xPlayer.showNotification(string.format(Lang.kick_pn, xTarget.source, GetPlayerName(xTarget.source)))
            DropPlayer(xTarget.source, string.format(Lang.been_kicked_pn, GetPlayerName(xPlayer.source), motivazione))
        else
            xPlayer.showNotification(Lang.player_not_online)
        end
    else
        DropPlayer(xPlayer.source, 'Bello fra, Ice_man154 - Flavio#7683 non lo inculi, modder di merda')
        print('^1ATTENZIONE ^2ID ^3'..xPlayer.source..' ^2STEAM ^3'..GetPlayerName(xPlayer.source)..' ^4ha provato a triggerare l\'evento im_menuadmin:kick non essendo staffer^0')
    end
end)

RegisterServerEvent('im_menuadmin:daisoldi')
AddEventHandler('im_menuadmin:daisoldi', function(giocatore, idstaffer, quantita, tipo)
    local xPlayer = ESX.GetPlayerFromId(idstaffer)
    local xTarget = ESX.GetPlayerFromId(giocatore)
    if CheckPerm(idstaffer) then
        if xTarget then
            if tipo == 'contanti' then
                xTarget.addMoney(quantita)
                xPlayer.showNotification(string.format(Lang.givemoney_pn, quantita, GetPlayerName(giocatore)))
                xPlayer.showNotification(string.format(Lang.recivemoney_pn, quantita, GetPlayerName(idstaffer)))
            elseif tipo == 'sporchi' then
                xTarget.addAccountMoney(Config.Accounts.dirty_money, quantita)
                xPlayer.showNotification(string.format(Lang.givebank_pn, quantita, GetPlayerName(giocatore)))
                xPlayer.showNotification(string.format(Lang.recivebank_pn, quantita, GetPlayerName(idstaffer)))
            elseif tipo == 'banca' then
                xTarget.addAccountMoney(Config.Accounts.bank, quantita)
                xPlayer.showNotification(string.format(Lang.givedmoney_pn, quantita, GetPlayerName(giocatore)))
                xPlayer.showNotification(string.format(Lang.recivedmoney_pn, quantita, GetPlayerName(idstaffer)))
            end
        else
            xPlayer.showNotification(Lang.player_not_online)
        end
    else
        DropPlayer(xPlayer.source, 'Bello fra, Ice_man154 - Flavio#7683 non lo inculi, modder di merda')
        print('^1ATTENZIONE ^2ID ^3'..xTarget.source..' ^2STEAM ^3'..GetPlayerName(xTarget.source)..' ^4ha provato a triggerare l\'evento im_menuadmin:daisoldi non essendo staffer^0')
    end
end)

ESX.RegisterServerCallback('im_menuadmin:jobs', function(source, cb)
    MySQL.Async.fetchAll('SELECT name, label FROM jobs WHERE whitelisted = @whitelisted',{
        ['@whitelisted'] = false
    }, function(risultato)
        for i=1, #risultato, 1 do
            local ris = risultato[i]
            table.insert(lavori, {
                lavoro = ris.name,
                label = ris.label
            })
        end
    end)
    cb(lavori)
end)

RegisterServerEvent('im_menuadmin:setjob')
AddEventHandler('im_menuadmin:setjob', function(id, idstaffer, job, grado)
    local xPlayer = ESX.GetPlayerFromId(idstaffer)
    local xTarget = ESX.GetPlayerFromId(id)
    if CheckPerm(idstaffer) then
        if xTarget then
            xTarget.setJob(job, grado)
            xPlayer.showNotification(string.format(Lang.setjob_pn, GetPlayerName(id), job))
            xTarget.showNotification(string.format(Lang.hb_setjob_pn, job, GetPlayerName(idstaffer)))
        else
            xPlayer.showNotification(Lang.player_not_online)
        end
    else
        DropPlayer(xPlayer.source, 'Bello fra, Ice_man154 - Flavio#7683 non lo inculi, modder di merda')
        print('^1ATTENZIONE ^2ID ^3'..xTarget.source..' ^2STEAM ^3'..GetPlayerName(xTarget.source)..' ^4ha provato a triggerare l\'evento im_menuadmin:daisoldi non essendo staffer^0')
    end
end)

ESX.RegisterServerCallback('im_menuadmin:prendisteam', function(source, cb, id)
    cb(GetPlayerName(id))
end)

ESX.RegisterServerCallback('im_menuadmin:checkonline', function(source, cb, id)
    local xPlayer = ESX.GetPlayerFromId(id)
    if xPlayer then
        cb(true)
    else
        cb(false)
    end
end)