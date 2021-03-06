local tArgs = { ... }

local server_address = tArgs[1]
local server_dir = tArgs[2]
if server_dir == nil then server_dir = "" end

local function split_string (inputstr, sep)
    local result={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(result, str)
    end
    return result
end

local paths_string = http.get(server_address .. "/api/list/" .. server_dir).readAll()
local paths = split_string(paths_string, ',')

for i, path in pairs(paths) do
    print(path)
    local file_string = http.get(server_address .. "/api/file/" .. server_dir .. "/" .. path).readAll()

    local file = fs.open(server_dir .. "/" .. path, "w")
    file.write(file_string)
    file.close()
end

