queue = {}
function queue.new ()
    return {first = 0, last = -1}
end

function queue.pushleft (queue, value)
    local first = queue.first - 1
    queue.first = first
    queue[first] = value
end

function queue.pushright (queue, value)
    local last = queue.last + 1
    queue.last = last
    queue[last] = value
end

function queue.popleft (queue)
    local first = queue.first
    if first > queue.last then error("list is empty") end
    local value = queue[first]
    queue[first] = nil        -- to allow garbage collection
    queue.first = first + 1
    return value
end

function queue.popright (queue)
    local last = queue.last
    if queue.first > last then error("list is empty") end
    local value = queue[last]
    queue[last] = nil         -- to allow garbage collection
    queue.last = last - 1
    return value
end