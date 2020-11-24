local queue = require '../../common/queue'

-- Constants
-- local INPUT_SIDE = "top"
local STORAGE_SIDE = "bottom"
local SEND_SIDE = "left"
-- local CONTINUE_SIDE = "front"

local INVENTORIES = {
    -- [INPUT_SIDE] = peripheral.wrap(INPUT_SIDE),
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

-- Refreshes metadata in storage slot, then returns it
local function refresh_stored_slot(slot)
    stored_items[slot] = INVENTORIES[STORAGE_SIDE].getItemMeta(slot)
    return stored_items[slot]
end

local function send_stack(slot, count)
    local sent_count = INVENTORIES[STORAGE_SIDE].pushItems(SEND_SIDE, slot, count)
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

local input_dirty = true

local function handle_input_items()
    while true do
        while input_dirty == false do coroutine.yield() end
        input_dirty = false

        for input_slot = 1, 16 do
            turtle.select(input_slot)
            -- This does not contain meta information :(
            local input_item = turtle.getItemDetail()

            if input_item ~= nil then
                if turtle.dropDown() then
                    local check_empty_slots = true
                    -- If items were stored, update storage metadata
                    for stored_slot = 1, INVENTORIES[STORAGE_SIDE].size() do
                        local stored_item = stored_items[stored_slot]
                        if stored_item == nil then
                            if check_empty_slots then
                                if refresh_stored_slot(stored_slot) == nil then
                                    -- An empty slot was not filled, no need to check additional empty slots
                                    check_empty_slots = false
                                end
                            end
                        elseif stored_item.name == input_item.name then
                            refresh_stored_slot(stored_slot)
                        end
                    end
                else
                    -- If there was no space, pass it on
                    turtle.drop()
                end
            end
        end

        rednet.broadcast(stored_items)
    end
end

local function on_turtle_inventory()
    input_dirty = true
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