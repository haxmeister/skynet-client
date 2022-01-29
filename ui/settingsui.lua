
Skynet.UI.Settings = Skynet.UI.Settings or {}

Skynet.UI.Settings.closeBtn = Skynet.UI.Settings.closeBtn or iup.stationbutton {
    title = "Close",
    ALIGNMENT="ACENTER",
    EXPAND="NO",
    action = function(self)
        HideDialog(Skynet.UI.SettingsWindow)
    end
}

Skynet.UI.Settings.saveBtn = Skynet.UI.Settings.saveBtn or iup.stationbutton {
    title = "Save",
    ALIGNMENT="ACENTER",
    EXPAND="NO",
    action = function(self)
        Skynet.Settings.username    = Skynet.UI.Settings.username.value or ""
        Skynet.Settings.password    = Skynet.UI.Settings.password.value or ""
        Skynet.Settings.autologin   = Skynet.UI.Settings.autologin.value or "OFF"
        Skynet.Settings.notifier    = Skynet.UI.Settings.autologin.notifier or "ON"
        Skynet.Settings.anonchat    = Skynet.UI.Settings.anonchat.value or "OFF"
        Skynet.Settings.notifyflash = Skynet.UI.Settings.notifyflash.value or "OFF"
        Skynet.Settings.sound       = Skynet.UI.Settings.sound.value or "ON"
--      Skynet.Settings.notifychat = Skynet.UI.Settings.notifychat.value or "ON"
--      Skynet.Settings.notifyhud = Skynet.UI.Settings.notifyhud.value or "ON"
        Skynet.SaveSettings()
        HideDialog(Skynet.UI.SettingsWindow)
    end
}

Skynet.UI.Settings.username = Skynet.UI.Settings.username or iup.text { value="", expand="NO", size="150x" }
Skynet.UI.Settings.password = Skynet.UI.Settings.password or iup.text { value="", expand="NO", size="150x", password="YES" }
Skynet.UI.Settings.autologin = Skynet.UI.Settings.autologin or iup.stationtoggle{
    value="OFF",
    title="Autologin to server",
    action=function(self, state)
        Skynet.Settings.autologin = (state==1 and "ON") or "OFF"
    end
}
Skynet.UI.Settings.notifier = Skynet.UI.Settings.notifier or iup.stationtoggle{ value="OFF", title="Notifier active",
    action=function(self, state)
        Skynet.Settings.notifier = (state==1 and "ON") or "OFF"
    end
}

Skynet.UI.Settings.anonchat = Skynet.UI.Settings.anonchat or iup.stationtoggle{ value="OFF", title="Chat Anonymously",
    action=function(self, state)
        Skynet.Settings.anonchat = (state==1 and "ON") or "OFF"
    end
}

Skynet.UI.Settings.notifyflash = Skynet.UI.Settings.notifyflash or iup.stationtoggle{ value="OFF", title="Flash on notifications",
    action=function(self, state)
        Skynet.Settings.notifyflash = (state==1 and "ON") or "OFF"
    end
}

Skynet.UI.Settings.sound = Skynet.UI.Settings.sound or iup.stationtoggle{ value="ON", title="Sound",
    action=function(self, state)
        Skynet.Settings.sound = (state==1 and "ON") or "OFF"
    end
}
Skynet.UI.SettingsWindow = Skynet.UI.SettingsWindow or iup.dialog{
    iup.hbox {
        iup.fill {},
        iup.vbox {
            iup.fill {},
            iup.stationhighopacityframe{
                expand="NO",
                iup.stationhighopacityframebg{
                    iup.vbox { margin="15x15",
                        iup.hbox {
                            iup.fill{}, iup.label { title="\127FF7E00Skynet\1270081FF | \127ffffffConfiguration", font=Font.H3 }, iup.fill{},
                        },
                        iup.fill { size="15" },
                        iup.hbox {
                            iup.vbox {
                                iup.hbox {
                                    iup.label { title="Username: "}, Skynet.UI.Settings.username,
                                },
                                iup.hbox {
                                    iup.label { title="Password: "}, Skynet.UI.Settings.password,
                                },
                                Skynet.UI.Settings.autologin,
                                Skynet.UI.Settings.notifier,
                                Skynet.UI.Settings.anonchat,
                                Skynet.UI.Settings.notifyflash,
                                Skynet.UI.Settings.sound,
                            },
                        },
                        iup.fill { size="15" },
                        iup.hbox {
                            iup.fill {},
                            Skynet.UI.Settings.saveBtn, iup.fill{ size="10" }, Skynet.UI.Settings.closeBtn,
                            iup.fill {},
                        },
                    },
                },
            },
            iup.fill {},
        },
        iup.fill {},
    },
    border="NO",menubox="NO",resize="NO",
    defaultesc=Skynet.UI.Settings.closeBtn,
    defaultenter=Skynet.UI.Settings.saveBtn,
    topmost="YES",
    modal="YES",
    alignment="ACENTER",
    bgcolor="0 0 0 92 *",
    fullscreen="YES",
    show_cb = function(self)
        Skynet.LoadSettings()
        Skynet.UI.Settings.username.value    = Skynet.Settings.username or ""
        Skynet.UI.Settings.password.value    = Skynet.Settings.password or ""
        Skynet.UI.Settings.autologin.value   = Skynet.Settings.autologin or "OFF"
        Skynet.UI.Settings.notifier.value    = Skynet.Settings.notifier or "ON"
        Skynet.UI.Settings.anonchat.value    = Skynet.Settings.anonchat or "OFF"
        Skynet.UI.Settings.notifyflash.value = Skynet.Settings.notifyflash or "OFF"
        Skynet.UI.Settings.sound.value       = Skynet.Settings.sound or "ON"
--      Skynet.UI.Settings.notifychat.value = Skynet.Settings.notifychat or "ON"
--      Skynet.UI.Settings.notifyhud.value = Skynet.Settings.notifyhud or "ON"
    end,
    --hide_cb = function()
        -- Save settings
    --end,
}
