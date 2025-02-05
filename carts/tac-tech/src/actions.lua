ActionTree = {
    sid=nil,
    transition=function(self)
    end,
    events={}
}

function ActionTree:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

function ActionTree:traverse_tree(path)
    local val = self
    for item in all(path) do
        val = val[item]
    end
    return val
end

function ActionTree:call_transition(game_state)
    self:traverse_tree(game_state.action_path):transition(game_state)
end

function ActionTree:handle_event(event, game_state)
    local cur_path = self:traverse_tree(game_state.action_path)
    if (cur_path[event.name]) then
        table.insert(game_state.action_path, event.name)
        self:call_transition(game_state)
        event.handled=true
    end
end

local move = ActionTree:new({
    sid=56,
    transition = function(self, game_state)
        game_state.map.show_movement=1
        game_state.map.selection_index=2
        game_state:log_msg("move action tree loaded")
    end,
    events={"tile_selected", "cancel"},
    tile_selected = {
        transition = function(self, game_state)
            game_state:log_msg("tile selected handled by move action")
            game_state.current_action = nil
            game_state.action_path = {'tile_selected'}
        end,
        events={"confirm", "cancel"},
        confirm = {
            transition = function(self, game_state)
                game_state.current_action = nil
                game_state.action_path = {}
                game_state.map:get_selected_tile().unit.move()
            end
        },
        cancel = {
            transition = function(self, game_state)
            end
        }

    },
    cancel = {
        transition = function(self, game_state)
        end
    }
})

local attack = ActionTree:new({
    sid=57,
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
})

local cover = ActionTree:new({
    sid=58,
    transition = function(game_state)
    end,
    events={"confirm"},
    confirm=function(game_state)
        -- tell hud to confirm the selection.
    end
})

ActionTrees = {
    move=move,
    attack=attack,
    cover=cover,
}

