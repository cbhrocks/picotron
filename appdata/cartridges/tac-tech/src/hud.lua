--[[pod_format="raw",created="2025-01-14 00:55:33",modified="2025-01-18 05:03:48",revision=1595]]
function create_hud(game_state)
    local hud = game_state.gui:attach{
        x=0, y=0, width=wWidth, height=wHeight,
        log_display=nil, 
        log_display_state="open", -- can be open, minimized
        cpu_display=nil,
        controls_display=nil,
        hover=function(self)
            handle_mouse(game_state)
        end,
        --tap=function(self)
        --    game_state:dispatch_event({name="mouse_tap"})
        --end
    }

    hud.attach_log_button = function(self)
        self.log_display = hud:attach{
            x=self.width-11, y=0,
            width=11, height=11,
            clicked=false,
            draw=function(lb)
                bgFill(lb, lb.clicked and 5 or 6)
                line(2, 2, lb.width-3, 2, 22)
                line(2, 4, lb.width-3, 4, 22)
                line(2, 6, lb.width-3, 6, 22)
                line(2, 8, lb.width-3, 8, 22)
                -- rounded
                pset(0, 0, 0)
                pset(lb.width-1, 0, 0)
                pset(0, lb.height-1, 0)
                pset(lb.width-1, lb.height-1, 0)
            end,
            click=function(lb)
                lb.clicked=true
            end,
            release=function(lb)
                lb.clicked=false
            end,
            tap=function(lb)
                self:toggle_log_state()
            end
        }
    end

    hud.attach_log_container = function(self)
        local log_container = self:attach{
            x=self.width-200, y=0,
            width=200, height=150,
        }

        local title_bar = log_container:attach{
            width=log_container.width, height=11,
            bg_col=22,
            draw=function(tb)
                bgFill(tb, tb.bg_col)
                print("Game Log", 2, 2, 7)
            end
        }

        local close_button = title_bar:attach{
            x=title_bar.width-11, y=0, z=50,
            width=11, height=11,
            clicked=false,
            draw=function(cb)
                bgFill(cb, cb.clicked and 5 or 6)
                -- close x
                line(2, 2, cb.width-4, 8, 22)
                line(3, 2, cb.width-3, 8, 22)
                line(2, 8, cb.width-4, 2, 22)
                line(3, 8, cb.width-3, 2, 22)
                -- rounded
                pset(0, 0, title_bar.bg_col)
                pset(cb.width-1, 0, title_bar.bg_col)
                pset(0, cb.height-1, title_bar.bg_col)
                pset(cb.width-1, cb.height-1, title_bar.bg_col)
            end,
            click=function(cb)
                cb.clicked=true
            end,
            release=function(cb)
                cb.clicked=false
            end,
            tap=function(cb)
                self:toggle_log_state()
            end
        }

        local log_text = log_container:attach_text_editor{
            x=0, y=11, width=log_container.width, height=135,
            has_search=true, show_line_numbers=true,
            text={"test"},--game_state.log,
        }

        -- tables passed by reference, so should update automatically
        log_text:set_text(game_state.log)

        local log_text_scrollbar = log_text:attach_scrollbars{}

        self.log_display = log_container
    end

    hud.attach_log_display = function(self)
        if (self.log_display_state == "open") then
            self:attach_log_container()
        elseif (self.log_display_state == "minimized") then
            self:attach_log_button()
        end
    end

    hud.detach_log_display = function(self)
        self:detach(self.log_display)
    end

    hud.toggle_log_state = function(self)
        self:detach_log_display()
        if (self.log_display_state == "open") then
            self.log_display_state = "minimized"
        elseif (self.log_display_state == "minimized") then
            self.log_display_state = "open"
        end
        self:attach_log_display()
    end

    hud.attach_cpu_display = function(self)
        self.cpu_display = self:attach {
            x=0, y=0, width=60, height=11,
            draw=function (self)
                bgFill(self, 0)
                print(string.format("CPU: %.3f", stat(1)*100).."%", 2, 2, 7)
            end,
        }
    end

    hud.detach_cpu_display = function(self)
        self:detach(self.cpu_display)
    end

    hud.attach_controls_display = function(self)
        self.controls_display = hud:attach {
            x=0, y=12, width=50, height=0,
            line_height = 12, to_print = {},
            padding_x=4, padding_y=2,
            update=function(self)
                self.to_print = {}
                for key, val in pairs(game_state.controls) do
                    if (val == true) then table.insert(self.to_print, key) end
                end
                self.height = #self.to_print * self.line_height
            end,
            draw=function(self)
                bgFill(self, 7)
                for i=0,#self.to_print do
                    print(self.to_print[i+1], 0 + self.padding_x, i*self.line_height + self.padding_y, 0)
                end
            end
        }
    end

    hud.detach_controls_display = function(self)
        self:detach(self.controls_display)
    end

    hud.attach_select_display = function(self)
        local select_display = hud:attach({
            x=50, y=hud.height - 50,
            width = hud.width - 100, height = 50,
            draw = function(self)
                local selection = game_state.map:get_selected_tile()
                bgFill(self)
                if (selection.unit != nil) then
                    print(selection.unit.type.." - "..selection.unit.name.." - "..selection.unit.owner, 2, 2, 0)
                end
            end
        })

        local action_container = select_display:attach({
            x=select_display.width/2, y=select_display.height-28, width = 0, height = 28,
            active=1
        })

        local num_buttons = 0
        local attach_button = function(sid, action)
            local hk = action_container:attach({
                x=num_buttons*20, y=0, width=18, height=8,
                hotkey=num_buttons+1,
                draw=function(bt)
                    print(bt.hotkey, 7, 0, action_container.active == bt.hotkey and 12 or 0)
                end
            })
            action_container:attach({
                x=num_buttons*20, y=8, width=18, height=18,
                draw=function(mb)
                    rect(0, 0, mb.width-1, mb.height-1, 0)
                    spr(sid, 1, 1)

                    if action_container.active == hk.hotkey then
                        draw_with_pattern(
                            function()
                                bgFill(mb, 12)
                            end,
                            "highlight"
                        )
                    end
                end,
                update=function(mb)
                end,
                tap=function(mb)
                    game_state:dispatch_event({name="unit_action", action=action})
                    return true
                end
            })
            num_buttons += 1
            action_container.width += num_buttons*20
            action_container.x -= 10
        end

        -- this needs to be moved to update, and read in available actions from entity that is clicked on
        local selection = game_state.map:get_selected_tile()
        if (selection.unit != nil and selection.unit.owner == game_state.map.current_turn.owner) then
            attach_button(56, "move")
            attach_button(57, "attack")
            attach_button(58, "cover")
        end

        -- local button_container = self.select_display:attach({
        --     x=
        -- })

        self.select_display = select_display
    end

    hud.detach_select_display = function(self)
        self.detach(self.select_display)
        game_state.select_display = nil
    end

    if (game_state.settings.show_log) then hud:attach_log_display() end
    if (game_state.settings.show_cpu_usage) then hud:attach_cpu_display() end
    if (game_state.settings.show_controls) then hud:attach_controls_display() end
    if (game_state.map.selection != nil) then hud:attach_select_display() end
    game_state.hud = hud
end
