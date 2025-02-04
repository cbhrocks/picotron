function rotate_around(o, p, a)
    local s = sin(-a)
    local c = cos(a)
    p.x = ((p.x - o.x) * c) - ((p.y - o.y) * s) + o.x
    p.y = ((p.x - o.x) * s) + ((p.y - o.y) * c) + o.y
end

function normalize(x, y)
    local d = sqrt(x^2 + y^2)
    return {x=x/d, y=y/d}
end

-- rotates sprite
function rspr(s,x,y,a,w,h)
    local sw=(w or 1)*8
    local sh=(h or 1)*8
    local sx=(s%8)*8
    local sy=flr(s/16)*8
    local x0=flr(0.5*sw)
    local y0=flr(0.5*sh)
    local sa=sin(-a)
    local ca=cos(a)
    for ix=sw*-1,sw+4 do
        for iy=sh*-1,sh+4 do
            local dx=ix-x0
            local dy=iy-y0
            local xx=flr(dx*ca-dy*sa+x0)
            local yy=flr(dx*sa+dy*ca+y0)
            if (xx>=0 and xx<sw and yy>=0 and yy<=sh-1) then
                local col = sget(sx+xx,sy+yy)
                if col != 0 then
                    pset(x+ix,y+iy,col)
                end
            end
        end
    end
end

-- rotates map coordinates
function pd_rotate(x,y,rot,mx,my,w,flip,scale)
  local step = 1/16
  scale=scale or 1
  rot=rot\step * step
  local halfw, cx=scale*-w/2, mx + .5
  local cy,cs,ss=my-halfw/scale,cos(rot)/scale,sin(rot)/scale
  local sx, sy, hx, hy=cx+cs*halfw, cy+ss*halfw, w*(flip and -4 or 4)*scale, w*4*scale
  for py=y-hy, y+hy do
  tline(x-hx, py, x+hx, py, sx -ss*halfw, sy + cs*halfw, cs/8, ss/8)
  halfw+=.125
  end
end

-- function rotate_towards()
--     Vector3 fromDirection = fromVector.normalized;
--     Vector3 toDirection = toVector.normalized;
-- 
--     float angleRadians = Mathf.Acos(Vector3.Dot(fromDirection, toDirection));
-- 
--     float angleDegrees = Mathf.Min(angleRadians * Mathf.Rad2Deg, maxAngleDegrees);
-- 
--     Vector3 axis = Vector3.Cross(fromDirection, toDirection);
-- 
--     Quaternion rotationIncrement = Quaternion.AngleAxis(angleDegrees, axis);
-- 
--     outputVector = rotationIncrement * fromVector;
-- end
