action_display = {}
-- cant be a class, since this will be passed to gui constructor
function action_display:new(config)
    self.x=screen_width/2-10*#config.actions
    self.y=screen_height - 28
    self.width=20*#config.actions
    self.height = 28
    self.selection=nil
    self.actions=config.actions
    return self
end

action_display.hover=function()
    game_state:set_mouse_focus("action_display")
    return true
end

action_display.create_action_button=function(self, action, hotkey, index)
    printh("creating action button "..index)
    local button = self:attach({
        x=(index-1)*20, y=8, width=18, height=18,
        draw=function(button)
            bgFill(button, 0)
            rect(0, 0, button.width-1, button.height-1, 0)
            spr(action.sid, 1, 1)
        end,
        tap=function()
            game_state:dispatch_event({name="load_action", action=action})
            return true
        end
    })

    self:attach({
        x=(index-1)*20, y=0, width=18, height=8,
        hotkey=hotkey,
        update=function()
            if (keyp(""..hotkey)) then
                game_state:dispatch_event({name="load_action", action=action})
            end
        end,
        draw=function()
            print(hotkey, 7, 0, button.clicked and 12 or 0)
        end
    })
end

action_display.create_action_buttons = function(self)
    printh("creating action buttons: "..dump(self.actions))
    for i=1,#self.actions do
        self:create_action_button(self.actions[i], ""..i, i)
    end
end
