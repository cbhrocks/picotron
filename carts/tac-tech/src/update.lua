--[[pod_format="raw",created="2025-01-17 23:56:35",modified="2025-01-23 07:07:01",revision=207]]
local function toggle_pause_menu(game_state)
    pause_menu = find_first(game_state.menus, function(menu) return menu.name == "pause_menu" end)
    if (pause_menu == nil) then
        printh("creating pause menu")
        -- TODO: This needs to be a list, not a dict. that way can determine menu focus priority
        table.insert(game_state.menus, create_menu(
            "pause_menu",
            Menus.pause_menu,
            {}
        ))
    else
        game_state.gui:detach(pause_menu)
        del(game_state.menus, pause_menu)
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

-- there are certain controls that will always do things, otherwise handle_controls should determine what has highest
-- priority, then pass the control state to that things handle_controls function.
local function handle_controls(game_state)
    if (game_state.controls.pause_p) then game_state:dispatch_event({name="toggle_pause_menu"}) end
    if (#game_state.menus > 0) then
        game_state.menus[1]:handle_controls(game_state.controls)
    elseif (game_state.map.loaded) then
        game_state.map:handle_controls(game_state)
        game_state.camera:handle_controls(game_state.controls)
    end
end

local function handle_tile_clicked(game_state)
    local selected_tile = game_state.map:select_hovered_tile()
    local unit = selected_tile.unit
    local display_config = {}
    if unit then
        printh('unit selected')
        if unit.owner == game_state.map.current_turn.owner then
            printh('unit matches current owner: '..game_state.map.current_turn.owner)
            display_config.action_display = {
                actions=unit.actions
            }
        end
    end
    printh('created display config: '..dump(display_config))
    game_state.hud:load_display(display_config)
end

local function handle_load_action(game_state, action)
    game_state.current_action = action
    game_state.action_path = {}
    action:call_transition(game_state)
end

local function handle_events(game_state)
    for event in all(game_state.events) do
        game_state:log_msg("Handling event: "..event.name)
        if (game_state.current_action != nil) then
            game_state.current_action:handle_event(event, game_state)
        end
        if (not event.handled and event.name == "toggle_pause_menu") then toggle_pause_menu(game_state) end
        if (not event.handled and event.name == "toggle_controls_display") then toggle_controls_display(game_state) end
        if (not event.handled and event.name == "toggle_cpu_usage_display") then toggle_cpu_usage_display(game_state) end
        if (not event.handled and event.name == "toggle_log_display") then toggle_log_display(game_state) end
        -- if (event.name == "unit_action") then handle_unit_action(game_state, event.action) end
        if (not event.handled and event.name == "load_map") then game_state.map:load(event.data) end
        if (not event.handled and event.name == "tile_clicked") then handle_tile_clicked(game_state) end
        if (not event.handled and event.name == "load_action") then handle_load_action(game_state, event.action) end
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
