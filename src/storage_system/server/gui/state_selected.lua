local selectable_list = require 'gui.selectable_list'

local FOCUS_BUNDLE = 1
local FOCUS_STACKS = 2

local function create(states, storage_handler, selected_name)
    local bundle_count = 0
    local total_count = 0

    local stacks = {}
    local selected_stack = 1

    local focus = FOCUS_BUNDLE

    local function update_stacks()
        stacks = {}
        total_count = 0
        for computerID, items in pairs(storage_handler.stored_items) do
            for slot, item in pairs(items) do
                if item.displayName == selected_name then
                    table.insert(stacks, {
                        computerID = computerID,
                        slot = slot,
                        item = item
                    })
                    total_count = total_count + item.count
                end
            end
        end

        -- Make sure that selected index is not out of bounds
        if selected_stack > #stacks then
            selected_stack = #stacks
        end
    end
    update_stacks()

    local function on_event(event, arg1, arg2, arg3)
        if event == 'char' then
            local number = tonumber(arg1)
            if focus == FOCUS_BUNDLE and number ~= nil then
                if bundle_count == 0 then
                    bundle_count = number
                else
                    local new_number = tostring(bundle_count) .. arg1
                    bundle_count = tonumber(new_number)
                end
                if bundle_count > total_count then bundle_count = total_count end
            end
        elseif event == 'key'then
            local key = keys.getName(arg1)
            if  key == 'tab' then
                -- Tab was pressed
                -- Switch to search state
                local search_state = states.search.create(states, storage_handler)
                -- Remove one letter from search
                -- search_state.set_search_input(string.sub(selected_name, 1, string.len(selected_name) - 1))
                return search_state
            elseif key == 'backspace' then
                if focus == FOCUS_BUNDLE then
                    bundle_count = math.floor(bundle_count / 10)
                end
            elseif key == 'down' then
                -- Down arrow was pressed
                if focus == FOCUS_BUNDLE then
                    focus = FOCUS_STACKS
                elseif focus == FOCUS_STACKS then
                    if selected_stack < #stacks then selected_stack = selected_stack + 1 end
                end
            elseif key == 'up' then
                -- Up arrow was pressed
                if focus == FOCUS_STACKS then
                    if selected_stack > 1 then
                        selected_stack = selected_stack - 1
                    else
                        focus = FOCUS_BUNDLE
                    end
                end
            elseif key == 'enter' then
                --Enter was pressed
                if focus == FOCUS_BUNDLE then
                    storage_handler.retrieve_bundle(selected_name, bundle_count)
                elseif focus == FOCUS_STACKS then
                    local stack = stacks[selected_stack]
                    storage_handler.retrieve_stack(stack.computerID, stack.slot, stack.item.count)
                end
            end
        elseif event == 'storage_changed' then
            update_stacks()
            if #stacks == 0 then
                -- If there are no more stacks left, return to search state
                return states.search.create(states, storage_handler)
            end
        end
    end

    local function draw_stacks(x, y)
        local selected_index = selected_stack
        -- Don't draw selection when focus is not on the stacks
        if focus ~= FOCUS_STACKS then selected_index = 0 end

        local width, height = term.getSize()
        selectable_list.draw(x, y, height - y, selected_index, #stacks, function (i) return '[' .. i .. ']' end)
    end

    local function draw_table(x, y, table)
        for key, value in pairs(table) do
            term.setCursorPos(x, y)
            if type(value) == 'table' then
                term.write(key .. ':')
                y = draw_table(x + 2, y + 1, value)
            else
                term.write(key .. ':' .. tostring(value))
            end

            y = y + 1
        end

        return y - 1
    end

    local function draw_selected_stack(x, y)
        -- Render item meta information
        draw_table(x, y, stacks[selected_stack].item)
    end

    local function draw()
        term.setCursorPos(2, 2)
        term.write(selected_name)

        if focus == FOCUS_BUNDLE then
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
        end
        term.setCursorPos(2, 4)
        term.write(bundle_count .. '/' .. total_count)

        -- Reset colors
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)

        draw_stacks(2, 6)
        
        if focus == FOCUS_STACKS then
            draw_selected_stack(8, 4)
        end
    end

    return {
        on_event = on_event,
        draw = draw
    }
end

return {
    create = create
}