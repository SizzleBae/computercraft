local storage_handler = require 'storage_handler'
local gui_manager = require 'gui.manager'

rednet.open("right")

function listen_to_user()
    local gui = gui_manager.create(storage_handler)
    while true do
        gui.on_event(os.pullEvent())
        

        -- storage_handler.retrieve_bundle(read(), tonumber(read()))
    end
end

function listen_to_clients()
    rednet.broadcast("", "read_contents")

    while true do
        local sender, items = rednet.receive()

        storage_handler.stored_items[sender] = items
        os.queueEvent('storage_changed')

        -- print(sender .. ":")
        -- for slot, item in pairs(items) do
        --     print(item.displayName .. " " .. item.count)
        -- end
    end
end

parallel.waitForAny(listen_to_user, listen_to_clients)