--[[pod_format="raw",created="2025-01-27 21:34:47",modified="2025-01-27 21:34:47",revision=0]]
game_map = {
    loaded=false,
    -- the selected index to use when showing movement
    show_movement=0,
    -- selection_index
    selection_index=1,
    data=nil,
    units={}, -- the units,
    objects={}, -- the obstacles,
    tiles={}, -- the base tiles,
    grid={}, -- stores the data by location in a grid
    selected={}, -- index of selected tiles, last is latest
    hovered=nil, -- index with mouse hovered over
    current_action=nil,
    turn_order={"player", "enemy"},
    current_turn={
        owner="",
        units={}
    }
}

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

-- returns the grid coordinate vector based on world coord vector  passed in
-- grid coords start at 0,0, to match the tile locations in the map.
function game_map.get_grid_vec(self, pos)
    local tile_w = self:get_tile_width()
    local tile_h = self:get_tile_height()
    return vec(pos.x\tile_w, pos.y\tile_h)
end

function game_map.validate_grid_vec(self, pos)
    return pos.x >= 0 and pos.x < self:get_width() and
        pos.y >= 0 and pos.y < self:get_height()
end

-- set the hovered index using a grid coordinate vector
function game_map.set_hovered_vec(self, pos)
    if (self:validate_grid_vec(pos))  then
        self.hovered = self:vec_to_index(pos)
        return self.hovered
    end
    return nil
end

function game_map.add_selected_vec(self, pos)
    if (self:validate_grid_vec(pos))  then
        table.insert(self.selected, self:vec_to_index(pos))
    end
end

function game_map.set_selected_vecs(self, positions)
    local selected_tiles = {}
    for pos in all(positions) do
        if (not self:validate_grid_vec(pos))  then
            return nil
        end
        table.insert(selected_tiles, self:vec_to_index(pos))
    end
    self.selected = selected_tiles
end

function game_map.get_selected_tile(self, index)
    local grid_index = self.selected[index]
    return self.grid[grid_index]
end

function game_map.get_selected_tiles(self)
    local selected_tiles = {}
    for i=1,#self.selected do
        local grid_index = self.selected[index]
        selected_tiles[i] = self.grid[grid_index]
    end
    return selected_tiles
end

function game_map.select_hovered_tile(self)
    if (self.hovered != nil) then
        self.selected[self.selection_index] = self.hovered
        dispatch_event({
            name="tile_selected",
            selected_tile = self.grid[self.hovered]
        })
    else
        printh("WARNING: nil tile selected from hover")
    end
end

-- returns the world coordinate based on grid coord passed in
function game_map.get_world_vec(self, pos)
    local tile_w = self:get_tile_width()
    local tile_h = self:get_tile_height()
    return vec(pos.x * tile_w, pos.y * tile_h)
end

function game_map.get_adjacent_indices(self, index)
    return {
        index-self:get_width(),
        index-1,
        index+1,
        index+self:get_width()
    }
end

function game_map.handle_controls(self, game_state)
    if (game_state.mouse_focus == 'map') then
        if (game_state.controls.mouse_pos ~= game_state.controls.last_mouse_pos) then
            local tile_hovered = self:get_grid_vec(game_state:get_mouse_world_pos())
            self:set_hovered_vec(tile_hovered)
        end
        if (game_state.controls.mouse_b_l) then
            self.tile_mouse_down = self:get_grid_vec(game_state:get_mouse_world_pos())
        end
    end
    if (game_state.controls.mouse_r_l) then
        if (game_state.mouse_focus == 'map') then
            local tile_mouse_up = self:get_grid_vec(game_state:get_mouse_world_pos())
            -- if the tile released is the same pressed, count as a select
            if (vec_eq(self.tile_mouse_down, tile_mouse_up)) then
                game_state:dispatch_event({name="tile_clicked"})
            end
        end
        self.tile_mouse_down = nil
    end
end

-- moves a unit to a given location on the grid
-- @param unit {entity} An unit entity that is currently on the board.
-- @param pos {vec} A vector representing x,y grid coordinates to move the unit to.
function game_map:move_unit(unit, pos)
    local start_pos_i = self:vec_to_index(self:get_grid_vec(unit.pos))
    local end_pos_i = self:vec_to_index(pos)
    self.grid[end_pos_i].unit = unit
    self.grid[start_pos_i].unit = nil
    unit.pos = self:get_world_vec(pos)
end

local unit_owner_mask = {
    [1] = "player",
    [2] = "enemy",
    [3] = "ally"
}

function game_map.draw(self)
    if (self.loaded != false) then 
        -- draw the base structure for the map
        map(self:get_tile_data().bmp)
    end
    if self.show_movement then
        self:draw_movement(self.show_movement)
    end
    self:draw_selected()
    self:draw_hovered()
    for unit in all(self.units) do
        unit:draw()
    end
    for object in all(self.objects) do
        object:draw()
    end
end

-- pos: vector with x & y representing indices in grid table
-- col: color to highlight grid square
function game_map.draw_highlight_loc(self, pos, col)
    local world_pos = self:get_world_vec(pos)
    rect(world_pos.x, world_pos.y, world_pos.x+self:get_tile_width()-1, world_pos.y+self:get_tile_height()-1, col)
    -- set black to transparent for shapes
    draw_with_pattern(
        function()
            rectfill(world_pos.x, world_pos.y, world_pos.x+self:get_tile_width()-1, world_pos.y+self:get_tile_height()-1, col)
        end,
        "highlight"
    )
end

function game_map.vec_to_index(self, vec)
    return vec.y * self:get_width() + vec.x + 1
end

-- takes an index for grid and converts it to vector coordinates
function game_map.index_to_vec(self, index)
    local vec = vec(index%self:get_width()-1, flr(index/self:get_width()))
    return vec
end

function game_map.draw_hovered(self)
    if (self.hovered != nil) then
        self:draw_highlight_loc(self:index_to_vec(self.hovered), 6)
    end
end

function game_map.draw_selected(self)
    for selected_tile in all(self.selected) do
        self:draw_highlight_loc(self:index_to_vec(selected_tile), 12)
    end
end

-- draw the movement highlights for the selected unit
-- this will draw blue boxes for locations that can be moved to in standard movement, and 
-- orange boxes for locations that require 2 moves.
-- s_index determines what selected tile to draw from
function game_map.draw_movement(self, s_index)
    local tile = self:get_selected_tile(s_index)
    if (tile != nil and tile.unit != nil) then
        local move_distance = tile.unit:get_move_distance()
        local display_distance = tile.unit.remaining_moves * move_distance + tile.unit.remaining_actions * move_distance
        if tile.unit.movement_tiles == nil then
            tile.unit.movement_tiles = self:get_tiles_by_distance(self.selected[s_index], display_distance)
        end
        for k,v in pairs(tile.unit.movement_tiles) do
            if v <= move_distance then
                self:draw_highlight_loc(self:index_to_vec(k), tile.unit.remaining_moves > 0 and 28 or 9)
            else
                self:draw_highlight_loc(self:index_to_vec(k), 9)
            end
        end
    end
end

function game_map.load(self, file_path)
    -- self:log_msg("loading map data from: "..file_path)
    local data = fetch(file_path)
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
            for j=0,(ud:height()-1) do
                local sprite_index = ud:get(i,j,1)
                local grid_index = j*ud:width()+i+1
                local grid_vec = self:index_to_vec(grid_index)
                if self.grid[grid_index] == nil then 
                    self.grid[grid_index] = {
                        pos=grid_vec
                    }
                end
                local world_pos = self:get_world_vec(grid_vec)
                if (layer == 1 or layer == 2) then -- units
                    if sprite_index != 0 then
                        -- local flag = fget(sprite_index) dont need flags for this.
                        printh("loading sprite: "..sprite_index)
                        local unit = units[sprite_index](world_pos, layer == 1 and "player" or "enemy")
                        self.grid[grid_index].unit = unit
                        table.insert(self.units, unit)
                    end
                elseif (layer == 3) then -- objects
                    if sprite_index != 0 then
                        local object = objects[sprite_index](world_pos)
                        self.grid[grid_index].object = object
                        table.insert(self.objects, object)
                    end
                elseif (layer == 4) then -- tiles
                    local tile = structures[sprite_index](world_pos)
                    self.grid[grid_index].tile = tile
                    table.insert(self.tiles, tile)
                end
            end
        end
    end
    self.loaded=true
    self:next_turn()
end

-- get a table of grid indices to number values where all the indices are within a certain distance from a starting
-- index location based on 
function game_map.get_tiles_by_distance(self, index, distance)
    local visited = {[index]=0}
    local last_visit = {[index]=0}
     -- cant move anymore, return all the visited tiles as they are possible.
    local current_visit = {}
    -- for every visited location, find its neighbors and check if their location has been visited yet. if not, add to table with
    -- unique key based on location indices.
    for d=1,distance do
        -- using last visit locations, start looking at new places to visit. ignore already visited locations
        for k,v in pairs(last_visit) do
            -- only if the tile is traversable
            if v then
                for next_pos in all(self:get_adjacent_indices(k)) do
                    -- if hasn't been visited yet add position to the to visit table. using key prevents duplicate to visit locations
                    if (
                        not visited[next_pos] and
                        self.grid[next_pos] != nil and
                        self.grid[next_pos].tile.traversable and
                        self.grid[next_pos].unit == nil and
                        self.grid[next_pos].object == nil
                    ) then
                        -- set to true if tile is traversable and theres no unit or object on it
                        current_visit[next_pos] = d
                    end
                end
            end
        end
        last_visit = current_visit
        current_visit = {}
        -- add all locations from the last visit to the visited table using unique keys
        for k,v in pairs(last_visit) do
            visited[k] = v
        end
    end
    return visited
end

function game_map.next_turn(self)
    local next_turn = {
        owner="player",
        units={},
    }
    for i=1,#self.turn_order do
        if (self.turn_order[i] == self.current_turn.owner) then next_turn.owner = self.turn_order[i] or self.turn_order[1] end
    end
    for unit in all(self.units) do
        if (unit.owner == self.current_turn.owner) then
            table.insert(next_turn.units, unit)
            unit:refresh_turn()
        end
    end
    self.current_turn = next_turn
end

function game_map.end_turn(self)
    self:next_turn()
end

