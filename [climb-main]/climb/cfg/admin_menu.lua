local cfg = {}

cfg.Buttons = {
    ["Ban"] = {function(self)
    local reason = nil
    local hours = nil
    AddTextEntry('FMMC_MPM_NC', "Enter Reason for Ban Player")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        if result then 
            reason = result
        end
    end
    AddTextEntry('FMMC_MPM_NC', "Enter Hours for Ban (-1 is perm ban)")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        if result then 
            hours = tonumber(result)
        end
    end
    TriggerServerEvent('CLIMBAdmin:Ban', self, hours, reason)
    end, "player.ban"},
    ["Kick"] = {function(self)
    AddTextEntry('FMMC_MPM_NC', "Enter Reason to Kick Player")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        if result then 
            result = result
            TriggerServerEvent('CLIMBAdmin:Kick', self, result, false)
        end
    end
    end, "player.kick"},
    ["No Warning Kick"] = {function(self)
        AddTextEntry('FMMC_MPM_NC', "Enter Reason to Kick Player")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            if result then 
                result = result
                TriggerServerEvent('CLIMBAdmin:Kick', self, result, true)
            end
        end
    end, "player.kick"},
    ["Revive"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:Revive', self)
    end, "player.revive"},
    ["Slap"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:SlapPlayer', self)
    end, "player.slap"},
    ["Spectate"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:SpectatePlr', self)
    end, "player.spectate"},
    
    ["Add Car"] = {function(self)
        AddTextEntry('FMMC_MPM_NC', "Enter the car spawncode")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            if result then 
                TriggerServerEvent('CLIMBAdmin:AddCar', self, result)
            end
        end
    end, "player.addcar"},
    ["TP To Player"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:TPTo', self)
    end, "player.tpto"},
    ["Bring Player"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:Bring', self)
    end, "player.tpbring"},
    ["Add Group"] = {function(self)
        AddTextEntry('FMMC_MPM_NC', "Enter the group name")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            if result then 
                TriggerServerEvent('CLIMBAdmin:AddGroup', self, result)
            end
        end
    end, "player.addGroups"},
    ["Warn Player"] = {function(self)
        userWarningMessage = getWarningUserMsg()
        if userWarningMessage then
            TriggerServerEvent("climb:warnPlayer",self,userWarningMessage)
        else
            tCLIMB.notify('Please enter a warning message!')
        end
    end, "player.kick"},
    ["Show Warnings"] = {function(self)
    ExecuteCommand("showwarnings "..tostring(self))
    end, "player.kick"},
}

--CLIMB:RemoveWarning
cfg.MiscButtons = {
    ["Entity Cleanup"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:PropCleanup')
    end, "player.propcleanup", "Gets rid of those pesky modders ramps! (Onesync)"},
    ["Remove Warning"] = {function(self)
        AddTextEntry('FMMC_MPM_NC', "Enter the WarningID")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            if result then 
                TriggerServerEvent('CLIMB:RemoveWarning', result)
            end
        end
    end, "admin.removewarning", "Removes a warning"},
    ["Entity Cleanup Gun"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:EntityCleanupGun')
    end, "player.propcleanup", "Makes your current Gun a Cleanup Gun! Deletes anything you aim at"},
    ["Deattach Entity Cleanup"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:DeAttachEntity')
    end, "player.propcleanup", "Gets rid of those pesky attached hamburgers! (Onesync)"},
    ["Vehicle Cleanup"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:VehCleanup')
    end, "player.vehcleanup", "Gets rid of those vehicles! (Onesync)"},
    ["Ped Cleanup"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:PedCleanup')
    end, "player.pedcleanup", "Gets rid of those peds! (Onesync)"},
    ["All Cleanup"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:CleanAll')
    end, "player.cleanallcleanup", "When your server is so fucked you need to cleanup everything. (Onesync)"},
    ["Shutdown Server"] = {function(self)
        TriggerServerEvent('CLIMBAdmin:ServerShutdown')
    end, "player.shutdownserver", "Shuts down the server!"},
    ["TP to Waypoint"] = {function(self)
        TriggerEvent("TpToWaypoint")
    end, "player.tptowaypoint", "Teleports you to a waypoint"},
    ["Noclip"] = {function(self)
        tCLIMB.toggleNoclip({})
    end, "player.noclip", "Teleports you to a waypoint"},
    ["Spawn Vehicle"] = {function(self)
        AddTextEntry('FMMC_MPM_NC', "Enter the car spawncode name")
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NC", "", "", "", "", "", 30)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            if result then 
                local mhash = GetHashKey(result)
                local i = 0
                while not HasModelLoaded(mhash) and i < 10000 do
                    RequestModel(mhash)
                    Citizen.Wait(10)
                    i = i+1
                    if i > 10000 then 
                        tCLIMB.notify('~r~Model could not be loaded!')
                        break 
                    end
                end
                -- spawn car
                if HasModelLoaded(mhash) then
                    local x,y,z = tCLIMB.getPosition()
                    if pos then
                        x,y,z = table.unpack(pos)
                    end
                    local nveh = CreateVehicle(mhash, x,y,z+0.5, 0.0, true, false)
                    SetVehicleOnGroundProperly(nveh)
                    SetEntityInvincible(nveh,false)
                    SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside
                    SetVehicleNumberPlateText(nveh, "P "..tCLIMB.getRegistrationNumber())
                    --Citizen.InvokeNative(0xAD738C3085FE7E11, nveh, true, true) -- set as mission entity
                    SetVehicleHasBeenOwnedByPlayer(nveh,true)
                    local nid = NetworkGetNetworkIdFromEntity(nveh)
                    SetNetworkIdCanMigrate(nid,cfg.vehicle_migration)
                end
            end
        end
    end, "admin.spawnveh", "Spawns you a car"},
}
return cfg
