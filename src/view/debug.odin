package view

import rl "vendor:raylib"
import app "../core/app"
import ui "../ui"

DrawDebug :: proc(state: ^app.State, style: ^ui.style) {
    if rl.IsKeyDown(rl.KeyboardKey.C){
        ui.DrawPalette(style.colors, offset_y = 34)
    }
}