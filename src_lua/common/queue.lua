local queue = {
    new = function()
        return {first = 0, last = -1}
    end,

    pushleft = function(list, value)
        local first = list.first - 1
        list.first = first
        list[first] = value
    end,

    pushright = function (list, value)
        local last = list.last + 1
        list.last = last
        list[last] = value
    end,

    popleft = function (list)
        local first = list.first
        if first > list.last then error("list is empty") end
        local value = list[first]
        list[first] = nil        -- to allow garbage collection
        list.first = first + 1
        return value
    end,

    popright = function (list)
        local last = list.last
        if list.first > last then error("list is empty") end
        local value = list[last]
        list[last] = nil         -- to allow garbage collection
        list.last = last - 1
        return value
    end,

    length = function (list)
        return list.last - list.first + 1
    end
}

return queue