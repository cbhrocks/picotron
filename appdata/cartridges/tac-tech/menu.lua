--[[pod_format="raw",created="2025-01-06 22:17:11",modified="2025-01-06 22:26:59",revision=1]]
menuItem = {
    text='update this with new text',
    -- top, left
    padding={2, 2},
    onSelect = function ()
        return
    end
}

function menuItem:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

menu = {
    type = 'menu',
    title = nil,
    backgroundCol = 0,
    highlightCol = 6,
    outlineCol = nil,
    textCol=0,
    -- width, height
    dimensions=nil,
    lineHeight=12,
    -- position
    position={0, 0},
    hover=1,
    -- if no mouse movement and keyboard used, then ignore mouse for selection
    last_mouse_pos=nil,
    -- if menu should register key presses and clicks
    active=true,
    -- color of line seperator
    seperate=false,
    seperateCol=0,

    items = {
        menuItem:new({
            text='update this menu with new items',
            onSelect = function ()
            end
        })
    }
}

function menu:new(o)
    local o = o or {}
    if (o.dimensions == nil) then
        local height = 0
        if (o.title != nil) then
            height += self.lineHeight
        end
        height += #o.items * self.lineHeight
        o.dimensions = {
            100,
            height
        }
    end
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

function menu:draw()
    local y = self.position[1]
    rectfill(self.position[1], self.position[2], self.position[1]+self.dimensions[1], self.position[2]+self.dimensions[2], self.backgroundCol)
    if (self.outlineCol != nil) then
        rect(self.position[1]-1, self.position[2]-1, self.position[1]+self.dimensions[1]+1, self.position[2]+self.dimensions[2]+1, self.outlineCol)
    end
    if (self.title != nil) then
        -- give title 2 pix padding
        y += 2
        print(self.title, self.position[1] + 2, y, self.textCol)
        y += self.lineHeight - 2
        line(self.position[1], y, self.position[1]+self.dimensions[1], y, 0)
        y += 1
    end
    for i=1,#self.items do
        local item = self.items[i]
        if (self.hover == i) then
            rectfill(self.position[1], y, self.position[1]+self.dimensions[1], y+self.lineHeight, self.highlightCol)
        end
        y += item.padding[1]
        print(item.text, self.position[1] + item.padding[2], y, self.textCol)
        y += self.lineHeight - item.padding[1]
        if (self.seperate and i != #self.items) then
            line(self.position[1], y, self.position[1]+self.dimensions[1], y, self.seperateCol)
            y += 1
        end
    end
end

function menu:update(up, down, mouse_pos, select)
    if (
        mouse_pos[1] > self.position[1] and mouse_pos[1] < self.position[1] + self.dimensions[1] and 
        mouse_pos[2] > self.position[2] and mouse_pos[2] < self.position[2] + self.dimensions[2]
    ) then
        if (
            self.last_mouse_pos[1] != mouse_pos[1] or
            self.last_mouse_pos[2] != mouse_pos[2]
        ) then
            local seperator = 0
            if (self.seperator) then
                seperator = 1
            end
            self.hover = flr((mouse_pos[2] - self.position[2]) / (self.lineHeight + seperator))
        end
    end
    if (up) then
        if (self.hover == 1) then
            self.hover = #self.items
        end
        self.hover -= 1
    end
    if (down) then
        if (self.hover == #self.items) then
            self.hover = 1
        end
        self.hover += 1
    end
    self.last_mouse_pos = mouse_pos
    if (select) then
        self.items[self.hover].onSelect()
    end
end
