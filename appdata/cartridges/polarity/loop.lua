--[[pod_format="raw",created="2024-07-11 06:27:31",modified="2024-07-12 20:06:49",revision=14]]
screen_width = 480
screen_height = 270
star_colors = {7, 2, 13}

function _init()
    -- enable mouse
    --poke(0x5f2d, 1)
    restart()
end

function _draw()
    cls()
    local update_time = time()
    state.player:draw()
    state.mouse:draw()
    for s in all(state.stars) do
        s:draw()
    end
    for e in all(state.enemies) do
        e:draw()
    end
    for p in all(state.projectiles) do
        p:draw()
    end
    local direction = atan2(state.player.vx, state.player.vy)
    --line(state.player.x, state.player.y, state.player.x + 20 * cos(direction), state.player.y + 20 * sin(direction), 7)
    --print("refresh rate: "..update_time-state.last_draw.."",state.camera.x, state.camera.y)
    print(string.format("cpu:%.3f",stat(1)), state.camera.x,state.camera.y,13)
    state.last_draw = update_time
end

function _update()
    local update_time = time()
    local mouse_x, mouse_y, mouse_b, wheel_x, wheel_y = mouse()

    if (state.player.hp <= 0) then
        restart()
    end

	state.player:control(btn(0), btn(1), btn(2), btn(3))

    if (btn(4) or btn(5) or (mouse_b & 0b0001) != 0) then
        state.player:shoot(state, atan2(state.mouse.x - state.player.x, state.mouse.y - state.player.y))
    end

    state.player:update(update_time - state.last_update)
    state.mouse:update(update_time - state.last_update)

    ArrayRemove(state.projectiles, function(t, i, j)
        local v = t[i]
        v:update(update_time - state.last_update)

        -- when enemy is hit, perform on hit
        for e in all(state.enemies) do
            if not e.dead and colliding(v,e) then
                v:onhit(e)
            end
        end

        return not v.dead or #v.particles > 0
    end)

    ArrayRemove(state.enemies, function(t, i, j)
        local v = t[i]
        if (v.dead) return false
        v:update(update_time - state.last_update)

        -- check if distance is max
        if (abs(v.x - state.player.x) + abs(v.y - state.player.y) > screen_width*2) then
            return false
        end

        -- check if colliding with player
        if colliding(v, state.player) then
            -- kill for now
            v:onhit(state.player)
            return false
        end

        return true
    end)

    state.camera:move(state.player.x - screen_width/2, state.player.y - screen_height/2)
    camera(state.camera.x, state.camera.y)

    update_stars(update_time - state.last_update)

    -- move mouse
    state.mouse:move(mouse_x + state.camera.x, mouse_y + state.camera.y)

    if (flr(update_time) == state.next_m) then
        local enemy = entity:new({
            s_id=1,
            type='enemy',
        })
        spawn_enemies(
            state.player,
            enemy
        )
        state.enemies[#state.enemies+1] = enemy
        state.next_m += state.meteor_interval
    end

    state.last_update = update_time
end

function restart()
    cls()
    --music(0)
    local mouse_x = stat(32)
    local mouse_y = stat(33)
    local mouse = entity:new({
        type='other'
    })
    local player = ship:new({
        g = guns.rocket,
        hp = 10
    })
    local camera = entity:new({
        x=player.x,
        y=player.y
    })

    state = {
        last_update = time(),
        last_draw = time(),
        mouse = mouse,
        player = player,
        camera = camera,
        -- better to keep these in seperate lists. easier to optimize loops
        enemies = { },
        projectiles = {},
        particles = {},
        stars = {},
        meteor_interval = 1,
        next_m = flr(time()),
    }

    ship_locs = queue:new()
end

function update_stars(time)
    for i=#state.stars, 50 do
        local x = state.camera.x + rnd(screen_width)
        local depth = rnd(58) + 2
        local color = star_colors[ceil(depth/60*3)]
        local y = state.camera.y + rnd(screen_height)
        local star = entity:new({
            x = x,
            y = y,
            depth = rnd(58) + 2,
            draw = function(o)
                pset(o.x, o.y, color)
            end,
            update = function(o, time, player)
                o.vx = -player.vx/o.depth
                o.vy = -player.vy/o.depth
                entity.update(o, time)
            end
        })
        add(state.stars, star)
    end
    for star in all(state.stars) do
        star:update(time, state.player)
        if star.x < state.camera.x then
            star.x = state.camera.x + screen_width
            star.y = state.camera.y + rnd(screen_height)
        elseif star.y < state.camera.y then
            star.y = state.camera.y + screen_height
            star.x = state.camera.x + rnd(screen_width)
        elseif star.x > state.camera.x + screen_width then
            star.x = state.camera.x
            star.y = state.camera.y + rnd(screen_height)
        elseif star.y > state.camera.y + screen_height then
            star.y = state.camera.y
            star.x = state.camera.x + rnd(screen_width)
        end
    end
end

function spawn_enemies(point, enemy)
    local distance = screen_width
    local direction = rnd(1)
    local x = distance * cos(direction) + state.player.x
    local y = distance * sin(direction) + state.player.y
    local dirx = (state.player.x - x)/distance
    local diry = (state.player.y - y)/distance
    local dirAng = atan2(dirx, diry) + rnd(0.1) - 0.05
    local vx = cos(dirAng)
    local vy = sin(dirAng)
    enemy.x = x
    enemy.y = y
    enemy.vx = vx
    enemy.vy = vy
end
