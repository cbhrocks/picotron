--[[pod_format="raw",created="2025-01-17 23:56:35",modified="2025-01-23 07:07:01",revision=207]]
local function toggle_pause_menu(game_state)
    if (game_state.menus.pause_menu == nil) then
        printh("creating pause menu")
        game_state.menus.pause_menu = create_menu(
            pause_menu,
            {}, 
            function() return game_state.controls.pause_p end, 
            function(key) game_state:log_msg(key.." selected.") end
        )
    else
        game_state.gui:detach(game_state.menus.pause_menu)
        game_state.menus.pause_menu = nil
    end
end

local function toggle_controls_display(game_state)
    if (game_state.settings.show_controls) then
        game_state.hud:detach_controls_display()
    else
        game_state.hud:attach_controls_display()
    end
    game_state.settings.show_controls = not game_state.settings.show_controls
end

local function toggle_cpu_usage_display(game_state)
    if (game_state.settings.show_cpu_usage) then
        game_state.hud:detach_cpu_display()
    else
        game_state.hud:attach_cpu_display()
    end
    game_state.settings.show_cpu_usage = not game_state.settings.show_cpu_usage
end

local function toggle_log_display(game_state)
    if (game_state.settings.show_log) then
        game_state.hud:detach_log_display()
    else
        game_state.hud:attach_log_display()
    end
    game_state.settings.show_log = not game_state.settings.show_log
end

local function handle_controls(game_state)
    if (game_state.controls.pause_p) then game_state:dispatch_event({name="toggle_pause_menu"}) end
end

local function handle_mouse_tap(game_state)
    if (game_state.menus.pause_menu != nil) then return end
    if (game_state.map.loaded) then
        local tile_clicked = game_state.map:get_loc_by_coord(game_state:get_mouse_world_pos())
        game_state:log_msg("Tile "..tile_clicked.x..", "..tile_clicked.y.." clicked")
        game_state.map:set_selected_tile(tile_clicked)
    end
end

local function handle_events(game_state)
    for event in all(game_state.events) do
        game_state:log_msg("Handling event: "..event.name)
        if (event.name == "toggle_pause_menu") then toggle_pause_menu(game_state) end
        if (event.name == "toggle_controls_display") then toggle_controls_display(game_state) end
        if (event.name == "toggle_cpu_usage_display") then toggle_cpu_usage_display(game_state) end
        if (event.name == "toggle_log_display") then toggle_log_display(game_state) end
        if (event.name == "load_map") then game_state.map:load(event.data) end
        if (event.name == "mouse_tap") then handle_mouse_tap(game_state) end
    end
    game_state.events = {}
end

function update(game_state)
    game_state.cur_update = time()

    game_state:update_controls()
    handle_controls(game_state)
    handle_events(game_state)
    game_state.camera:update(game_state)
    
    game_state.gui:update_all()

    -- loop through all particles, removing them when dead and all child particles are gone
    ArrayRemove(
        game_state.projectiles, 
        function(t, i, j)
            local v = t[i]
            v:update(game_state)

            return not v.dead or #v.particles > 0
        end
    )

    -- remove enemies if dead, otherwise update
    ArrayRemove(
        game_state.units, 
        function(t, i, j)
            local v = t[i]
            if (v.dead) then return false end
            v:update(game_state)

            return true
        end
    )

    -- set camera to the camera state location
    camera(game_state.camera.x, game_state.camera.y)

    game_state.last_update = game_state.cur_update
end
