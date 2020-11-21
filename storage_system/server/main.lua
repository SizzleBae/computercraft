rednet.open("right")

-- Maps a computer to it's stored items
stored_items = {}

function retrieve_stack(computerID, slot, count)
    rednet.send(computerID, {slot = slot, count = count}, "send_stack")
end

function retrieve_bundle(item_name, item_count)
    local remaining_count = item_count

    for computerID, items in pairs(stored_items) do
        for slot, item in pairs(items) do
            if item.displayName == item_name and remaining_count > 0 then
                -- This is the correct item type
                -- Calculate the amount of items to retrieve
                to_retrieve = remaining_count
                if to_retrieve > item.count then to_retrieve = item.count end

                -- Retrieve the stack
                retrieve_stack(computerID, slot, to_retrieve)
                remaining_count = remaining_count - to_retrieve

                print("Requested " .. to_retrieve .. " " .. item_name .. " from " .. computerID)
            end
        end
    end
end

function listen_to_user()
    while true do
        rednet.broadcast("", "read_contents")

        retrieve_bundle(read(), tonumber(read()))
    end
end

function listen_to_clients()
    while true do
        local sender, items = rednet.receive()

        stored_items[sender] = items
        print(sender .. ":")
        for slot, item in pairs(items) do
            print(item.displayName .. " " .. item.count)
        end
    end
end

parallel.waitForAny(listen_to_user, listen_to_clients)