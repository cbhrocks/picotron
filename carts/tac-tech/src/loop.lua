--[[pod_format="raw",created="2025-01-09 16:02:14",modified="2025-01-18 05:03:48",revision=2325]]
window{
    pauseable=false
}

--poke4(get(fetch(pwd().."/src/pal/0.pal")))
screen_width = 480
screen_height = 270

function _init()
    restart()
end

function _draw()
    cls()
    local draw_time = time()

    game_state.map:draw()
    game_state.gui:draw_all()

    game_state.last_draw = draw_time
end

function _update()
    update(game_state)
end

function restart()
    cls()
    game_state=state:new()
    create_hud(game_state)
end

function dispatch_event(event)
    game_state:dispatch_event(event)
end
