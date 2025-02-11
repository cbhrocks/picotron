--[[pod_format="raw",created="2025-01-09 16:01:30",modified="2025-01-14 00:53:59",revision=854]]
--[[pod_format="raw",created="2025-01-06 21:02:01",modified="2025-01-06 21:02:01",revision=0]]
entity = {
    type = 'entity',
    name = "",
    owner = "enemy",
}

function entity:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

function entity:draw()
    if not self.dead then
        if (self.draw_circle != nil) self:draw_circle()
        if (self.draw_sprite != nil) self:draw_sprite()
        -- local points = self:get_hit_box()
        -- line(points[1][1], points[1][2], points[2][1], points[2][2])
        -- line(points[2][1], points[2][2], points[3][1], points[3][2])
        -- line(points[3][1], points[3][2], points[4][1], points[4][2])
        -- line(points[4][1], points[4][2], points[1][1], points[1][2])
    end
    if (self.draw_particles != nil) self:draw_particles()
    for p in all(self.particles) do
        p:draw()
    end
end

function entity:update(game_state)
    local time_elapsed = game_state.cur_update - game_state.last_update
    if not self.dead then
        -- if (self.handle_controls != nil) self:handle_controls(game_state) this should be called by update
        if (self.update_duration != nil) self:update_duration(game_state)
        if (self.update_position != nil) self:update_position(game_state)
    end
    if (self.update_particles != nil) self:update_particles(game_state)
end

entity.add_circle = function(self, radius, col)
    self.radius = radius
    self.col = col
    self.draw_circle = function(self)
        circ(self.pos.x, self.pos.y, self.radius, self.col)
    end
    return self
end

entity.add_sprite = function(self, s_id, width, height)
    self.s_id = s_id
    self.width = width
    self.height = height
    self.draw_sprite = function(self)
        spr(self.s_id, self.pos.x, self.pos.y)
    end
    return self
end

entity.add_duration = function(self, duration)
    self.duration = duration
    self.update_duration = function(self, game_state)
        local time_elapsed = game_state.cur_update - game_state.last_update
        if (self.duration < 0) then
            self.dead = true
        else
            self.duration -= time_elapsed
        end
    end
    return self
end

entity.add_particles = function(self)
    self.particles = {}
    self.draw_particles = function(self)
        for p in all(self.particles) do
            p:draw()
        end
    end
    self.update_particles = function(self, game_state)
        local time_elapsed = game_state.cur_update - game_state.last_update
        for p in all(self.particles) do
            p:update()
        end
        ArrayRemove(
            self.particles, 
            function(t, i, j)
                if (t[i].dead) return false
                t[i]:update(time_elapsed)
                return true
            end
        )
    end
    return self
end

-- TODO: change to use vectors
entity.add_hitbox = function(self, type)
    -- hit box
    self.hb = {
        t = "ngon",
        -- todo, reformat to be ngon
        h = 4,
        w = 4
    }
    self.get_hit_box = function(self)
        return {
            {self.x-self.hb.w, self.y-self.hb.h}, --top left
            {self.x-self.hb.w, self.y+self.hb.h-1}, --bottom left
            {self.x+self.hb.w-1, self.y+self.hb.h-1}, --bottom right
            {self.x+self.hb.w-1, self.y-self.hb.h}, --top right
        }
    end
    self.on_hit = function(self) print("hit") end
    return self
end

entity.add_terrain = function(self)
    self.elevation = 0
    -- top, right, bottom, left cover supplied to surounding spaces
    self.cover = {0, 0, 0, 0}
    self.traversable = true
    return self
end

entity.add_stats = function(self)
    -- health
    self.maxHealth = 20
    self.health = 20
    -- armor
    self.maxArmor = 5
    self.armor = 5

    -- attributes
    -- controls how fast the unit moves and can get shots off on visible enemies
    self.speed = 10
    -- controls how fast the unit can react. i.e. shooting at enemies peaking from behind cover, moving between cover
    self.reflexes = 5
    -- controls melee damage and how much the unit can carry
    self.strength = 5
    -- controls the health and resistances of the unit
    self.constitution = 5
    -- controls how accurate the unit is with their attacks
    self.accuracy = 5

    function self.get_move_distance(self)
        return self.speed\2
    end

    -- stats used when taking turn. these get refreshed at the beginning of each turn
    function self.refresh_turn(self)
        self.movement_tiles = nil
        self.remaining_moves = 2
        self.remaining_actions = 1
    end
    self:refresh_turn()

    self.actions = ActionTree:new({
        display_config={
            action_display={
                buttons={
                    {
                        sid=56,
                        hotkey='1',
                        event={
                            name='move',
                        }
                    },
                    {
                        sid=57,
                        hotkey='2',
                        event={
                            name='attack',
                        }
                    },
                    {
                        sid=58,
                        hotkey='3',
                        event={
                            name='cover',
                        }
                    },
                }
            }
        },
        handle=function(self, event, game_state)
            game_state.hud:load_display(self:traverse_tree().display_config)
        end,
        events={"move", "attack", "cover"},
        move=ActionTrees.move,
        attack=ActionTrees.attack,
        cover=ActionTrees.cover
    })
    -- self.actions:add_tree(ActionTrees.move, {}, 'move')
    -- self.actions:add_tree(ActionTrees.attack, {}, 'attack')
    -- self.actions:add_tree(ActionTrees.cover, {}, 'cover')

    return self
end

-- adds functions and fields related with positioning to entity
-- @param pos {vec | nil} the initial location of the entity. defaults to 0,0
-- @return self
entity.add_position = function(self, pos)
    self.pos = pos or vec(0,0)
    self.move = function(self, new_pos)
        self.pos = new_pos
    end
    return self
end

-- requires position first
entity.add_movement = function(self, max_velocity, pdx, pdy)
     -- max velocity
    self.mv = max_velocity or 20
    -- acceleration (pixels per second)
    self.dx = 0
    self.dy = 0
    -- passive decelleration
    self.pdx = pdx or 0
    self.pdy = pdy or 0
    -- velocity
    self.vx = 0
    self.vy = 0
    self.calculate_velocity = function(self, time_elapsed)
        if (self.dx != 0) then
            self.vx = mid(-self.mv, self.vx + (self.dx * time_elapsed), self.mv)
        elseif (self.vx > 0) then
            self.vx = max(0, self.vx - (self.pdx * time_elapsed))
        elseif (self.vx < 0) then
            self.vx = min(0, self.vx + (self.pdx * time_elapsed))
        end
        if (self.dy != 0) then
            self.vy = mid(-self.mv, self.vy + (self.dy * time_elapsed), self.mv)
        elseif (self.vy > 0) then
            self.vy = max(0, self.vy - (self.pdy * time_elapsed))
        elseif (self.vy < 0) then
            self.vy = min(0, self.vy + (self.pdy * time_elapsed))
        end
    end
    self.calculate_position = function(self, time_elapsed)
        self.pos += vec(self.vx, self.vy)
    end
    self.update_position = function(self, game_state)
        local time_elapsed = game_state.cur_update - game_state.last_update
        self:calculate_velocity(time_elapsed)
        self:calculate_position(time_elapsed)
    end

   return self
end

--https://gamedevacademy.org/lua-inheritance-tutorial-complete-guide/
