local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('eske_druglab:hasPerm', function(source, cb, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasPerm = xPlayer.getGroup() == ConfigServer.admingroup
    cb(hasPerm)
end)

ESX.RegisterServerCallback('eske_druglab:doesGangHave', function(source, cb, gang)
    MySQL.query('SELECT * FROM eske_druglabs WHERE gang = ?', {gang}, function(result)
        if result[1] then
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('eske_druglab:hasItem', function(source, cb, item, farmtype)
    local xPlayer = ESX.GetPlayerFromId(source)
    if farmtype == 'process' then
        if xPlayer.hasItem(ConfigServer.Shells[item]['farm'].item) and xPlayer.hasItem(ConfigServer.Shells[item]['farm'].item).count >= ConfigServer.Shells[item]['process'].amount_required then
            cb(true)
        else
            cb(false)
        end
    elseif farmtype == 'pak' then
        print(xPlayer.hasItem(ConfigServer.Shells[item]['process'].item))
        if xPlayer.hasItem(ConfigServer.Shells[item]['process'].item) and xPlayer.hasItem(ConfigServer.Shells[item]['process'].item).count >= ConfigServer.Shells[item]['pack'].amount_required then
            cb(true)
        else
            cb(false)
        end
    end
end)

ESX.RegisterServerCallback('eske_druglab:getLabs', function(source, cb)
    MySQL.query('SELECT * FROM eske_druglabs', function(result)
        if result then
            local labs = {}
            for i=1, #result, 1 do
                local json = json.decode(result[i].info)
                for k,v in pairs(json) do
                    local lab = {
                        x = nil,
                        y = nil,
                        z = nil,
                        id = result[i].id,
                        entryx = nil,
                        entryy = nil,
                        entryz = nil,
                        type = result[i].object,
                        pakx = nil,
                        paky = nil,
                        pakz = nil,
                        processx = nil,
                        processy = nil,
                        processz = nil,
                        farmx = nil,
                        farmy = nil,
                        farmz = nil
                    }
                    for k2, v2 in pairs(v) do
                        if k2 == 'entrypos' then
                            lab.x = v2.x
                            lab.y = v2.y
                            lab.z = v2.z
                        end
                        if k2 == 'shellpos' then
                            lab.entryx = v2.x
                            lab.entryy = v2.y
                            lab.entryz = v2.z
                        end
                        if k2 == 'door' then
                            lab.doorx = v2.x
                            lab.doory = v2.y
                            lab.doorz = v2.z
                        end
                        if k2 == 'pak' then
                            lab.pakx = v2.x
                            lab.paky = v2.y
                            lab.pakz = v2.z
                        end
                        if k2 == 'process' then
                            lab.processx = v2.x
                            lab.processy = v2.y
                            lab.processz = v2.z
                        end
                    end
                    table.insert(labs, lab)
                end
            end
            cb(labs)
        else
            cb({})
        end
    end)
end)

ESX.RegisterServerCallback('eske_druglab:canEnterLab', function(source, cb, kode, id)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query('SELECT * FROM eske_druglabs WHERE id = ? AND pin = ?', {id, kode}, function(result)
        if result[1] and xPlayer.getJob().name == result[1].gang then
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('eske_druglab:canPoliceRaid', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasPerm = xPlayer.getJob().name == 'police'
    TriggerEvent("eske_logs:createLog", "policeRaid", "Politiet raidede et lab", "red", "[" .. xPlayer.source .. "] " .. xPlayer.getName() .. ' raidede lige et lab.' , true)
    cb(hasPerm)
end)

ESX.RegisterServerCallback('eske_druglab:canRaidLab', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed = false
    for k,v in pairs(ConfigServer.whitelisted_gangs) do
        if xPlayer.getJob().name == v then
            TriggerEvent("eske_logs:createLog", "playerRaid", "En spiller raidede et lab", "red", "[" .. xPlayer.source .. "] " .. xPlayer.getName() .. ' raidede lige et lab.' , true)
            cb(true)
            return
        end
    end
    cb(false)
end)

RegisterNetEvent('eske_druglab:opretLab')
AddEventHandler('eske_druglab:opretLab', function(object, info, gang, pin)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        MySQL.Async.execute('INSERT INTO eske_druglabs (object, gang, info, pin) VALUES (@object, @gang, @info, @pin)', {
            ['@object'] = object,
            ['@gang'] = gang,
            ['@info'] = info,
            ['@pin'] = tonumber(pin)
        }, function(rowsChanged)
            TriggerEvent("eske_logs:createLog", "opretLab", "Oprettelse af druglab", "green", "[" .. xPlayer.source .. "] " .. xPlayer.getName() .. ' oprettede et ' .. object .. ' lab til banden ' .. gang .. ' med koden ' .. pin .. '.' , true)
        end)
    else
        print('[ESKE DRUGLAB] - ERROR: Player is nil')
    end 
end)

ESX.RegisterServerCallback('eske_druglab:processDrug', function(source, cb, drug)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        if xPlayer.canCarryItem(ConfigServer.Shells[drug]['process'].item, ConfigServer.Shells[drug]['process'].amount_given) then
            xPlayer.removeInventoryItem(ConfigServer.Shells[drug]['farm'].item, ConfigServer.Shells[drug]['process'].amount_required)
            xPlayer.addInventoryItem(ConfigServer.Shells[drug]['process'].item, ConfigServer.Shells[drug]['process'].amount_given)
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('eske_druglab:packDrug', function(source, cb, drug)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        if xPlayer.canCarryItem(ConfigServer.Shells[drug]['pack'].item, ConfigServer.Shells[drug]['pack'].amount_given) then
            xPlayer.removeInventoryItem(ConfigServer.Shells[drug]['process'].item, ConfigServer.Shells[drug]['pack'].amount_required)
            xPlayer.addInventoryItem(ConfigServer.Shells[drug]['pack'].item, ConfigServer.Shells[drug]['pack'].amount_given)
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

ESX:RegisterServerCallback('eske_druglab:farmDrug', function(source, cb, drug)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        if ConfigServer.Shells[drug] then
            if xPlayer.canCarryItem(ConfigServer.Shells[drug]['pack'].item, ConfigServer.Shells[drug]['pack'].amount_given) then
                xPlayer.addInventoryItem(ConfigServer.Shells[drug]['farm'].item, ConfigServer.Shells[drug]['farm'].amount_given)
                cb(true)
            else
                cb(false)
            end
        else
            print('[ESKE DRUGLAB] ERROR: Drug not found in config.')
            cb(false)
        end
    else
        cb(false)
    end
end)