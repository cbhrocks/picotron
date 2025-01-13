--[[pod_format="raw",created="2025-01-11 06:57:49",modified="2025-01-12 15:06:31",revision=26]]
cam = entity:new({
    grabbed=false,
    last_mouse_pos=nil,
    handle_controls = function(self, time_elapsed, controls)
    	if (self.grab and last_mouse_pos != nil) then
			self.x -= controls.mouse_pos[1] - last_mouse_pos[1]
			self.y -= controls.mouse_pos[2] - last_mouse_pos[2]
		else
			if (controls.left) then 
				self.dx = -25
			elseif (controls.right) then 
				self.dx = 25
			else
				self.dx = 0
			end
			if (controls.up) then 
				self.dy = -25
			elseif (controls.down) then 
				self.dy = 25
			else
				self.dy = 0
			end
		end 
		last_mouse_pos = mouse_pos
    end
})

add_position(cam)
add_movement(cam, 50, 40, 40)

function cam:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end
