-- these tables are used to create entities based on sprites loaded form maps.

function load_ground (x_pos, y_pos) return entity:new():add_position(x_pos, y_pos):add_sprite(1, 16, 16) end
function load_wall (x_pos, y_pos) return entity:new():add_position(x_pos, y_pos):add_sprite(8, 16, 16) end
function load_marine (x_pos, y_pos) return entity:new():add_position(x_pos, y_pos):add_sprite(16, 16, 16) end
function load_mech (x_pos, y_pos) return entity:new():add_position(x_pos, y_pos):add_sprite(24, 16, 16) end
function load_barrel (x_pos, y_pos) return entity:new():add_position(x_pos, y_pos):add_sprite(2, 16, 16) end
function load_crate (x_pos, y_pos) return entity:new():add_position(x_pos, y_pos):add_sprite(3, 16, 16) end

structures = {
    [1] = load_ground,
    [8] = load_wall,
    [9] = load_wall,
    [10] = load_wall,
    [11] = load_wall,
    [12] = load_wall,
}

units = {
    [16] = load_marine,
    [24] = load_mech
}

objects = {
    [2] = load_barrel,
    [3] = load_crate
}
