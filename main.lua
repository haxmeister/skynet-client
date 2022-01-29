--[[
Skynet 2.0
By TheRedSpy
]]

-- Helper function
--local function get_args(str)
    --local quotechar
    --local i=0
    --local args,argn,rest={},1,{}
    --while true do
        --local found,nexti,arg = string.find(str, '^"(.-)"%s*', i+1)
        --if not found then found,nexti,arg = string.find(str, "^'(.-)'%s*", i+1) end
        --if not found then found,nexti,arg = string.find(str, "^(%S+)%s*", i+1) end
        --if not found then break end
        --table.insert(rest, string.sub(str, nexti+1))
        --table.insert(args, arg)
        --i = nexti
    --end
    --return args,rest
--end


Skynet = Skynet or {}
Skynet.SettingsId = 82912305760
Skynet.ServerIdSting = "93321253741944961"

dofile("rpc.lua")      -- Remote Procedure Calls
dofile("tcpstuff.lua") -- Socket stuff
dofile("notifier.lua") -- Notifier
dofile("ui/ui.lua")    -- UI windows
dofile("commands.lua") -- command line commands

Skynet.server ="172.97.103.11"
Skynet.port = 9765 --7777
--Skynet.server = "0.0.0.0"
--Skynet.port = 9765

Skynet.Settings = {}

Skynet.SaveSettings = function()
    SaveSystemNotes(spickle(Skynet.Settings), Skynet.SettingsId)
end

Skynet.LoadSettings = function()
    Skynet.Settings = unspickle(LoadSystemNotes(Skynet.SettingsId))
    Skynet.Settings.notifytimeout = tonumber(Skynet.Settings.notifytimeout or 10)
    if (Skynet.Settings.notifytimeout>30) then Skynet.Settings.notifytimeout=10 end
end

Skynet.print = function(str)
    pcall(function() HUD:PrintSecondaryMsg("\127FF7E00Skynet\1270080FF | \127dddddd" .. str) end)
end

Skynet.printerror = function(str)
    pcall(function() HUD:PrintSecondaryMsg("\127FF7E00Skynet\1270080FF | \127FF0001" .. str) end)
end

Skynet.PlayerEnteredGame = function()
    Skynet.print("Skynet loaded...")
    Skynet.UI.Init()
    Skynet.LoadSettings()
    if (Skynet.Settings.sound == "ON") then
        Skynet.LoadSounds()
    end
    if (Skynet.Settings.autologin=="ON") then -- Auto connect?
        Skynet.TCPConn.connect()
    end

end


Skynet.LoadSounds = function()
--Load sounds
gksound.GKLoadSound{soundname='humil',    filename="plugins/skynet-client/sounds/humil.ogg"}
gksound.GKLoadSound{soundname='massa',    filename="plugins/skynet-client/sounds/massacre.ogg"}
gksound.GKLoadSound{soundname='smack',    filename="plugins/skynet-client/sounds/smackdown.ogg"}
gksound.GKLoadSound{soundname='domin',    filename="plugins/skynet-client/sounds/dominate.ogg"}
gksound.GKLoadSound{soundname='game',     filename="plugins/skynet-client/sounds/gameover.ogg"}
gksound.GKLoadSound{soundname='sweet',    filename="plugins/skynet-client/sounds/sweetvengence.ogg"}
gksound.GKLoadSound{soundname='waste',    filename="plugins/skynet-client/sounds/waste.ogg"}
gksound.GKLoadSound{soundname='poor',     filename="plugins/skynet-client/sounds/poorbaby.ogg"}
gksound.GKLoadSound{soundname='tooez',    filename="plugins/skynet-client/sounds/tooeasy.ogg"}
gksound.GKLoadSound{soundname='bow',      filename="plugins/skynet-client/sounds/bow.ogg"}
gksound.GKLoadSound{soundname='nocha',    filename="plugins/skynet-client/sounds/nochance.ogg"}
gksound.GKLoadSound{soundname='yoda',     filename="plugins/skynet-client/sounds/sizemattersnot.ogg"}
gksound.GKLoadSound{soundname='headshot', filename="plugins/skynet-client/sounds/headshot.ogg"}
gksound.GKLoadSound{soundname='3kills',   filename="plugins/skynet-client/sounds/3_kills.ogg"}
gksound.GKLoadSound{soundname='4kills',   filename="plugins/skynet-client/sounds/4_kills.ogg"}
gksound.GKLoadSound{soundname='5kills',   filename="plugins/skynet-client/sounds/5_kills.ogg"}
gksound.GKLoadSound{soundname='6kills',   filename="plugins/skynet-client/sounds/6_kills.ogg"}
gksound.GKLoadSound{soundname='7kills',   filename="plugins/skynet-client/sounds/7_kills.ogg"}
gksound.GKLoadSound{soundname='8kills',   filename="plugins/skynet-client/sounds/8_kills.ogg"}
gksound.GKLoadSound{soundname='9kills',   filename="plugins/skynet-client/sounds/9_kills.ogg"}
gksound.GKLoadSound{soundname='10kills',  filename="plugins/skynet-client/sounds/10_kills.ogg"}
gksound.GKLoadSound{soundname='godlike',  filename="plugins/skynet-client/sounds/godlike.ogg"}
gksound.GKLoadSound{soundname='immortal', filename="plugins/skynet-client/sounds/immortal.ogg"}
gksound.GKLoadSound{soundname='double',   filename="plugins/skynet-client/sounds/double_kill.ogg"}
gksound.GKLoadSound{soundname='triple',   filename="plugins/skynet-client/sounds/triple_kill.ogg"}
gksound.GKLoadSound{soundname='quad',     filename="plugins/skynet-client/sounds/quad_kill.ogg"}
gksound.GKLoadSound{soundname='annihilation', filename="plugins/skynet-client/sounds/annihilation.ogg"}
gksound.GKLoadSound{soundname='genocide', filename="plugins/skynet-client/sounds/genocide.ogg"}


end

Skynet.ShowHelp = function()
    Skynet.print("Skynet help")
    Skynet.print("Skynet accepts the following commands:")
    Skynet.print("/Skynet help - Display this help")
    Skynet.print("/Skynet config - Configure Skynet")
    Skynet.print("/Skynet connect - Manually connect to server")
    Skynet.print("/Skynet disconnect - Disconnect from server")
    Skynet.print("/Skynet clearspots - Clears all the spots on the HUD")
    Skynet.print("Additionally Skynet will display payment/KOS status for a pilot when you target him (at the bottom of your hud)")
    Skynet.print("You will also be notified when other pilotss using Skynet meet pilots around the verse")

end

RegisterEvent(Skynet.PlayerEnteredGame, "PLAYER_ENTERED_GAME")

