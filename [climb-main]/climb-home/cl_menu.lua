local isDisplaying UI = false;

local function UI(bool)
      isDisplayingUI = bool;
    SetNuiFocus(isDisplayingUI, isDisplayingUI)
    if isDisplayingUI then
        SendNUIMessage({action = "openMainMenu"})
    else
        SendNUIMessage({action = "hideMainMenu"})
    end
end

RegisterCommand("menu", function()
  UI(not isDisplaying)
end)

RegisterNetEvent("foid", function()
  UI(not isDisplaying)
end)

RegisterNUICallback('climb-home', function(data, cb)
    if data.action == "multiplayer" then
        if not isPlaying then
            DoScreenFadeOut(500)
            Wait(510)
            UI(false)
            SetEntityCoords(PlayerPedId(), -381.59, 2591.59, 89.74, false, false, false, false)
            Wait(1000)
            DoScreenFadeIn(1900)
            isPlaying = true;
            cb(true)
        end
    end
end)

RegisterNUICallback('climb-home', function(data, cb)
    if data.action == "privatelobby" then
        if not isPlaying then
            DoScreenFadeOut(500)
            Wait(510)
            UI(false)
            SetEntityCoords(PlayerPedId(), -381.59, 2591.59, 89.74, false, false, false, false)
            Wait(1000)
            DoScreenFadeIn(1900)
            isPlaying = true;
            cb(true)
        end
    end
end)