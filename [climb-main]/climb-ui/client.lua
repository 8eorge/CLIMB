local PlayerPedId = PlayerPedId
local CreateThread = CreateThread
local screenRes = {x = nil,y=nil }
local aspectRatio = nil;

local function getMinimapAnchor()
	local safezone = GetSafeZoneSize()
	local safezone_x = 1.0 / 20.0
	local safezone_y = 1.0 / 20.0
	local aspect_ratio = GetAspectRatio(0)
	local res_x, res_y = GetActiveScreenResolution()
	local xscale = 1.0 / res_x
	local yscale = 1.0 / res_y
	local Minimap = {}
	Minimap.width = xscale * (res_x / (4 * aspect_ratio))
	Minimap.height = yscale * (res_y / 5.674)
	Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
	Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
	Minimap.right_x = Minimap.left_x + Minimap.width
	Minimap.top_y = Minimap.bottom_y - Minimap.height
	Minimap.x = Minimap.left_x
	Minimap.y = Minimap.top_y
	Minimap.xunit = xscale
	Minimap.yunit = yscale
	return Minimap
end

local function startHud()
	CreateThread(function()
		while true do
			local resX, resY = false, false
			if screenRes.x == nil or screenRes.x ~= resX or screenRes.y == nil or screenRes.y ~= resY then
				SendNUIMessage({
					action = "updateResolution",
					position = getMinimapAnchor(),
				})
			end
			resX, resY = GetActiveScreenResolution()
			screenRes = {x = resX, y = resY}
			Wait(2000)
			local AspectRatio = GetAspectRatio(0)
			if aspectRatio ~= AspectRatio then
				aspectRatio = AspectRatio
				SendNUIMessage({
					action = "updateResolution",
					position = getMinimapAnchor(),
				})
			end
			Wait(0)
		end
	end)
end

startHud()

Citizen.CreateThread(function()
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)
