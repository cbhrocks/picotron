--[[pod_format="raw",created="2025-01-11 06:57:49",modified="2025-01-14 00:47:03",revision=45]]
cam = entity:new({
    last_mouse_pos=nil,
    width=wWidth, height=wHeight,
    handle_controls = function(self, game_state)
        time_elapsed = game_state.cur_update - game_state.last_update
        controls = game_state.controls
        if (controls.mouse_b_m and controls.last_mouse_pos != nil) then
            self.x -= controls.mouse_pos[1] - controls.last_mouse_pos[1]
            self.y -= controls.mouse_pos[2] - controls.last_mouse_pos[2]
        else
            if (controls.left) then 
                self.dx = -100
            elseif (controls.right) then 
                self.dx = 100
            else
                self.dx = 0
            end
            if (controls.up) then 
                self.dy = -100
            elseif (controls.down) then 
                self.dy = 100
            else
                self.dy = 0
            end
        end 
        self.last_mouse_pos = controls.mouse_pos
    end
}):add_position():add_movement(20, 100, 100)

function cam:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end
