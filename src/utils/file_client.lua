tArgs = { ... }

server_address = tArgs[1]
if server_address == nil then server_address = "http://85.164.111.235:8000" end
server_dir = tArgs[2]
if server_dir == nil then server_dir = "" end

function split_string (inputstr, sep)
    local result={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(result, str)
    end
    return result
end

paths_string = http.get(server_address .. "/api/list/" .. server_dir)
paths = split_string(paths_string, ',')

for i, path in pairs(paths) do
    print(path)
end

