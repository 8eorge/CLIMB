
---- event from server to show notification
RegisterNetEvent("RageUI:Popup", function(array)
    RageUI.Popup(array)
end)

---Popup
---@param array table
---@public
function RageUI.Popup(array)
    ClearPrints()
    if (array.colors == nil) then
        ThefeedSetNextPostBackgroundColor(140)
    else
        ThefeedSetNextPostBackgroundColor(array.colors)
    end
    BeginTextCommandThefeedPost("STRING")
    if (array.message == nil) then
        error("Missing arguments, message")
    else
        AddTextComponentSubstringPlayerName(tostring(array.message))
    end
    EndTextCommandThefeedPostTicker(false, true)
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
end


---PopupChar
---@param array table
---@public
function RageUI.PopupChar(array)
    if (array.colors == nil) then
        ThefeedSetNextPostBackgroundColor(140)
    else
        ThefeedSetNextPostBackgroundColor(array.colors)
    end
    BeginTextCommandThefeedPost("STRING")
    if (array.message == nil) then
        error("Missing arguments, message")
    else
        AddTextComponentSubstringPlayerName(tostring(array.message))
    end
    if (array.request_stream_texture_dics ~= nil) then
        RequestStreamedTextureDict(array.request_stream_texture_dics, false)
    end
    if (array.picture ~= nil) then
        if (array.iconTypes == 1) or (array.iconTypes == 2) or (array.iconTypes == 3) or (array.iconTypes == 7) or (array.iconTypes == 8) or (array.iconTypes == 9) then
            EndTextCommandThefeedPostMessagetext(tostring(array.picture), tostring(array.picture), true, array.iconTypes, array.sender, array.title)
        else
            EndTextCommandThefeedPostMessagetext(tostring(array.picture), tostring(array.picture), true, 4, array.sender, array.title)
        end
    else
        if (array.iconTypes == 1) or (array.iconTypes == 2) or (array.iconTypes == 3) or (array.iconTypes == 7) or (array.iconTypes == 8) or (array.iconTypes == 9) then
            EndTextCommandThefeedPostMessagetext('CHAR_ALL_PLAYERS_CONF', 'CHAR_ALL_PLAYERS_CONF', true, array.iconTypes, array.sender, array.title)
        else
            EndTextCommandThefeedPostMessagetext('CHAR_ALL_PLAYERS_CONF', 'CHAR_ALL_PLAYERS_CONF', true, 4, array.sender, array.title)
        end
    end
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
    EndTextCommandThefeedPostTicker(false, true)
end

---Text
---@param array table
---@public
function RageUI.Text(array)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    if (array.message ~= nil) then
        AddTextComponentSubstringPlayerName(tostring(array.message))
    else
        error("Missing arguments, message")
    end
    if (array.time_display ~= nil) then
        EndTextCommandPrint(tonumber(array.time_display), 1)
    else
        EndTextCommandPrint(6000, 1)
    end
    if (array.sound ~= nil) then
        if (array.sound.audio_name ~= nil) then
            if (array.sound.audio_ref ~= nil) then
                PlaySoundFrontend(-1, array.sound.audio_name, array.sound.audio_ref, true)
            else
                error("Missing arguments, audio_ref")
            end
        else
            error("Missing arguments, audio_name")
        end
    end
end
