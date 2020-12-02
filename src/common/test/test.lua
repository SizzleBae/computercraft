local EventHandler = require '~../event_handler'

local event_handler = EventHandler:new()

event_handler:on('char', function (char)
    print(char)
end)
event_handler:on('key', function (code)
    print(code)
end)
event_handler:listen_loop()