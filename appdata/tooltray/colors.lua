--[[pod_format="raw",created="2025-01-11 04:30:58",modified="2025-01-11 04:31:27",revision=2]]
-- colors.lua
local GRID_SIZE=20
local palette={0,20,4,31,15,8,24,2,21,5,22,6,7,23,14,30,1,16,17,12,28,29,13,18,19,3,27,11,26,10,9,25}
function _draw()
    cls(0)
    for i=1,32 do
        local x = ((i-1)%8)*GRID_SIZE
        local y = ((i-1)//8)*GRID_SIZE
        rectfill(x,y,x+GRID_SIZE,y+GRID_SIZE,palette[i])
        print(palette[i],x+3,y+3,7)
        if palette[i] == 7 then print(palette[i],x+3,y+3,0) end
    end
end