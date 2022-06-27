shell.run("wget https://raw.githubusercontent.com/rxi/json.lua/master/json.lua json.lua")

json = require "json"

local protocol = "auth"
local hostname = "auth_server"

local uuid_file = "/data/uuid.txt"

rednet.open("back")

local function create_user(code, level, callback)
    local ip = rednet.lookup(protocol, hostname)
    rednet.send(ip, json.encode({["command"] = "create-user", ["code"] = code, ["level"] = level}), protocol)
    local id, message = rednet.receive()
    local response = json.decode(message)
    if(response["uuid"] ~= nil) then
        callback(response["uuid"])
    end
end

term.clear()
term.setBackgroundColor(colors.gray)
term.setCursorPos(1, 1)
term.write(" Authenticator v1.0 Installer                   ")
term.setBackgroundColor(colors.black)
term.setCursorPos(1, 3)
term.write("Press Ctrl + T to cancel")
term.setCursorPos(2, 5)
term.setBackgroundColor(colors.gray)
term.write("Code        ")
term.setCursorPos(2, 6)
term.write("            ")
term.setBackgroundColor(colors.black)
term.setCursorPos(2, 7)
term.write("Please enter the code of an administrative user")
term.setCursorPos(2, 8)
term.write("(Level 5 or higher)")
term.setCursorPos(2, 10)
term.setBackgroundColor(colors.gray)
term.write("Level (0-5) ")
term.setCursorPos(2, 11)
term.write("            ")
term.setBackgroundColor(colors.black)
term.setCursorPos(2, 12)
term.write("Enter the security level")
term.setCursorPos(3, 13)
term.write("0 => guest")
term.setCursorPos(3, 14)
term.write("1 => worker")
term.setCursorPos(3, 15)
term.write("2 => advanced worker")
term.setCursorPos(3, 16)
term.write("3 => leader")
term.setCursorPos(3, 17)
term.write("4 => operator")
term.setCursorPos(3, 18)
term.write("5 => administrator")

term.setCursorPos(3, 6)
local code = read("*")

term.setCursorPos(3, 11)
local level = read()

if not (pcall(function()
    if(math.floor(tonumber(level)) >= 0 and math.floor(tonumber(level)) <= 5) then
        create_user(code, level, function(uuid)
            local h = fs.open(uuid_file, "w")
            h.write(uuid)
        end)
    end
end)) then
    error("an unknown error occurred")
end