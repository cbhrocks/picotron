--[[pod_format="raw",created="2025-01-13 19:40:16",modified="2025-01-24 18:38:00",revision=1687]]
state = {
    cur_update = nil,
    last_update = time(),
    last_draw = time(),
    camera = cam:new(),
    cur_pal = nil,
    map = game_map,
    units = {},
    projectiles = {},
    particles = {},
    -- contains current state of controls being pressed, moved, pos, etc.
    controls = {},
    log = {""},
    events = {
    },
    settings={
        show_cpu_usage=true,
        show_log=true,
        show_controls=true,
    },
    menus={},
    gui = create_gui()
}

function state:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

function state:update_controls()
    local mouse_x, mouse_y, mouse_b, wheel_x, wheel_y = mouse()
    self.controls.last_mouse_pos = self.controls.mouse_pos
    self.controls.mouse_pos = vec(mouse_x, mouse_y)
    -- mouse release
    self.controls.mouse_r_l = self.controls.mouse_b_l and not (mouse_b & 0b0001) == 1
    self.controls.mouse_r_r = self.controls.mouse_b_r and not (mouse_b & 0b0010) == 2
    self.controls.mouse_r_m = self.controls.mouse_b_m and not (mouse_b & 0b0100) == 4
    -- mouse press
    self.controls.mouse_b_l = (mouse_b & 0b0001) == 1
    self.controls.mouse_b_r = (mouse_b & 0b0010) == 2
    self.controls.mouse_b_m = (mouse_b & 0b0100) == 4
    self.controls.mouse_wheel_x = wheel_x
    self.controls.mouse_wheel_y = wheel_y
    self.controls.up = btn(2) or btn(10)
    self.controls.up_p = btnp(2) or btnp(10)
    self.controls.right = btn(1) or btn(9)
    self.controls.right_p = btnp(1) or btnp(9)
    self.controls.down = btn(3) or btn(11)
    self.controls.down_p = btnp(3) or btnp(11)
    self.controls.left = btn(0) or btn(8)
    self.controls.left_p = btnp(0) or btnp(8)
    self.controls.primary = btn(4)
    self.controls.primary_p = btnp(4)
    self.controls.secondary = btn(5)
    self.controls.secondary_p = btnp(5)
    self.controls.pause = btn(6)
    self.controls.pause_p = btnp(6)
end

function state:log_msg(msg)
    table.insert(self.log, msg)
end

function state.clear_events(self)
    self.events = {}
end

function state.dispatch_event(self, event)
    table.insert(self.events, event)
end

function state.load_pal(self, path)
    -- poke4(get(fetch"/ram/cart/pal/0.pal"))
    self.cur_pal = get(fetch(path))
    printh("pal loaded: "..dump(self.cur_pal))
    poke4(0x5000, self.cur_pal)
end

function state.get_world_pos(self, pos)
    printh("camera ", dump(self.camera))
    return vec(self.camera.x, self.camera.y) + pos
end

function state.get_mouse_world_pos(self)
    return self:get_world_pos(self.controls.mouse_pos)
end

-- function state.load_map(self, file_path)
--     self:log_msg("loading map data from: "..file_path)
--     data = fetch(file_path)
--     if (data == nil) then
--         self:log_msg("Error - Map File "..file_path.." not found")
--         return
--     else
--         self.map_data = data
--     end
--     printh("loaded map with num layers: "..#self.map_data)
--     for layer=1,#self.map_data do
--         local layer_info = self.map_data[layer]
--         printh("loading map layer "..layer..": "..dump(layer_info))
--         local ud = layer_info.bmp
--         -- i and j start at 0 because ud is indexed by 0
--         for i=0,(ud:width()-1) do
--             if (layer == 1) then
--                 self.current_map.locations[i+1] = { }
--             end
--             for j=0,(ud:height()-1) do
--                 --printh(dump(ud:get(i,j,1)))
--                 local sprite_index = ud:get(i,j,1)
--                 -- local sp = get_spr(ud:get(i,j,1))
--                 if (layer == 1) then -- units
--                     -- initialize locations matrix
--                     self.current_map.locations[i+1][j+1] = { }
-- 
--                     if sprite_index != 0 then
--                         local unit = units[sprite_index](layer_info.tile_w*i, layer_info.tile_h*j)
--                         self.current_map.locations[i+1][j+1].unit = unit
--                         table.insert(self.current_map.units, unit)
--                     end
--                 elseif (layer == 2) then -- objects
--                     if sprite_index != 0 then
--                         local object = objects[sprite_index](layer_info.tile_w*i, layer_info.tile_h*j)
--                         self.current_map.locations[i+1][j+1].object = object
--                         table.insert(self.current_map.objects, object)
--                     end
--                 elseif (layer == 3) then -- structure
--                     local structure = structures[sprite_index](layer_info.tile_w*i, layer_info.tile_h*j)
--                     self.current_map.locations[i+1][j+1].structure = structure
--                     table.insert(self.current_map.structure, structure)
--                 end
--             end
--         end
--     end
--     -- printh("map loaded: "..dump(self.current_map))
--     self.camera:move(0, 0)
-- end
