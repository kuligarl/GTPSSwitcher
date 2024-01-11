local savedgtpses = {'RGT'}
local hostlinetotal = {0}
local gtpshosts = {}

local function openFiles(mode, files)
    if files == 0 then
        G = io.open("GTPS.dat", mode)
        H = io.open("hosts.dat", mode)
    elseif files == 1 then
        G = io.open("GTPS.dat", mode)
    else
        H = io.open("hosts.dat", mode)
    end
end

local function closeFiles(files)
    if files == 0 then
        H:close()
        G:close()
    elseif files == 1 then
        G:close()
    else
        H:close()
    end
end

local function writeFiles(string1, string2, files)
    if files == 0 then
        G:write(string1)
        H:write(string2)
        G:flush()
        H:flush()
    elseif files == 1 then
        G:write(string1)
        G:flush()
    else
        H:write(string2)
        H:flush()
    end
end

local function validation(name, mode)

    --MODE 2 FOR SAVING AND EDITING, MODE 1 FOR EVERYTHING ELSE

    if string.lower(name) == 'rgt' then
        print('Invalid selection.')
        return false
    end
    if mode == 1 then
        for k,v in pairs(savedgtpses) do
            if string.lower(v) == name then
                return true
            end
        end
        print("Invalid selection.")
        return false
    elseif mode == 2 then
        for k,v in pairs(savedgtpses) do
            if not (string.lower(v) == name) then
                return true
            end
        end
        print("Invalid selection.")
        return false
    end
end

local function input(name)
    io.write(name)
    local var = io.read()
    return var
end

print("Loading GTPS-es...\n\n")

local function collectSavedGTPS()
    openFiles("r", 0)
    if not G and not H then
        io.output('GTPS.dat')
        io.output('hosts.dat')
    end
    if G then
        for GTPS in G:lines("l") do
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
        local hosts = ""
        repeat
            if v == 0 then break end
            if H then
            local host = H:read("L")
            hosts = hosts .. host
            v = v - 1
            end
        until v == 0
        table.insert(gtpshosts, hosts)
    end
    closeFiles(0)
end

collectSavedGTPS()

local function SaveGTPS()
    local GTPSname
    repeat GTPSname = input("GTPS name: ") until validation(GTPSname, 2)
    local hosts = input("Hosts(separate lines using comma): ")
    print("Saving...")

    table.insert(savedgtpses, GTPSname)

    local hostlinestotal = 0
    local i = 0
    while true do
---@diagnostic disable-next-line: cast-local-type
        i = string.find(hosts, ",", i+1)
        if not i then break end
        hostlinestotal = hostlinestotal + 1
    end
    hostlinestotal = hostlinestotal + 1
    table.insert(hostlinetotal, hostlinestotal)
    hosts = string.gsub(hosts, ",", "\n")
    table.insert(gtpshosts, hosts)

    local allData

    openFiles("a+", 0)
    if G and H then
        allData = G:read("a")
        if allData == "" then
            writeFiles(GTPSname .. "\n" .. hostlinestotal, string.format(hosts), 0)
        else
            writeFiles("\n" .. GTPSname .. "\n" .. hostlinestotal, "\n" .. string.format(hosts), 0)
        end
    end
    closeFiles(0)

    openFiles('r', 1)
    if G:read("a") == allData then
        print("* -- !! Save unsuccessful! This shouldn't happen... Contact the devs! !! -- *")
    else
        print("Save successful!")
    end
    closeFiles(1)
end

local function deleteGTPS()
    local GTPSname
    local removelinetotal
    local removehosts
    repeat GTPSname = input("GTPS name: ") until validation(string.lower(GTPSname), 1)

    print("\nDeleting...\n")

    for k,v in pairs(savedgtpses) do
        if string.lower(v) == string.lower(GTPSname) then
            table.remove(savedgtpses, k)
            removehosts = table.remove(gtpshosts, k)
            removelinetotal = table.remove(hostlinetotal, k)
            break
        end
    end

    openFiles("r", 0)
    local allGTPSData = G:read("a")
    local allHostData = H:read("a")
    local failcheck = allGTPSData
    closeFiles(0)
    openFiles("w+", 0)

    allGTPSData = string.gsub(allGTPSData, GTPSname .. "\n" .. removelinetotal .. "\n", "")
    allGTPSData = string.gsub(allGTPSData,"\n" .. GTPSname .. "\n" .. removelinetotal, "")
    allGTPSData = string.gsub(allGTPSData,GTPSname .. "\n" .. removelinetotal, "")

    allHostData = string.gsub(allHostData, removehosts .. "\n", "")
    allHostData = string.gsub(allHostData, "\n" .. removehosts, "")
    allHostData = string.gsub(allHostData, removehosts, "")

    writeFiles(allGTPSData, allHostData, 0)
    closeFiles(0)

    for k,v in pairs(savedgtpses) do
        if string.lower(v) == GTPSname then
            print("\n* -- !! 1 Deletion unsuccesful! This shouldn't happen... Contact the devs -- !! *\n")
            break
        end
    end

    openFiles('r', 1)
    if G:read('a') == failcheck then
        print("\n* -- !! 2 Deletion unsuccesful! This shouldn't happen... Contact the devs -- !! *\n")
    else
        print('Deletion successful!')
    end
    closeFiles(1)
end

local function switchGTPS()
    local GTPSname
    local switchhost
    local currenthost = ''
    repeat GTPSname = string.lower(input("GTPS name: ")) until GTPSname == 'rgt' or validation(GTPSname, 1)
    

    if not (GTPSname == 'rgt') then
        for k,v in pairs(savedgtpses) do
            if string.lower(v) == GTPSname then
            switchhost = gtpshosts[k]
            end
        end
    else
        switchhost = ''
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
        hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "r")
        if hostsfile then
            AllHostfileData = hostsfile:read('a')
        end
        hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "a+")
        if hostsfile then
            hostsfile:write(switchhost)
            hostsfile:flush()
            hostsfile:close()
        end
        hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "r")
        if hostsfile then
            if AllHostfileData == hostsfile:read('a') then
                print("\n* -- !! Switch unsuccesful. Check if you're running as administrator. -- !! *\n")
            else
                print("\nSwitched to " .. GTPSname .. '\n')
            end
        end
    else

    hostsfile = io.open("C:/Windows/System32/drivers/etc/hosts", "r")

    if hostsfile then
        AllHostfileData = hostsfile:read('a')
        hostsfile:close()
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
            print("\n* -- !! Switch unsuccesful. Check if you're running as administrator. -- !! *\n")
        end
        hostsfile:close()
    end
end
end

local function changeName(GTPS)
    local newName
    repeat newName = input("New name: ") until validation(newName, 2)

    for k,v in pairs(savedgtpses) do
        if v == GTPS then
            table.remove(savedgtpses, k)
            table.insert(savedgtpses, k, newName)
            break
        end
        return newName
    end

    openFiles('r', 1)
    local allGTPSData = G:read('a')
    local failcheck = allGTPSData
    closeFiles(1)

    allGTPSData = string.gsub(allGTPSData, GTPS, newName)

    openFiles('w+', 1)
    writeFiles(allGTPSData,'', 1)
    closeFiles(1)

    openFiles('r', 1)
    if G:read('a') == failcheck then
        print("* -- !! Name change unsuccessful! This shouldn't happen... Contact the devs! !! -- *")
    else print("Name edit successful!")
    end
    closeFiles(1)
end

local function changeHosts(GTPS)
    local newHostlinetotal = 1
    local newHosts = input('New hosts(use , for new line): ')

    local hostlinestotal = ''
    local hosts = ''
    local i = 0

    for k,v in pairs(savedgtpses) do
        if v == GTPS then
            hosts = table.remove(gtpshosts, k)
            table.insert(gtpshosts, k, newHosts)

            while true do
                ---@diagnostic disable-next-line: cast-local-type
                i = string.find(hosts, ',', i + 1)
                if not i then break end
                newHostlinetotal = newHostlinetotal + 1
            end
            hostlinestotal = table.remove(hostlinetotal, k)
            table.insert(hostlinetotal, k, newHostlinetotal)
            break
        end
    end

    newHosts = string.gsub(newHosts, ',', '\n')

    openFiles('r', 0)
    local allHostData = H:read('a')
    local failcheck = allHostData
    local allGTPSData = G:read('a')
    closeFiles(0)

    allHostData = string.gsub(allHostData, hosts, newHosts)
    allGTPSData = string.gsub(allGTPSData, GTPS .. '\n' .. tostring(hostlinestotal), GTPS .. '\n' .. tostring(newHostlinetotal))

    openFiles('w+', 0)
    writeFiles(allGTPSData, allHostData, 0)
    closeFiles(0)

    openFiles('r', 2)
    if H:read('a') == failcheck then
        print("* -- !! Host change unsuccessful! This shouldn't happen... Contact the devs! !! -- *")
    else
        print("Hosts edit successful!")
    end
    closeFiles(2)
end



local function editGTPS()
    local GTPS
    repeat GTPS = input("GTPS name: ") until validation(string.lower(GTPS), 1)
    print("What do you want to change?\n\nname - GTPS name\nhosts - GTPS hosts\nboth - GTPS name and hosts")
    local act = string.lower(io.read())

    if act == 'name' then
        changeName(GTPS)
    elseif act == 'hosts' then
        changeHosts(GTPS)
    elseif act == 'both' then
        GTPS = changeName(GTPS)
        changeHosts(GTPS)
    end
end


function interface()
    local GTPSlist = ''
    for k,v in pairs(savedgtpses) do
        GTPSlist = GTPSlist .. v .. "\n"
    end

    print("Welcome to GTPS Switcher!\n\nSaved GTPS-es:\n" .. GTPSlist .. "\nWhat do you want to do?\n\nsave - Save a new GTPS\nswitch - Switch GTPS\ndelete - Delete a GTPS\nedit - Edit a GTPS\nquit - Exit the program")
    print("*Note: This progam won't work unless you run it as administrator.")
    local act = string.lower(io.read())

    if act == "save" then
        SaveGTPS()
        input('PRESS ENTER TO CONTINUE>>> ')
        interface()
    elseif act == "delete" then
        deleteGTPS()
        input('PRESS ENTER TO CONTINUE>>> ')
        interface()
    elseif act == "switch" then
        switchGTPS()
        input('PRESS ENTER TO CONTINUE>>> ')
        interface()
    elseif act == 'edit' then
        editGTPS()
        input('PRESS ENTER TO CONTINUE>>> ')
        interface()
    elseif act == "quit" then
        os.exit()
    else
        print('Invalid command')
        interface()
    end
end

interface()

