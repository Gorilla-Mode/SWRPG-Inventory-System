package view

import rl "vendor:raylib"
import st "../core/state"
import ui "../ui"

DrawDebug :: proc(state: ^st.State, style: ^ui.style) {
    if rl.IsKeyDown(rl.KeyboardKey.C){
        ui.DrawPalette(style.colors, offset_y = 34)
    }
}