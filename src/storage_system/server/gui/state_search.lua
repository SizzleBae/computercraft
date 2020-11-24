local selectable_list = require 'gui.selectable_list'

local function create(states, storage_handler)
    local search_input = ""

    local suggestions = {}
    local selected_suggestion = 1

    local function update_suggestions()
        -- Update suggestions
        suggestions = {}
        local visited = {}
        for computerID, items in pairs(storage_handler.stored_items) do
            for slot, item in pairs(items) do
                local match = string.match(string.lower(item.displayName), string.lower(search_input))
                if match ~= nil and visited[item.displayName] == nil then
                    table.insert(suggestions, item.displayName)
                    visited[item.displayName] = true
                end
            end
        end
        table.sort(suggestions)

        -- Make sure that selected index is not out of bounds
        if selected_suggestion > #suggestions then 
            selected_suggestion = #suggestions
        elseif selected_suggestion < 1 then
            selected_suggestion = 1
        end
    end
    update_suggestions()

    local function set_search_input(new_search_input)
        search_input = new_search_input
        update_suggestions()
    end

    local function on_event(event, arg1, arg2, arg3)
        if event == 'char' then
            set_search_input(search_input .. arg1)
        elseif event == 'key'then
            -- print(arg1)
            if  arg1 == 14 then
                -- Backspace was pressed
                set_search_input(string.sub(search_input, 1, string.len(search_input) - 1))
            elseif arg1 == 208 then
                -- Down arrow was pressed
                if selected_suggestion < #suggestions then selected_suggestion = selected_suggestion + 1 end
            elseif arg1 == 200 then
                -- Up arrow was pressed
                if selected_suggestion > 1 then selected_suggestion = selected_suggestion - 1 end
            elseif arg1 == 28 then
                --Enter was pressed
                local selected_name = suggestions[selected_suggestion]
                if selected_name ~= nil then
                    --An item type was selected
                    return states.selected.create(states, storage_handler, selected_name)
                end
            end
        elseif event == 'storage_changed' then
            update_suggestions()
        end
    end

    local function draw_suggestions(x, y)
        local width, height = term.getSize()
        selectable_list.draw(x, y, height - y, selected_suggestion, #suggestions, function (i) return suggestions[i] end)
    end

    local function draw()
        term.scroll(selected_suggestion)
        term.setCursorPos(2, 2)
        term.write(search_input)
        draw_suggestions(2, 4)

    end

    return {
        set_search_input = set_search_input,
        on_event = on_event,
        draw = draw
    }
end

return {
    create = create
}