local staffGroups = {
    ['Founder'] = true,
    ['Management'] = true,
    ['Staff'] = true,

local defaultGroups = {
    ["user"] = true,
}
function getGroupInGroups(id, type)
    if type == 'Staff' then
        for k,v in pairs(CLIMB.getUserGroups(id)) do
            if staffGroups[k] then 
                return k
            end 
        end
    elseif type == 'Default' then
        for k,v in pairs(CLIMB.getUserGroups(id)) do
            if defaultGroups[k] then 
                return k
            end 
        end
        return "Climbing"
    end
end


local uptime = 0
local function playerListMetaUpdates()
    local uptimemessage = ''
    if uptime < 60 then
        uptimemessage = math.floor(uptime) .. ' seconds'
    elseif uptime >= 60 and uptime < 3600 then
        uptimemessage = math.floor(uptime/60) .. ' minutes and ' .. math.floor(uptime%60) .. ' seconds'
    elseif uptime >= 3600 then
        uptimemessage = math.floor(uptime/3600) .. ' hours and ' .. math.floor((uptime%3600)/60) .. ' minutes and ' .. math.floor(uptime%60) .. ' seconds'
    end
    return {uptimemessage, #GetPlayers(), GetConvarInt("sv_maxclients",64)}
end


RegisterNetEvent('CLIMB:getPlayerListData')
AddEventHandler('CLIMB:getPlayerListData', function()
    local source = source
    local user_id = CLIMB.getUserId(source)
    local staff = {}
    local police = {}
    local nhs = {}
    local lfb = {}
    local hmp = {}
    local civillians = {}
    for k,v in pairs(CLIMB.getUsers()) do
        if not hiddenUsers[k] then
            local name = GetPlayerName(v)
            if name ~= nil then
                local minutesPlayed = CLIMB.getUserDataTable(k).PlayerTime or 0
                local hours = math.floor(minutesPlayed/60)
                if CLIMB.hasPermission(k, 'admin.menu') then
                    staff[k] = {name = name, rank = getGroupInGroups(k, 'Staff'), hours = hours}
                end
                if (not CLIMB.hasPermission(k, "police.onduty.permission") or CLIMB.hasPermission(k, 'police.undercover')) and not CLIMB.hasPermission(k, "nhs.onduty.permission") and not CLIMB.hasPermission(k, "lfb.onduty.permission") and not CLIMB.hasPermission(k, "prisonguard.onduty.permission") then
                    civillians[k] = {name = name, rank = getGroupInGroups(k, 'Default'), hours = hours}
                end
            end
        end
    end
    TriggerClientEvent('CLIMB:gotFullPlayerListData', source, staff, police, nhs, lfb, hmp, civillians)
    TriggerClientEvent('CLIMB:gotJobTypes', source, nhsGroups, pdGroups, lfbGroups, hmpGroups, tridentGroups)
end)

RegisterServerEvent('GetActivePlayers')
AddEventHandler('GetActivePlayers', function()
    local count = GetNumPlayerIndices()
    -- Callback to client
    TriggerClientEvent('GetActivePlayers:CB', source, count)
end)

