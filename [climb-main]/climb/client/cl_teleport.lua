-- Define the teleportation coordinates here (replace with your desired location)
local teleportLocation = vector3(-381.59, 2591.59, 89.74)

-- Register the teleportation command
RegisterCommand("spawn", function(source, args, rawCommand)
    local player = source
    local playerPed = GetPlayerPed(player)

    -- Check if the player is on foot (you can add more checks based on your needs)
    if IsPedOnFoot(playerPed) then
        -- Teleport the player to the specified location
        SetEntityCoords(playerPed, teleportLocation.x, teleportLocation.y, teleportLocation.z)

        -- Optionally, notify the player that they have been teleported
        TriggerClientEvent("chatMessage", player, "^*^1Teleportation:^0^r You have been teleported.")
    else
        -- Notify the player that they can only use the teleportation command on foot
        TriggerClientEvent("chatMessage", player, "^*^1Teleportation:^0^r You can only use this command while on foot.")
    end
end, false)
