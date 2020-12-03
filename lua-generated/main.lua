--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____EventHandler = require("utils.EventHandler")
local EventHandler = ____EventHandler.EventHandler
print("Hello World!")
local handler = __TS__New(EventHandler)
local Test = __TS__Class()
Test.name = "Test"
function Test.prototype.____constructor(self)
    self.a = os.time()
end
local name, key = os.pullEvent()
print(name, key)
handler:listen()
return ____exports
