function ArrayRemove(t, fnKeep)
    local j, n = 1, #t;

    for i=1,n do
        if (fnKeep(t, i, j)) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end

function find_first(array, fn)
    for i=1,#array do
        if fn(array[i]) then
            return array[i]
        end
    end
    return nil
end

function find_first_index(array, fn)
    for i=1,#array do
        if fn(array[i]) then
            return i
        end
    end
    return nil
end

function remove_first(array, fn)
    index = find_first_index(array, fn)
    if index then
        deli(array, index)
    end
    
end

-- array must have at least 2 objects
function getClosest(obj, array)
    -- i: closest
    j, n = 1, #array
    -- distance to current closest
    d = array[j].x^2 + array[j].y^2
    for i=2,n do
        -- distance of i element
        local id = array[i].x^2 + array[i].y^2
        if (id < d) then
            j = i
            d = id
        end
    end
    return array[j]
end
