package view

import ui "../ui"
import rl "vendor:raylib"
import app "../core/app"

DrawHeader :: proc(style: ^ui.style, state: ^app.State) {
    pos := rl.Vector2{5, 0}
    fontSize := f32(ui.font_size.title)

    rl.DrawTextEx(style.fonts.bold[ui.font_size.title],
    "SWIS",
    pos,
    fontSize,
    0,
    style.colors.text)

    rl.DrawLine(0, i32(pos.y + fontSize + 2), i32(state.window.width), i32(pos.y + fontSize + 2), style.colors.secondary)
}