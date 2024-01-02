local savedgtpses = {}
local hostlinetotal = {}
local gtpshosts = {}
GTPSlist = ""

function openFiles(mode)
    g = io.open("GTPS.dat", mode)
    h = io.open("hosts.dat", mode)
end

function closeFiles()
    h:close()
    g:close()
end

function writeFiles(string1, string2)
    g:write(string1)
    h:write(string2)
    g:flush()
    h:flush()
end

function input(name)
    io.write(name)
    local var = io.read()
    return var
end

print("Loading GTPS-es...\n\n")

local function collectSavedGTPS()
    openFiles("r")
    if g then
        for GTPS in g:lines("l") do
            table.insert(savedgtpses, GTPS)
        end
    end
    for k,v in pairs(savedgtpses) do
        if string.find(v, "%d") then
            table.remove(savedgtpses, k)
            table.insert(hostlinetotal, tonumber(v))
        end
    end
    for k,v in pairs(hostlinetotal) do
        hosts = ""
        repeat
            if h then
            host = h:read("L")
            hosts = hosts .. host
            v = v - 1
            end
        until v == 0
        table.insert(gtpshosts, hosts)
    end
    if h and g then
        h:close()
        g:close()
    end
end

collectSavedGTPS()

function SaveGTPS()

    local GTPSname = input("GTPS name: ")
    local hosts = input("Hosts(separate lines using comma): ")
    print("Saving...")

    table.insert(savedgtpses, GTPSname)

    local hostlinestotal = 0
    local i = 0|nil
    while true do
        i = string.find(hosts, ",", i+1)
        if not i then break end
        hostlinestotal = hostlinestotal + 1
    end
    hostlinestotal = hostlinestotal + 1
    table.insert(hostlinetotal, hostlinestotal)
    hosts = string.gsub(hosts, ",", "\n")
    table.insert(gtpshosts, hosts)

    openFiles("a+")
    if g and h then
        local allData = g:read("a")
        if allData == "" then
            writeFiles(GTPSname .. "\n" .. hostlinestotal, string.format(hosts))
        else
            writeFiles("\n" .. GTPSname .. "\n" .. hostlinestotal, "\n" .. string.format(hosts))
        end
    end
end

function deleteGTPS()
    local removelinetotal = ""
    local removehosts = ""
    local GTPSname = input("GTPS name: ")

    print("\nDeleting...\n")

    for k,v in pairs(savedgtpses) do
        if v == GTPSname then
            table.remove(savedgtpses, k)
            removehosts = table.remove(gtpshosts, k)
            removelinetotal = table.remove(hostlinetotal, k)
        end
    end
    openFiles("r")
    local allGTPSData = g:read("a")
    local allHostData = h:read("a")
    openFiles("w+")
    allGTPSData = string.gsub(allGTPSData, GTPSname .. "\n" .. removelinetotal .. "\n", "")
    allHostData = string.gsub(allHostData, removehosts, "")
    writeFiles(allGTPSData, allHostData)
    closeFiles()
end

function switchGTPS()
    local switchhost = ""
    local currenthost = ""
    local GTPSname = input("GTPS name: ")
    
    for k,v in pairs(savedgtpses) do
        if v == GTPSname then
            switchhost = gtpshosts[k]
        end
    end

    local hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "r")
    if hostsfile then
    for k in hostsfile:lines("L") do
        if string.find(k, "growtopia") then
            currenthost = currenthost .. k
            for k in hostsfile:lines('L') do
                if (k == '\n') or string.find(k, 'growtopia') then
                    currenthost = currenthost .. k
                end
            end
        end
    end
    end
    if currenthost == '' then
        hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "a+")
        if hostsfile then
        hostsfile:write(switchhost)
        hostsfile:flush()
        hostsfile:close()
        end
    else
    hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "r")
    if hostsfile then
        AllHostfileData = hostsfile:read('a')
    end
    AllHostfileData = string.gsub(AllHostfileData, currenthost, string.format(switchhost))
    hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "w+")
    if hostsfile then
        hostsfile:write(AllHostfileData)
        hostsfile:flush()
        hostsfile:close()
    end
    hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "r")
    if hostsfile then
    if AllHostfileData == hostsfile:read('a') then
        print("\nSwitched to " .. GTPSname .. '\n')
    else
        print("\n*Switch unsuccesful. Check if you're running as administrator.\n")
    end
    end
end
end

function changeName(name)
    local newName = input("New name:")
    

function editGTPS()
    local hosts = ""
    local GTPSname = input("GTPS name: ")
    for k,v in pairs(savedgtpses) do
        if v == GTPSname then
            hosts = gtpshosts[k]
            break
        end
    end

    local act = input("What do you want to change?\n\nname - GTPS name\nHosts - GTPS hosts\nboth - GTPS name and host.")
        if act == "name" then
            changeName()
            interface()
        elseif act == "hosts" then
            changeHosts()
            interface()
        elseif act == "both" then
            changeName(GTPSname)
            changeHosts(hosts)
            interface()
        end
function interface()
    local GTPSlist = ""
    for k,v in pairs(savedgtpses) do
        GTPSlist = GTPSlist .. v .. "\n"
    end

    print("Welcome to GTPS Switcher!\n\nSaved GTPS-es:\n" .. GTPSlist .. "\nWhat do you want to do?\n\nsave - Save a new GTPS\nswitch - Switch GTPS\ndelete - Delete a GTPS\nquit - Exit the program")
    print("*Note: This progam won't work unless you run it as administrator.")
    local act = io.read()

    if act == "save" then
        SaveGTPS()
        interface()
    elseif act == "delete" then
        deleteGTPS()
        interface()
    elseif act == "quit" then
        os.exit()
    elseif act == "switch" then
        switchGTPS()
        interface()
    else
        print('Invalid command')
        interface()
    end
end

interface()

