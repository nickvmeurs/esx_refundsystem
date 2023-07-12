# refundsystem
  ==== Refund System - byK3#7147 ====

Remake of the refund system from byK3#7147, remade by nick.vm.
Whats different? i added logs to every action with the sentodiscord function he embedded, all the actions are in dutch so keep that in mind you might need to change the language of your chat messages and logs.

![image](https://github.com/nickvmeurs/esx_refundsystem/assets/97262293/f0e89f40-354f-4786-a300-f2a1834b93d2)
![image](https://github.com/nickvmeurs/esx_refundsystem/assets/97262293/7559aecb-1c82-433f-a900-3093dd299752)
![image](https://github.com/nickvmeurs/esx_refundsystem/assets/97262293/693a56e3-8da5-41b8-bf79-636c15ea2b89)
![image](https://github.com/nickvmeurs/esx_refundsystem/assets/97262293/294ee702-133f-4009-981e-20c3f81733c6)

![image](https://github.com/nickvmeurs/esx_refundsystem/assets/97262293/12447e90-74ab-4f24-a93b-d59c77984110)

  === INSTRUCATION === 

    1. Add the resource to your server.cfg
    2. Add the webhook to the config.lua
    3. Add the permissions to the config.lua
    4. Add the commands to the config.lua
    5. Change the logs and chat notifications to your own messages


    Current supported types: item, money, bank, black_money, weapon
    If you use weapon as type, the name must be the weapon hash (e.g. WEAPON_PISTOL)
    If you use item as type, the name must be the item name (e.g. bread)
    If you use money, bank or black_money as type, the name must be nil so just leave it empty (e.g. /refund [steam:id] [type] [amount]


    Check server.lua to see how the commands work and how to add more commands if you want to
    Also you need to adjust the SendToDiscord function yourself - I wrote the function, just enter where you want

==== Refund System - byK3#7147 ====
