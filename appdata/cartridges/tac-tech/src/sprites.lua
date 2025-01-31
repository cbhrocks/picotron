local marine_names = {"Tyler", "Paul", "Randal", "Jason", "Henry", "Luke", "Ron", "Charlie", "Rodjer", "Marco"}


local function use_name()
    -- local index = rnd(#marine_names)
    -- printh('marine name index: '..index)
    --local name = marine_names[index]
    -- deli(marine_names, index)
    return rnd(marine_names)
end

-- these tables are used to create entities based on sprites loaded form maps.

function load_ground (x_pos, y_pos)
    return entity:new({
        type="structure",
        name="ground",
    })
    :add_position(x_pos, y_pos)
    :add_sprite(1, 16, 16)
    :add_terrain()
end

function load_wall (x_pos, y_pos)
    return entity:new({
        type="structure",
        name="wall"})
        :add_position(x_pos, y_pos)
        :add_sprite(8, 16, 16) 
end

function load_marine(x_pos, y_pos, owner) return
    entity:new({
        type="unit",
        name=use_name(),
        owner=owner or "neutral"
    })
    :add_stats()
    :add_position(x_pos, y_pos)
    :add_sprite(16, 16, 16)
end

function load_mech(x_pos, y_pos, owner) return
    entity:new({
        type="unit",
        name="Mech",
        owner=owner or "neutral"
    })
    :add_stats()
    :add_position(x_pos, y_pos)
    :add_sprite(24, 16, 16)
end

function load_barrel (x_pos, y_pos) return
    entity:new({
        type="object",
        name="barrel"
    })
    :add_position(x_pos, y_pos)
    :add_sprite(2, 16, 16)
end

function load_crate (x_pos, y_pos) return
    entity:new({
        type="object",
        name="crate"
    })
    :add_position(x_pos, y_pos)
    :add_sprite(3, 16, 16)
end

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
