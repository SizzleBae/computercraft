-- A map of transfer locations and their contained items
local inventories = {}

-- Retrieve all possible inventory peripherals
for i, name in pairs(peripheral.getNames()) do
    local peripheral = peripheral.wrap(name)
    if peripheral["pullItems"] and peripheral["pushItems"] and peripheral["size"] then
        local items = {}

        inventories[name] = {
            items = items,
            peripheral = peripheral
        }
    end
end

local function update_inventory_slot(name, slot)
    inventories[name] = inventories[name].peripheral.getItemMeta(slot)
end

-- Updates a given inventory's item contents
local function update_inventory(name)
    local new_items = {}
    for slot = 1, inventories[name].peripheral.size() do
        -- Getting the metadata yields the coroutine
        table.insert(new_items, inventories[name].peripheral.getItemMeta(slot))
    end
    inventories[name] = new_items
end

-- Updates all connected inventories, uses coroutines for optimization
local function update_inventories()
    -- Spawn a coroutine for each inventory that reads its metadata
    local routines = {}
    for name, inventory in pairs(inventories) do
        table.insert(routines, function () update_inventory(name) end)
    end
    parallel.waitForAll(table.unpack(routines))
end

local function transfer_stack(from, to, from_slot, to_slot, count)
    inventories[from].peripheral.pushItems(to, from_slot, count, to_slot)
end


-- API
local function on_stack_request(id, count)
    -- If not available, reject request

    -- If available, send items to ender chest and accept request
end
local function on_stack_receive(stack_meta)
    -- If not desired, reject request

    -- If desired, accept request
end
local function on_stack_received(ender_slot)
    -- Store stack
end
local function on_list_stacks()
    -- Send a message containing a map of stacks and their identifiers.
end


-- local function test1()
--     while true do
--         -- inventories["minecraft:chest_0"].peripheral.pushItems("minecraft:ironchest_iron_0", 1)
--         -- print("Pushed item!")
--         -- inventories["minecraft:chest_0"].peripheral.pullItems("minecraft:ironchest_iron_0", 1)
--         -- print("Pulled item!")
--         inventories["minecraft:chest_0"].peripheral.getItemMeta(1)
--         print("Got meta!")
--     end
-- end

-- local function test2()
--     while true do
--         print("Coroutine performed!")
--         coroutine.yield()
--     end
-- end

update_inventories()

-- parallel.waitForAll(test1, test2)