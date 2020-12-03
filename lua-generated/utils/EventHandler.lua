--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
____exports.EventHandler = __TS__Class()
local EventHandler = ____exports.EventHandler
EventHandler.name = "EventHandler"
function EventHandler.prototype.____constructor(self)
    self.handlers = {}
    self.routines = {}
    __TS__ArrayForEach(
        self.routines,
        function(____, routine) return {
            coroutine.resume(routine)
        } end
    )
end
function EventHandler.prototype.listen(self)
    while true do
        local eventPack = {
            os.pullEvent()
        }
        local eventName = eventPack[1]
        if self.handlers[eventName] then
            (function()
                local ____self = self.handlers
                return ____self[eventName](
                    ____self,
                    unpack(eventPack)
                )
            end)()
        end
    end
end
return ____exports
