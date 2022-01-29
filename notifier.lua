--[[
Skynet 2.0
By TheRedSpy
]]


Skynet.Notifier = Skynet.Notifier or {}

dofile("notifierobject.lua")

Skynet.Notifier.UpdateNotifyDisplayTimer = Timer()
Skynet.Notifier.UpdateNotifyTimer = Timer()
Skynet.Notifier.Notifications = {}
Skynet.Notifier.NotificationsDisplay = {}
Skynet.Notifier.CurrentState = {}
Skynet.Lastkill = {streak=0, lasttime=0, multi=0}
Skynet.StreakAnnounceTimer = Timer()
Skynet.MutliKillTimer = Timer()
SendSpot = {}
SendSpot2 = {t=8, spots={}}

-- {{1231}={{[FAMY] TheRedSpy}={"Serco SkyCommand Prometheus"},{[FAMY] Savet Hegar}={"Valkryie X1"}}, {2412}={bla bla}}


Skynet.StreakAnnounce = function(killer, killerguild, killerfaction, streak)
    local thesound = nil
    local killmessage = nil
    if streak == 3 then
        thesound = "3kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is a serial killer! (" .. streak .. " kills)"
    elseif streak == 5 then
        thesound = "5kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is a five kill stud! (" .. streak .. " kills)"
    elseif streak == 9 then
        thesound = "4kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is an ultimate warrior! (" .. streak .. " kills)"
    elseif streak == 12 then
        thesound = "6kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF amazes himself! (" .. streak .. " kills)"
    elseif streak == 15 then
        thesound = "7kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is a bona fide badass! (" .. streak .. " kills)"
    elseif streak == 18 then
        thesound = "8kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is legendary! (" .. streak .. " kills)"
    elseif streak == 21 then
        thesound = "9kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is damn good! (" .. streak .. " kills)"
    elseif streak == 24 then
        thesound = "10kills"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is UNBELIEVEABLE! (" .. streak .. " kills)"
    elseif streak == 28 then
        thesound = "godlike"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is \127d3bc5fGODLIKE!! \127FFFFFFt(" .. streak .. " kills)"
    elseif streak >= 32 then
        thesound = "immortal"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF is \127aa0000IMMORTAL! Somebody KILL HIM!!! \127FFFFFFt(" .. streak .. " kills)"
    end
    if killmessage ~= nil then
    if Skynet.Settings.sound == "ON" then
        gksound.GKPlaySound(thesound, 1) --Wrap this in IF tags for the option to have sounds on/off
    end
    print(killmessage)
    end
end

Skynet.MultiKillAnnounce = function(killer, killerguild, killerfaction, multi)
    local thesound = nil
    local killmessage = nil
    if multi == 2 then
        thesound = "double"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF double tapped"
    elseif multi == 3 then
        thesound = "triple"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF got a hat trick"
    elseif multi == 4 then
        thesound = "quad"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF got a quad kill!"
    elseif multi == 5 then
        thesound = "genocide"
        killmessage = killerfaction .. killerguild .. killer  .. "\127FFFFFF is \127d3bc5fGENOCIDAL"
    elseif multi >= 6 then
        thesound = "annihilation"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF \127aa0000ANNIHILATED \127FFFFFFthe enemy team!!"
    end
    if killmessage ~= nil then
    if Skynet.UI.Settings.sound.value == "ON" then
        gksound.GKPlaySound(thesound, 1) --Wrap this in IF tags for the option to have sounds on/off
    end
    print(killmessage)
    end
end

Skynet.ClearSpots = function()
    for idx, notify in ipairs(Skynet.Notifier.NotificationsDisplay) do
            FadeStop(notify.label)
            iup.Detach(notify.label)
            iup.Destroy(notify.label)
            notify.label = nil
            notify.txt = nil
    end
    Skynet.Notifier.CurrentState = {}
    Skynet.Notifier.NotificationsDisplay = {}
    Skynet.Notifier.UpdateNotifyDisplay()

end

Skynet.Notifier.UpdateNotifyDisplay = function()
    for sector,sectorspots in pairs(Skynet.Notifier.CurrentState) do
        if sector ~= GetCurrentSectorid() then
            local updated
            local notification = ShortLocationStr(sector) .. ": "
            for name, vars in pairs(sectorspots) do
                -- vars[3] is set if the entry has changed
                if vars[3] then
                    vars[3] = nil
                    updated = true
                end

                if (table.getn2(sectorspots) == 1) then
                    local shipname = vars[1]
                    if shipname == "" then shipname = "Docked/Out of Range" end
                    notification = notification .. name .. '\127CCCCCC - ' .. shipname .. '\127CCCCCC, '
                else
                    notification = notification .. name .. '\127CCCCCC, '
                end
            end
            notification = notification:gsub(",(%s*)$", "") --makes it pretty removes the ", " at the end
            table.insert(Skynet.Notifier.NotificationsDisplay, {time=os.time(), txt=notification, label=nil, updated=updated})
        end
    end

    local now = os.time()
    for idx, notify in ipairs(Skynet.Notifier.NotificationsDisplay) do
        if (notify.label~=nil) then
            FadeStop(notify.label)
            iup.Detach(notify.label)
            iup.Destroy(notify.label)
            notify.label = nil
            notify.txt = nil
        end
        if (notify.notified==nil and GetCurrentSectorid() ~= notify.sect) then
            if ((Skynet.Settings.notifyhud or "ON")=="ON") then
                notify.label = iup.frame{iup.label{title=notify.txt, font=Font.H3*HUD_SCALE*0.75, alignment="ALEFT", expand="HORIZONTAL"}, segmented="0 0 1 1", bgcolor="255 0 0 0 *"}
                if ((Skynet.Settings.notifyflash or "ON")=="ON") then
                    if notify.updated then
                        FadeControl(notify.label, 10, 0.5, 0)
                    end
                end
                if (Skynet.UI.NotifyHolder~=nil) then
                    iup.Append(Skynet.UI.NotifyHolder, notify.label)
                end
            end
--          if ((Skynet.Settings.notifychat or "ON")=="ON") then --TODO This statement causes issues with legacy users that had this option ON in the old FAMYTools
--              local rep = ""
--              if (notify.reporter) then rep = " -- (" .. notify.reporter .. ")" end
--              Skynet.print(notify.txt .. rep)
--          end
            Skynet.Notifier.NotificationsDisplay[idx].notified=true
        end

    end
    pcall(function()
        iup.Refresh(Skynet.UI.NotifyHolder)
    end)

    local tmp = {}
    for _, notify in ipairs(Skynet.Notifier.NotificationsDisplay) do
        if (notify.txt~=nil) then table.insert(tmp, notify) end
    end
    Skynet.Notifier.NotificationsDisplay = tmp
    if (#Skynet.Notifier.NotificationsDisplay>0) then
        if (Skynet.UI.NotifyHolder~=nil) then
            if ((Skynet.Settings.notifyhud or "ON")=="ON") then
                Skynet.UI.NotifyHolder2.visible = "YES"
            else
                Skynet.UI.NotifyHolder2.visible = "NO"
            end
        end
    else
        Skynet.UI.NotifyHolder2.visible = "NO"
    end

end

Skynet.Notifier.JumpSector = function()
    for idx, notify in ipairs(Skynet.Notifier.NotificationsDisplay) do
        if notify.sectorid == GetCurrentSectorid() then
            FadeStop(notify.label)
            iup.Detach(notify.label)
            iup.Destroy(notify.label)
            notify.label = nil
            notify.txt = nil
        end
    end
end


---extra function for debug purposes


function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

Skynet.Notifier.UpdateNotify = function()
    local tmplist = {}
    if (#Skynet.Notifier.Notifications>0) then -- Any unknowns?
        for idx, notif in ipairs(Skynet.Notifier.Notifications) do
            local notifobj = notif:getobject()
            if (notifobj~=nil) then
                table.insert(tmplist, notifobj) -- FIRST BIG STEP IS TO FIND THE SORT FUNCTIONALITY FOR TABLES IN LUA
            end
        end
        local tmp = {}
        for idx, notif in ipairs(Skynet.Notifier.Notifications) do
            if (notif:getcharid()~=-99) then
                table.insert(tmp, notif)
            end
        end
        for idx, notif in ipairs(Skynet.Notifier.Notifications) do
        --Skynet.print(idx .. ": " .. table.tostring(notif)) -- Debug message for the individual spotter tables
        end
        Skynet.Notifier.Notifications = tmp
--  Skynet.print("Debug:  " .. table.tostring(tmplist)) --debug message (TRS)
    end
    if (#tmplist>0) then
        Skynet.TCPConn.SendData({ action='playerseen', playerlist=tmplist })
    end
    Skynet.Notifier.UpdateNotifyTimer:SetTimeout(1500, Skynet.Notifier.UpdateNotify)
end

---end extra function

Skynet.Notifier.EventPlayerEnteredSector = function(_, charid)
    local n = Skynet.Notifier.notif.new(charid, 0)
    table.insert(Skynet.Notifier.Notifications, n)
    --guildtarget(charid) -------------------------------does it work?
    Skynet.Notifier.UpdateNotify()
end

Skynet.Notifier.EventPlayerLeftSector = function(_, charid)
    local n = Skynet.Notifier.notif.new(charid, 1)
    table.insert(Skynet.Notifier.Notifications, n)
    Skynet.Notifier.UpdateNotify()
end


Skynet.Notifier.EventPlayerDied = function(_, victim, killer, weapon)
local thekiller = GetPlayerName(killer)
local thevictim = GetPlayerName(victim)
    if ((string.sub(thevictim, 1, 1)~="*") and (string.sub(thekiller, 1, 1)~="*")) then
        local killerfaction = ""
              if ((tonumber(GetPlayerFaction(killer)) or 0) > 0) then
                  killerfaction = rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction(killer))])
              else
                  killerfaction = '\127FF0000'
              end
        local killerguild = ""
              if ((GetGuildTag(killer) or "")~="") then
                  killerguild = "[" .. GetGuildTag(killer) .. "] "
              end
        local victimfaction = ""
              if ((tonumber(GetPlayerFaction(victim)) or 0) > 0) then
                  victimfaction = rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction(victim))])
              else
                  victimfaction = '\127FF0000'
              end
        local victimguild = ""
              if ((GetGuildTag(victim) or "")~="") then
                  victimguild = "[" .. GetGuildTag(victim) .. "] "
              end
        if thekiller == GetPlayerName() then
            print(Skynet.GetTheKillMessage(thekiller, GetPlayerHealth(killer), killerguild, killerfaction, thevictim, victimguild, victimfaction, weapon))
            local tmplist = {}
            local killnotify = {t=1, k=thekiller, health=GetPlayerHealth(killer), kguild=killerguild, kfaction=killerfaction, v=thevictim, vguild=victimguild, vfaction=victimfaction, w=weapon}
            table.insert(tmplist, killnotify)
            Skynet.TCPConn.SendData({ action='announce', playerlist=tmplist })
                if thevictim == thekiller then -- If you're /exploding or killing yourself
                    Skynet.Lastkill.streak = 0 -- Reset kill streak
                    Skynet.Lastkill.multi = 0 -- Reset multikills
                else
                    if Skynet.Lastkill.lasttime == 0 then Skynet.Lastkill.lasttime = os.time() end
                    Skynet.Lastkill.streak = Skynet.Lastkill.streak + 1 -- Add 1 to the streak
                    local difference = os.time() - Skynet.Lastkill.lasttime
                        if (difference < 120) then
                            Skynet.Lastkill.multi = Skynet.Lastkill.multi + 1
                            if Skynet.Lastkill.multi >= 2 then
                                Skynet.MutliKillTimer:SetTimeout(1250, function()
                                Skynet.MultiKillAnnounce(thekiller, killerguild, killerfaction, Skynet.Lastkill.multi)
                                local tmplist = {}
                                local killnotify = {t=4, k=thekiller, kguild=killerguild, kfaction=killerfaction, multi=Skynet.Lastkill.multi}
                                table.insert(tmplist, killnotify)
                                Skynet.TCPConn.SendData({ action='announce', playerlist=tmplist })
                                end)
                            end
                        else
                        Skynet.Lastkill.multi = 1
                        end
                    Skynet.Lastkill.lasttime = os.time() -- Record the time
                end
            if (Skynet.Lastkill.streak >= 3 and thevictim ~= GetPlayerName()) then
                Skynet.StreakAnnounceTimer:SetTimeout(2500, function()
                    Skynet.StreakAnnounce(thekiller, killerguild, killerfaction, Skynet.Lastkill.streak)
                    local tmplist = {}
                    local killnotify = {t=3, k=thekiller, kguild=killerguild, kfaction=killerfaction, streak=Skynet.Lastkill.streak}
                    table.insert(tmplist, killnotify)
                    Skynet.TCPConn.SendData({ action='announce', playerlist=tmplist })
                end)
            end
        elseif thevictim == GetPlayerName() then
            print("\127FFFFFFYou were destroyed by " .. killerfaction .. killerguild .. thekiller .. "\127FFFFFF")
            local tmplist = {}
            local killnotify = {t=2, k=thekiller, health=GetPlayerHealth(killer), kguild=killerguild, kfaction=killerfaction, v=thevictim, vguild=victimguild, vfaction=victimfaction, w=weapon}
            table.insert(tmplist, killnotify)
            Skynet.TCPConn.SendData({ action='announce', playerlist=tmplist })
            Skynet.Lastkill.streak = 0 -- Reset kill streak
        end
    end
end

Skynet.GetTheKillMessage = function(killer, killerhp, killerguild, killerfaction, victim, victimguild, victimfaction, weapon)
local killmessage = ""
local thesound = ""
    if killer == victim then
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF suffered explosive decompression"
    elseif (victim == GetPlayerName()) then
        killmessage = "\127FFFFFFYou were destroyed by " .. killerfaction .. killerguild .. killer .. "\127FFFFFF's " .. Skynet.GetWeaponMsg(weapon)
    elseif (killer == "yodaofborg" and killerhp>=50 and weapon == 86) then -- The "Yoda exception"
        thesound = "yoda"
        killmessage = victimfaction .. victimguild .. victim .. "\127FFFFFF has suffered a yoda malfunction"
    elseif (killer == "Mr. Chaos" and killerhp>=80 and weapon == 173) then -- For Mr. Chaos
        thesound = "headshot"
        killmessage = killerfaction .. killerguild .. killer .. "\127FFFFFF got a headshot on " .. victimfaction .. victimguild .. victim
    elseif (killerhp>=99) then
        thesound = "nocha"
        killmessage = victimfaction .. victimguild .. victim .. "\127FFFFFF had no chance against " .. killerfaction .. killerguild .. killer .. "\127FFFFFF's " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=90 and killerhp<99) then
        thesound = "domin"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " has dominated " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=80 and killerhp<90) then
        thesound = "waste"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " despatched the waste of time " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=70 and killerhp<80) then
        thesound = "humil"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " has humiliated " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=60 and killerhp<70) then
        thesound = "smack"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " smacked down " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=50 and killerhp<60) then
        thesound = "tooez"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " all too easily despatched " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=40 and killerhp<50) then
        thesound = "massa"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " has massacred " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=30 and killerhp<40) then
        thesound = "bow"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " extracted respect from " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=20 and killerhp<30) then
        thesound = "poor"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " just beat that poor baby " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp>=10 and killerhp<20) then
        thesound = "game"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " ended the game for " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    elseif (killerhp<10) then
        thesound = "sweet"
        killmessage = killerfaction .. killerguild .. killer .. '\127FFFFFF' .. " got vengeance at the last second on " .. victimfaction .. victimguild .. victim .. "\127FFFFFF with a " .. Skynet.GetWeaponMsg(weapon)
    end
    if Skynet.Settings.sound == "ON" then
        gksound.GKPlaySound(thesound, 1) --Wrap this in IF tags for the option to have sounds on/off
    end
    return killmessage

end

Skynet.GetWeaponMsg = function(number)
    local message = {[46]="Mega Positron", [173]="Sunflare", [702]="Raven", [44]="AAP", [48]="LENB", [34]="Neutron Blaster Mk II", [42]="Positron Blaster", [183]="Seeker Missile", [91]="Gov't Plasma Cannon", [71]="Charged Cannon", [114]="Plasma Cannon MkII", [116]="Plasma Cannon MkIII", [26]="Phase Blaster MkII", [20]="Ion Blaster MkII", [118]="Plasma Cannon HX", [87]="Fletchette Cannon", [32]="Neutron Blaster", [89]="Fletchette Cannon MkII", [103]="Gauss Cannon", [156]="Rail Gun", [105]="Gauss Cannon MkII", [84]="Iceflare", [158]="Rail Gun MkII", [160]="Rail Gun MkIII", [162]="Advanced Rail Gun",[86]="Starflare",[108]="Gemini Missile", [708]="Plasma Eliminator", [704]="Plasma Eliminator MkII", [97]="Gatling Cannon", [99]="Gatling Turret", [147]="Plasma Devastator MkII", [145]="Plasma Devastator", [121]="Lightning Mine", [136]="Stingray Missile", [175]="Jackhammer Rocket", [177]="Screamer Rocket", [200]="Chaos Swarm Missile", [18]="Ion Blaster", [24]="Phase Blaster", [22]="Ion Blaster MkIII", [124]="Proximity Mine", [198]="Locust Swarm Missile", [28]="Orion Phase Blaster XGX", [36]="Neutron Blaster MkIII", [711]="Gauss Cannon MkIII", [150]="Hive Positron Blaster", [152]="Hive Gatling Cannon", [134]="YellowJacket Missile", [138]="Firefly Missile", [128]="Tellar Ulam Mine", [179]="Avalon Torpedo", [706]="Plasma Annihilator", [30]="TPG Sparrow Phase Blaster", [40]="Corvus Widowmaker", [56]="Capital Gauss", [188]="Capital Gauss", [191]="Hull Explosion", [0]="Self Destruct Protocol"}
    if message[number] ~= nil then
        local theweapon = message[number]
        return theweapon
    else
        return "Hull Explosion"

    end
end

Skynet.Notifier.EventSectorChanged = function(_, data)
    if (#Skynet.Notifier.Notifications>0) then -- Dont report any player_left secor because WE are the one who left
        local tmplist = {}
        for idx, notif in ipairs(Skynet.Notifier.Notifications) do
            if (notif:gettype()==1) then Skynet.Notifier.Notifications[idx]:settype(2) end
        end
    end
    ForEachPlayer(
        function (charid)
            local n = Skynet.Notifier.notif.new(charid, 0)
            if (charid~=0) then table.insert(Skynet.Notifier.Notifications, n) end
        end
    )
    for sectorid, names in pairs(Skynet.Notifier.CurrentState) do --This part deletes a notification if you enter a sector where theres a current notification of that sector
        if sectorid == GetCurrentSectorid() then
        Skynet.Notifier.CurrentState[sectorid] = nil
        end
    end
Skynet.Notifier.UpdateNotifyDisplay()
Skynet.Notifier.UpdateNotify()
end

---This is an example function that sends a fake spot

SendSpot.Command1 = function(_, args)
    local spooflist = {}
    local incstuff1 = { t=0, name="Fake Guy No.1", shipname="Valkryie X-1", health="100", sectorid=4131, faction=1, guildtag="FAMY", reporter="TheReporter" }
    local incstuff2 = { t=0, name="Fake Guy No.3", shipname="IDF Valkryie Vigilant", health="100", sectorid=4131, faction=1, guildtag="FAMY", reporter="TheReporter" }

    table.insert(spooflist, incstuff1)
    table.insert(spooflist, incstuff2)


            Skynet.TCPConn.SendData({ action='playerseen', playerlist=spooflist})
end

SendSpot.Command2 = function()
    local spooflist = {}
    local incstuff2 = { t=2, name="Fake Guy No.1", shipname="Valkryie X-1", health="100", sectorid=5751, faction=1, guildtag="FAMY", reporter="TheReporter" }
    local incstuff3 = { t=2, name="Fake Guy No.3", shipname="Corvus Greyhound", health="100", sectorid=4131, faction=2, guildtag="FAMY", reporter="TheReporter" }
    for i=1,6 do SendSpot2.spots[i] = GetCharacterInfo(i) end
    table.insert(spooflist, SendSpot2)
    Skynet.TCPConn.SendData({ action='announce', playerlist=spooflist})
end

SendSpot.Command3 = function(_, args)
Skynet.print("Skynet.Notifier.NotificationsDisplay: " .. table.tostring(Skynet.Notifier.NotificationsDisplay))
Skynet.print("Skynet.Notifier.CurrentState: " .. table.tostring(Skynet.Notifier.CurrentState))
end

function Skynet.AllianceChannel(_, data)
        local factioncolor = ""
        if ((tonumber(GetPlayerFaction()) or 0) > 0) then
            factioncolor = rgbtohex(FactionColor_RGB[tonumber(GetPlayerFaction())])
        else
            factioncolor = '\127FF0000'
        end
        if data ~= nil then
          local tmplist = {}
          if Skynet.Settings.anonchat == "OFF" then
            local message = {t=1, msg=data, factioncolor=factioncolor, player=GetPlayerName(), sector=ShortLocationStr(GetCurrentSectorid())}
            table.insert(tmplist, message)
            Skynet.TCPConn.SendData({ action='channel', playerlist=tmplist })
            local msg = table.concat(data, " ") or ""
            --print("\12737c8ab(Alliance) [" .. ShortLocationStr(GetCurrentSectorid()) .. "] <" .. factioncolor .. GetPlayerName() .."\12737c8ab> " .. msg)
          elseif Skynet.Settings.anonchat == "ON" then
            local message = {t=2, msg=data, name=Skynet.ConnectedAccountName}
            table.insert(tmplist, message)
            Skynet.TCPConn.SendData({ action='channel', playerlist=tmplist })
            local msg = table.concat(data, " ") or ""
            --print("\12737c8ab(Alliance) <\127FFFFFF" .. Skynet.ConnectedAccountName .. "\12737c8ab> " .. msg)
          end
        end
end

function Skynet.AnonChannel(_, data)
        if data ~= nil then
          local tmplist = {}
          local message = {t=2, msg=data, name=Skynet.ConnectedAccountName}
          table.insert(tmplist, message )
          Skynet.TCPConn.SendData({ action='channel', playerlist=tmplist })
          local msg = table.concat(data, " ") or ""
          --print("\12737c8ab(Alliance) <\127FFFFFF" .. Skynet.ConnectedAccountName .. "\12737c8ab> " .. msg)
        end
end


function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Skynet.grouptarget()
    if GetTargetInfo() ~= nil then
        local name, health, distance, factionid, guild, ship = GetTargetInfo()
        if health ~= nil then
            SendChat('Targeting: '..name..', piloting '..Article(ship)..' with '.. math.floor(GetPlayerHealth(GetCharacterIDByName(name))) ..'% armor ' .. 'at ' ..  round(distance, 0) .. 'm.','GROUP')
        else SendChat('Targeting: '..name.. ' at ' .. round(distance, 0) .. 'm.', 'GROUP')
        end
    end
end

function Skynet.guildtarget()
    if GetTargetInfo() ~= nil then
        local name, health, distance, factionid, guild, ship = GetTargetInfo()
        if health ~= nil then
            SendChat('Targeting: '..name ..', piloting '..Article(ship)..' with '.. math.floor(GetPlayerHealth(GetCharacterIDByName(name))) ..'% armor ' .. 'at ' .. round(distance, 0) .. 'm.', 'GUILD')
        else SendChat('Targeting: '..name.. ' at ' .. round(distance, 0) .. 'm.', 'GUILD')
        end
    end
end

function Skynet.alliancetarget()
    if GetTargetInfo() ~= nil then
        local name, health, distance, factionid, guild, ship = GetTargetInfo()
        local ladata = ""
        if health ~= nil then
            ladata = 'Targeting: '..name ..', piloting '..Article(ship)..' with '.. math.floor(GetPlayerHealth(GetCharacterIDByName(name))) ..'% armor ' .. 'at ' .. round(distance, 0) .. 'm.'
        else ladata = 'Targeting: '..name.. ' at ' .. round(distance, 0) .. 'm.'
        end
        local datatable = {ladata}
        Skynet.AllianceChannel("target",datatable)
    end
end

Skynet.Notifier.TargetChanged = function()
    Skynet.UI.Status.title = ""
    Skynet.UI.StatusWindow.visible = "NO"
    pcall(function()
        local name, h, d, f, guild, s = GetTargetInfo()
        if (name~=nil and f~=nil) then
            if (string.sub(name, 1, 1)~="*") then
                Skynet.TCPConn.SendData({ action='playerstatus', name=name, guild=guild })
            end
        end
    end)
end



RegisterUserCommand('grouptarget', Skynet.grouptarget)
RegisterUserCommand('guildtarget', Skynet.guildtarget)
RegisterUserCommand('alliancetarget', Skynet.alliancetarget)

Skynet.Notifier.UpdateNotifyTimer:SetTimeout(1500, Skynet.Notifier.UpdateNotify)

RegisterEvent(Skynet.Notifier.TargetChanged, "TARGET_CHANGED")
RegisterEvent(Skynet.Notifier.EventPlayerEnteredSector, "PLAYER_ENTERED_SECTOR")
RegisterEvent(Skynet.Notifier.EventPlayerLeftSector, "PLAYER_LEFT_SECTOR")
RegisterEvent(Skynet.Notifier.EventPlayerDied, "PLAYER_DIED")
--RegisterEvent(Skynet.Notifier.EventPlayerEnteredStation, "ENTERED_STATION")
RegisterEvent(Skynet.Notifier.EventSectorChanged, "SECTOR_CHANGED")
RegisterUserCommand('sendspot', SendSpot.Command1)
RegisterUserCommand('sendspot2', SendSpot.Command2)
RegisterUserCommand('show', SendSpot.Command3)
UnregisterEvent(chatreceiver, "CHAT_MSG_DEATH")


RegisterUserCommand("\12737c8abAlliance:", Skynet.AllianceChannel) -- register the CommandThing function as a /command
RegisterUserCommand("\127FFFFFFAnonymous:", Skynet.AnonChannel) -- register the CommandThing function as a /command
gkinterface.GKProcessCommand("alias alliancechat 'prompt \12737c8abAlliance: '") -- make an alias to bring up a prompt dialog of the CommandThing command
gkinterface.GKProcessCommand("bind Y alliancechat") -- make an alias to bring up a prompt dialog of the CommandThing command
gkinterface.GKProcessCommand("alias anonchat 'prompt \127FFFFFFAnonymous: '") -- make an alias to bring up a prompt dialog of the CommandThing command
gkinterface.GKProcessCommand("bind ^ anonchat") -- make an alias to bring up a prompt dialog of the CommandThing command
