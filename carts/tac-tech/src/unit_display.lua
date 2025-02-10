unit_display = {}

function unit_display:new(params)
    self.x = 0
    self.y = 20
    self.width = 50
    self.height = 150
    self.unit = params.unit
    return self
end

function unit_display:draw()
    bgFill(self, 6)
    print(self.unit.name, 2, 2, 0)
end

function unit_display:hover()
    game_state:set_mouse_focus("unit_display")
    return true
end

function unit_display:create_display()
    self.health_display=self:create_health_display()
    self.resources_display=self:create_resources_display()
end

function unit_display:create_health_display()
    local health_display = self:attach{
        x=5, y=12, width=self.width - 10, height=10
    }

    function health_display.draw(hd)
        bgFill(health_display, 0)
        rectfill(0, 0, (self.unit.health/self.unit.maxHealth)*hd.width, hd.height, 11)
        local text_width = print(self.unit.health.." / "..self.unit.maxHealth, screen_width, 0, 0) - screen_width
        printh("text width: "..text_width)
        print(self.unit.health.." / "..self.unit.maxHealth, hd.width/2 - text_width/2, 1, 0)
    end
end

-- create the display for actions and movement attached to the main display
function unit_display:create_resources_display()
end

function unit_display:create_stats_display()
end
