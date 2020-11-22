local args = {...}
local server_dir = args[1]
local server_address = args[2]

-- Defaults
if server_dir == nil then server_dir = "" end
if server_address == nil then server_address = "http://85.164.111.235:8000" end

-- Get the github api program
if fs.exists("file_client") then fs.delete("file_client") end
shell.run("pastebin", "get", "YLh9qWnT", "file_client")

startup_file = fs.open("startup", "w")
-- Download updated code
startup_file.writeLine("shell.run('file_client','" .. server_address .. "','" .. server_dir .. "')")
startup_file.writeLine("shell.run('file_client','" .. server_address .. "','common')")
-- Run updated script
startup_file.writeLine("shell.run('" .. server_dir .. "/main')")

print("Restart computer to start auto updates!")
