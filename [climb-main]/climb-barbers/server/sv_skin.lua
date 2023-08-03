local Tunnel = module("climb", "lib/Tunnel")
local Proxy = module("climb", "lib/Proxy")

CLIMB = Proxy.getInterface("CLIMB")
CLIMBclient = Tunnel.getInterface("CLIMB","CLIMB")

RegisterNetEvent("CLIMB:saveFaceData")
AddEventHandler("CLIMB:saveFaceData", function(faceSaveData)
    local source = source
    local user_id = CLIMB.getUserId({source})
    CLIMB.setUData({user_id, "CLIMB:Face:Data", json.encode(faceSaveData)})
end)

RegisterNetEvent("CLIMB:saveClothingHairData") -- this updates hair from clothing stores
AddEventHandler("CLIMB:saveClothingHairData", function(hairtype, haircolour)
    local source = source
    local user_id = CLIMB.getUserId({source})
    local facesavedata = {}
    CLIMB.getUData({user_id, "CLIMB:Face:Data", function(data)
        if data ~= nil and data ~= 0 and hairtype ~= nil and haircolour ~= nil then
            facesavedata = json.decode(data)
            if facesavedata == nil then
                facesavedata = {}
            end
            facesavedata["hair"] = hairtype
            facesavedata["haircolor"] = haircolour
            CLIMB.setUData({user_id, "CLIMB:Face:Data", json.encode(facesavedata)})
        end
    end})
end)

RegisterNetEvent("CLIMB:changeHairstyle")
AddEventHandler("CLIMB:changeHairstyle", function()
    local source = source
    local user_id = CLIMB.getUserId({source})
    CLIMB.getUData({user_id, "CLIMB:Face:Data", function(data)
        if data ~= nil and data ~= 0 then
            TriggerClientEvent("CLIMB:setHairstyle", source, json.decode(data))
        end
    end})
end)

AddEventHandler("CLIMB:playerSpawn", function(user_id, source, first_spawn)
    SetTimeout(1000, function() 
        local source = source
        local user_id = CLIMB.getUserId({source})
        CLIMB.getUData({user_id, "CLIMB:Face:Data", function(data)
            if data ~= nil and data ~= 0 then
                TriggerClientEvent("CLIMB:setHairstyle", source, json.decode(data))
            end
        end})
    end)
end)