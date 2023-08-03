local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")
local RageUIAdmin = module("cfg/admin_menu")
local Groups = module("cfg/groups")
-- this module define some admin menu functions

local player_lists = {}

local function ch_list(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.list") then
        if player_lists[player] then -- hide
            player_lists[player] = nil
            CLIMBclient.removeDiv(player,{"user_list"})
        else -- show
            local content = ""
            local count = 0
            for k,v in pairs(CLIMB.rusers) do
                count = count+1
                local source = CLIMB.getUserSource(k)
                CLIMB.getUserIdentity(k, function(identity)
                    if source ~= nil then
                        content = content.."<br />"..k.." => <span class=\"pseudo\">"..CLIMB.getPlayerName(source).."</span> <span class=\"endpoint\">"..'REDACATED'.."</span>"
                        if identity then
                            content = content.." <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> <span class=\"reg\">"..identity.registration.."</span> <span class=\"phone\">"..identity.phone.."</span>"
                        end
                    end
                    
                    -- check end
                    count = count-1
                    if count == 0 then
                        player_lists[player] = true
                        local css = [[
                        .div_user_list{ 
                            margin: auto; 
                            padding: 8px; 
                            width: 650px; 
                            margin-top: 80px; 
                            background: black; 
                            color: white; 
                            font-weight: bold; 
                            font-size: 1.1em;
                        } 
                        
                        .div_user_list .pseudo{ 
                            color: rgb(0,255,125);
                        }
                        
                        .div_user_list .endpoint{ 
                            color: rgb(255,0,0);
                        }
                        
                        .div_user_list .name{ 
                            color: #309eff;
                        }
                        
                        .div_user_list .reg{ 
                            color: rgb(0,125,255);
                        }
                        
                        .div_user_list .phone{ 
                            color: rgb(211, 0, 255);
                        }
                        ]]
                        CLIMBclient.setDiv(player,{"user_list", css, content})
                    end
                end)
            end
        end
    end
end

local function ch_whitelist(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.whitelist") then
        CLIMB.prompt(player,"User id to whitelist: ","",function(player,id)
            id = parseInt(id)
            CLIMB.setWhitelisted(id,true)
            CLIMBclient.notify(player,{"whitelisted user "..id})
        end)
    end
end

local function ch_unwhitelist(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.unwhitelist") then
        CLIMB.prompt(player,"User id to un-whitelist: ","",function(player,id)
            id = parseInt(id)
            CLIMB.setWhitelisted(id,false)
            CLIMBclient.notify(player,{"un-whitelisted user "..id})
        end)
    end
end

local function ch_addgroup(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.group.add") then
        CLIMB.prompt(player,"User id: ","",function(player,id)
            if id then 
                id = parseInt(id)
                CLIMB.prompt(player,"Group to add: ","",function(player,group)
                    if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
                        if CLIMB.hasPermission(user_id, 'player.manage_' .. group) then
                                CLIMB.addUserGroup(id, group)
                                CLIMBclient.notify(player,{'~g~Success! Added Group: ' .. group})
                        else 
                            CLIMBclient.notify(player,{'~r~You do not have permission to add this group.'})
                        end
                    else 
                        CLIMB.addUserGroup(id, group)
                        CLIMBclient.notify(player,{'~g~Success! Added Group: ' .. group})
                    end 
                end)
            end 
        end)
    
    end
end

local function ch_removegroup(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.group.remove") then
        CLIMB.prompt(player,"User id: ","",function(player,id)
            id = parseInt(id)
            if id then 
                CLIMB.prompt(player,"Group to remove: ","",function(player,group)
                    if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
                        if CLIMB.hasPermission(user_id, 'player.manage_' .. group) then
                                CLIMB.removeUserGroup(id, group)
                                CLIMBclient.notify(player,{'~g~Success! Removed Group: ' .. group})
                        else 
                            CLIMBclient.notify(player,{'~r~You do not have permission to remove this group.'})
                        end
                    else 
                        CLIMB.removeUserGroup(id, group)
                        CLIMBclient.notify(player,{'~g~Success! Removed Group: ' .. group})
                    end 
                end)
            end
        end)
    end
end

local function ch_kick(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.kick") then
        CLIMB.prompt(player,"User id to kick: ","",function(player,id)
            id = parseInt(id)
            CLIMB.prompt(player,"Reason: ","",function(player,reason)
                local source = CLIMB.getUserSource(id)
                if source ~= nil then
                    saveKickLog(id, GetPlayerName(player), reason)
                    CLIMB.kick(source,reason)
                    CLIMBclient.notify(player,{"kicked user "..id})
                end
            end)
        end)
    end
end

RegisterNetEvent('CLIMB:RemoveWarning')
AddEventHandler('CLIMB:RemoveWarning', function(warningid)
    local source = source
    local user_id = CLIMB.getUserId(source)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"admin.removewarning") then
        exports['ghmattimysql']:execute("DELETE FROM climb_warnings WHERE warning_id = @uid", {uid = warningid})
        CLIMBclient.notify(source,{"~g~Removed Warning"})
    end
end)

local function ch_removewarning(player, choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"admin.removewarning") then
        CLIMB.prompt(player,"Warning ID to remove warning from: ","",function(player,idwarning)
            if idwarning and tonumber(idwarning) then 
                exports['ghmattimysql']:execute("DELETE FROM climb_warnings WHERE warning_id = @uid", {uid = idwarning})
            else 
                CLIMBclient.notify(player,{"Please enter a warningID!"})
            end
        end)
    end
end

local function ch_ban(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.ban") then
        CLIMB.prompt(player,"User id to ban: ","",function(player,id)
            id = parseInt(id)
            if id then  -- Thanks to JamesUK <3 For updated temp bans
                CLIMB.prompt(player,"Reason: ","",function(player,reason)
                    if reason then 
                        CLIMB.prompt(player,"Duration of Ban (-1 for perm ban): ","",function(player,hours)
                            saveBanLog(id, GetPlayerName(player), reason, hours)
                            if tonumber(hours) then 
                                if tonumber(hours) == -1 then 
                                    CLIMB.ban(player,id,"perm",reason)
                                else 
                                    CLIMB.ban(player,id,hours,reason)
                                end
                            else 
                                CLIMBclient.notify(player,{"Please enter a number for the ban hours."})
                            end 
                        end)
                    else 
                        CLIMBclient.notify(player,{"Please enter a ban reason!"})
                    end 
                end)
            else 
                CLIMBclient.notify(player,{"Please enter an id to ban!"})
            end      
        end)
    end
end

local function ch_unban(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.unban") then
        CLIMB.prompt(player,"User id to unban: ","",function(player,id)
            id = parseInt(id)
            CLIMB.setBanned(id,false)
            CLIMBclient.notify(player,{"un-banned user "..id})
        end)
    end
end

local function ch_emote(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.custom_emote") then
        CLIMB.prompt(player,"Animation sequence ('dict anim optional_loops' per line): ","",function(player,content)
            local seq = {}
            for line in string.gmatch(content,"[^\n]+") do
                local args = {}
                for arg in string.gmatch(line,"[^%s]+") do
                    table.insert(args,arg)
                end
                
                table.insert(seq,{args[1] or "", args[2] or "", args[3] or 1})
            end
            
            CLIMBclient.playAnim(player,{true,seq,false})
        end)
    end
end

local function ch_sound(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil and CLIMB.hasPermission(user_id,"player.custom_sound") then
        CLIMB.prompt(player,"Sound 'dict name': ","",function(player,content)
            local args = {}
            for arg in string.gmatch(content,"[^%s]+") do
                table.insert(args,arg)
            end
            CLIMBclient.playSound(player,{args[1] or "", args[2] or ""})
        end)
    end
end

local function ch_coords(player,choice)
    CLIMBclient.getPosition(player,{},function(x,y,z)
        CLIMB.prompt(player,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z,function(player,choice) end)
    end)
end

local function ch_tptome(player,choice)
    CLIMBclient.getPosition(player,{},function(x,y,z)
        CLIMB.prompt(player,"User id:","",function(player,user_id) 
            local tplayer = CLIMB.getUserSource(tonumber(user_id))
            if tplayer ~= nil then
                CLIMBclient.teleport(tplayer,{x,y,z})
            end
        end)
    end)
end

local function ch_tpto(player,choice)
    CLIMB.prompt(player,"User id:","",function(player,user_id) 
        local tplayer = CLIMB.getUserSource(tonumber(user_id))
        if tplayer ~= nil then
            CLIMBclient.getPosition(tplayer,{},function(x,y,z)
                CLIMBclient.teleport(player,{x,y,z})
            end)
        end
    end)
end

local function ch_tptocoords(player,choice)
    CLIMB.prompt(player,"Coords x,y,z:","",function(player,fcoords) 
        local coords = {}
        for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
            table.insert(coords,tonumber(coord))
        end
        
        local x,y,z = 0,0,0
        if coords[1] ~= nil then x = coords[1] end
        if coords[2] ~= nil then y = coords[2] end
        if coords[3] ~= nil then z = coords[3] end
        
        CLIMBclient.teleport(player,{x,y,z})
    end)
end

local function ch_givemoney(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil then
        CLIMB.prompt(player,"Amount:","",function(player,amount) 
            amount = parseInt(amount)
            CLIMB.giveMoney(user_id, amount)
        end)
    end
end

local function ch_giveitem(player,choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil then
        CLIMB.prompt(player,"Id name:","",function(player,idname) 
            idname = idname or ""
            CLIMB.prompt(player,"Amount:","",function(player,amount) 
                amount = parseInt(amount)
                CLIMB.giveInventoryItem(user_id, idname, amount,true)
            end)
        end)
    end
end


local AdminCooldown = {}

local function ch_calladmin(player,choice)
    local user_id = CLIMB.getUserId(player)
    if CLIMBConfig.AdminCoolDown then 
        if AdminCooldown[player] and not (os.time() > AdminCooldown[player]) then
            return CLIMBclient.notify(player,{"~r~Please wait 60 seconds before calling again."})
        else 
            AdminCooldown[player] = nil
        end
    end
    if user_id ~= nil then
        CLIMB.prompt(player,"Describe your problem:","",function(player,desc) 
            desc = desc or ""
            if desc ~= nil and desc ~= "" then
                local answered = false
                local players = {}
                AdminCooldown[player] = os.time() + tonumber(CLIMBConfig.AdminCooldownTime)
                for k,v in pairs(CLIMB.rusers) do
                    local player = CLIMB.getUserSource(tonumber(k))
                    -- check user
                    if CLIMB.hasPermission(k,"admin.tickets") and player ~= nil then
                        table.insert(players,player)
                    end
                end
                
                -- send notify and alert to all listening players
                for k,v in pairs(players) do
                    CLIMB.request(v,"Admin ticket (user_id = "..user_id..") take/TP to ?: "..htmlEntities.encode(desc), 60, function(v,ok)
                        if ok then -- take the call
                            if not answered then
                                -- answer the call
                                CLIMBclient.notify(player,{"An admin took your ticket."})
                                CLIMBclient.getPosition(player, {}, function(x,y,z)
                                    CLIMBclient.teleport(v,{x,y,z})
                                end)
                                answered = true
                            else
                                CLIMBclient.notify(v,{"Ticket already taken."})
                            end
                        end
                    end)
                end
            else
                CLIMBclient.notify(player,{"Empty Admin Call."})
            end
        end)
    end
end


--CLIMB Admin 


AddEventHandler("entityCreating",  function(entity)
    local owner = NetworkGetEntityOwner(entity)
    local model = GetEntityModel(entity)
    if (owner ~= nil and owner > 0) then
        local config = LoadResourceFile(GetCurrentResourceName(), "modules/banned-props.json")
        local configjson = json.decode(config)
        if configjson then 
            if configjson[tostring(model)] then
                CancelEvent()
            end
        end 
    end
end)

RegisterNetEvent('CLIMBAdmin:UpdateBlacklistedProps')
AddEventHandler('CLIMBAdmin:UpdateBlacklistedProps', function(entity)
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.addblacklistedprops') then 
        local config = LoadResourceFile(GetCurrentResourceName(), "modules/banned-props.json")
        local configjson = json.decode(config)
        configjson[entity] = true;
        SaveResourceFile(GetCurrentResourceName(), "modules/banned-props.json", json.encode(configjson, { indent = true }), -1)
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)

RegisterNetEvent('CLIMBAdmin:ReturnPlayers')
AddEventHandler('CLIMBAdmin:ReturnPlayers', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'climb.adminmenu') then 
        local Table = {}
        local Buttons = {}
        local Config = {}
        for i,v in pairs(GetPlayers()) do 
            local user_id = CLIMB.getUserId(v)
            if user_id ~= nil then 
                Table[user_id] = {v, GetPlayerName(v)}
            end
        end
        for i,v in pairs(RageUIAdmin.Buttons) do 
            if CLIMB.hasPermission(user_id, v[2]) then 
                Buttons[i] = true
            end
        end
        for i,v in pairs(RageUIAdmin.MiscButtons) do 
            if CLIMB.hasPermission(user_id, v[2]) then 
                Config[i] = v[3]
            end
        end
        TriggerClientEvent('CLIMBAdmin:RecievePlayers', source, Table, Buttons, Config)
    end
end)

RegisterNetEvent('CLIMBAdmin:Groups')
AddEventHandler('CLIMBAdmin:Groups', function(id)
    local source = source
    local user_id = CLIMB.getUserId(source)
    local GroupsL = {}
    if CLIMB.hasPermission(user_id, 'climb.adminmenu') then 
        for i,v in pairs(Groups.groups) do 
            if CLIMB.hasGroup(id, i) then
                GroupsL[i] = true;
            end
        end
        TriggerClientEvent('CLIMBAdmin:ReturnGroups', source, GroupsL)
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)



RegisterNetEvent('CLIMBAdmin:EntityCleanupGun')
AddEventHandler('CLIMBAdmin:EntityCleanupGun', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.propcleanup') then
        TriggerClientEvent('CLIMBAdmin:EntityCleanupGun', source)
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)

RegisterNetEvent('CLIMBAdmin:PropCleanup')
AddEventHandler('CLIMBAdmin:PropCleanup', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.propcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' has triggered a entity cleanup. Entity cleanup in 60s'}
          })
          Wait(30000)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' Entity cleanup in 30s.'}
          })
          Wait(30000)
          for i,v in pairs(GetAllObjects()) do 
             DeleteEntity(v)
          end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Entity Cleanup Completed"}
          })
        else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)


RegisterNetEvent('CLIMBAdmin:DeAttachEntity')
AddEventHandler('CLIMBAdmin:DeAttachEntity', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.propcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' has triggered a Deattach entity cleanup. Entity cleanup in 60s'}
          })
          Wait(30000)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. '  Deattach entity cleanup in 30s.'}
          })
          Wait(30000)
          TriggerClientEvent("CLIMBAdmin:EntityWipe", -1)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", " Deattach entity Cleanup Completed"}
          })
        else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)

RegisterNetEvent('CLIMBAdmin:PedCleanup')
AddEventHandler('CLIMBAdmin:PedCleanup', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.pedcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' has triggered a Ped cleanup. Ped cleanup in 60s'}
          })
          Wait(30000)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' Ped cleanup in 30s.'}
          })
          Wait(30000)
          for i,v in pairs(GetAllPeds()) do 
             DeleteEntity(v)
          end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Ped Cleanup Completed"}
          })
        else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)


RegisterNetEvent('CLIMBAdmin:VehCleanup')
AddEventHandler('CLIMBAdmin:VehCleanup', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.pedcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' has triggered a Vehicle cleanup. Vehicle cleanup in 60s'}
          })
          Wait(30000)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' Vehicle cleanup in 30s.'}
          })
          Wait(30000)
          for i,v in pairs(GetAllVehicles()) do 
             DeleteEntity(v)
          end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Vehicle Cleanup Completed"}
          })
        else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)

RegisterNetEvent('CLIMBAdmin:CleanAll')
AddEventHandler('CLIMBAdmin:CleanAll', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.cleanallcleanup') then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' has triggered a Vehicle, Ped, Entity Cleanup. The cleanup starts in 60s.'}
          })
          Wait(30000)
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Staff Member: " .. GetPlayerName(source) .. ' has triggered a Vehicle, Ped, Entity Cleanup. The cleanup starts in 30s.'}
          })
          Wait(30000)
          for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
         end
         for i,v in pairs(GetAllPeds()) do 
           DeleteEntity(v)
        end
        for i,v in pairs(GetAllObjects()) do
           DeleteEntity(v)
        end
          TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Vehicle, Ped, Entity Cleanup Completed"}
          })
        else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end
end)

RegisterNetEvent('CLIMBAdmin:RemoveGroup')
AddEventHandler('CLIMBAdmin:RemoveGroup', function(id, group)
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.removeGroups') then
        if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
            if CLIMB.hasPermission(user_id, 'player.manage_' .. group) then
                    CLIMB.removeUserGroup(id, group)
                    CLIMBclient.notify(source,{'~g~Success! Removed Group: ' .. group})
                    local GroupsL = {}
                    for i,v in pairs(Groups.groups) do 
                        if CLIMB.hasGroup(id, i) then
                            GroupsL[i] = true;
                        end
                    end
                    TriggerClientEvent('CLIMBAdmin:ReturnGroups', source, GroupsL)
            else 
                CLIMBclient.notify(source,{'~r~You do not have permission to remove this group.'})
            end
        else 
            CLIMB.removeUserGroup(id, group)
            CLIMBclient.notify(source,{'~g~Success! Removed Group: ' .. group})
            local GroupsL = {}
            for i,v in pairs(Groups.groups) do 
                if CLIMB.hasGroup(id, i) then
                    GroupsL[i] = true;
                end
            end
            TriggerClientEvent('CLIMBAdmin:ReturnGroups', source, GroupsL)
        end 
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)


RegisterNetEvent('CLIMBAdmin:AddGroup')
AddEventHandler('CLIMBAdmin:AddGroup', function(id, group)
    local source = source
    local user_id = CLIMB.getUserId(source)
    if CLIMB.hasPermission(user_id, 'player.addGroups') then
        if Groups.groups[group] and Groups.groups[group]._config and Groups.groups[group]._config['special'] then 
            if CLIMB.hasPermission(user_id, 'player.manage_' .. group) then
                    CLIMB.addUserGroup(id, group)
                    CLIMBclient.notify(source,{'~g~Success! Added Group: ' .. group})
                    local GroupsL = {}
                    for i,v in pairs(Groups.groups) do 
                        if CLIMB.hasGroup(id, i) then
                            GroupsL[i] = true;
                        end
                    end
                    TriggerClientEvent('CLIMBAdmin:ReturnGroups', source, GroupsL)
            else 
                CLIMBclient.notify(source,{'~r~You do not have permission to add this group.'})
            end
        else 
            CLIMB.addUserGroup(id, group)
            CLIMBclient.notify(source,{'~g~Success! Added Group: ' .. group})
            local GroupsL = {}
            for i,v in pairs(Groups.groups) do 
                if CLIMB.hasGroup(id, i) then
                    GroupsL[i] = true;
                end
            end
            TriggerClientEvent('CLIMBAdmin:ReturnGroups', source, GroupsL)
        end 
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('CLIMBAdmin:Revive')
AddEventHandler('CLIMBAdmin:Revive', function(id)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.revive') then
        if SelectedPlrSource then  
            CLIMBclient.varyHealth(SelectedPlrSource,{100})
            CLIMBclient.notify(source,{"~g~Revived Player"})
        else 
            CLIMBclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('CLIMBAdmin:SlapPlayer')
AddEventHandler('CLIMBAdmin:SlapPlayer', function(id)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.slap') then
        if SelectedPlrSource then  
            CLIMBclient.setHealth(SelectedPlrSource,{0})
            CLIMBclient.notify(source,{"~g~Slapped Player"})
        else 
            CLIMBclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

local onesync = GetConvar('onesync', nil)
RegisterNetEvent('CLIMBAdmin:SpectatePlr')
AddEventHandler('CLIMBAdmin:SpectatePlr', function(id)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.spectate') then
        if SelectedPlrSource then  
            if onesync ~= "off" then 
                local ped = GetPlayerPed(SelectedPlrSource)
                local pedCoords = GetEntityCoords(ped)
                print(pedCoords)
                TriggerClientEvent('CLIMBAdmin:Spectate', source, SelectedPlrSource, pedCoords)
            else 
                TriggerClientEvent('CLIMBAdmin:Spectate', source, SelectedPlrSource)  
            end
        else 
            CLIMBclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('CLIMBAdmin:TPTo')
AddEventHandler('CLIMBAdmin:TPTo', function(id)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.tpto') then
        if SelectedPlrSource then  
            if onesync ~= "off" then 
                local ped = GetPlayerPed(source)
                local otherPlr = GetPlayerPed(SelectedPlrSource)
                local pedCoords = GetEntityCoords(otherPlr)
                SetEntityCoords(ped, pedCoords)
            else 
                TriggerClientEvent('CLIMBAdmin:TPTo', source, false, id)  
            end
        else 
            CLIMBclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)

RegisterNetEvent('CLIMBAdmin:Bring')
AddEventHandler('CLIMBAdmin:Bring', function(id)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.tpto') then
        if SelectedPlrSource then  
            if onesync ~= "off" then 
                local ped = GetPlayerPed(source)
                local otherPlr = GetPlayerPed(SelectedPlrSource)
                local pedCoords = GetEntityCoords(ped)
                SetEntityCoords(otherPlr, pedCoords)
            else 
                TriggerClientEvent('CLIMBAdmin:Bring', SelectedPlrSource, false, id)  
            end
        else 
            CLIMBclient.notify(source,{"~r~This player may have left the game."})
        end
    else 
        CLIMB.banConsole(userid,'-1',GetPlayerName(source) .. ' is cheating! He\'s triggering events without permission')
    end 
end)
RegisterNetEvent('CLIMBAdmin:Kick')
AddEventHandler('CLIMBAdmin:Kick', function(id, reason, nof10)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.kick') then
        if SelectedPlrSource then  
            if not nof10 then 
                saveKickLog(id, GetPlayerName(source), reason)
            end
            CLIMB.kick(SelectedPlrSource,reason)
            CLIMBclient.notify(source,{'~g~Successfully kicked Player.'})
        end
    end
end)


RegisterNetEvent('CLIMBAdmin:AddCar')
AddEventHandler('CLIMBAdmin:AddCar', function(id, car)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.addcar') then
        if SelectedPlrSource and car ~= "" then  
            CLIMB.getUserIdentity(id, function(identity)	
                if not identity then
                    identity = {}
                    identity.registration = "JamesUK#6793"
                elseif not identity.registration then 
                    identity.registration = "JamesUK#6793"
                end	
                MySQL.execute("CLIMB/add_vehicle", {user_id = id, vehicle = car, registration = "P "..identity.registration})
            end)
            CLIMBclient.notify(source,{'~g~Successfully added Player\'s car'})
        else 
            CLIMBclient.notify(source,{'~r~Failed to add Player\'s car'})
        end
    end
end)

RegisterNetEvent('CLIMBAdmin:ServerShutdown')
AddEventHandler('CLIMBAdmin:ServerShutdown', function()
    local source = source 
    local userid = CLIMB.getUserId(source)
    if CLIMB.hasPermission(userid, 'player.shutdownserver') then
        TriggerClientEvent('CLIMBAdmin:ActivateShutdown', -1)
        Wait(300000)
        for i,v in pairs(GetPlayers()) do 
            DropPlayer(v, 'This server has shutdown please try rejoining in a few minutes.')
        end
        os.exit()
    end
end)


RegisterNetEvent('CLIMBAdmin:Ban')
AddEventHandler('CLIMBAdmin:Ban', function(id, hours, reason)
    local source = source 
    local SelectedPlrSource = CLIMB.getUserSource(id) 
    local userid = CLIMB.getUserId(source)
    local admin = GetPlayerName(source)
    if CLIMB.hasPermission(userid, 'player.ban') then
        if SelectedPlrSource then  
            if tonumber(hours) then 
                if tonumber(hours) == -1 then 
                    CLIMB.ban(source,id,"perm",reason)
                    saveBanLog(id, admin, reason, hours)
                    CLIMBclient.notify(source,{'~g~Successfully banned Player.'})
                else 
                    CLIMB.ban(source,id,hours,reason)
                    saveBanLog(id, admin, reason, hours)
                    CLIMBclient.notify(source,{'~g~Successfully banned Player.'})
                end
            else 
                CLIMBclient.notify(source,{"Please enter a number for the ban hours."})
            end 
        end
    end
end)




--CLIMB Admin



RegisterCommand('calladmin', function(source)
    local user_id = CLIMB.getUserId(source)
    if user_id ~= nil then
        if CLIMB.hasPermission(user_id,"player.calladmin") then
            ch_calladmin(source, nil)
        end
    end 
end)

local player_customs = {}

local function ch_display_custom(player, choice)
    CLIMBclient.getCustomization(player,{},function(custom)
        if player_customs[player] then -- hide
            player_customs[player] = nil
            CLIMBclient.removeDiv(player,{"customization"})
        else -- show
            local content = ""
            for k,v in pairs(custom) do
                content = content..k.." => "..json.encode(v).."<br />" 
            end
            
            player_customs[player] = true
            CLIMBclient.setDiv(player,{"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content})
        end
    end)
end

local function ch_noclip(player, choice)
    CLIMBclient.toggleNoclip(player, {})
end

-- Hotkey Open Admin Menu 1/2
function CLIMB.openAdminMenu(source)
    CLIMB.buildMenu("admin", {player = source}, function(menudata)
        menudata.name = "Admin"
        menudata.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
        CLIMB.openMenu(source,menudata)
    end)
end

-- Hotkey Open Admin Menu 2/2
function tCLIMB.openAdminMenu()
    CLIMB.openAdminMenu(source)
end

-- admin god mode
-- function task_god()
-- SetTimeout(10000, task_god)

-- for k,v in pairs(CLIMB.getUsersByPermission("admin.god")) do
-- CLIMB.setHunger(v, 0)
-- CLIMB.setThirst(v, 0)

-- local player = CLIMB.getUserSource(v)
-- if player ~= nil then
-- CLIMBclient.setHealth(player, {200})
-- end
-- end
-- end

-- task_god()
