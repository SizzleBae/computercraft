
-- Maps a computer to it's stored items
local stored_items = {}

local function retrieve_stack(computerID, slot, count)
    rednet.send(computerID, {slot = slot, count = count}, "send_stack")
end

local function retrieve_bundle(item_name, item_count)
    local remaining_count = item_count

    for computerID, items in pairs(stored_items) do
        for slot, item in pairs(items) do
            if item.displayName == item_name and remaining_count > 0 then
                -- This is the correct item type
                -- Calculate the amount of items to retrieve
                local to_retrieve = remaining_count
                if to_retrieve > item.count then to_retrieve = item.count end

                -- Retrieve the stack
                retrieve_stack(computerID, slot, to_retrieve)
                remaining_count = remaining_count - to_retrieve

                print("Requested " .. to_retrieve .. " " .. item_name .. " from " .. computerID)
            end
        end
    end
end

return {
    stored_items = stored_items,
    retrieve_bundle = retrieve_bundle,
    retrieve_stack = retrieve_stack
}