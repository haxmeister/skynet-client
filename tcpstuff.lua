--[[
Skynet 2.0
By TheRedSpy
]]


dofile("json.lua") -- json.encode and json.decode
dofile("tcpsock.lua") -- Socket stuff

Skynet.getfact = function(fact) -- Return faction text with correct color
    if (fact==nil) then return "" end
    if (fact==-1) then return "" end
    local factionstr = factionfriendlyness(fact)
    local color = rgbtohex(factionfriendlynesscolor(fact))
    if (factionstr=="Kill on Sight") then factionstr = "KOS" end
    if (factionstr=="Pillar of Society") then factionstr = "POS" end
    return color .. factionstr
end


Skynet.TCPConn = Skynet.TCPConn or {}

Skynet.TCPConn.isConnected = false
Skynet.TCPConn.isLoggedIn = false
Skynet.ConnectedAccountName = nil
Skynet.TCPConn.reconnect_timer = Timer()
Skynet.TCPConn.connect_attempts = 0

-- Connection events

Skynet.TCPConn.OnConnect = function(sock, errmsg)
    local connOk = false
    if (sock) then
        if (sock.tcp:GetPeerName()~=nil) then -- We are connected
            Skynet.TCPConn.Socket = sock
            Skynet.Send = sock.Send
            connOk = true
        else
            connOk = false
        end
    end
    if (connOk) then -- We are connected OK
        Skynet.TCPConn.isConnected = true
        Skynet.TCPConn.isLoggedIn = false
        Skynet.TCPConn.connect_attempts = 0
        Skynet.print("Connected to server ok.")
--      if (Skynet.Settings.autologin=="ON") then -- Removed by TheRedSpy, viewed as a bug.
            Skynet.TCPConn.Login()
--      end
    else
        Skynet.TCPConn.isConnected = false
        Skynet.TCPConn.isLoggedIn = false

        if Skynet.TCPConn.connect_attempts == 0 then
            if (errmsg) then
                Skynet.printerror("Error connecting to server: " .. errmsg)
            else
                Skynet.printerror("Error connecting to server.")
            end
        end
    end
end

Skynet.TCPConn.OnDisconnect = function()
    Skynet.TCPConn.isConnected = false
    Skynet.TCPConn.isLoggedIn = false

    local function reconnect_cb()
        Skynet.TCPConn.connect_attempts = Skynet.TCPConn.connect_attempts + 1
        Skynet.TCPConn.connect()
    end

    local timeout = (Skynet.TCPConn.connect_attempts < 5) and 5 or 60
    Skynet.TCPConn.reconnect_timer:SetTimeout(timeout * 1000, reconnect_cb)

    Skynet.printerror("Disconnected from server. Reconnecting in "..tostring(timeout).."s.")
end

Skynet.TCPConn.OnData = function(sock, input)
    local data = string.gsub(input, "[\r\n]", "")
    --print(input)
    data = json.decode(data)
    local action = data.action
    local result = tonumber(data.result)
    if (result<1) then
        Skynet.printerror("Error executing command: " .. action)
        if (data.error) then
            Skynet.printerror(data.error)
        end
        return
    end

    if (Skynet.rpc[action]) then
        Skynet.rpc[action](data)

    else
        Skynet.printerror("Invalid response from server: " .. action)
    end
end


-- Connection functions
Skynet.TCPConn.Login = function()
    Skynet.print("Logging in to the server...")
    Skynet.TCPConn.SendData({ action="auth", username=Skynet.Settings.username, password=Skynet.Settings.password, idstring=Skynet.ServerIdSting })
    Skynet.ConnectedAccountName = Skynet.Settings.username --Ensures people can't change their display name for alliance chat
end

Skynet.TCPConn.Logout = function()
    -- Skynet.print("Logging out from the server...")
    Skynet.TCPConn.SendData({ action="logout" })
end

Skynet.TCPConn.connect = function()
    Skynet.TCPConn.reconnect_timer:Kill()

    if (Skynet.TCPConn.isConnected) then
        Skynet.TCPConn.Disconnect()
    end

    if Skynet.TCPConn.connect_attempts == 0 then
        Skynet.print("Trying to connect to server...")
    end

    if (Skynet.server~=nil and Skynet.port~=nil and Skynet.server~="" and Skynet.port~="") then
        TCP.make_client(Skynet.server, Skynet.port, Skynet.TCPConn.OnConnect, Skynet.TCPConn.OnData, Skynet.TCPConn.OnDisconnect)
    else
        Skynet.printerror("Server or port not set - cant connect.")
    end
end

Skynet.TCPConn.Disconnect = function()
    Skynet.TCPConn.reconnect_timer:Kill()
    Skynet.TCPConn.connect_attempts = 0

    if (Skynet.TCPConn.isLoggedIn) then
        Skynet.TCPConn.Logout()
    end
    Skynet.TCPConn.isConnected = false
    Skynet.TCPConn.isLoggedIn = false

    if Skynet.TCPConn.Socket then
        Skynet.TCPConn.Socket.tcp:Disconnect()
    end
    -- Skynet.printerror("Disconnected from the server");
end

--Skynet.TCPConn.Disconnect = function()
    --if (Skynet.TCPConn.isLoggedIn) then
        --Skynet.TCPConn.Logout()
    --end
    --Skynet.TCPConn.isConnected = false
    --Skynet.TCPConn.isLoggedIn = false

    ---- .Socket is nil if the connection was never established
    ---- checking .isConnected would probably do too
    --if Skynet.TCPConn.Socket then
        --Skynet.TCPConn.Socket.tcp:Disconnect()
    --end
    ---- Skynet.printerror("Disconnected from the server");
--end

Skynet.TCPConn.SendData = function(data)
    if (Skynet.TCPConn.isConnected) then
        Skynet.TCPConn.Socket:Send(json.encode(data) .. "\r\n")
    else
        Skynet.printerror("Unable to communicate with the server - not connected to server.")
    end
end


-- Interface unloaded
Skynet.TCPConn.UnloadInterface = function()
    Skynet.TCPConn.Disconnect()
end


Skynet.DisplayNotification = function(txt)
    local exists = false
    for _, noti in ipairs(Skynet.Notifier.NotificationsDisplay) do
        if (noti.txt==txt) then
            exists=true
            break
        end
    end
    if (exists==false) and (txt ~= "") then
        table.insert(Skynet.Notifier.NotificationsDisplay, { time=os.time(), txt=txt, label=nil })
    end
end

Skynet.Refuel = function(tbl)
    local txt = ""
    local guild = ""
    local tbl1 = tbl[2]
    if ((tbl1.name~=GetPlayerName()) and (tonumber(tbl1.sectorid)~=GetCurrentSectorid()) and (tbl1.reporter~=GetPlayerName())) then
        if ((tbl1.guildtag or "")~="") then
            guild = "[" .. tbl1.guildtag .. "] "
        end
        local reporterguild = ""
        if ((tbl1.reporterguild or "")~="") then
            reporterguild = "[" .. tbl1.reporterguild .. "] "
        end
        local factioncolor = ""
        if ((tonumber(tbl1.faction) or 0) > 0) then
            factioncolor = rgbtohex(FactionColor_RGB[tonumber(tbl1.faction)])
        else
            factioncolor = '\127FF0000'
        end
        local reporterfactioncolor = ""
        if ((tonumber(tbl1.reporterfaction) or 0) > 0) then
            reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(tbl1.reporterfaction)])
        else
            reporterfactioncolor = '\127FF0000'
        end
        local location = "Unknown Location"
        local sectid = tbl1.sectorid or -1
        if (sectid>0) then
            location = ShortLocationStr(sectid)
        end
        local shipname = (tbl1.shipname) or ""
        if (shipname~="") then
            if (tonumber(tbl1.health)>0) then
                tbl1.health = string.format("%d", tbl1.health)
                shipname = shipname .. " (" .. tbl1.health .. "%)"
            end
            shipname = " flying a " .. shipname
        else
            shipname = " either docked or out of range"
        end
        tbl1.t = tonumber(tbl1.t or 0)
        txt = "\127FFFFFF" .. factioncolor .. guild .. tbl1.name .. '\127cccccc' .. " just refuelled at " .. '\127FFFFFF' .. location .. "\127cccccc" .. shipname .. "."
        Skynet.DisplayNotification(txt)
    end
end

Skynet.Multispot = function(tbl)
local finaltable = {}
local multi_list = {}
    for _,player in ipairs(tbl or {}) do
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
        multi_list[player.t] = multi_list[player.t] or {} --create sectorid entry if it doesn't already exist
        multi_list[player.t][player.sectorid] = multi_list[player.t][player.sectorid] or {} --create muffin entry if doesn't exist
        table.insert(multi_list[player.t][player.sectorid], player.name)
    end
    for t,sector in pairs(multi_list) do
        local themessage = ""
        local exists = false
        if (t == 0) then
            if (tonumber(sector)~=GetCurrentSectorid()) then
                for sectorid,names in pairs(sector) do
                    local printer = table.concat(names,"\127cccccc, ") .. "\127cccccc spotted in " .. '\127ffffff' .. ShortLocationStr(sectorid) .. "\127cccccc."
                    local mystring = printer:gsub(",([^,]+)$", " and%1")
                    themessage = mystring
                end
            end
        elseif (t == 1) then
            if (tonumber(sector)~=GetCurrentSectorid()) then
                for sectorid,names in pairs(sector) do
                    local printer = table.concat(names,"\127cccccc, ") .. "\127cccccc have left " .. '\127ffffff' .. ShortLocationStr(sectorid) .. "\127cccccc."
                    local mystring = printer:gsub(",([^,]+)$", " and%1")
                    themessage = mystring
                end
            end
        elseif (t == 2) then
            if (tonumber(sector)~=GetCurrentSectorid()) then
                for sectorid,names in pairs(sector) do
                    local printer = table.concat(names,"\127cccccc, ") .. "\127cccccc last seen in " .. '\127ffffff' .. ShortLocationStr(sectorid) .. "\127cccccc."
                    local mystring = printer:gsub(",([^,]+)$", " and%1")
                    themessage = mystring
                end
            end
        end
    Skynet.DisplayNotification(themessage)
    end
end

Skynet.SingleSpot = function(tbl)
    for idx, player in ipairs(tbl) do
        if (player.name~="") then
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
            local txt = ""
            if (player.t==1) then -- Left sector
                if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
                txt = factioncolor .. guild .. player.name .. "\127cccccc has left " .. '\127FFFFFF' .. location .. "\127cccccc."
                end --Skynet.GetTheKillMessage = function(killer, killerhp, killerguild, killerfaction, victim, victimguild, victimfaction)
            elseif (player.t==2) then -- Lost - WE left sector
                if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
                txt = factioncolor .. guild .. player.name .. '\127cccccc was last seen in ' .. '\127FFFFFF' .. location .. "\127cccccc."
                end
            elseif (player.t==3) then -- A spotter kills
                if (player.name ~= GetPlayerName()) then
                txt = Skynet.GetTheKillMessage(player.reporter, player.reporterhealth, reporterguild, reporterfactioncolor, player.name, guild, factioncolor)
                end
            elseif (player.t==4) then -- A spotter gets killed
                if (player.name ~= GetPlayerName()) then
                txt = factioncolor .. guild .. player.name .. "\127cccccc" .." has destroyed " .. reporterfactioncolor .. reporterguild .. player.reporter .. "\127cccccc."
                end
            else -- Entered sector
            if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
                if (shipname~="") then
                    if (tonumber(player.health)>0) then
                        player.health = string.format("%d", player.health)
                        shipname = shipname .. " (" .. player.health .. "%)"
                    end
                    shipname = " flying a " .. shipname
                else
                    shipname = " either docked or out of range"
                end
                txt = "\127FFFFFF" .. factioncolor .. guild .. player.name .. '\127cccccc' .. " spotted in " .. '\127FFFFFF' .. location .. "\127cccccc" .. shipname .. "." .. '\127FFFFFF'
            end
            end
            Skynet.DisplayNotification(txt)
        end
    end
end



RegisterEvent(Skynet.TCPConn.UnloadInterface, "UNLOAD_INTERFACE")
RegisterEvent(Skynet.TCPConn.Disconnect, "PLAYER_LOGGED_OUT")
