function fade_init() -- Call once when you want to initiate a fade
    frames = 20 -- Default number of frames for the fade
    fade_col = {0,0,0} -- Default color to fade to
    fade_time = 0
    fade = true
    fadeout = true
    red = {}
    green = {}
    blue = {}
    for i = 1,63 do
        red[i] = peek(0x5002+i*4)
        green[i] = peek(0x5001+i*4)
        blue[i] = peek(0x5000+i*4)
    end
end

function fade_update() -- Call in the update function
    if fade then
        if fadeout then
            fade_time += 1
            if fade_time >= frames then
                fadeout = false
            end
        else
            fade_time -= 1
            if fade_time <= 0 then
                fade_time = 0
                fade = false
                fadeout = true
            end
        end
        for i = 1, 63 do
            poke4(0x5000+i*4,
            (flr(red[i]-(red[i]-fade_col[1])*fade_time/frames) << 16) +
            (flr(green[i]-(green[i]-fade_col[2])*fade_time/frames) << 8) +
            (flr(blue[i]-(blue[i]-fade_col[3])*fade_time/frames) << 0))
        end 	
    end
end
