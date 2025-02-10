action_display = {}
-- cant be a class, since this will be passed to gui constructor
function action_display:new(params)
    self.x=screen_width/2-10*#params.buttons
    self.y=screen_height - 28
    self.width=20*#params.buttons
    self.height = 28
    self.selection=nil
    self.buttons = params.buttons or {}
    return self
end

-- action_display.draw=function(self)
--     bgFill(self, 7)
-- end

action_display.hover=function()
    game_state:set_mouse_focus("action_display")
    return true
end

action_display.create_action_button=function(self, button_config, index)
    local button = self:attach({
        x=(index-1)*20, y=8, width=18, height=18,
        draw=function(button)
            bgFill(button, 0)
            rect(0, 0, button.width-1, button.height-1, 0)
            if (not button_config.disabled) then
                spr(button_config.sid, 1, 1)
            end
        end,
        tap=function()
            if (not button_config.disabled) then
                game_state:dispatch_event(button_config.event)
            end
            return true
        end
    })

    self:attach({
        x=(index-1)*20, y=0, width=18, height=8,
        hotkey=button_config.hotkey,
        update=function()
            if (keyp(""..button_config.hotkey) and not button_config.disabled) then
                game_state:dispatch_event(button_config.event)
            end
        end,
        draw=function()
            print(button_config.hotkey, 7, 0, button.clicked and 12 or 0)
        end
    })
end

action_display.create_action_buttons = function(self)
    local buttons = self.buttons
    for i=1,#buttons do
        self:create_action_button(buttons[i], i)
    end
end
