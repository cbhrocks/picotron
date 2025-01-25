--[[pod_format="raw",created="2025-01-18 00:47:52",modified="2025-01-18 05:03:48",revision=173]]
pause_menu = {
    type="menu",
    items={"Settings", "Level Select", "Close"},
    ["Settings"]={
        type="menu",
        items={
            "CPU Usage",
            "Controls Display",
            "Log Display",
            "Back",
        },
        ["CPU Usage"]={
            type="toggle",
            is_checked=function() return game_state.settings.show_cpu_usage end,
            call=function(menu) game_state:dispatch_event({name="toggle_cpu_usage_display"}) end
        },
        ["Controls Display"]={
            type="toggle",
            is_checked=function() return game_state.settings.show_controls end,
            call=function(menu) game_state:dispatch_event({name="toggle_controls_display"}) end
        },
        ["Log Display"]={
            type="toggle",
            is_checked=function() return game_state.settings.show_log end,
            call=function(menu) game_state:dispatch_event({name="toggle_log_display"}) end
        },
        ["Back"]={
            type="function",
            call=function(menu) menu:set_path({ }) end,
        },
    },
    ["Level Select"]={
        type="menu",
        items={"Test", "Back"},
        ["Test"]={
            type="function",
            call=function(menu) 
                game_state:dispatch_event({name="load_map", data="src/map/test.map"})
                game_state:dispatch_event({name="toggle_pause_menu"})
            end,
        },
        ["Back"]={
            type="function",
            call=function(menu) menu:set_path({ }) end,
        }
    },
    ["Close"]={
        type="function",
        call=function(menu)
            game_state:dispatch_event({name="toggle_pause_menu"})
        end,
    }
}
