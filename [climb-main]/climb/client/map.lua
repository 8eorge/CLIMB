-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

-- TUNNEL CLIENT API

-- BLIP

-- create new blip, return native id
function tCLIMB.addBlip(x,y,z,idtype,idcolor,text)
  local blip = AddBlipForCoord(x+0.001,y+0.001,z+0.001) -- solve strange gta5 madness with integer -> double
  SetBlipSprite(blip, idtype) -- Sets the displayed sprite(https://docs.fivem.net/docs/game-references/blips/) for a specific blip.
  SetBlipAsShortRange(blip, true) -- Sets whether or not the specified blip should only be displayed when nearby, or on the minimap.
  SetBlipColour(blip,idcolor) --Set Blip Color
  SetBlipScale(blip, 0.9) -- Set Blip Size on Map
  SetBlipDisplay(blip,6) -- Shows the blip in map and minimap

  if text ~= nil then
    AddTextEntry("MAPBLIP", text)
    BeginTextCommandSetBlipName("MAPBLIP")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
  end

  return blip
end

-- remove blip by native id
function tCLIMB.removeBlip(id)
  RemoveBlip(id)
end


local named_blips = {}

-- set a named blip (same as addBlip but for a unique name, add or update)
-- return native id
function tCLIMB.setNamedBlip(name,x,y,z,idtype,idcolor,text)
  tCLIMB.removeNamedBlip(name) -- remove old one

  named_blips[name] = tCLIMB.addBlip(x,y,z,idtype,idcolor,text)
  return named_blips[name]
end

-- remove a named blip
function tCLIMB.removeNamedBlip(name)
  if named_blips[name] ~= nil then
    tCLIMB.removeBlip(named_blips[name])
    named_blips[name] = nil
  end
end

-- GPS

-- set the GPS destination marker coordinates
function tCLIMB.setGPS(x,y)
  SetNewWaypoint(x+0.0001,y+0.0001)
end

-- set route to native blip id
function tCLIMB.setBlipRoute(id)
  SetBlipRoute(id,true)
end

-- MARKER

local markers = {}
local marker_ids = Tools.newIDGenerator()
local named_markers = {}
local drawing_markers = {}

-- add a circular marker to the game map
-- return marker id
function tCLIMB.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  local marker = {x=x,y=y,z=z,sx=sx,sy=sy,sz=sz,r=r,g=g,b=b,a=a,visible_distance=visible_distance}


  -- default values
  if marker.sx == nil then marker.sx = 2.0 end
  if marker.sy == nil then marker.sy = 2.0 end
  if marker.sz == nil then marker.sz = 0.7 end

  if marker.r == nil then marker.r = 0 end
  if marker.g == nil then marker.g = 155 end
  if marker.b == nil then marker.b = 255 end
  if marker.a == nil then marker.a = 200 end

  -- fix gta5 integer -> double issue
  marker.x = marker.x+0.001
  marker.y = marker.y+0.001
  marker.z = marker.z+0.001
  marker.sx = marker.sx+0.001
  marker.sy = marker.sy+0.001
  marker.sz = marker.sz+0.001

  if marker.visible_distance == nil then marker.visible_distance = 150 end

  local id = marker_ids:gen()
  markers[id] = marker

  return id
end

-- remove marker
function tCLIMB.removeMarker(id)
  if markers[id] ~= nil then
    markers[id] = nil
    marker_ids:free(id)
  end
end

-- set a named marker (same as addMarker but for a unique name, add or update)
-- return id
function tCLIMB.setNamedMarker(name,x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  tCLIMB.removeNamedMarker(name) -- remove old marker

  named_markers[name] = tCLIMB.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  return named_markers[name]
end

function tCLIMB.removeNamedMarker(name)
  if named_markers[name] ~= nil then
    tCLIMB.removeMarker(named_markers[name])
    named_markers[name] = nil
  end
end

-- markers sort loop
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)

    local px,py,pz = tCLIMB.getPosition()

    for k,v in pairs(markers) do
      -- 150 is the min distance wich the markers will be starting to be drawn
      if #(vector3(v.x,v.y,v.z) - vector3(px,py,pz)) <= 150.0 then
        drawing_markers[k] = v
      else
        if drawing_markers[k] then drawing_markers[k] = nil end
      end
    end
  end
end)

-- markers draw loop
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    local px,py,pz = tCLIMB.getPosition()

    -- if this loop get filled with too many markers, the clientside
    -- starts lagging
    for k,v in pairs(drawing_markers) do
      -- check visibility
      if #(vector3(v.x,v.y,v.z) - vector3(px,py,pz)) <= v.visible_distance then
        DrawMarker(1,v.x,v.y,v.z,0,0,0,0,0,0,v.sx,v.sy,v.sz,v.r,v.g,v.b,v.a,0,0,0,0)
      end
    end
  end
end)

-- AREA

local areas = {}

-- create/update a cylinder area
function tCLIMB.setArea(name,x,y,z,radius,height)
  local area = {x=x+0.001,y=y+0.001,z=z+0.001,radius=radius,height=height}

  -- default values
  if area.height == nil then area.height = 6 end

  areas[name] = area
end

-- remove area
function tCLIMB.removeArea(name)
  if areas[name] ~= nil then
    areas[name] = nil
  end
end

-- areas triggers detections
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(250)

    local px,py,pz = tCLIMB.getPosition()

    for k,v in pairs(areas) do
      -- detect enter/leave

      local player_in = (GetDistanceBetweenCoords(v.x,v.y,v.z,px,py,pz,true) <= v.radius and math.abs(pz-v.z) <= v.height)

      if v.player_in and not player_in then -- was in: leave
        CLIMBserver.leaveArea({k})
      elseif not v.player_in and player_in then -- wasn't in: enter
        CLIMBserver.enterArea({k})
      end

      v.player_in = player_in -- update area player_in
    end
  end
end)

-- DOOR

-- set the closest door state
-- doordef: .model or .modelhash
-- locked: boolean
-- doorswing: -1 to 1
function tCLIMB.setStateOfClosestDoor(doordef, locked, doorswing)
  local x,y,z = tCLIMB.getPosition()
  local hash = doordef.modelhash
  if hash == nil then
    hash = GetHashKey(doordef.model)
  end

  SetStateOfClosestDoorOfType(hash,x,y,z,locked,doorswing+0.0001)
end

function tCLIMB.openClosestDoor(doordef)
  tCLIMB.setStateOfClosestDoor(doordef, false, 0)
end

function tCLIMB.closeClosestDoor(doordef)
  tCLIMB.setStateOfClosestDoor(doordef, true, 0)
end
