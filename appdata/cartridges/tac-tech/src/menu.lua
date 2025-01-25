--[[pod_format="raw",created="2025-01-09 16:03:03",modified="2025-01-18 05:03:48",revision=1925]]
local itemHeight = 14

local function traverse_path(menu_tree, path)
    local val = menu_tree
    for item in all(path) do
        val = val[item]
    end
    return val
end

-- attaches a menu gui object to the specified root element. 


--[[ a map of all the menus. Every instance should have a type of either
    - menu
    - function
    menu must have a list of item names, and an entry that corresponds to each of those
    function must have a call entry, which executes when selected
]]--

function create_menu(tree, path, toggle_check, on_select)
    local path = path or {}
    
    local menu_container = game_state.gui:attach{
        x=wWidth/2-50, y=wHeight/2,
        width=100, height=0, -- start at 0 then increase as built.
        hover=1, tree=tree, path=path or {},
        update=function(self)
            local cur_loc = traverse_path(self.tree, self.path)
            if (game_state.controls.down_p) then
                self.hover = self.hover < #cur_loc.items and self.hover+1 or 1
            end
            if (game_state.controls.up_p) then
                self.hover = self.hover > 1 and self.hover-1 or #cur_loc.items
            end
            if (game_state.controls.primary_p) then
                self:select_item(cur_loc.items[self.hover])
            end
        end
    }
    
    menu_container.set_path=function(self, path)
        if (path != self.path) then
            self.path = path
            self.hover = 1
            self:build_menu()
        end
    end
    
    menu_container.select_item=function(self, key)
        local cur_loc = traverse_path(self.tree, self.path)
        local type = cur_loc[key].type
        if (self.on_select != nil) then
            self.on_select(key)
        end
        if (type == "menu") then
            self.path[#self.path+1] = key
            self.hover = 1
            self:build_menu()
        elseif (type == "function") then
            cur_loc[key].call(self)
        elseif (type == "toggle") then
            cur_loc[key].call(self)
        end
    end
    
    function menu_container.build_menu(self)
        remove_all_children(self)
        self.height = 0
        self.y = wHeight/2

        local cur_loc = traverse_path(self.tree, self.path)
        local title = self:attach{
            x=0, y=0,
            width=self.width, height=itemHeight,
            draw=function(title)
                bgFill(title, 15)
                print(self.path[#path] or "Main Menu", 2, 2, 1)
            end
        }
        self.y -= title.height/2
        self.height += title.height     

        for i=1,#cur_loc.items do
            local item = cur_loc[cur_loc.items[i]]
            if (item.type == "toggle") then
                self:attach{
                    x=0, y=itemHeight*i-i,
                    width=self.width, height=itemHeight,
                    clicked=false,
                    draw=function(mi)
                        bgFill(mi, mi.clicked and 5 or (self.hover==i and 22) or 7)
                        border(mi)
                        print(cur_loc.items[i], 3, 3, 1)
                        rect(mi.width-11, 2, mi.width-3, mi.height-3, 5)
                        if (item.is_checked()) then
                            rectfill(mi.width-9, 4, mi.width-5, mi.height-5, 5)
                        end
                    end,
                    click=function(mi) mi.clicked=true end,
                    release=function(mi) mi.clicked=false end,
                    tap=function(mi)
                        self:select_item(cur_loc.items[i])
                    end
                }
            else -- menu and func
                self:attach{
                    x=0, y=itemHeight*i-i,
                    width=self.width, height=itemHeight,
                    clicked=false,
                    draw=function(mi)
                        bgFill(mi, mi.clicked and 5 or (self.hover==i and 22) or 7)
                        border(mi)
                        print(cur_loc.items[i], 3, 3, 1)
                    end,
                    click=function(mi) mi.clicked=true end,
                    release=function(mi) mi.clicked=false end,
                    tap=function(mi)
                        printh("item clicked")
                        self:select_item(cur_loc.items[i])
                    end
                }
            end
            self.height += itemHeight
            self.y -= itemHeight/2
        end
    end
    
    menu_container:build_menu()
    
    return menu_container
end


