--[[pod_format="raw",created="2025-01-06 21:02:01",modified="2025-01-06 21:02:01",revision=0]]
entity = {
    type = 'entity',
    -- game details
    -- sprite id, width, height
    s_id=nil,
    w=1,
    h=1,
    -- position
    x=63,
    y=63,
    dead = false,
    -- max velocity
    mv = 20,
    -- acceleration (pixels per second)
    dx = 0,
    dy = 0,
    -- velocity
    vx = 0,
    vy = 0,

    -- hit box
    hb = {
        t = 'ngon',
        -- todo, reformat to be ngon
        h = 4,
        w = 4
    },

    duration=nil,
    particles=nil
}

function entity:new(o)
    local o = o or {}
    if (o.particles == nil) then
        o.particles = {}
    end
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

function entity:draw()
    if not self.dead then
        if (self.s_id == nil) then
            circ(self.x,self.y,5,7)
        else
            spr(self.s_id, self.x-4,self.y-4,1,1)
        end
        -- local points = self:get_hit_box()
        -- line(points[1][1], points[1][2], points[2][1], points[2][2])
        -- line(points[2][1], points[2][2], points[3][1], points[3][2])
        -- line(points[3][1], points[3][2], points[4][1], points[4][2])
        -- line(points[4][1], points[4][2], points[1][1], points[1][2])
    end
    for p in all(self.particles) do
        p:draw()
    end
end

function entity:move(new_x, new_y)
    self.x = new_x
    self.y = new_y
end

function entity:update(time)
    if not self.dead then
        if self.duration ~= nil then
            if (self.duration < 0) then
                self.dead = true
            else
                self.duration -= time
            end
        end
        if (self.g) then 
            self.g.x = self.x
            self.g.y = self.y
            self.g:update(time)
        end
        -- update velocity based on acceleration value
        self.vx = mid(-self.mv, self.vx + (self.dx * time), self.mv)
        self.vy = mid(-self.mv, self.vy + (self.dy * time), self.mv)

        self.x += self.vx
        self.y += self.vy
    end
    ArrayRemove(self.particles, function(t, i, j)
        if (t[i].dead) return false
        t[i]:update(time)
        return true
    end)
end

function entity:shoot(world, direction)
    self.g:shoot(world, direction)
end

function entity:get_hit_box()
    return {
        {self.x-self.hb.w, self.y-self.hb.h}, --top left
        {self.x-self.hb.w, self.y+self.hb.h-1}, --bottom left
        {self.x+self.hb.w-1, self.y+self.hb.h-1}, --bottom right
        {self.x+self.hb.w-1, self.y-self.hb.h}, --top right
    }
end

function entity:onhit(o)
    o.hp -= 1
end

terrain = entity: new({
    type="terrain",

    -- how high the spot is
    elevation = 0,
    -- top, right, bottom, left cover supplied to surounding spaces
    cover = {
        0, 0, 0, 0
    },
    -- whether a unit can ocupy the space or not
    traversable = true
})

unit = entity:new({
    type="unit",
    owner="player",

    -- health
    maxHealth = 20,
    health = 20,
    -- armor
    maxArmor = 5,
    armor = 5,

    -- attributes
    -- controls how fast the unit moves and can get shots off on visible enemies
    speed = 5,
    -- controls how fast the unit can react. i.e. shooting at enemies peaking from behind cover, moving between cover
    reflexes = 5,
    -- controls melee damage and how much the unit can carry
    strength = 5,
    -- controls the health and resistances of the unit
    constitution = 5,
    -- controls how accurate the unit is with their attacks
    accuracy = 5,
})

setmetatable(unit, {__index=entity})

function unit:draw()
    entity.draw(self)
end

function unit:update(time)
    entity.update(self, time)
end

--https://gamedevacademy.org/lua-inheritance-tutorial-complete-guide/
