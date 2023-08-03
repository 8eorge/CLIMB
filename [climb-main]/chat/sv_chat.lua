RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

local blockedWords = {"nigger", "nigga", "wog", "coon", "paki","faggot","faggit",}

local cooldown = {}

AddEventHandler('_chat:messageEntered', function(author, color, message)
    local name = GetPlayerName(source)
    if not message or not author then
        return
    end

    if not WasEventCanceled() then
        if cooldown[source] and not (os.time() > cooldown[source]) then
            TriggerClientEvent('chatMessage', source, "CLIMB",  { 255, 201, 31 }, "You are being rate limited.", "alert")
            return
        else
            cooldown[source] = nil
        end

        for k,v in pairs(blockedWords) do
            if string.match(message:lower(), v) then
                CancelEvent()
                return
            end
        end
        cooldown[source] = os.time() + 2
        TriggerClientEvent('chatMessage', -1, "CLIMB User: "..author..":",  { 255, 201, 31 }, message)
        TriggerEvent("chat:TwitterLogs", message, name, source)
    end

    print(author .. '^7: ' .. message .. '^7')
end)


-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)