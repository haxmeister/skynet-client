--[[
FAMY Tools

By Drunken Viking - 2012
]]

dofile("json.lua") -- json.encode and json.decode
dofile("tcpsock.lua") -- Socket stuff

FAMYTools.getfact = function(fact) -- Return faction text with correct color
	if (fact==nil) then return "" end
	if (fact==-1) then return "" end
	local factionstr = factionfriendlyness(fact)
	local color = rgbtohex(factionfriendlynesscolor(fact))
	if (factionstr=="Kill on Sight") then factionstr = "KOS" end
	if (factionstr=="Pillar of Society") then factionstr = "POS" end
	return color .. factionstr
end


FAMYTools.TCPConn = FAMYTools.TCPConn or {}

FAMYTools.TCPConn.isConnected = false
FAMYTools.TCPConn.isLoggedIn = false

-- OnConnect
FAMYTools.TCPConn.OnConnect = function(sock, errmsg)
	local connOk = false
	if (sock) then
		if (sock.tcp:GetPeerName()~=nil) then -- We are connected
			FAMYTools.TCPConn.Socket = sock
			FAMYTools.Send = sock.Send
			connOk = true
		else
			connOk = false
		end
	end
	if (connOk) then -- We are connected OK
		FAMYTools.TCPConn.isConnected = true
		FAMYTools.TCPConn.isLoggedIn = false
		FAMYTools.print("Connected to server ok.")
		if (FAMYTools.Settings.autologin=="ON") then -- Do autologin if selected
			FAMYTools.TCPConn.Login()
		end
	else
		FAMYTools.TCPConn.isConnected = false
		FAMYTools.TCPConn.isLoggedIn = false
		if (errmsg) then
			FAMYTools.printerror("Error connecting to server: " .. errmsg)
		else
			FAMYTools.printerror("Error connecting to server.")
		end
	end
end

FAMYTools.TCPConn.Login = function()
	FAMYTools.print("Logging in to the server...")
	FAMYTools.TCPConn.SendData({ action="auth", username=FAMYTools.Settings.username, password=FAMYTools.Settings.password, idstring=FAMYTools.ServerIdSting })
end

FAMYTools.TCPConn.Disconnect = function()
	if (FAMYTools.TCPConn.isLoggedIn) then
		FAMYTools.TCPConn.Logout()
	end
	FAMYTools.TCPConn.isConnected = false
	FAMYTools.TCPConn.isLoggedIn = false
	FAMYTools.TCPConn.Socket.tcp:Disconnect()
	-- FAMYTools.printerror("Disconnected from the server");
end

FAMYTools.TCPConn.Logout = function()
	-- FAMYTools.print("Logging out from the server...")
	FAMYTools.TCPConn.SendData({ action="logout" })
end

FAMYTools.TCPConn.SendData = function(data)
	if (FAMYTools.TCPConn.isConnected) then
		FAMYTools.TCPConn.Socket:Send(json.encode(data) .. "\r\n")
	else
		FAMYTools.printerror("Unable to communicate with the server - not connected to server.")
	end
end

-- OnDisconnect
FAMYTools.TCPConn.OnDisconnect = function()
	FAMYTools.TCPConn.isConnected = false
	FAMYTools.TCPConn.isLoggedIn = false
	FAMYTools.printerror("Disconnected from server.")
end

FAMYTools.TCPConn.OnData = function(sock, input)
	local data = string.gsub(input, "[\r\n]", "")
	data = json.decode(data)
	local action = data.action
	local result = tonumber(data.result)
	if (result<1) then
		FAMYTools.printerror("Error executing command: " .. action)
		if (data.error) then
			FAMYTools.printerror(data.error)
		end
		return
	end
	if (FAMYTools.Events[action]) then
		FAMYTools.Events[action](data)
	else
		FAMYTools.printerror("Invalid response from server: " .. action)
	end
end

FAMYTools.TCPConn.connect = function()
	if (FAMYTools.TCPConn.isConnected) then
		FAMYTools.TCPConn.Disconnect()
	end
	FAMYTools.print("Trying to connect to server...")
	if (FAMYTools.server~=nil and FAMYTools.port~=nil and FAMYTools.server~="" and FAMYTools.port~="") then
		TCP.make_client(FAMYTools.server, FAMYTools.port, FAMYTools.TCPConn.OnConnect, FAMYTools.TCPConn.OnData, FAMYTools.TCPConn.OnDisconnect)
	else
		FAMYTools.printerror("Server or port not set - cant connect.")
	end
end

-- Interface unloaded
FAMYTools.TCPConn.UnloadInterface = function()
	FAMYTools.TCPConn.Disconnect()
end

--[[:::::::::::::::::::::: EVENTS FROM SERVER :::::::::::::::::::::::::::::]]
FAMYTools.Events = FAMYTools.Events or {}

-- Response to Authentication
FAMYTools.Events["auth"] = function(params)
	FAMYTools.print("Logged in OK")
	FAMYTools.TCPConn.isLoggedIn = true
end

-- Response from Logout
FAMYTools.Events["logout"] = function(params)
	FAMYTools.print("Logged out from the server.")
end

-- Response to Add to payment list
FAMYTools.Events["addpayment"] = function(params)
	FAMYTools.print("Added payment for " .. params.name)
end

-- Response to Remove from payment list
FAMYTools.Events["removepayment"] = function(params)
	FAMYTools.print("No more payment records for " .. params.name)
end

-- Response to Add to KOS list
FAMYTools.Events["addkos"] = function(params)
	FAMYTools.print("Added KOS for " .. params.name)
end

-- Response to Remove from KOS list
FAMYTools.Events["removekos"] = function(params)
	FAMYTools.print("No more KOS records for " .. params.name)
end

-- Response to Add to Ally list
FAMYTools.Events["addally"] = function(params)
	FAMYTools.print("Added ALLY status for " .. params.name)
end

-- Response to Remove from Ally list
FAMYTools.Events["removeally"] = function(params)
	FAMYTools.print("No more ALLY records for " .. params.name)
end


-- Response to LISTPAYMENT
FAMYTools.Events["getlist"] = function(params)
	FAMYTools.List.List.DELLIN = "1--1"
	local colors = { KOS='230 30 30', PAID='30 200 30', ALLY='200 200 200' }
	for idx, record in ipairs(params.list) do
		FAMYTools.List.List.ADDLIN=1
		FAMYTools.List.List[idx .. ':1'] = " " .. record.name
		FAMYTools.List.List[idx .. ':2'] = record.status
		FAMYTools.List.List[idx .. ':3'] = record.remaining .. " "
		FAMYTools.List.List:setattribute("BGCOLOR", idx, -1, FAMYTools.List.bg[math.fmod(idx,2)])
		FAMYTools.List.List:setattribute("FGCOLOR", idx, 2, colors[record.status])
	end
	ShowDialog(FAMYTools.List.ListWindow);
end


-- Response to PLAYERSTATUS
FAMYTools.Events["playerstatus"] = function(params)
	local colors = { 
		[0]='\127ffffff',
		[1]='\127ff2222',
		[2]='\12722ff22',
		[3]='\127dddddd'
	}
	local color = colors[tonumber(params.statustype)] or '\127333333'
	FAMYTools.UI.Status.title = "Status for " .. params.name .. ": " .. color .. params.status
	iup.Refresh(FAMYTools.UI.Status)
	FAMYTools.UI.StatusWindow.visible = "YES"
end








-- Response to PLAYERSEEN
FAMYTools.Events["playerseen"] = function(params)
	local playerlist = params.playerlist or {}
	FAMYTools.print(table.tostring(playerlist)) --Debug Incoming Messages TRS
	FAMYTools.print(#playerlist)
	local msgstr = "xx"
	if (playerlist[1].name == playerlist[2].name) then --fix for the undocking bug
		local exists = false
		local txt = ""
		local guild = "" 
		if ((playerlist[2].guildtag or "")~="") then
			guild = "[" .. playerlist[2].guildtag .. "] "
		end
		local reporterguild = "" 
		if ((playerlist[2].reporterguild or "")~="") then
			reporterguild = "[" .. playerlist[2].reporterguild .. "] "
		end
		local factioncolor = ""
		if ((tonumber(playerlist[2].faction) or 0) > 0) then
			factioncolor = rgbtohex(FactionColor_RGB[tonumber(playerlist[2].faction)])
		else
			factioncolor = '\127FF0000'
		end
		local reporterfactioncolor = ""
		if ((tonumber(playerlist[2].reporterfaction) or 0) > 0) then
			reporterfactioncolor = rgbtohex(FactionColor_RGB[tonumber(playerlist[2].reporterfaction)])
		else
			reporterfactioncolor = '\127FF0000'
		end
		local location = "Unknown Location"
		local sectid = playerlist[2].sectorid or -1
		if (sectid>0) then
			location = ShortLocationStr(sectid)
		end
		local shipname = (playerlist[2].shipname) or ""
		playerlist[2].t = tonumber(playerlist[2].t or 0)
		txt = "\127FFFFFF" .. guild .. playerlist[2].name .. '\127cccccc' .. " just refuelled at " .. '\127FFFFFF' .. location .. "\127cccccc" .. shipname .. "." .. '\127FFFFFF'
		for _, noti in ipairs(FAMYTools.Notifier.NotificationsDisplay) do
			if (noti.txt==txt) then
				exists=true
				break
			end
		end
		if (exists==false) and (txt ~= "") then
			table.insert(FAMYTools.Notifier.NotificationsDisplay, { time=os.time(), txt=txt, label=nil, reporter=params.reporter })
		end
	elseif (#playerlist == 1) then 
		FAMYTools.print("Hell Yeah!")
		for idx, player in ipairs(playerlist) do
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
					end 
				elseif (player.t==2) then -- Lost - WE left sector
					if (player.name~=GetPlayerName()) and (tonumber(player.sectorid)~=GetCurrentSectorid() and player.reporter~=GetPlayerName()) then
					txt = factioncolor .. guild .. player.name .. '\127cccccc was last seen in ' .. '\127FFFFFF' .. location .. "\127cccccc."
					end
				elseif (player.t==3) then -- A spotter kills
					if (player.name ~= GetPlayerName()) then
					txt = FAMYTools.GetTheKillMessage(player.reporter, player.reporterhealth, reporterguild, reporterfactioncolor, player.name, guild, factioncolor)
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
						local stdstr = ""
						if (FAMYTools.Settings.showfaction=="ON") then
							if (player.fitani~=nil) then 
								if (player.fitani>-1) then
									stdstr = stdstr .. " [" .. "\1276080ffI: " .. FAMYTools.getfact(player.fitani) .. '\127cccccc' .. ", "
								end
							end
							if (player.fserco~=nil) then 
								if (player.fserco>-1) then
									stdstr = stdstr .. "\127ff2020S: " .. FAMYTools.getfact(player.fserco) .. '\127cccccc' .. ", "
								end
							end
							if (player.fuit~=nil) then 
								if (player.fuit>-1) and (player.flocal>-1) then
									stdstr = stdstr .. "\127c0c000U: " .. FAMYTools.getfact(player.fuit) .. '\127cccccc' .. ", "
								elseif (player.fuit>-1) then
									stdstr = stdstr .. "\127c0c000U: " .. FAMYTools.getfact(player.fuit) .. '\127cccccc' .. "]"
								end
							end
							if (player.flocal~=nil) then 
								if (player.flocal>-1) then
									stdstr = stdstr .. "\127ccccccL: " .. FAMYTools.getfact(player.flocal) .. '\127cccccc' .. "]"
								end
							end
						end
						txt = "\127FFFFFF" .. factioncolor .. guild .. player.name .. '\127cccccc' .. " spotted in " .. '\127FFFFFF' .. location .. "\127cccccc" .. shipname .. stdstr .. "." .. '\127FFFFFF'
					end
				end
				local exists = false
				for _, noti in ipairs(FAMYTools.Notifier.NotificationsDisplay) do
					if (noti.txt==txt) then
						exists=true
						break
					end
				end
				if (exists==false) and (txt ~= "") then
					table.insert(FAMYTools.Notifier.NotificationsDisplay, { time=os.time(), txt=txt, label=nil, reporter=params.reporter })
				end
			end
		end
	elseif (#playerlist > 1) then
		local multi_list = {}
		for _,player in ipairs(playerlist or {}) do
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
		for _, noti in ipairs(FAMYTools.Notifier.NotificationsDisplay) do
			if (noti.txt==themessage) then
				exists=true
				break
			end
		end
		if (exists==false) and (themessage ~= "") then
			table.insert(FAMYTools.Notifier.NotificationsDisplay, { time=os.time(), txt=themessage, label=nil, reporter=params.reporter })
		end
	end
end



FAMYTools.Printnoti = function()
FAMYTools.print(table.tostring(FAMYTools.Notifier.NotificationsDisplay))

end

--[[:::::::::::::::::::::: END EVENTS FROM SERVER :::::::::::::::::::::::::]]

RegisterEvent(FAMYTools.TCPConn.UnloadInterface, "UNLOAD_INTERFACE")
RegisterUserCommand('lulz', FAMYTools.Printnoti)
