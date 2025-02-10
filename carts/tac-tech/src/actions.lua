ActionTree = {
    sid=nil,
    handle=function(self)
    end,
    events={},
    path={}
}

function ActionTree:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

-- function ActionTree:add_tree(tree, path, event_name)
--     local node = self:traverse_tree(path)
--     node[event_name] = {
--         sid     = tree.sid,
--         events  = tree.events,
--         handle  = tree.handle
--     }
--     table.insert(node.events, event_name)
--     return self
-- end

function ActionTree:traverse_tree(path)
    local path = self.path or path
    local val = self
    for item in all(path) do
        val = val[item]
    end
    return val
end

function ActionTree:handle_event(event, game_state)
    local cur_node = self:traverse_tree(self.path)
    if (cur_node[event.name]) then
        cur_node[event.name].handle(self, event, game_state)
        event.handled=true
    elseif cur_node.ignore_events and find_first(
            cur_node.ignore_events,
            function (item) return item == event.name end
        ) then
        event.handled=true
    end
end

function ActionTree:transition(event)
    if (event) then
        table.insert(self.path, event.name)
    else
        deli(self.path)
    end
end

local move = ActionTree.new{
    display_config = {
        action_display={
            buttons={
                {
                    sid=60,
                    hotkey='2',
                    event={
                        name='cancel'
                    }
                }
            },
        }
    },
    handle = function(self, event, game_state)
        self:transition(event)
        game_state.hud:load_display(self:traverse_tree().display_config)
        game_state.map.show_movement=1
        game_state.map.selection_index=2
        game_state:log_msg("move action tree loaded")
    end,
    events={"tile_selected", "cancel"},
    tile_selected = {
        display_config={
            action_display={
                buttons={
                    {
                        sid=59,
                        hotkey='1',
                        event={
                            name='confirm',
                        }
                    },
                    {
                        sid=60,
                        hotkey='2',
                        event={
                            name='cancel',
                        }
                    }
                }
            }
        },
        handle = function(self, event, game_state)
            self:transition(event)
            local current_node = self:traverse_tree()
            local in_range = false
            for k,v in pairs(game_state.map:get_selected_tile(1).unit.movement_tiles) do
                if game_map.grid[k] == event.selected_tile then
                    in_range = true
                    break
                end
            end
            if in_range then
                current_node.display_config.action_display.buttons[1].disabled=false
            else
                current_node.display_config.action_display.buttons[1].disabled=true
            end
            game_state.hud:load_display(self:traverse_tree().display_config)
        end,
        events={"confirm", "cancel"},
        ignore_events={"tile_clicked"},
        confirm = {
            handle = function(self, event, game_state)
                local unit = game_state.map:get_selected_tile(1).unit
                game_state.map:move_unit(unit, game_state.map:get_selected_tile(2).pos)
                game_state.map.selected[1] = deli(game_state.map.selected)
                game_state.map.show_movement = false
                game_state.map.selection_index = 1
                self.path = {}
                self:traverse_tree().display_config.action_display.buttons[1].disabled = true
                game_state.hud:load_display(self:traverse_tree().display_config)
            end
        },
        cancel = {
            handle = function(self, event, game_state)
                self:transition()
                deli(game_state.map.selected)
                game_state.hud:load_display(self:traverse_tree().display_config)
            end
        }
    },
    cancel = {
        handle = function(self, event, game_state)
            self:transition()
            game_state.map.show_movement = false
            game_state.map.selection_index = 1
            game_state.hud:load_display(self:traverse_tree().display_config)
        end
    }
}

local attack = ActionTree.new{
    sid=57,
    create_button=true,
    transition = function(game_state)
    end,
    events={"select_target", "next_target", "cancel"},
    select_target = {
        transition = function(game_state)
        end
    },
    next_target = {
        transition = function(game_state)
        end
    },
    cancel = {
        transition = function(game_state)
        end
    }
}

local cover = ActionTree.new{
    sid=58,
    create_button=true,
    transition = function(game_state)
    end,
    events={"confirm"},
    confirm=function(game_state)
        -- tell hud to confirm the selection.
    end
}

ActionTrees = {
    move=move,
    attack=attack,
    cover=cover,
}

