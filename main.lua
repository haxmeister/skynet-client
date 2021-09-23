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
    Skynet.LoadSounds()

    if (Skynet.Settings.autologin=="ON") then -- Auto connect?
        Skynet.TCPConn.connect()
    end

end


Skynet.LoadSounds = function()
--Load sounds
gksound.GKLoadSound{soundname='humil', filename="plugins/Skynet/sounds/humil.ogg"}
gksound.GKLoadSound{soundname='massa', filename="plugins/Skynet/sounds/massacre.ogg"}
gksound.GKLoadSound{soundname='smack', filename="plugins/Skynet/sounds/smackdown.ogg"}
gksound.GKLoadSound{soundname='domin', filename="plugins/Skynet/sounds/dominate.ogg"}
gksound.GKLoadSound{soundname='game', filename="plugins/Skynet/sounds/gameover.ogg"}
gksound.GKLoadSound{soundname='sweet', filename="plugins/Skynet/sounds/sweetvengence.ogg"}
gksound.GKLoadSound{soundname='waste', filename="plugins/Skynet/sounds/waste.ogg"}
gksound.GKLoadSound{soundname='poor', filename="plugins/Skynet/sounds/poorbaby.ogg"}
gksound.GKLoadSound{soundname='tooez', filename="plugins/Skynet/sounds/tooeasy.ogg"}
gksound.GKLoadSound{soundname='bow', filename="plugins/Skynet/sounds/bow.ogg"}
gksound.GKLoadSound{soundname='nocha', filename="plugins/Skynet/sounds/nochance.ogg"}
gksound.GKLoadSound{soundname='yoda', filename="plugins/Skynet/sounds/sizemattersnot.ogg"}
gksound.GKLoadSound{soundname='headshot', filename="plugins/Skynet/sounds/headshot.ogg"}
gksound.GKLoadSound{soundname='3kills', filename="plugins/Skynet/sounds/3_kills.ogg"}
gksound.GKLoadSound{soundname='4kills', filename="plugins/Skynet/sounds/4_kills.ogg"}
gksound.GKLoadSound{soundname='5kills', filename="plugins/Skynet/sounds/5_kills.ogg"}
gksound.GKLoadSound{soundname='6kills', filename="plugins/Skynet/sounds/6_kills.ogg"}
gksound.GKLoadSound{soundname='7kills', filename="plugins/Skynet/sounds/7_kills.ogg"}
gksound.GKLoadSound{soundname='8kills', filename="plugins/Skynet/sounds/8_kills.ogg"}
gksound.GKLoadSound{soundname='9kills', filename="plugins/Skynet/sounds/9_kills.ogg"}
gksound.GKLoadSound{soundname='10kills', filename="plugins/Skynet/sounds/10_kills.ogg"}
gksound.GKLoadSound{soundname='godlike', filename="plugins/Skynet/sounds/godlike.ogg"}
gksound.GKLoadSound{soundname='immortal', filename="plugins/Skynet/sounds/immortal.ogg"}
gksound.GKLoadSound{soundname='double', filename="plugins/Skynet/sounds/double_kill.ogg"}
gksound.GKLoadSound{soundname='triple', filename="plugins/Skynet/sounds/triple_kill.ogg"}
gksound.GKLoadSound{soundname='quad', filename="plugins/Skynet/sounds/quad_kill.ogg"}
gksound.GKLoadSound{soundname='annihilation', filename="plugins/Skynet/sounds/annihilation.ogg"}
gksound.GKLoadSound{soundname='genocide', filename="plugins/Skynet/sounds/genocide.ogg"}


end

Skynet.ShowHelp = function()
    Skynet.print("Skynet help")
    Skynet.print("Skynet accepts the following commands:")
    Skynet.print("/Skynet help - Display this help")
    Skynet.print("/Skynet config - Configure Skynet")
    Skynet.print("/Skynet connect - Manually connect to server")
    Skynet.print("/Skynet disconnect - Disconnect from server")
    Skynet.print("/Skynet clearspots - Clears all the spots on the HUD")
    Skynet.print("Additionally Skynet will display payment/KOS status for a player when you target him (at the bottom of your hud)")
    Skynet.print("You will also be notified when other players using Skynet meet players around the verse")

end

RegisterEvent(Skynet.PlayerEnteredGame, "PLAYER_ENTERED_GAME")

