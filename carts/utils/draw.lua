patterns = {
    highlight = function()
        poke(0x550b,0x3f)
        palt()
        fillp(
            0b11101111,
            0b01111111,
            0b11111011,
            0b11011111,
            0b11111110,
            0b11110111,
            0b10111111,
            0b11111101
        )
    end,
    default = function()
        fillp(
            0b00000000,
            0b00000000,
            0b00000000,
            0b00000000,
            0b00000000,
            0b00000000,
            0b00000000,
            0b00000000
        )
        poke(0x550b,0x00)
        palt()
    end
}

function draw_with_pattern(draw_func, pattern, original)
    patterns[pattern]()
    draw_func()
    patterns[original or "default"]()
end
