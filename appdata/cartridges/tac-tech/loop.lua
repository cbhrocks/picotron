--[[pod_format="raw",created="2024-07-11 06:27:31",modified="2025-01-06 22:26:56",revision=15]]
screen_width = 480
screen_height = 270

function _init()
    -- enable mouse
    --poke(0x5f2d, 1)
    restart()
end

function _draw()
    cls()
    local update_time = time()
    state.mouse:draw()
    if (state.map_data != nil) then 
        map(state.map_data[2].bmp)
    end
    for e in all(state.units) do
        e:draw()
    end
    for p in all(state.projectiles) do
        p:draw()
    end
    for m in all(state.menus) do
        if (m.active) then
            m:draw()
        end
    end
    buttonsPressed = ""
    if (state.controls.mouse_b_l) then buttonsPressed = buttonsPressed.."m_b_l, " end
    if (state.controls.mouse_b_r) then buttonsPressed = buttonsPressed.."m_b_r, " end
    if (state.controls.mouse_b_m) then buttonsPressed = buttonsPressed.."m_b_m, " end
    if (state.controls.up) then buttonsPressed = buttonsPressed.."up, " end
    if (state.controls.right) then buttonsPressed = buttonsPressed.."right, " end
    if (state.controls.down) then buttonsPressed = buttonsPressed.."down, " end
    if (state.controls.left) then buttonsPressed = buttonsPressed.."left, " end
    if (state.controls.primary) then buttonsPressed = buttonsPressed.."primary, " end
    if (state.controls.secondary) then buttonsPressed = buttonsPressed.."secondary, " end
    print(string.format("cpu: %.3f\ncontrols: %s", stat(1), buttonsPressed), state.camera.position[1], state.camera.position[2], 13)
    --?""
    state.last_draw = update_time
end

function _update()
    local update_time = time()

    update_controls()
    state.mouse:update(update_time - state.last_update)
    state.camera:update(
        state.controls.up,
        state.controls.down,
        state.controls.left,
        state.controls.right,
        state.controls.mouse_pos,
        state.controls.mouse_b_m
    )

    for menu in all(state.menus) do
        if (menu.active) then
            menu:update(state.controls.up, state.controls.down, state.controls.mouse_pos, state.controls.mouse_b_l or state.controls.primary)
        end
    end

    -- loop through all particles, removing them when dead and all child particles are gone
    ArrayRemove(state.projectiles, function(t, i, j)
        local v = t[i]
        v:update(update_time - state.last_update)

        return not v.dead or #v.particles > 0
    end)

    -- remove enemies if dead, otherwise update
    ArrayRemove(state.units, function(t, i, j)
        local v = t[i]
        if (v.dead) return false
        v:update(update_time - state.last_update)

        return true
    end)

    -- state.camera:move(state.player.x - screen_width/2, state.player.y - screen_height/2)
    camera(state.camera.position[1], state.camera.position[2])

    -- move mouse
    state.mouse:move(state.controls.mouse_pos[1] + state.camera.position[1], state.controls.mouse_pos[2] + state.camera.position[2])

    state.last_update = update_time
end

function update_controls()
    local mouse_x, mouse_y, mouse_b, wheel_x, wheel_y = mouse()
    state.controls.last_mouse_pos = state.controls.mouse_pos
    state.controls.mouse_pos = {mouse_x, mouse_y}
    state.controls.mouse_b_l = (mouse_b & 0b0001) == 1
    state.controls.mouse_b_r = (mouse_b & 0b0010) == 2
    state.controls.mouse_b_m = (mouse_b & 0b0100) == 4
    state.controls.mouse_wheel_x = wheel_x
    state.controls.mouse_wheel_y = wheel_y
    state.controls.up = btn(2) or btn(10)
    state.controls.right = btn(1) or btn(9)
    state.controls.down = btn(3) or btn(11)
    state.controls.left = btn(0) or btn(8)
    state.controls.primary = btn(4)
    state.controls.secondary = btn(5)
end

function restart()
    cls()
    --music(0)
    local mouse_x = stat(32)
    local mouse_y = stat(33)
    local mouse = entity:new({
        type='other'
    })

    sceneMenu = menu:new({
        backgroundCol=5,
        outlineCol=7,
        title='Select Scene',
        seperate=true,
        position={20,20},
        items={
            menuItem:new({
                text='Demo Level',
                onSelect = function ()
                    state.map_data = fetch("test.map")
                    printh(dump(state.map_data))
                    printh(dump(state.map_data[1].bmp))
                    local ud = state.map_data[1].bmp
                    for i=0,(ud:height()-1) do
                        for j=0,(ud:width()-1) do
                            printh(dump(ud:get(i,j,1)))
                        end
                    end
                    sceneMenu.active=false
                    return
                end
            }),
            menuItem:new({
                text='Demo Level',
                onSelect = function ()
                    return
                end
            }),
        }
    })

    state = {
        last_update = time(),
        last_draw = time(),
        mouse = mouse,
        camera = cam:new(),
        -- better to keep these in seperate lists. easier to optimize loops
        -- map = {
        --     nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        --     nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        --     nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        --     { terrain:new() }, { terrain:new() }, { terrain:new() }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), },
        --     { terrain:new() }, { terrain:new() }, { terrain:new() }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), },
        --     { terrain:new() }, { terrain:new() }, { terrain:new() }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), }, { terrain:new(), },
        --     nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        --     nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        --     nil, nil, { terrain:new() }, { terrain:new(), }, {terrain:new(), }, nil, nil,
        -- }
        map_data = nil,
        units = {},
        projectiles = {},
        particles = {},
        controls = {
            up,
            down,
            left,
            right,

            mouse_pos,
            mouse_b_l,
            mouse_b_r,
            mouse_b_m,
            mouse_wheel_x,
            mouse_wheel_y,
        },
        menus = {
            sceneMenu
        }
    }
end

function load_map()

end
