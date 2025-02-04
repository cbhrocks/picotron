--[[pod_format="raw",created="2025-01-08 17:33:11",modified="2025-01-18 05:03:48",revision=3036]]
wWidth = get_display():width()
wHeight = get_display():height()

function remove_all_children(el)
    for child in all(el.child) do
        el:detach(child)
    end
end

function bgFill(self, col)
    rectfill(0, 0, self.width, self.height, col or 6)
end

function border(self, col)
    rect(0, 0, self.width-1, self.height-1, col or 5)
end
