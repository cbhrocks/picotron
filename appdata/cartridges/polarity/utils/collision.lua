-- https://stackoverflow.com/questions/10962379/how-to-check-intersection-between-2-rotated-rectangles
function colliding(a, b)
    if (a.hb.t == 'line' and b.hb.t == 'ngon') or (a.hb.t == 'ngon' and b.hb.t == 'line') then
        local line, hitbox
        if a.hb.t == 'line' then
            line = a:get_hit_box()
            hitbox = b:get_hit_box()
        else
            line = b:get_hit_box()
            hitbox = a:get_hit_box()
        end
        for i=1,#hitbox do
            local i2 = i+1
            if (i2 > #hitbox) i2 = 1
            if intersect(line[1], line[2], hitbox[i], hitbox[i2]) then
                return true
            end
        end
        return false
    elseif a.hb.t == 'ngon' and b.hb.t == 'ngon' then
        for i, polygon in pairs({a, b}) do
            local points = polygon:get_hit_box()
            for i1=1, #points do -- for each point thats connected
                local i2 = i1 + 1
                if (i1 == #points) i2 = 1
                local p1 = points[i1]
                local p2 = points[i2]
                local normal = {p2[2] - p1[2], p1[1] - p2[1]}

                local mina,maxa
                for i,p in pairs(a:get_hit_box()) do
                    local projected = normal[1] * p[1] + normal[2] * p[2]
                    if (mina == nil or projected < mina) then
                        mina = projected
                    end
                    if (maxa == nil or projected > maxa) then
                        maxa = projected
                    end
                end

                local minb,maxb
                for i,p in pairs(b:get_hit_box()) do
                    local projected = normal[1] * p[1] + normal[2] * p[2]
                    if (minb == nil or projected < minb) then
                        minb = projected
                    end
                    if (maxb == nil or projected > maxb) then
                        maxb = projected
                    end
                end

                if (maxa < minb or maxb < mina) then
                    return false
                end
            end
        end
        return true
    end
    return false
end

-- https://bryceboe.com/2006/10/23/line-segment-intersection-algorithm/
function ccw(a,b,c)
    return (c[2] - a[2]) * (b[1] - a[1]) > (b[2]-a[2]) * (c[1]-a[1])
end

function intersect(a,b,c,d)
    return ccw(a,c,d) != ccw(b,c,d) and ccw(a,b,c) != ccw(a,b,d)
end
