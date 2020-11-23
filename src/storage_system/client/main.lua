local queue = require '../../common/queue'

-- Constants
local INPUT_SIDE = "top"
local STORAGE_SIDE = "bottom"
local SEND_SIDE = "left"
local CONTINUE_SIDE = "front"

local INVENTORIES = {
    [INPUT_SIDE] = peripheral.wrap(INPUT_SIDE),
    [STORAGE_SIDE] = peripheral.wrap(STORAGE_SIDE)
}

-- The stored items. Maps slot index to item metadata
local stored_items = {}

-- Gets the items in an inventory. Returns a map of slot to item metadata
-- This function is very expensive to run
local function get_items(inventory)
    local slots = inventory.list()

    local items = {}
    for slot, _ in pairs(slots) do
        items[slot] = inventory.getItemMeta(slot)
    end
    return items
end

-- Completely refreshes stored items in memory by reading chest contents
local function refresh_stored_items()
    stored_items = get_items(INVENTORIES[STORAGE_SIDE])

    -- Send update to server
    rednet.broadcast(stored_items)
end

-- Refreshes metadata in storage slot
local function refresh_stored_slot(slot)
    stored_items[slot] = INVENTORIES[STORAGE_SIDE].getItemMeta(slot)
end

-- Retrieves all the input items in the input container
local function retrieve_input_items()

    local input_items = get_items(INVENTORIES[INPUT_SIDE])
    for input_slot, input_item in pairs(input_items) do
        local remaining_count = input_item.count

        -- Attempt to fill already existing stacks in storage
        for stored_slot, stored_item in pairs(stored_items) do
            if remaining_count > 0 and stored_item.displayName == input_item.displayName then
                local remaining_space = stored_item.maxCount - stored_item.count
                if remaining_space > 0 then
                    local moved_count = INVENTORIES[INPUT_SIDE].pushItems(STORAGE_SIDE, input_slot, remaining_space, stored_slot)
                    remaining_count = remaining_count - moved_count

                    -- Update the storage metadata
                    refresh_stored_slot(stored_slot)
                end
            end
        end

        -- Check if there are any remaining items
        -- Attempt to put remaining items into an empty slot
        for slot_i=1, INVENTORIES[STORAGE_SIDE].size() do
            if remaining_count > 0 and stored_items[slot_i] == nil then
                -- This is an empty slot, put the rest in here
                local moved_count = INVENTORIES[INPUT_SIDE].pushItems(STORAGE_SIDE, input_slot, input_item.count, slot_i)
                remaining_count = remaining_count - moved_count

                -- Update the storage metadata
                refresh_stored_slot(slot_i)
            end
        end

        -- Check if there are any remaining items
        if remaining_count > 0 then
            -- Forward remaining items
            INVENTORIES[INPUT_SIDE].pushItems(CONTINUE_SIDE, input_slot)
        end
    end

end

local function send_stack(slot, count)
    sent_count = INVENTORIES[STORAGE_SIDE].pushItems(SEND_SIDE, slot, count)
    -- Update the storage metadata
    refresh_stored_slot(slot)
    rednet.broadcast(stored_items)

    print("Sent " .. sent_count .. " items from slot " .. slot)
end

local function on_rednet_message(sender, data, protocol)
    if protocol == 'read_contents' then
        rednet.send(sender, stored_items)
    elseif protocol == 'send_stack' then
        send_stack(data.slot, data.count)
    end
end

local input_event_count = 1

local function handle_input_items()
    while true do
        while input_event_count == 0 do coroutine.yield() end

        for i = 1, 16 do
            turtle.select(i)
            turtle.dropUp()
        end
        retrieve_input_items()
        rednet.broadcast(stored_items)

        if input_event_count > 1 then input_event_count = 1 else input_event_count = 0 end
    end
end

local function on_turtle_inventory()
    input_event_count = input_event_count + 1
end

local event_handlers = {
    rednet_message = on_rednet_message,
    turtle_inventory = on_turtle_inventory
}
local event_queue = queue.new()

local function dispatch_events()
    while true do
        if queue.length(event_queue) == 0 then coroutine.yield() end

        local event = queue.popleft(event_queue)
        local identifier = table.remove(event, 1) -- Don't pass identifier to handler function
        local handler = event_handlers[identifier]
        if handler ~= nil then
            handler(table.unpack(event))
        end
    end
end

local function receive_events()
    while true do
        local event = table.pack(os.pullEvent())
        queue.pushright(event_queue, event)
    end
end

rednet.open("right")
refresh_stored_items()
parallel.waitForAll(receive_events, dispatch_events, handle_input_items)