--[[
Skynet 1.0
By haxmeister
]]


Skynet.UI = Skynet.UI or {}
dofile("ui/settingsui.lua")
dofile("ui/listui.lua")

Skynet.UI.adduser  = dofile("ui/adduser.lua")
Skynet.UI.Display = Skynet.UI.Display or {}
Skynet.UI.NotifyTimer = Timer()



Skynet.UI.Init = function()
    if (Skynet.UI.NotifyHolder==nil) then
        Skynet.UI.NotifyHolder = iup.vbox { margin="8x4", expand="YES", alignment="ALEFT" }
        Skynet.UI.NotifyHolder2 = iup.vbox {
            visible="NO",
            iup.fill { size="%80" },
            iup.hbox {
                iup.fill {},
                iup.hudrightframe {
                    border="2 2 2 2",
                    iup.vbox {
                        expand="NO",
                        iup.hudrightframe {
                            border="0 0 0 0",
                            iup.hbox {
                                Skynet.UI.NotifyHolder,
                            },
                        },
                    },
                },
                iup.fill {},
            },
            iup.fill {},
            alignment="ACENTER",
            gap=2
        }
        iup.Append(HUD.pluginlayer, Skynet.UI.NotifyHolder2)
    end
        -- warranty status window
        if (Skynet.UI.Status==nil) then
        Skynet.UI.Status = iup.label{title="", font=Font.H3*HUD_SCALE*1.05, alignment="ALEFT", expand="HORIZONTAL"}
        Skynet.UI.StatusWindow = iup.vbox {
            visible="NO",
            iup.fill { size="150" }, -- add space from top of screen
            iup.hbox {
                iup.fill {}, -- add space from left of screen? (add size=)
                iup.hudrightframe {
                    border="2 2 2 2",
                    iup.vbox {
                        expand="NO",

                        iup.hudrightframe {
                            border="0 0 0 0",
                            iup.hbox {
                                margin="10x10",
                                Skynet.UI.Status,
                            },
                        },
                    },
                },
                iup.fill {},
            },
            iup.fill {},
            alignment="ACENTER",
            gap=2
        }
        iup.Append(HUD.pluginlayer, Skynet.UI.StatusWindow)
    end

Skynet.Notifier.UpdateNotifyDisplayTimer:SetTimeout(1500, Skynet.Notifier.UpdateNotifyDisplay)
end
