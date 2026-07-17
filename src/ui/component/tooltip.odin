package component

import rl "vendor:raylib"
import ui ".."

ToolTip :: proc(text: cstring, pos: rl.Vector2, textSize: rl.Vector2, style: ^ui.style) {
    messageSize := rl.MeasureTextEx(style.fonts.regular[.default], text, f32(ui.font_size.default), 0)
    rect := rl.Rectangle{
        x = pos.x,
        y = pos.y,
        width = textSize.x + 10,
        height = textSize.y + 10,
    }
    backGroundRect := rl.Rectangle{
        x = pos.x + 2,
        y = pos.y + 2,
        width = messageSize.x + 6,
        height = messageSize.y + 6,
    }
    mousePos := rl.GetMousePosition()

    if rl.CheckCollisionPointRec(mousePos, rect) {
        rl.DrawRectangleRec(backGroundRect, style.colors.surface)
        rl.DrawRectangleLinesEx(backGroundRect, 1, style.colors.primary)
        rl.DrawTextEx(style.fonts.regular[.default], text, {rect.x + 5, rect.y + 5}, f32(ui.font_size.default), 0, style.colors.text)
    }
}