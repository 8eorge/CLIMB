Citizen.CreateThread(function()
    if SetDiscordRichPresenceAction then 
        SetDiscordRichPresenceAction(0,"CLIMB Now","fivem://connect/connect.climb.me")
        SetDiscordRichPresenceAction(1, "Discord","https://discord.gg/climb")
    end 
end)

Citizen.CreateThread(function()
    while true do
        Wait(5000)
        if u ~= nil and v ~= nil and x ~= nil then
            SetDiscordAppId(1133345418810490970)
            SetDiscordRichPresenceAsset('climb') 
            SetDiscordRichPresenceAssetText("discord.gg/climb") 
            SetDiscordRichPresenceAssetSmall('climb')
            SetDiscordRichPresenceAssetSmallText('CLIMB')
            SetRichPresence("[ID:" .. tostring(tCLIMB.getUserId()) .. "] | " .. tostring(v) .. "/" .. tostring(x))
        end
        Wait(15000)
    end
end)