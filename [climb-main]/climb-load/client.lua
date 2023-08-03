AddEventHandler("LoadingScreen", function(varName, varValue)
	SendNUIMessage({name = varName, value = varValue })
end)

RegisterNetEvent("FDM:StartLoadingVid", function()
    SendNUIMessage({
        action = "vid",
    })
end)
