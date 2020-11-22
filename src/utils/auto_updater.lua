local args = {...}
local repository_path = args[1]
local user_name = args[2]
local repository_name = args[3]

-- Defaults
if user_name == nil then user_name = 'SizzleBae' end
if repository_name == nil then repository_name = 'computercraft' end

-- Get the github api program
if fs.exists("github") then fs.delete("github") end
shell.run("pastebin", "get", "yE4xG1sx", "github")

startup_file = fs.open("startup", "w")

-- Download updated code
startup_file.writeLine("shell.run('github', '" .. user_name .. "','" .. repository_name .. "','.','" .. repository_path .."')")
startup_file.writeLine("shell.run('github', '" .. user_name .. "','" .. repository_name .. "','.','common')")
-- Run updated script
startup_file.writeLine("shell.run('" .. repository_path .. "/main')")

print("Restart computer to start auto updates!")
