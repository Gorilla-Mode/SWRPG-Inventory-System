package component

import rl "vendor:raylib"
import ui ".."

ToolTipVec2 :: proc(text: cstring, pos: rl.Vector2, textSize: rl.Vector2, style: ^ui.style, top_align: bool = true) {
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

    if !top_align{
        rect.y -= rect.height / 2
        backGroundRect.y -= backGroundRect.height / 2
    }

    if rl.CheckCollisionPointRec(mousePos, rect) {
        rl.DrawRectangleRec(backGroundRect, style.colors.surface)
        rl.DrawRectangleLinesEx(backGroundRect, 1, style.colors.primary)
        rl.DrawTextEx(style.fonts.regular[.default], text, {rect.x + 5, rect.y + 5}, f32(ui.font_size.default), 0, style.colors.text)
    }
}

ToolTipRect :: proc(text: cstring, hitbox: rl.Rectangle, style: ^ui.style) {
    messageSize := rl.MeasureTextEx(style.fonts.regular[.default], text, f32(ui.font_size.default), 0)
    mousePos := rl.GetMousePosition()
    backGroundRect := rl.Rectangle{
        x = mousePos.x + 2,
        y = mousePos.y + 2,
        width = messageSize.x + 6,
        height = messageSize.y + 6,
    }

    if rl.CheckCollisionPointRec(mousePos, hitbox) {
        rl.DrawRectangleRec(backGroundRect, style.colors.surface)
        rl.DrawRectangleLinesEx(backGroundRect, 1, style.colors.primary)
        rl.DrawTextEx(style.fonts.regular[.default], text, {mousePos.x + 5, mousePos.y + 5}, f32(ui.font_size.default), 0, style.colors.text)
    }
}