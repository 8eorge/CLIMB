local plrsInServer = {}
local SelectedPerm = nil;
local SelectedGroup = nil;
local Buttons = {}
local MiscBtn = {}
local EntitysDeleted = {}
local Groups = {}
local cfg = module('cfg/admin_menu')
RMenu.Add('CLIMBAdmin', 'main', RageUI.CreateMenu("Player Management", "~y~Staff Menu",1250,100))
RMenu.Add('CLIMBAdmin', 'players',  RageUI.CreateSubMenu(RMenu:Get("CLIMBAdmin", "main")))
RMenu.Add('CLIMBAdmin', 'player_selected',  RageUI.CreateSubMenu(RMenu:Get("CLIMBAdmin", "players")))
RMenu.Add('CLIMBAdmin', 'groups',  RageUI.CreateSubMenu(RMenu:Get("CLIMBAdmin", "player_selected")))
RMenu.Add('CLIMBAdmin', 'groups_manage',  RageUI.CreateSubMenu(RMenu:Get("CLIMBAdmin", "groups")))
RMenu.Add('CLIMBAdmin', 'misc',  RageUI.CreateSubMenu(RMenu:Get("CLIMBAdmin", "main")))
RMenu.Add('CLIMBAdmin', 'EntitysDeleted',  RageUI.CreateSubMenu(RMenu:Get("CLIMBAdmin", "main")))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
                RageUI.Button("Players", "", {}, true, function(Hovered, Active, Selected) end, RMenu:Get("CLIMBAdmin", "players"))
                RageUI.Button("Misc Options", "", {}, true, function(Hovered, Active, Selected) end, RMenu:Get("CLIMBAdmin", "misc"))
                RageUI.Button("Entity Options", "", {}, true, function(Hovered, Active, Selected) end, RMenu:Get("CLIMBAdmin", "EntitysDeleted"))
        end)
    end
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'misc')) then 
        RMenu:Get('CLIMBAdmin', 'misc'):SetTitle('Server Management') 
        RMenu:Get('CLIMBAdmin', 'misc'):SetSubtitle(" ")
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            
            for i,v in pairs(MiscBtn) do 
                RageUI.Button(i, v, {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        cfg.MiscButtons[i][1]()
                    end
                end)
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'EntitysDeleted')) then 
        RMenu:Get('CLIMBAdmin', 'EntitysDeleted'):SetTitle('Server Management') 
        RMenu:Get('CLIMBAdmin', 'EntitysDeleted'):SetSubtitle("~y~Add Blacklisted Entities here")
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            RageUI.Button('Clear Entities', "", {}, true, function(Hovered, Active, Selected) 
                if Selected then 
                    EntitysDeleted = {}
                end
            end)
            for i,v in pairs(EntitysDeleted) do 
                RageUI.Button(i, "This makes it so it can never be spawned again!", {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        TriggerServerEvent('CLIMBAdmin:UpdateBlacklistedProps', i)
                        EntitysDeleted[i] = nil 
                    end
                end)
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'players')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            for i,v in pairs(plrsInServer) do 
                RageUI.Button(v[2], "~w~Perm ID: ~y~" .. i .. ' ~w~| Temp ID: ~y~' .. v[1], {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        SelectedPerm = i
                        RMenu:Get('CLIMBAdmin', 'player_selected'):SetSubtitle("PermID: ~y~" .. 1 .." ~w~| ~w~TempID: ~y~" .. v[1] .. '  ~w~| Name: ~y~' .. v[2])
                    end
                end, RMenu:Get("CLIMBAdmin", "player_selected"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'player_selected')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            for i,v in pairs(Buttons) do 
                RageUI.Button(i, "", {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        cfg.Buttons[i][1](SelectedPerm)
                    end
                end)
            end
            RageUI.Button('Players Groups', "", {}, true, function(Hovered, Active, Selected)
                if Selected then 
                    TriggerServerEvent('CLIMBAdmin:Groups', SelectedPerm)
                    RMenu:Get('CLIMBAdmin', 'groups'):SetSubtitle("~y~Groups for PermID: " .. SelectedPerm)
                end
            end, RMenu:Get("CLIMBAdmin", "groups"))
        end) 
    end
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'groups')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            for i,v in pairs(Groups) do 
                RageUI.Button(i, "", {}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        SelectedGroup = i;
                    end
                end, RMenu:Get("CLIMBAdmin", "groups_manage"))
            end
        end) 
    end
    if RageUI.Visible(RMenu:Get('CLIMBAdmin', 'groups_manage')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true}, function()
            RageUI.Button('Remove Group', "", {}, true, function(Hovered, Active, Selected) 
                if Selected then
                    TriggerServerEvent('CLIMBAdmin:RemoveGroup', SelectedPerm, SelectedGroup)
                end
            end)
        end) 
    end
end)

RegisterCommand('openadminmenu', function()
    TriggerServerEvent('CLIMBAdmin:ReturnPlayers')
end, false)


RegisterKeyMapping('openadminmenu', 'Opens admin menu', 'keyboard', 'F2')



RegisterNetEvent('CLIMBAdmin:RecievePlayers')
AddEventHandler('CLIMBAdmin:RecievePlayers', function(table, perms, misc)
    plrsInServer = table
    Buttons = perms
    MiscBtn = misc
    RageUI.Visible(RMenu:Get('CLIMBAdmin', 'main'), not RageUI.Visible(RMenu:Get('CLIMBAdmin', 'main')))
end)

RegisterNetEvent('CLIMBAdmin:ReturnGroups')
AddEventHandler('CLIMBAdmin:ReturnGroups', function(groups)
    Groups = groups
end)


local Spectating = false;
local LastCoords = nil;
RegisterNetEvent('CLIMBAdmin:Spectate')
AddEventHandler('CLIMBAdmin:Spectate', function(plr,tpcoords)
    local playerPed = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(plr))
    if not Spectating then
        LastCoords = GetEntityCoords(playerPed) 
        if tpcoords then 
            SetEntityCoords(playerPed, tpcoords - 10.0)
        end
        Wait(300)
        targetPed = GetPlayerPed(GetPlayerFromServerId(plr))
        if targetPed == playerPed then tCLIMB.notify('~r~I mean you cannot spectate yourself...') return end
		NetworkSetInSpectatorMode(true, targetPed)
        SetEntityCollision(playerPed, false, false)
        SetEntityVisible(playerPed, false, 0)
		SetEveryoneIgnorePlayer(playerPed, true)	
		SetEntityInvincible(playerPed, true) 
        Spectating = true
        tCLIMB.notify('~g~Spectating Player.')
    else 
        NetworkSetInSpectatorMode(false, targetPed)
        SetEntityVisible(playerPed, true, 0)
		SetEveryoneIgnorePlayer(playerPed, false)
		SetEntityInvincible(playerPed, false)
		SetEntityCollision(playerPed, true, true)
        Spectating = false;
        SetEntityCoords(playerPed, LastCoords)
        tCLIMB.notify('~r~Stopped Spectating Player.')
    end 
end)

RegisterNetEvent('CLIMBAdmin:TPTo')
AddEventHandler('CLIMBAdmin:TPTo', function(coords, plr)
    if coords then 
        SetEntityCoords(PlayerPedId(), coords)
    else 
        local targetPed = GetPlayerPed(GetPlayerFromServerId(plr))
        local plrcoords = GetEntityCoords(targetPed)
        SetEntityCoords(PlayerPedId(), plrcoords)
    end
end)

RegisterNetEvent('CLIMBAdmin:Bring')
AddEventHandler('CLIMBAdmin:Bring', function(coords, plr)
    if coords then 
        SetEntityCoords(PlayerPedId(), coords)
    else 
        local targetPed = GetPlayerPed(GetPlayerFromServerId(plr))
        local plrcoords = GetEntityCoords(targetPed)
        SetEntityCoords(PlayerPedId(), plrcoords)
    end
end)

function NetworkDelete(entity)
    Citizen.CreateThread(function()
        if DoesEntityExist(entity) and not (IsEntityAPed(entity) and IsPedAPlayer(entity)) then
            NetworkRequestControlOfEntity(entity)
            local timeout = 5
            while timeout > 0 and not NetworkHasControlOfEntity(entity) do
                Citizen.Wait(1)
                timeout = timeout - 1
            end
            DetachEntity(entity, 0, false)
            SetEntityCollision(entity, false, false)
            SetEntityAlpha(entity, 0.0, true)
            SetEntityAsMissionEntity(entity, true, true)
            SetEntityAsNoLongerNeeded(entity)
            DeleteEntity(entity)
        end
    end)
end

RegisterNetEvent("CLIMBAdmin:EntityWipe")
AddEventHandler("CLIMBAdmin:EntityWipe", function(id)
    Citizen.CreateThread(function() 
        for k,v in pairs(GetAllEnumerators()) do 
            local enum = v
            for entity in enum() do 
                local owner = NetworkGetEntityOwner(entity)
                local playerID = GetPlayerServerId(owner)
                NetworkDelete(entity)
            end
        end
    end)
end)

local EntityCleanupGun = false;
RegisterNetEvent("CLIMBAdmin:EntityCleanupGun")
AddEventHandler("CLIMBAdmin:EntityCleanupGun", function()
    EntityCleanupGun = not EntityCleanupGun
    if EntityCleanupGun then 
        GiveWeaponToPed(PlayerPedId(), GetHashKey('WEAPON_PISTOL'), 250, false, true)
        tCLIMB.notify("~g~Entity cleanup gun enabled.")
    else 
        tCLIMB.notify("~r~Entity cleanup gun disabled.")
        RemoveWeaponFromPed(PlayerPedId(), GetHashKey('WEAPON_PISTOL'))
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(0)
        if EntityCleanupGun then 
            local plr = PlayerId()
            if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_PISTOL') then
                if IsPlayerFreeAiming(plr) then 
                    local yes, entity = GetEntityPlayerIsFreeAimingAt(plr)
                    if yes then 
                        EntitysDeleted[GetEntityModel(entity)] = true;
                        tCLIMB.notify('~g~Deleted Entity: ' .. GetEntityModel(entity))
                        NetworkDelete(entity)
                    end
                end 
            else 
                RemoveWeaponFromPed(PlayerPedId(), GetHashKey('WEAPON_PISTOL'))
                EntityCleanupGun = false;
                tCLIMB.notify("~r~Entity cleanup gun disabled.")
            end 
        end
    end
end)


local KickActive = false;
local currenttime = 300; 

RegisterNetEvent('CLIMBAdmin:ActivateShutdown')
AddEventHandler('CLIMBAdmin:ActivateShutdown', function()
    KickActive = true;
end)

Citizen.CreateThread(function()
    while true do 
        Wait(1000)
        if KickActive then
            currenttime = currenttime - 1 
        end
    end
end)

local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if KickActive then
            if HasScaleformMovieLoaded(scaleform) then
                PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
                BeginTextComponent("STRING")
                AddTextComponentString("~r~THIS SERVER IS SHUTTING DOWN IN: " .. currenttime .. " Seconds")
                EndTextComponent()
                PopScaleformMovieFunctionVoid()
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
            end
        else 
            currenttime = 300
        end
    end
end)

