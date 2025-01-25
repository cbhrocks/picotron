game_map = {
    loaded=false,
    data=nil,
    units={}, -- the units,
    objects={}, -- the obstacles,
    tiles={}, -- the base tiles,
    grid={}, -- stores the data by location in a grid
    selected=nil -- tile selected
}

function game_map.draw(self)
    if (self.loaded != false) then 
        -- draw the base structure for the map
        map(self:get_tile_data().bmp)
    end
    -- draw selected
    if (self.selected != nil) then
        self:draw_selected()
    end
    for unit in all(self.units) do
        unit:draw()
    end
    for object in all(self.objects) do
        object:draw()
    end
end

function game_map.draw_selected(self)
    pos = self.selected * vec(self:get_tile_width(), self:get_tile_height())
    rect(pos.x-1, pos.y-1, pos.x+self:get_tile_width(), pos.y+self:get_tile_height(), 28)
end

function game_map.load(self, file_path)
    -- self:log_msg("loading map data from: "..file_path)
    data = fetch(file_path)
    if (data == nil) then
        return
    else
        self.data = data
    end
    printh("loaded map with num layers: "..#self.data)

    for layer=1,#self.data do
        local layer_info = self.data[layer]
        printh("loading map layer "..layer..": "..dump(layer_info))
        local ud = layer_info.bmp
        -- i and j start at 0 because ud is indexed by 0
        for i=0,(ud:width()-1) do
            if (layer == 1) then
                self.grid[i+1] = { }
            end
            for j=0,(ud:height()-1) do
                --printh(dump(ud:get(i,j,1)))
                local sprite_index = ud:get(i,j,1)
                -- local sp = get_spr(ud:get(i,j,1))
                if (layer == 1) then -- units
                    -- initialize grid matrix
                    self.grid[i+1][j+1] = { }

                    if sprite_index != 0 then
                        local unit = units[sprite_index](layer_info.tile_w*i, layer_info.tile_h*j)
                        self.grid[i+1][j+1].unit = unit
                        table.insert(self.units, unit)
                    end
                elseif (layer == 2) then -- objects
                    if sprite_index != 0 then
                        local object = objects[sprite_index](layer_info.tile_w*i, layer_info.tile_h*j)
                        self.grid[i+1][j+1].object = object
                        table.insert(self.objects, object)
                    end
                elseif (layer == 3) then -- tiles
                    local tile = structures[sprite_index](layer_info.tile_w*i, layer_info.tile_h*j)
                    self.grid[i+1][j+1].tile = tile
                    table.insert(self.tiles, tile)
                end
            end
        end
    end
    self.loaded=true
end

function game_map.get_tile_data(self)
    return self.data[#self.data]
end

function game_map.get_height(self)
    return self:get_tile_data().bmp:height()
end

function game_map.get_width(self)
    return self:get_tile_data().bmp:width()
end

function game_map.get_tile_width(self)
    return self:get_tile_data().tile_w
end

function game_map.get_tile_height(self)
    return self:get_tile_data().tile_h
end

-- returns the tile coordinate based on where the mouse clicks
-- tiles locations start at 0,0, to match the tile locations in the map.
function game_map.get_loc_by_coord(self, pos)
    local tile_w = self:get_tile_width()
    local tile_h = self:get_tile_height()
    return vec(flr(pos.x/tile_w), flr(pos.y/tile_h))
end

function game_map.set_selected_tile(self, pos)
    if (
        pos.x >= 0 and pos.x < self:get_width() and
        pos.y >= 0 and pos.y < self:get_height()
    )  then
        self.selected = pos
    end
end

