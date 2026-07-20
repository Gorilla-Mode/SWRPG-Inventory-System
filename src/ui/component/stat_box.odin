package component

import rl "vendor:raylib"
import ui ".."

DrawStatBox :: proc(pos: rl.Vector2, style: ^ui.style, size: f32, font: rl.Font, title, count: cstring, debug: bool = false) -> rl.Rectangle{
    bounds := rl.Rectangle{pos.x, pos.y, size, size}
    padding: f32 = 2
    countSize := rl.MeasureTextEx(font, count, f32(font.baseSize), 0)
    countPos := ui.SnapVector2( {pos.x + (size - countSize.x) / 2, pos.y + (size - countSize.y) / 2})

    rl.DrawRectangleLinesEx(bounds, padding, style.colors.primary)
    rl.DrawTextEx(style.fonts.regular[.label], title, rl.Vector2{pos.x + padding * 2, pos.y + padding}, f32(ui.font_size.label), 0, style.colors.text)
    rl.DrawTextEx(font, count, countPos, f32(font.baseSize), 0, style.colors.text)

    if debug do rl.DrawRectangleRec(bounds, rl.Color{255, 0, 0, 64})
    return bounds
}