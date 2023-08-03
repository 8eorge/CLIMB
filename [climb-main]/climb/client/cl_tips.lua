prefix = '^3[CLIMB Tips]^0 '

CLIMBTips = 
{ 
    prefix.."Remember you can press E to tiptoe emote.",
    prefix.."Dont fall.",
    prefix.."If you touch the electric rods you die.",
    prefix.."Double Click Space While In The Air To Mantle",
    prefix.."If you are ever stuck use /spawn.",
    prefix.."discord.gg/climb for updates.",
    prefix.."To give us suggestions head over to our report system ESC.",


}


Citizen.CreateThread(function()
    Wait(100000)
    while true do
        math.randomseed(GetGameTimer())
        num = math.random(1,#CLIMBTips)
        TriggerEvent('chatMessage',"", {255, 51, 51}, "" .. CLIMBTips[num], "ooc")
        Wait(6000000)
    end
end)
