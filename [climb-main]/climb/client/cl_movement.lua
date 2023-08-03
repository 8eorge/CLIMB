--Mantle--
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        SetPedCanRagdoll(ped, false)
        if IsPedJumping(ped) then
            Wait(650)
            if IsControlPressed(0, Config.Button) then
                for _,v in pairs(Config.Objects) do
                    if DoesObjectOfTypeExistAtCoords(GetEntityCoords(ped), Config.Radius, v.objectHash, true) then
                        TaskClimb(ped)
                    end
                end
            end
        end
        Wait(0)
    end
end)

--TipToe--
Citizen.CreateThread(function()
	while true do
        local ped = GetPlayerPed(-1)
		local ad = "move_action@generic@core"
		local anim = "run_down"
		if IsPedOnFoot(ped) then
			if not IsPedRagdoll(ped) then
				if IsControlPressed(0, 46) then
							TaskPlayAnim(ad)
							SetPedMoveRateOverride(ped, 1.25)
							TaskPlayAnim(ped, ad, "exit", 3.0, 1.0, -1, 0, 0, 0, 0, 0)
							ClearPedSecondaryTask(ped)
							TaskPlayAnim(ped, ad, anim, 3.0, 1.0, -1, 0, 0, 0, 0, 0)

							  Wait(300)
							TaskPlayAnim(ped, ad, "exit", 3.0, 1.0, -1, 0, 0, 0, 0, 0)
							ClearPedSecondaryTask(ped)
						end
					end
				end
	  Wait(0)
	end
end)

--beds--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        -- Adjust the range and height as needed based on your prop's size and where you want the boost to trigger.
        local propNearby = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, GetHashKey("gr_prop_bunker_bed_01"), false, false, false)

        if DoesEntityExist(propNearby) then
            local propCoords = GetEntityCoords(propNearby)
            local propHeight = propCoords.z + 25.0 -- The height you want the player to be boosted.

            -- Check if the player is on the prop.
            if coords.z > propCoords.z and coords.z < propCoords.z + 0.5 then
                -- Apply the vertical boost.
                SetEntityVelocity(playerPed, 0.0, 0.0, 25.0) -- Change the last value to adjust the boost force.
            end
        end
    end
end)