local EventHandler = require '~../event_handler'

local event_handler = EventHandler:new()

event_handler:on('char', function (code)
    print(code)
end)
event_handler:off('char', function (code)
    print(code .. " HEHE")
end)
event_handler:listen_loop()