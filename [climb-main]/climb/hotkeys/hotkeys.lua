CLIMB = Proxy.getInterface("CLIMB")

-- Admin Menu Hot Key (WIP)
Citizen.CreateThread(function()
  while true do
  Citizen.Wait(0)
	  if IsControlPressed(1, 288) then -- F1
		CLIMBserver.openAdminMenu({})
		end
	end
end)