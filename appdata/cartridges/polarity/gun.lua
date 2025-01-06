--[[pod_format="raw",created="2024-07-12 18:12:32",modified="2024-07-12 20:47:36",revision=2]]
gun = {
    x = 0,
    y = 0,
    -- maximum distance a projectile can travel
    range = nil,
    -- delay before shot is fired (charging up)
    delay = 0,
    -- how quickly can shoot again
    rate = 1,
    -- while shooting 
    shooting = false,
    remaining_delay = 0,
    sfx = 63
}

gun.__index=gun

function gun:new(o)
    return setmetatable(o or {}, self)
end

function gun:update(time)
    if (self.remaining_delay > self.delay) then
        self.remaining_delay -= time
    elseif (self.shooting) then
        self.shooting = false
        self.remaining_delay -= time
    else
        self.remaining_delay = self.delay
    end
end

function gun:shoot(o, direction)
    -- needs to be implemented!
    return nil
end

function shootPlasma(gun, state, direction)
	if (gun.remaining_delay <= 0) then
        add(state.projectiles, entity:new({
            x=gun.x,
            y=gun.y,
            vx=state.player.vx + cos(direction) * 2,
            vy=state.player.vy + sin(direction) * 2,
            duration = 2,
            s_id = 17,
            draw = function(projectile)
                for p in all(projectile.particles) do
                    p:draw()
                end
                if not projectile.dead then
                    --rspr(projectile.s_id, projectile.x-4, projectile.y-4, atan2(projectile.vx, projectile.vy), projectile.w, projectile.h)
                    spr(192, projectile.x-4, projectile.y-4)
                end
            end,
            update = function(o, time)
                entity.update(o, time)
                -- add particles after, so they draw where they spawn
                if (not o.dead) then
                    add(o.particles, entity:new({
                        duration=rnd(.075)+.075,
                        x=o.x,
                        y=o.y,
                        draw=function(o)
                            pset(o.x, o.y, 1)
                        end
                    }))
                end
            end,
            onhit = function(s, o)
                s.dead = true
                o.dead = true
            end
        }))
        gun.remaining_delay = gun.rate + gun.delay
        sfx(gun.sfx, -1, 0, 2)
    end
    gun.shooting = true
end

function createLaserParticles(start_x, start_y, end_x, end_y)
    local dx,dy,distance,particles
    dx= end_x - start_x
    dy= end_y - start_y
    distance= max(abs(dx), abs(dy))
    particles = {}
    for i=0,distance do
        local x,y
        x = start_x + i * dx / distance
        y = start_y + i * dy / distance
        add(particles, entity:new({
            --duration=rnd(.075)+.075,
            duration=rnd(.075)+.075,
            vx=state.player.vx,
            vy=state.player.vy,
            x=x,
            y=y,
            draw=function(o)
                pset(o.x, o.y, 11)
            end
        }))
    end
    return particles
end

function shootLaser(g, state, direction)
    if (g.remaining_delay <= 0) then
        -- distances
        local dx = cos(direction) * g.range
        local dy = sin(direction) * g.range
        local particles = createLaserParticles(g.x, g.y, g.x+dx, g.y+dy)
        add(state.projectiles, entity:new({
            x=g.x,
            y=g.y,
            vx=state.player.vx,
            vy=state.player.vy,
            duration = .2,
            particles = particles,
            draw = function(o)
                for p in all(o.particles) do
                    p:draw()
                end
            end,
            -- needs its own update function because it shouldn't update position based on velocity
            update = function(o, time)
                if o.duration ~= nil then
                    if (o.duration < 0) then
                        o.dead = true
                    else
                        o.duration -= time
                    end
                end
                ArrayRemove(o.particles, function(t, i, j)
                    if (t[i].dead) return false
                    t[i]:update(time)
                    return true
                end)
            end,
            hb = {
                t='line'
            },
            get_hit_box=function(o)
                return {{o.x, o.y}, {o.x+dx, o.y+dy}}
            end,
            onhit=function(s, o)
                o.dead = true
            end
        }))
        g.remaining_delay = g.rate + g.delay
        sfx(g.sfx, -1, 2, 2)
    end
    g.shooting = true
end

function shootRocket(gun, state, direction)
	if (gun.remaining_delay <= 0) then
        local target = getClosest(gun, state.enemies)
        local speed = 1
        add(state.projectiles, entity:new({
            x=gun.x,
            y=gun.y,
            vx=state.player.vx + cos(direction) * speed,
            vy=state.player.vy + sin(direction) * speed,
            turnRate = 15,
            duration = 2,
            s_id = 194,
            target = target,
            draw = function(projectile)
                for p in all(projectile.particles) do
                    p:draw()
                end
                if not projectile.dead then
                    --rspr(projectile.s_id, projectile.x-4, projectile.y-4, atan2(projectile.vx, projectile.vy), projectile.w, projectile.h)
                    spr(projectile.s_id, projectile.x-4, projectile.y-4)
                end
            end,
            update = function(o, time)
                printh(dump(o))
                local dir = atan2(o.vx, o.vy)
                local targetDir = atan2(o.target.x, o.target.y)
                local rotationNeeded = targetDir - dir
                local rotationPossible = o.turnRate * time
                local rotation = min(rotationNeeded, rotationPossible)
                local vel_vec = {x=o.vx, y=o.vy}
                rotate_around(o, vel_vec, rotation)
                o.vx = vel_vec.x
                o.vy = vel_vec.y
                
                entity.update(o, time)
                -- add particles after, so they draw where they spawn
                if (not o.dead) then
                    add(o.particles, entity:new({
                        duration=rnd(.075)+.075,
                        x=o.x,
                        y=o.y,
                        draw=function(o)
                            pset(o.x, o.y, 1)
                        end
                    }))
                end
            end,
            onhit = function(s, o)
                s.dead = true
                o.dead = true
            end
        }))
        gun.remaining_delay = gun.rate + gun.delay
        sfx(gun.sfx, -1, 0, 2)
    end
    gun.shooting = true
end

guns = {
    plasma = gun:new({
        shoot=shootPlasma
    }),
    laser = gun:new({
        range=100,
        shoot=shootLaser
    }),
    rocket = gun:new({
        range=500,
        shoot=shootRocket
    })
}