
Skynet.Command = Skynet.Command or {}

Skynet.Command.Dispatch = function(_, args)
    if (args~=nil) then
        if (Skynet.Command[args[1]]) then
            Skynet.Command[args[1]](args)
        else
            Skynet.printerror("Invalid command "..args[1])
        end
    end
end

--done
Skynet.Command["connect"] = function(args)
    Skynet.TCPConn.connect()
end

--done
Skynet.Command["disconnect"] = function(args)
    Skynet.TCPConn.Disconnect()
end

Skynet.Command["config"] = function(args)
    ShowDialog(Skynet.UI.SettingsWindow)
end

--done
Skynet.Command["listpayment"] = function(args)
    Skynet.TCPConn.SendData({ action='listpayment'})
end

--done
Skynet.Command["listkos"] = function(args)
    Skynet.TCPConn.SendData({ action='listkos'})
end

--done
Skynet.Command["listallies"] = function(args)
    Skynet.TCPConn.SendData({ action='listallies'})
end

--done
Skynet.Command["list"] = function(args)
    Skynet.TCPConn.SendData({ action='list'})
end

--done
Skynet.Command["addpayment"] = function(args)
    if (args[2]==nil or args[3]==nil) then
        Skynet.printerror("Missing parameters for command - " .. args[1])
        return
    end
    local name = substitute_vars(args[2])
    Skynet.TCPConn.SendData({ action='addpayment', name=name, length=args[3] })
end

--done
Skynet.Command["removepayment"] = function(args)
    if (args[2]==nil) then
        Skynet.printerror("Missing parameters for command - " .. args[1])
        return
    end
    local name = substitute_vars(args[2])
    Skynet.TCPConn.SendData({ action='removepayment', name=name})
end

--done
Skynet.Command["addkos"] = function(args)
    if (args[2]==nil) then
        Skynet.printerror("Missing parameters for command - " .. args[1])
        return
    end
    local name = substitute_vars(args[2])
    local len = args[3] or "0"
    local note = args[4] or ""
    Skynet.TCPConn.SendData({ action='addkos', name=name, length=len, notes=note})
end

--done
Skynet.Command["removekos"] = function(args)
    if (args[2]==nil) then
        Skynet.printerror("Missing parameters for command - " .. args[1])
        return
    end
    local name = substitute_vars(args[2])
    Skynet.TCPConn.SendData({ action='removekos', name=name})
end

--done
Skynet.Command["addally"] = function(args)
    if (args[2]==nil) then
        Skynet.printerror("Missing parameters for command - " .. args[1])
        return
    end
    local name = substitute_vars(args[2])
    Skynet.TCPConn.SendData({ action='addally', name=name})
end

--done
Skynet.Command["removeally"] = function(args)
    if (args[2]==nil) then
        Skynet.printerror("Missing parameters for command - " .. args[1])
        return
    end
    local name = substitute_vars(args[2])
    Skynet.TCPConn.SendData({ action='removeally', name=name })
end

--done
Skynet.Command["adduser"] = function(args)
    Skynet.UI.adduser.dialog:show()
end

Skynet.Command["removeuser"] = function(args)
    if (args[2]==nil) then
        Skynet.printerror("Adduser command need 1 parameters: username")
    else
        Skynet.TCPConn.SendData({ action='removeuser', username=args[2] })
    end
end

Skynet.Command["clearspots"] = function(args)
    Skynet.ClearSpots()
end

Skynet.Command["help"] = function(args)
    Skynet.ShowHelp()
end

RegisterUserCommand('Skynet', Skynet.Command.Dispatch)
