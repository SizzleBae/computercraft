local args = {...}
local repository_path = args[1]
local user_name = args[2]
local repository_name = args[3]

-- Defaults
if user_name == nil then user_name = 'SizzleBae' end
if repository_name == nil then repository_name = 'computercraft' end

-- Get the github api program
shell.run("delete", "github")
shell.run("pastebin", "get", "yE4xG1sx", "github")

startup_file = fs.open("startup", "w")

-- Download update
startup_file.writeLine("shell.run('github', '" .. user_name .. "','" .. repository_name .. "','.','" .. repository_path .."')")
-- Run updated script
startup_file.writeLine("shell.run('downloads/" .. repository_name .. "/" .. repository_path .. "/main')")

print("Restart computer to start auto updates!")
