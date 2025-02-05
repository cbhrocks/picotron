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
    -- used to determine what should handle mouse state
    mouse_focus=nil,
    log = {""},
    events = {
    },
    settings={
        show_cpu_usage=true,
        show_log=true,
        show_controls=true,
    },
    menus={},
    current_action=nil,
    action_path={},
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
    self.controls.mouse_r_l = not self.controls.mouse_r_l and
        self.controls.mouse_b_l and (mouse_b & 0b0001) != 1
    self.controls.mouse_r_r = not self.controls.mouse_r_l and
        self.controls.mouse_b_r and (mouse_b & 0b0010) != 2
    self.controls.mouse_r_m = not self.controls.mouse_r_l and
        self.controls.mouse_b_m and (mouse_b & 0b0100) != 4
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
    return vec(self.camera.x, self.camera.y) + pos
end

function state.get_mouse_world_pos(self)
    return self:get_world_pos(self.controls.mouse_pos)
end

function state.set_mouse_focus(self, name)
    self.mouse_focus = name
end

function state.load_action_tree(self, action_tree)
    self.current_action = action_tree
    self.action_path = {}
    action_tree:call_transition(self)
end

