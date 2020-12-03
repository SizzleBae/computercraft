local TransferClient = {}
TransferClient.__index = TransferClient

function TransferClient:new(callbacks)
    local instance = {
        callbacks = callbacks
    }
    setmetatable(instance, self)

    return instance
end

return TransferClient