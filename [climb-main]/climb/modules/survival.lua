local cfg = module("cfg/survival")
local lang = CLIMB.lang

-- api

function CLIMB.getHunger(user_id)
    local data = CLIMB.getUserDataTable(user_id)
    if data then
        return data.hunger
    end

    return 0
end

function CLIMB.getThirst(user_id)
    local data = CLIMB.getUserDataTable(user_id)
    if data then
        return data.thirst
    end

    return 0
end

function CLIMB.setHunger(user_id, value)
    local data = CLIMB.getUserDataTable(user_id)
    if data then
        data.hunger = value
        if data.hunger < 0 then
            data.hunger = 0
        elseif data.hunger > 100 then
            data.hunger = 100
        end

        -- update bar
        local source = CLIMB.getUserSource(user_id)
        CLIMBclient.setProgressBarValue(source, {"CLIMB:hunger", data.hunger})
        if data.hunger >= 100 then
            CLIMBclient.setProgressBarText(source, {"CLIMB:hunger", lang.survival.starving()})
        else
            CLIMBclient.setProgressBarText(source, {"CLIMB:hunger", ""})
        end
    end
end

function CLIMB.setThirst(user_id, value)
    local data = CLIMB.getUserDataTable(user_id)
    if data then
        data.thirst = value
        if data.thirst < 0 then
            data.thirst = 0
        elseif data.thirst > 100 then
            data.thirst = 100
        end

        -- update bar
        local source = CLIMB.getUserSource(user_id)
        CLIMBclient.setProgressBarValue(source, {"CLIMB:thirst", data.thirst})
        if data.thirst >= 100 then
            CLIMBclient.setProgressBarText(source, {"CLIMB:thirst", lang.survival.thirsty()})
        else
            CLIMBclient.setProgressBarText(source, {"CLIMB:thirst", ""})
        end
    end
end

function CLIMB.varyHunger(user_id, variation)
    if CLIMBConfig.EnableFoodAndWater then 
        local data = CLIMB.getUserDataTable(user_id)
        if data then
            local was_starving = data.hunger >= 100
            data.hunger = data.hunger + variation
            local is_starving = data.hunger >= 100

            -- apply overflow as damage
            local overflow = data.hunger - 100
            if overflow > 0 then
                CLIMBclient.varyHealth(CLIMB.getUserSource(user_id), {-overflow * cfg.overflow_damage_factor})
            end

            if data.hunger < 0 then
                data.hunger = 0
            elseif data.hunger > 100 then
                data.hunger = 100
            end

            -- set progress bar data
            local source = CLIMB.getUserSource(user_id)
            CLIMBclient.setProgressBarValue(source, {"CLIMB:hunger", data.hunger})
            if was_starving and not is_starving then
                CLIMBclient.setProgressBarText(source, {"CLIMB:hunger", ""})
            elseif not was_starving and is_starving then
                CLIMBclient.setProgressBarText(source, {"CLIMB:hunger", lang.survival.starving()})
            end
        end
    end
end

function CLIMB.varyThirst(user_id, variation)
    if CLIMBConfig.EnableFoodAndWater then 
        local data = CLIMB.getUserDataTable(user_id)
        if data then
            local was_thirsty = data.thirst >= 100
            data.thirst = data.thirst + variation
            local is_thirsty = data.thirst >= 100

            -- apply overflow as damage
            local overflow = data.thirst - 100
            if overflow > 0 then
                CLIMBclient.varyHealth(CLIMB.getUserSource(user_id), {-overflow * cfg.overflow_damage_factor})
            end

            if data.thirst < 0 then
                data.thirst = 0
            elseif data.thirst > 100 then
                data.thirst = 100
            end

            -- set progress bar data
            local source = CLIMB.getUserSource(user_id)
            CLIMBclient.setProgressBarValue(source, {"CLIMB:thirst", data.thirst})
            if was_thirsty and not is_thirsty then
                CLIMBclient.setProgressBarText(source, {"CLIMB:thirst", ""})
            elseif not was_thirsty and is_thirsty then
                CLIMBclient.setProgressBarText(source, {"CLIMB:thirst", lang.survival.thirsty()})
            end
        end
    end
end

-- tunnel api (expose some functions to clients)

function tCLIMB.varyHunger(variation)
    if CLIMBConfig.EnableFoodAndWater then 
        local user_id = CLIMB.getUserId(source)
        if user_id ~= nil then
            CLIMB.varyHunger(user_id, variation)
        end
    end
end

function tCLIMB.varyThirst(variation)
    if CLIMBConfig.EnableFoodAndWater then 
        local user_id = CLIMB.getUserId(source)
        if user_id ~= nil then
            CLIMB.varyThirst(user_id, variation)
        end
    end
end

-- tasks

-- hunger/thirst increase
function task_update()
    for k, v in pairs(CLIMB.users) do
        CLIMB.varyHunger(v, cfg.hunger_per_minute)
        CLIMB.varyThirst(v, cfg.thirst_per_minute)
    end

    SetTimeout(60000, task_update)
end

if CLIMBConfig.EnableFoodAndWater then 
    task_update()
end

-- handlers

-- init values
AddEventHandler("CLIMB:playerJoin", function(user_id, source, name, last_login)
    local data = CLIMB.getUserDataTable(user_id)
    if data.hunger == nil then
        data.hunger = 0
        data.thirst = 0
    end
end)

-- add survival progress bars on spawn
AddEventHandler("CLIMB:playerSpawn", function(user_id, source, first_spawn)
    local data = CLIMB.getUserDataTable(user_id)
    CLIMBclient.setFriendlyFire(source, {cfg.pvp})
end)

-- EMERGENCY

---- revive
local revive_seq = {{"amb@medic@standing@kneel@enter", "enter", 1}, {"amb@medic@standing@kneel@idle_a", "idle_a", 1},
                    {"amb@medic@standing@kneel@exit", "exit", 1}}

local choice_revive = {function(player, choice)
    local user_id = CLIMB.getUserId(player)
    if user_id ~= nil then
        CLIMBclient.getNearestPlayer(player, {10}, function(nplayer)
            local nuser_id = CLIMB.getUserId(nplayer)
            if nuser_id ~= nil then
                CLIMBclient.isInComa(nplayer, {}, function(in_coma)
                    if in_coma then
                        if CLIMB.tryGetInventoryItem(user_id, "medkit", 1, true) then
                            CLIMBclient.playAnim(player, {false, revive_seq, false}) -- anim
                            SetTimeout(15000, function()
                                CLIMBclient.varyHealth(nplayer, {50}) -- heal 50
                            end)
                        end
                    else
                        CLIMBclient.notify(player, {lang.emergency.menu.revive.not_in_coma()})
                    end
                end)
            else
                CLIMBclient.notify(player, {lang.common.no_player_near()})
            end
        end)
    end
end, lang.emergency.menu.revive.description()}
