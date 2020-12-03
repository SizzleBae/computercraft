export class EventHandler {
    private handlers: Record<string, ((...args: any[]) => void)> = {};
    private routines: LuaThread[] = [];

    constructor() {
        this.routines.forEach(routine => coroutine.resume(routine))
    }

    public listen() {

        //     while true do
        //     -- Yield until next event
        //     local event_pack = table.pack(os.pullEvent())
        //     local event_name = event_pack[1]

        //     -- Create coroutines for handlers if any
        //     local handlers = self.handlers[event_name]
        //     if handlers ~= nil then
        //         for _, handler in ipairs(handlers) do
        //             local routine = coroutine.create(function () handler(table.unpack(event_pack, 2)) end)
        //             table.insert(self.routines, routine)
        //         end
        //     end

        //     -- Resume all coroutines
        //     for i, routine in ipairs(self.routines) do
        //         if routine ~= nil then
        //             -- Copy the event data to each coroutine
        //             coroutine.resume(routine, table.unpack(event_pack))
        //         end
        //     end

        //     -- Remove dead coroutines
        //     ArrayUtils:fast_remove(self.routines, function (routine, i)
        //         return coroutine.status(routine) ~= "dead"
        //     end)
        // end      

        while (true) {
            const eventPack = os.pullEvent();
            const eventName = eventPack[0];

            if (this.handlers[eventName]) {
                this.handlers[eventName](...eventPack);
            }
        }
    }
}