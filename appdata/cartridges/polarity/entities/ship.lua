ship = entity:new({
    s_id=0,
})

setmetatable(ship, {__index=entity})

function ship:draw()
    entity.draw(self)
end

function ship:control(left,right,up,down)
    -- update change in velocity using max acceleration
    self.dx = 0
    self.dy = 0
    if (left) then
        self.dx -= self.accel
        line(self.x, self.y, self.x+10, self.y, 8)
    end
    if (right) self.dx += self.accel
    if (up) self.dy -= self.accel
    if (down) self.dy += self.accel
end

function ship:update(time)
    --left jet
    local duration = .15
    local function draw(o)
        local progress = o.duration/duration
        local colors = {8,9,10,12}
        local color = colors[ceil(progress*4)]
        pset(o.x, o.y, color)
    end
    for i=1,2 do
        if self.dx > 0 then
            add(self.particles, entity:new{
                x = self.x - self.hb.w,
                y = self.y - flr(rnd(2)),
                vx = self.vx - 1,
                vy = self.vy + rnd(2)-1,
                duration=duration,
                draw=draw
            })
        --right jet
        elseif self.dx < 0 then
            add(self.particles, entity:new{
                x = self.x + self.hb.w - 1,
                y = self.y - flr(rnd(2)),
                vx = self.vx + 1,
                vy = self.vy + rnd(2)-1,
                duration=duration,
                draw=draw
            })
        end
        -- top jet
        if self.dy > 0 then
            add(self.particles, entity:new{
                x = self.x - flr(rnd(2)),
                y = self.y - self.hb.h,
                vx = self.vx + rnd(2)-1,
                vy = self.vy - 1,
                duration=duration,
                draw=draw
            })
        -- bot jet
        elseif self.dy < 0 then
            add(self.particles, entity:new{
                x = self.x - flr(rnd(2)),
                y = self.y + self.hb.h - 1,
                vx = self.vx + rnd(2)-1,
                vy = self.vy + 1,
                duration=duration,
                draw=draw
            })
        end
    end
    entity.update(self, time)
end

--https://gamedevacademy.org/lua-inheritance-tutorial-complete-guide/