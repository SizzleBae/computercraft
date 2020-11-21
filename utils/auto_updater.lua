local args = {...}
local user_name = args[1]
local repository_name = args[2]
local repository_path = args[3]

-- Get the github api program
shell.run("pastebin", "get", "wPtGKMam", "github")

startup_file = fs.open("startup", "w")

-- Download update
startup_file.writeLine("shell.run('github', '" .. user_name .. "','" .. repository_name .. "','.','" .. repository_path .."')")
-- Run updated script
startup_file.writeLine("shell.run('downloads/" .. repository_name .. "/" .. repository_path .. "/main')")

print("Restart computer to start auto updates!")
