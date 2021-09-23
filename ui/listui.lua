
Skynet.List = Skynet.List or {}

local alpha, selalpha = ListColors.Alpha, ListColors.SelectedAlpha
local even, odd, sel = ListColors[0], ListColors[1], ListColors[2]

Skynet.List.bg = {
    [0] = even.." "..alpha,
    [1] = odd.." "..alpha,
    [2] = sel.." "..selalpha
}

Skynet.List.List = Skynet.List.List or iup.pdasubsubmatrix {
    numcol=4,
    expand='YES',
    edit_mode='NO',
    bgcolor='0 0 0 128 *',
    edition_cb = function()
        return iup.IGNORE
    end,
    enteritem_cb = function(self, line, col)
        self:setattribute("BGCOLOR", line, -1, Skynet.List.bg[2])
    end,
    leaveitem_cb = function(self, line, col)
        self:setattribute("BGCOLOR", line, -1, Skynet.List.bg[math.fmod(line,2)])
    end

    --[[
    click_cb = function(self, line, col)
        if line == 0 then
            -- Click on header
            if sortd == -1 then
                sortd = 1
            elseif sortd == 1 then
                sortd = -1
            end
            Skynet.List.Sort(Skynet.List.List,col,sortd)
        else
            -- Not header - select a line
        end
    end
    ]]
}

Skynet.List.List['0:1'] = 'Name'
Skynet.List.List['0:2'] = 'Type'
Skynet.List.List['0:3'] = 'Remaining'
Skynet.List.List['0:4'] = 'Notes'

Skynet.List.List['ALIGNMENT1'] = 'ALEFT'
Skynet.List.List['ALIGNMENT3'] = 'ARIGHT'
Skynet.List.List['WIDTH'.. 1]='90'
Skynet.List.List['WIDTH'.. 2]='100'
Skynet.List.List['WIDTH'.. 3]='120'
Skynet.List.List['WIDTH'.. 4]='220'

Skynet.List.closeBtn = Skynet.List.closeBtn or iup.stationbutton {
    title = "Close",
    ALIGNMENT="ACENTER",
    EXPAND="NO",
    action = function(self)
        HideDialog(Skynet.List.ListWindow)
    end
}

Skynet.List.ListWindow = Skynet.List.ListWindow or iup.dialog{
    iup.hbox {
        iup.fill {},
        iup.vbox {
            iup.fill {},
            iup.stationhighopacityframe{
                expand="NO",
                size="x500",
                iup.stationhighopacityframebg{
                    iup.vbox { margin="15x15",
                        iup.hbox {
                            iup.fill{}, iup.label { title="Registered players", font=Font.H3 }, iup.fill{},
                        },
                        iup.fill { size="15" },
                        iup.hbox {
                            Skynet.List.List,
                        },
                        iup.fill { size="15" },
                        iup.hbox {
                            iup.fill {},
                            Skynet.List.closeBtn,
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
    defaultesc=Skynet.List.closeBtn,
    topmost="YES",
    modal="YES",
    alignment="ACENTER",
    bgcolor="0 0 0 92 *",
    fullscreen="YES"
}
Skynet.List.ListWindow:map()


