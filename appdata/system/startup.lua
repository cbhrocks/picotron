--[[pod_format="raw",created="2025-01-11 04:31:42",modified="2025-01-11 04:33:18",revision=3]]
-- /appdata/system/startup.lua
-- edit the x and y to place the widget wherever you want; width and height should stay the same as below
create_process("/appdata/tooltray/colors.lua", {
	window_attribs = {
		workspace = "tooltray", 
		x=2, 
		y=36, 
		width=160, 
		height=80
	}
})
