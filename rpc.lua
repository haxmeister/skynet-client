--[[
Skynet 2.0
By TheRedSpy
]]


--[[:::::::::::::::::::::: EVENTS FROM SERVER :::::::::::::::::::::::::::::]]
Skynet.rpc = Skynet.rpc or {}

-- Response to skynetmessage
Skynet.rpc["skynetmessage"] = function(params)

    local msg = params.msg
    print("\127FF7E00Skynet\1270080FF | \127dddddd" .. msg)
end

-- Response to Authentication
Skynet.rpc["auth"] = function(params)
    Skynet.print("Logged in OK")
    Skynet.TCPConn.isLoggedIn = true
end

-- Response from Logout
Skynet.rpc["logout"] = function(params)
    Skynet.print("Logged out from the server.")
end

-- Response to Add to payment list
Skynet.rpc["addpayment"] = function(params)
    Skynet.print("Added payment for " .. params.name)
end

-- Response to Remove from payment list
Skynet.rpc["removepayment"] = function(params)
    Skynet.print("No more payment records for " .. params.name)
end

-- Response to Add to KOS list
Skynet.rpc["addkos"] = function(params)
    Skynet.print("Added KOS for " .. params.name)
end

-- Response to Remove from KOS list
Skynet.rpc["removekos"] = function(params)
    Skynet.print("No more KOS records for " .. params.name)
end

-- Response to Add to Ally list
Skynet.rpc["addally"] = function(params)
    Skynet.print("Added ALLY status for " .. params.name)
end

-- Response to Remove from Ally list
Skynet.rpc["removeally"] = function(params)
    Skynet.print("No more ALLY records for " .. params.name)
end


-- Response to LIST commands
Skynet.rpc["showlist"] = function(params)
    Skynet.List.List.DELLIN = "1--1"
    local colors = { KOS='230 30 30', PAID='30 200 30', ALLY='200 200 200' }
    for idx, record in ipairs(params.list) do
        Skynet.List.List.ADDLIN=1
        Skynet.List.List[idx .. ':1'] = " " .. record.name
        Skynet.List.List[idx .. ':2'] = record.status
        Skynet.List.List[idx .. ':3'] = record.remaining .. " "
        Skynet.List.List[idx .. ':4'] = record.notes
        Skynet.List.List:setattribute("BGCOLOR", idx, -1, Skynet.List.bg[math.fmod(idx,2)])
        Skynet.List.List:setattribute("FGCOLOR", idx, 2, colors[record.status])
    end
    ShowDialog(Skynet.List.ListWindow);
end


-- Response to PLAYERSTATUS
Skynet.rpc["playerstatus"] = function(params)
    local colors = {
        [0]='\127ffffff',
        [1]='\127ff2222',
        [2]='\12722ff22',
        [3]='\127dddddd'
    }
    local color = colors[tonumber(params.statustype)] or '\127333333'
    Skynet.UI.Status.title = "Status for " .. params.name .. ": " .. color .. params.status
    iup.Refresh(Skynet.UI.Status)
    Skynet.UI.StatusWindow.visible = "YES"
end

-- Response to PLAYERSEEN
Skynet.rpc["playerseen"] = function(params)
    local playerlist = params.playerlist or {}
    local multi_list = Skynet.Notifier.CurrentState or {}
    for idx,player in ipairs(playerlist) do
        local guild = ""
        if ((player.guildtag or "")~="") then
            guild = "[" .. player.guildtag .. "] "
        end
        local reporterguild = ""
        if ((player.reporterguild or "")~="") then
            reporterguild = "[" .. player.reporterguild .. "] "
        end
        local factioncolor = ""
        if ((tonumber(player.faction) or 0) > 0) then
            factioncolor = rgbtohex(FactionColor_RGB[tonumber(player.faction)])
        else
            factioncolor = '\127FF0000'
        end
        local reporterfactioncolor = ""
        if ((tonumber(player.reporterfaction) or 0) > 0) then
            reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(player.reporterfaction)])
        else
            reporterfactioncolor = '\127FF0000'
        end
        local location = "Unknown Location"
        local sectid = player.sectorid or -1
        if (sectid>0) then
            location = ShortLocationStr(sectid)
        end
        local shipname = (player.shipname) or ""
        player.t = tonumber(player.t or 0)
        player.name = factioncolor .. guild .. player.name
        multi_list[player.sectorid] = multi_list[player.sectorid] or {} --create muffin entry if doesn't exist
        if player.sectorid ~= GetCurrentSectorid() then
            if (player.t == 0) then
                -- NOTE: uncomment the if statement to only flash the display if the values actually changed
                local playervars = multi_list[player.sectorid][player.name] or {}
                --if shipname ~= playervars[1] or player.health ~= playervars[2] then
                    -- the third field indicates that the entry has changed. it is cleared by the display function
                    playervars = {shipname, player.health, true}
                --end
                multi_list[player.sectorid][player.name] = playervars
            else
                multi_list[player.sectorid][player.name] = nil
            end
        end
        if table.getn2(multi_list[player.sectorid]) == 0 then multi_list[player.sectorid] = nil end
    end
    Skynet.Notifier.CurrentState = multi_list
-- Skynet.print(table.tostring(Skynet.Notifier.NotificationsDisplay))
Skynet.Notifier.UpdateNotifyDisplay()
end


--{t=1, k=thekiller, health=tonumber(GetPlayerHealth(killer)), kguild=killerguild, kfaction=killerfaction, v=thevictim, vguild=victimguild, vfaction=victimfaction, w=weapon}


Skynet.rpc["announce"] = function(params)
local playerlist = params.playerlist or {}
local myguild = "[" .. GetGuildTag() .. "] "
    for idx,announcement in ipairs(playerlist) do
        if (announcement.t == 1) then
            print(Skynet.GetTheKillMessage(announcement.k, announcement.health, announcement.kguild, announcement.kfaction, announcement.v, announcement.vguild, announcement.vfaction, announcement.w))
        elseif (announcement.t == 2) then
            print(announcement.vfaction .. announcement.vguild .. announcement.v .. "\127FFFFFF was destroyed by " .. announcement.kfaction .. announcement.kguild .. announcement.k .. "\127FFFFFF's " .. Skynet.GetWeaponMsg(announcement.w))
        elseif (announcement.t == 3) then
            Skynet.StreakAnnounce(announcement.k, announcement.kguild, announcement.kfaction, announcement.streak)
        elseif (announcement.t == 4) then
            Skynet.MultiKillAnnounce(announcement.k, announcement.kguild, announcement.kfaction, announcement.multi)
        elseif (announcement.t == 5) then
            SendSpot.Command2()
        end
    end

end

Skynet.rpc["channel"] = function(params)
local playerlist = params.playerlist or {}
    for idx,message in ipairs(playerlist) do
        local msg = ""
        if message.msg ~= nil then
        msg = table.concat(message.msg, " ")

            if message.t == 1 then
                print("\12737c8ab(Alliance) [" .. message.sector .. "] <" .. message.factioncolor .. message.player .. "\12737c8ab> " .. msg)
            elseif message.t == 2 then
                print("\12737c8ab(Alliance) <\127FFFFFF" .. message.name .. "\12737c8ab> " .. msg)
            end
        end
    end
end

-- Response to adduser
Skynet.rpc["adduser"] = function(params)
    Skynet.print("User " .. params.username .. " added OK.")
end

Skynet.rpc["removeuser"] = function(params)
    Skynet.print("User " .. params.username .. " removed OK.")
end

Skynet.rpc["setpassword"] = function(params)
    Skynet.print("Password for user " .. params.username .. " changed OK.")
end

