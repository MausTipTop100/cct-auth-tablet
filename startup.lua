json = require "json"

local protocol = "auth"
local hostname = "auth_server"

local uuid_file = "/data/uuid.txt"

if not fs.exists(uuid_file) then
	error("invalid uuid file")
end

-- def

local function get_uuid()
	local h = fs.open(uuid_file, "r")
	local uuid = h.readAll()
	h.close()
	return uuid
end

local function gen_code(callback)
	local ip = rednet.lookup(protocol, hostname)
	rednet.send(ip, json.encode({["command"] = "gen-code", ["uuid"] = get_uuid()}), protocol)
	local id, message = rednet.receive()
	local status, error = pcall(function()
		local response = json.decode(message)
		if(response["code"] ~= nil) then
			callback(response["code"], response["level"])
		elseif(response["error"] ~= nil) then
			print(response["error"])
		end
	end)
end

-- main

rednet.open("back")

local function draw_progress_bar()
	term.setCursorPos(0, 20)
	term.setBackgroundColor(colors.blue)
	term.write("                            ")
	for i = 60, 0, -1 do
		sleep(1)
		local length = math.floor((i/60) * 28)
		term.setCursorPos(0, 20)
		term.setBackgroundColor(colors.gray)
		term.write("                            ")
		term.setCursorPos(0, 20)
		term.setBackgroundColor(colors.blue)
		for i = length, 1, -1 do
			term.write(" ")
		end
		term.setBackgroundColor(colors.gray)
		if(i == 0) then
			gen_code(function(code, level)
				term.setCursorPos(12, 9)
				term.write(code)
			end)
		end
	end
end

term.setBackgroundColor(colors.black)
term.clear()

term.setBackgroundColor(colors.gray)
term.setCursorPos(1, 1)
term.write(" Authenticator v1.0                           ")

term.setCursorPos(8, 8)
term.write("            ")
term.setCursorPos(8, 9)
term.write("            ")
term.setCursorPos(8, 10)
term.write("            ")

gen_code(function(code, level)
		term.setCursorPos(12, 9)
		term.write(code)
		term.setCursorPos(1, 19)
		term.setBackgroundColor(colors.black)
		term.write("Level: " .. level)
	end)

while true do
	draw_progress_bar()
end