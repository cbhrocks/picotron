--[[pod_format="raw",created="2025-01-09 16:02:14",modified="2025-01-18 05:03:48",revision=2325]]
window{
    pauseable=false
}

--poke4(get(fetch(pwd().."/src/pal/0.pal")))
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

    game_state.map:draw()

    for p in all(game_state.projectiles) do
        p:draw()
    end
    game_state.gui:draw_all()
    buttonsPressed = ""
    if (game_state.controls.mouse_b_l) then buttonsPressed = buttonsPressed.."m_b_l, " end
    if (game_state.controls.mouse_b_r) then buttonsPressed = buttonsPressed.."m_b_r, " end
    if (game_state.controls.mouse_b_m) then buttonsPressed = buttonsPressed.."m_b_m, " end
    if (game_state.controls.up) then buttonsPressed = buttonsPressed.."up, " end
    if (game_state.controls.right) then buttonsPressed = buttonsPressed.."right, " end
    if (game_state.controls.down) then buttonsPressed = buttonsPressed.."down, " end
    if (game_state.controls.left) then buttonsPressed = buttonsPressed.."left, " end
    if (game_state.controls.primary) then buttonsPressed = buttonsPressed.."primary, " end
    if (game_state.controls.secondary) then buttonsPressed = buttonsPressed.."secondary, " end
    --print(string.format("cpu: %.3f \ncontrols: %s", stat(1), buttonsPressed), game_state.camera.x, game_state.camera.y, 13)
    --?""
    game_state.last_draw = update_time
end

function _update()
    update(game_state)
end

function restart()
    cls()
    game_state=state:new()
    -- printh("loading pal from path "..pwd().."/src/pal/base.pal")
    -- game_state:load_pal(pwd().."/src/pal/base.pal")
    create_hud(game_state)
end
