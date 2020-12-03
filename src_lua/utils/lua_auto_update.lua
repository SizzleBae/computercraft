local args = {...}
local main_path = args[1]
local server_address = args[2]

-- Defaults
if server_address == nil then server_address = "http://85.164.111.235:8000" end

local function split_string (inputstr, sep)
    local result={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(result, str)
    end
    return result
end

local dependencies_string = http.get(server_address .. "/api/lua-dependencies/" .. main_path).readAll()
local dependencies = split_string(dependencies_string, ',')

for i, path in pairs(dependencies) do
    print("Retrieving " .. path .. "...")
    local file_string = http.get(server_address .. "/api/file/" .. path).readAll()

    local file = fs.open(path, "w")
    file.write(file_string)
    file.close()
end

-- if fs.exists("update") then fs.delete("update") end
-- shell.run("pastebin", "get", "Sn0qynhR", "update")

local startup_file = fs.open("startup", "w")

-- Download updated code
startup_file.writeLine("shell.run('update','" .. main_path .. "','" .. server_address .. "')")
-- Run updated script
startup_file.writeLine("shell.run('" .. main_path .. "')")

print("Restart computer to start auto updates!")
