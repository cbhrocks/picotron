local action = {
    sid=nil,
    action_tree={},
}

function action:new(o)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    -- need to set in constructor so it creates a new table object each time
    return o
end

function action:traverse_tree(path)
    local val = self.action_tree
    for item in all(path) do
        val = val[item]
    end
    return val
end

function action:call_transition(game_state)
    self:traverse_tree(game_state.action_path).transition(game_state)
end

function action:handle_event(event, game_state)
    local cur_path = self:traverse_tree(game_state.action_path)
    if (cur_path[event.name]) then
        table.insert(game_state.action_path, event.name)
        self:call_transition(game_state)
    end
    event.handled=true
end

local move = action:new({
    sid=56,
    action_tree={
        transition = function(game_state)
            game_state.map.show_movement=true
        end,
        events={"tile_selected", "cancel"},
        tile_selected = {
            transition = function(game_state)
                game_state:log_msg("tile selected handled by move action")
            end,
            events={"confirm", "cancel"},
            confirm = {
                transition = function(game_state)
                end
            },
            cancel = {
                transition = function(game_state)
                end
            }

        },
        cancel = {
            transition = function(game_state)
            end
        }
    },
})

local attack = action:new({
    sid=57,
    action_tree={
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
    },
})

local cover = action:new({
    sid=58,
    action_tree={
        transition = function(game_state)
        end,
        events={"confirm"},
        confirm=function(game_state)
            -- tell hud to confirm the selection.
        end
    },
})

Actions = {
    move=move,
    attack=attack,
    cover=cover,
}

