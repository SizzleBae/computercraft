local ArrayUtils = require '~array_utils'

local EventHandler = {}

function EventHandler:new()
    local instance = {
        handlers = {},
        routines = {}
    }
    setmetatable(instance, self)
    self.__index = self

    return instance
end

function EventHandler:on(event_name, handler)
    if self.handlers[event_name] == nil then self.handlers[event_name] = {} end

    table.insert(self.handlers[event_name], handler)
end

function EventHandler:off(event_name, handler)
    if self.handlers[event_name] == nil then self.handlers[event_name] = {} end

    ArrayUtils:fast_remove(self.handlers[event_name], function (element)
        return element ~= handler
    end)
end

function EventHandler:listen_loop()
    while true do
        -- Yield until next event
        local event_pack = table.pack(os.pullEvent())
        local event_name = event_pack[1]

        -- Create coroutines for handlers if any
        local handlers = self.handlers[event_name]
        if handlers ~= nil then
            for _, handler in ipairs(handlers) do
                local routine = coroutine.create(function () handler(table.unpack(event_pack, 2)) end)
                table.insert(self.routines, routine)
            end
        end

        -- Resume all coroutines
        for i, routine in ipairs(self.routines) do
            if routine ~= nil then
                -- Copy the event data to each coroutine
                coroutine.resume(routine, table.unpack(event_pack))
            end
        end

        -- Remove dead coroutines
        ArrayUtils:fast_remove(self.routines, function (routine, i)
            return coroutine.status(routine) ~= "dead"
        end)
    end
end



return EventHandler