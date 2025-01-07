cam = {
    type = 'camera',
    position={0, 0},
    grabbed=false,
    last_mouse_pos=nil
}

function cam:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

function cam:update(up, down, left, right, mouse_pos, grab)
    if (grab and last_mouse_pos != nil) then
        self.position[1] -= mouse_pos[1] - last_mouse_pos[1]
        self.position[2] -= mouse_pos[2] - last_mouse_pos[2]
    end
    last_mouse_pos = mouse_pos
end
