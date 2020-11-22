local queue = require '../../common/queue'

-- Constants
local INPUT_SIDE = "front"
local STORAGE_SIDE = "back"
local SEND_SIDE = "left"
local CONTINUE_SIDE = "top"

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
        if remaining_count > 0 then
            -- Attempt to put remaining items into an empty slot
            for slot_i=1, INVENTORIES[STORAGE_SIDE].size() do
                if stored_items[slot_i] == nil then
                    -- This is an empty slot, put the rest in here
                    local moved_count = INVENTORIES[INPUT_SIDE].pushItems(STORAGE_SIDE, input_slot, input_item.count, slot_i)
                    remaining_count = remaining_count - moved_count

                    -- Update the storage metadata
                    refresh_stored_slot(slot_i)
                end
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

    print("Sent " .. sent_count .. " items from slot " .. slot)
end

local function msg_read_contents(sender, data)
    rednet.send(sender, stored_items)
end

local function msg_send_stack(sender, data)
    send_stack(data.slot, data.count)
end

local handlers = {
    read_contents = msg_read_contents,
    send_stack = msg_send_stack
}

local messages = queue.new()

local function handle_messages()
    print("Storage client ready!")

    while true do
        -- Wait until a message is available
        while queue.length(messages) == 0 do coroutine.yield() end

        local message = queue.popleft(messages)

        local handler = handlers[message.protocol]
        if (handler) then
            handler(message.sender, message.data)
        else
            print("Invalid protocol: " .. message.protocol)
        end
    end
end

local function receive_messages()
    while true do
        local sender, data, protocol = rednet.receive()

        queue.pushright(messages, { sender = sender, data = data, protocol = protocol })
    end
end

local function handle_input_items()
    while true do
        sleep(1)
        retrieve_input_items()
    end
end

rednet.open("right")
refresh_stored_items()
parallel.waitForAll(receive_messages, handle_messages, handle_input_items)