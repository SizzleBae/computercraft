local function create(states, storage_handler, selected_name)
    local bundle_count = 0

    local stacks = {}
    local selected_stack = 1

    local function update_stacks()
        stacks = {}
        for computerID, items in pairs(storage_handler.stored_items) do
            for slot, item in pairs(items) do
                if item.displayName == selected_name then
                    table.insert(stacks, {
                        computerID = computerID,
                        slot = slot,
                        item = item
                    })
                end
            end
        end

        -- Make sure that selected index is not out of bounds
        if selected_stack > table.getn(stacks) then
            selected_stack = table.getn(stacks)
        end
    end
    update_stacks()

    local function create_search_state()
    end

    local function on_event(event, arg1, arg2, arg3)
        if event == 'char' then
            local number = tonumber(arg1)
            if number ~= nil then
                if bundle_count == 0 then
                    bundle_count = number
                else
                    local new_number = tostring(bundle_count) .. arg1
                    bundle_count = tonumber(new_number)
                end
            end
        elseif event == 'key'then
            if  arg1 == 14 then
                -- Backspace was pressed
                -- Switch to search state
                local search_state = states.search.create(states, storage_handler)
                -- Remove one letter from search
                search_state.set_search_input(string.sub(selected_name, 1, string.len(selected_name) - 1))
                return search_state
            elseif arg1 == 208 then
                -- Down arrow was pressed
                if selected_stack < table.getn(stacks) then selected_stack = selected_stack + 1 end
            elseif arg1 == 200 then
                -- Up arrow was pressed
                if selected_stack > 1 then selected_stack = selected_stack - 1 end
            elseif arg1 == 28 then
                --Enter was pressed
                local stack = stacks[selected_stack]
                storage_handler.retrieve_stack(stack.computerID, stack.slot, stack.item.count)
            end
        elseif event == 'storage_changed' then
            update_stacks()
            if table.getn(stacks) == 0 then
                -- If there are no more stacks left, return to search state
                return states.search.create(states, storage_handler)
            end
        end
    end

    local function draw_stacks(x, y)
        for i, stack in pairs(stacks) do
            -- Draw selected suggetion with white background
            if i == selected_stack then
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            end

            term.setCursorPos(x, y + i - 1)
            term.write(stack.item.displayName)
            term.setCursorPos(x + string.len(stack.item.displayName) + 2, y + i - 1)
            term.write(stack.item.count)

        end
        -- Reset colors
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
    end

    local function draw_selected_stack(x, y)

    end

    local function draw()
        term.setCursorPos(2, 2)
        term.write(selected_name)

        -- term.setCursorPos(string.len(selected_name) + 4, 2)
        -- term.write(bundle_count)

        draw_stacks(2, 4)
    end

    return {
        on_event = on_event,
        draw = draw
    }
end

return {
    create = create
}