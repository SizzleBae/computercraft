local search_state = require 'gui.state_search'
local selected_state = require 'gui.state_selected'

local states = {
    search = search_state,
    selected = selected_state
}

local function create(storage_handler)
    local width, height = term.getSize()

    local current_state = search_state.create(states, storage_handler)

    local function draw()
        term.clear()
        current_state.draw()
    end

    local function on_event(event, arg1, arg2, arg3)
        -- print(event, arg1, arg2, arg3)
        local new_state = current_state.on_event(event, arg1, arg2, arg3)
        if new_state ~= nil then current_state = new_state end

        draw()
    end

    return {
        draw = draw,
        on_event = on_event
    }
end

return {
    create = create
}