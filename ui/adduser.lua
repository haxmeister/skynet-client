
local adduser = adduser or {}

local txt_username = iup.text{  size = "150x" }
local txt_password = iup.text{  size = "150x" }
local chk_manuser  = iup.stationtoggle { title = "Manage Users",}
local chk_manwarr  = iup.stationtoggle { title = "Add Warranties",}
local chk_seewarr  = iup.stationtoggle { title = "See Warranties",}
local chk_seespots = iup.stationtoggle { title = "See Spots",}
local chk_seechat  = iup.stationtoggle { title = "See Alliance Chat",}
local chk_manstat  = iup.stationtoggle { title = "Change KOS, ALLY",}
local chk_seestat  = iup.stationtoggle { title = "See KOS, ALLY",}
local chk_addbot   = iup.stationtoggle { title = "Add Bot Status",}
local btn_submit   = iup.button {title = "Submit",}
local btn_close    = iup.button {title = "Close",}

local dialog = iup.dialog{

    border="NO",menubox="NO",resize="NO",
    defaultesc   = closeBtn,
    defaultenter = saveBtn,
    topmost      = "YES",
    modal        = "YES",
    alignment    = "ACENTER",
    bgcolor      = "0 0 0 92 *",
    fullscreen   = "YES",

    iup.hbox {
        iup.fill {},
        iup.vbox {
            iup.fill {},

            iup.pdasubsubsubframebg{
                iup.pdarootframe{
                    expand = "NO",

                    iup.vbox {
                        margin = "15X",
                        iup.fill{size = "20x"},
                        iup.hbox{
                            iup.fill{},
                            iup.label {
                                title="\127FF7E00Skynet\1270081FF | \127ffffffAdd User",
                                font=Font.H3
                            },
                            iup.fill{},
                        },
                        iup.fill{size = "20x"},
                        iup.hbox {
                            iup.label{ title = "Username: ", font=Font.H3*HUD_SCALE*1.05 },
                            txt_username,
                        },
                        iup.hbox {
                            iup.label{ title = "Password: ", font=Font.H3*HUD_SCALE*1.05 },
                            txt_password,
                        },

                        iup.fill{size="20x"},
                        iup.hbox{

                            iup.vbox {
                                chk_manuser,
                                chk_manwarr,
                                chk_seewarr,
                                chk_seespots,
                            },
                            iup.vbox{
                                chk_seechat,
                                chk_manstat,
                                chk_seestat,
                                chk_addbot,
                            },
                            --gap = 5,
                        },
                        iup.fill{size = "20x"},
                        iup.hbox{
                            expand    = "YES",
                            iup.fill{},
                            btn_submit,
                            btn_close,

                        }
                    }
                },
            },

            iup.fill {},
        },
        iup.fill {},
    },
    show_cb = function(self)
        txt_username.value = ""
        txt_password.value = ""
        chk_manuser.value  = "OFF"
        chk_manwarr.value  = "OFF"
        chk_seewarr.value  = "OFF"
        chk_seespots.value = "OFF"
        chk_seechat.value  = "OFF"
        chk_manstat.value  = "OFF"
        chk_seestat.value  = "OFF"
        chk_addbot.value   = "OFF"
    end,
}



function btn_submit:action()
    local msg = {
        action   = "sn_adduser",
        username = txt_username.value,
        password = txt_password.value,
        seespots = chk_seespots.value,
        seechat  = chk_seechat.value,
        seewarr  = chk_seewarr.value,
        manwarr  = chk_manwarr.value,
        seestat  = chk_seestat.value,
        manstat  = chk_manstat.value,
        addbots  = chk_addbot.value,
        manuser  = chk_manuser.value,
    }

    -- convert ON and OFF to 0 and 1
    for k, v in pairs(msg) do
        if (v == "ON") then
            msg[k]="1"
        end
        if (v == "OFF") then
            msg[k]="0"
        end
    end

    Skynet.TCPConn.SendData(msg)

    dialog:hide()
end

function btn_close:action()
    dialog:hide()
end
dialog:map() -- if you don't do this, eventually it will crash
adduser.dialog = dialog

return adduser


