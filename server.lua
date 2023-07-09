ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    loadDatabase()
    SendToDiscord(65280, '**REFUND SYSTEM**', 'Refund System started - file loaded')
end)

list = {}

loadDatabase = function()
    local file = json.decode(LoadResourceFile(GetCurrentResourceName(), "list.json")) or {}

    list = file
end

saveDatabase = function()
    SaveResourceFile(GetCurrentResourceName(), 'list.json', json.encode(list), -1)
end

ESX.RegisterServerCallback('getGroup:data', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()

    if Config.Permission[group] then
        SendToDiscord(65280, '**REFUND SYSTEM**', 'Permission granted')
    end
end)

isAdmin = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()

    if Config.Permission[group] then
        return true
    else
        return false
    end
end

RegisterCommand('refund', function(source, args, rawCommand)
    if isAdmin(source) then
        local target = args[1]
        local type = args[2]
        local name = args[3]
        local amount = args[4]

        -- Check if name is nil for type 'item' or 'weapon'
        if (type == 'item' or type == 'weapon') and name == nil then
            SendToDiscord(16711680, 'Refund Request', 'Invalid name')
            return
        end

        if string.sub(target, 1, 6) ~= 'steam:' and string.sub(target, 1, 9) ~= 'license:' then
            SendToDiscord(16711680, 'Refund Request', 'Invalid target')
            return
        end

        if type ~= 'item' and type ~= 'money' and type ~= 'bank' and type ~= 'black_money' and type ~= 'weapon' then
            SendToDiscord(16711680, 'Refund Request', 'Invalid type')
            return
        end

        if type == 'money' or type == 'bank' or type == 'black_money' then
            amount = args[3]
            name = nil
        end

        if amount == nil or not tonumber(amount) or tonumber(amount) <= 0 then
            SendToDiscord(16711680, 'Refund Request', 'Invalid amount')
            return
        end

        local data = {
            target = target,
            type = type,
            name = name,
            amount = amount
        }

        table.insert(list, data)
        saveDatabase()

        SendToDiscord(16776960, 'Refund Gemaakt', 'Admin: ' .. GetPlayerName(source) .. '\nType: ' .. type .. '\nTarget: ' .. target .. '\nName: ' .. tostring(name) .. '\nAmount: ' .. amount)

        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je refund voor '.. amount ..' '.. (name or "") .. ' van '.. target .. ' is succesvol gemaakt' }
        })
    end
end, false)



ESX.RegisterServerCallback('checkrefund:data', function(source, cb)
    checkRefund(source)
end)

checkRefund = function(source)
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, 6) == "steam:" or string.sub(v, 1, 9) == "license:" then
            identifier = v
            break
        end
    end

    local license = identifier

    for i = 1, #list do
        if list[i].target == license then
            local refundType = list[i].type or "Unknown"
            local refundName = ""
            
            if refundType == "bank" then
                refundName = "bank money"
            elseif refundType == "money" then
                refundName = "money"
            elseif refundType == "black_money" then
                refundName = "black money"
            elseif refundType == "item" then
                refundName = list[i].name or "Unknown item"
            elseif refundType == "weapon" then
                refundName = list[i].name or "Unknown weapon"
            end

            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="padding: 0.5vw !important; margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
                args = { 'REFUND', 'Er staat '.. refundName .. ' voor je klaar! gebruik /' .. Config.Commands.redeem .. ' om je refund te claimen' }
            })
            return
        end
    end
end




RegisterCommand(Config.Commands.check, function(source, args, rawCommand)
    checkRefund(source)
end, false)

RegisterCommand(Config.Commands.redeem, function(source, args, rawCommand)
    getRefund(source)
end, false)

getRefund = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    for k, v in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, 6) == "steam:" or string.sub(v, 1, 9) == "license:" then
            identifier = v
            break
        end
    end

    local license = identifier

    for i = 1, #list do
        if list[i].target == license then
            local refundType = list[i].type
            local refundAmount = tonumber(list[i].amount)

            if refundType == 'item' then
                xPlayer.addInventoryItem(list[i].name, refundAmount)
                SendToDiscord(65280, '**REFUND GECLAIMED**', 'Speler ' .. GetPlayerName(source) .. ' heeft zijn refund geclaimed: ' .. list[i].name .. ' (' .. refundAmount .. 'x)')
                TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol '.. refundAmount ..' ' .. list[i].name .. ' gerefund' }
        })
            elseif refundType == 'money' then
                xPlayer.addMoney(refundAmount)
                SendToDiscord(65280, '**REFUND GECLAIMED**', 'Speler ' .. GetPlayerName(source) .. ' heeft zijn refund geclaimed: contant geld (' .. refundAmount .. ')')
                TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol je €'.. refundAmount ..' contant gerefund' }
        })
            elseif refundType == 'bank' then
                xPlayer.addAccountMoney('bank', refundAmount)
                SendToDiscord(65280, '**REFUND GECLAIMED**', 'Speler ' .. GetPlayerName(source) .. ' heeft zijn refund geclaimed: bank geld (' .. refundAmount .. ')')
                TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol je €'.. refundAmount ..' op je bank gerefund' }
        })
            elseif refundType == 'black_money' then
                xPlayer.addAccountMoney('black_money', refundAmount)
                SendToDiscord(65280, '**REFUND GECLAIMED**', 'Speler ' .. GetPlayerName(source) .. ' heeft zijn refund geclaimed: zwartgeld (' .. refundAmount .. ')')
                TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol je €'.. refundAmount ..' zwartgeld gerefund' }
        })






            elseif refundType == 'weapon' then
                xPlayer.addWeapon(list[i].name, refundAmount)
                SendToDiscord(65280, '**REFUND GECLAIMED**', 'Speler ' .. GetPlayerName(source) .. ' heeft zijn refund geclaimed: wapen (' .. list[i].name .. ')')
                TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol je ' .. list[i].name .. ' gerefund' }
        })
            end

            table.remove(list, i)
            saveDatabase()

            --notify(source, 'You have redeemed your refund')
            TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je refund is succesvol geclaimed.' }
        })
            return
        end
    end

    --notify(source, 'You have no refund')
           TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Er staat op het moment geen refund klaar.' }
        })
    end




RegisterCommand(Config.Commands.clear, function(source, args, rawCommand)
    if isAdmin(source) then
        local target = args[1]

        if target == 'all' then
            list = {}
            saveDatabase()
            SendToDiscord(16711680, '**REFUND SYSTEEM**', 'Alle refunds zijn verwijderd door admin: ' .. GetPlayerName(source))
            TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol de refund lijst geleegd' }
        })
        else
            for i = 1, #list do
                if list[i].target == target then
                    table.remove(list, i)
                    saveDatabase()
                    SendToDiscord(16711680, '**REFUND SYSTEEM**', 'Refund verwijderd door admin: ' .. GetPlayerName(source) .. ' | de refund was van: ' .. target)    
                    TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw !important;  margin: 0.5vw; background-color: rgba(0, 0, 255, 0.6); border-radius: 3px;"><i class="fas fa-globe"></i> {0}:<br> {1}</div>',
            args = { 'REFUND', 'Je hebt succesvol de refund van ' .. target .. ' verwijderd' }
        })
                end
            end
        end
    end
end, false)

RegisterCommand(Config.Commands.debug_list, function(source, args, rawCommand)
    if isAdmin(source) then
        print(json.encode(list))
    end
end, false)

RegisterCommand(Config.Commands.debug_steamid, function(source, args, rawCommand)
    local idargs = args[1]

    for k, v in ipairs(GetPlayerIdentifiers(idargs)) do
        if string.sub(v, 1, 6) == "steam:" then
            identifier = v
            break
        end
    end

    if identifier == nil then
        print('Steam not found')
    else
        print('Steam ID is: ' .. identifier)
    end
end, false)

SendToDiscord = function(color, title, msg)
    local embed = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] = msg,
            ["footer"] = {
                ["text"] = os.date("%c") .. " | Refund Systeem | Middelvoorste Roleplay",
            },
        }
    }
    local data = {
        ["username"] = "Refund",
        ["embeds"] = embed
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end


