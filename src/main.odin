package main

import rl "vendor:raylib"
import util "utils"

window_width: i32 = 1280
window_height: i32 = 720

primary_color: u32 = 0x334147

main :: proc()
{
    defer rl.CloseWindow()

    primary_color := util.hex_to_col(primary_color)

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(window_width, window_height, "SWIS")
    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    for !rl.WindowShouldClose()
    {
        rl.BeginDrawing()
        rl.ClearBackground(primary_color)
        rl.EndDrawing()
    }
}