local stopWatch = false
local m, s, r = 00, 00, 00
Citizen.CreateThread(function()
    if not HasStreamedTextureDictLoaded("timerbars") then
        RequestStreamedTextureDict("timerbars")
        while not HasStreamedTextureDictLoaded("timerbars") do
            Wait(0)
        end
    end
end)
function DrawGTAText(A, v, w, aa, ab, ac)
    SetTextFont(0)
    SetTextScale(aa, aa)
    SetTextColour(254, 254, 254, 255)
    if ab then
        SetTextWrap(v - ac, v)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(A)
    EndTextCommandDisplayText(v, w)
end
function DrawGTATimerBar(ad, A, ae)
    local ac = 0.17
    local af = -0.01
    local ag = 0.038
    local ah = 0.008
    local ai = 0.005
    local aj = 0.32
    local ak = -0.04
    local al = 0.014
    local am = GetSafeZoneSize()
    local an = al + am - ac + ac / 2
    local ao = ak + am - ag + ag / 2 - (ae - 1) * (ag + ai)
    DrawSprite("timerbars", "all_black_bg", an, ao, ac, 0.038, 0, 0, 0, 0, 128)
    DrawGTAText(ad, am - ac + 0.06, ao - ah, aj)
    DrawGTAText(string.upper(A), am - af, ao - 0.0175, 0.5, true, ac / 2)
end

Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 56) then
            stopWatch = not stopWatch
            if not stopWatch then
                m, s, r = 00, 00, 00
            end
        end
        if stopWatch then
            r = r + 1
            if r == 60 then
                r = 00
                s = s + 1
            end
            if s == 60 then
                s = 00
                m = m + 1
            end
            DrawGTATimerBar("~y~Stopwatch:", m .. ":" .. s .. ":" .. r, 1)
        end
        Citizen.Wait(1)
    end
end)