ESX = nil


local firstspawn = true


AddEventHandler('playerSpawned', function(spawn)

    if Config.EachSpawn then
        if firstspawn then
            firstspawn = false

            ESX.TriggerServerCallback('checkrefund:data', function(cb)
            end)
            
        end
    end
end)

-- The refund chat suggestions, change this to your own language
TriggerEvent('chat:addSuggestion', '/' .. "refund", "Geef een speler een refund", {
            { name="steam:xxxxxxxxxxxxxxx", help= "Speler zijn steam id" },
            { name="item type", help = "item, money, bank, black_money, weapon" },
            { name="item naam", help = "Bijvoorbeeld: WEAPON_BAT, of bij geld hoeveelheid geld" },
            { name="Hoeveelheid", help = "Hoeveelheid van wat je wilt geven" }
})

TriggerEvent('chat:addSuggestion', '/' .. "checkrefund", "Controleert of je een refund klaar hebt staan")
TriggerEvent('chat:addSuggestion', '/' .. "refundclear", "Verwijder refunds", {{ name = 'steam-id/all', help = 'Steam-id van degene waarvan je zijn refund wilt verwijderen of all als je alle refunds wilt verwijderen'}})
TriggerEvent('chat:addSuggestion', '/' .. "refundlist", "Lijst van ongeclaimde refunds (Staff)")
