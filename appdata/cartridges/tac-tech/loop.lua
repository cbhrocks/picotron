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

    -- loop through all particles, removing them when dead and all child particles are gone
    ArrayRemove(state.projectiles, function(t, i, j)
        local v = t[i]
        v:update(update_time - state.last_update)

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
        map = {
            nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
            nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
            nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
            { terrain:new() }, { terrain:new() }, { terrain:new() }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), },
            { terrain:new() }, { terrain:new() }, { terrain:new() }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), },
            { terrain:new() }, { terrain:new() }, { terrain:new() }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), },
            nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
            nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
            nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        }
        units = {},
        projectiles = {},
        particles = {},
    }

    ship_locs = queue:new()
end
