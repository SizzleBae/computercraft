local queue = {}

function queue:new()
    return {first = 0, last = -1}
end

function queue.pushleft(list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end

function queue.pushright(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end

function queue.popleft(list)
    local first = list.first
    if first > list.last then error("list is empty") end
    local value = list[first]
    list[first] = nil        -- to allow garbage collection
    list.first = first + 1
    return value
end

function queue.popright(list)
    local last = list.last
    if list.first > last then error("list is empty") end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
    return value
end

function queue.length(list)
    return list.last - list.first + 1
end

return { queue.new, queue.pushright, queue.pushleft, queue.popright, queue.popleft, queue.length }