package component

import rl "vendor:raylib"
import inv "../../core/inventory"
import str "core:strings"
import ui ".."

DrawItemList :: proc(definition: ^inv.Item, style: ^ui.style, width, height: f32, pos: rl.Vector2, mousePos: rl.Vector2) {
    backGround := rl.Rectangle{pos.x, pos.y, width, height}
    padding: f32 = 2
    b := str.Builder{}
    str.builder_init(&b)
    name := str.clone_to_cstring(definition.name, context.temp_allocator)
    textSize := rl.MeasureTextEx(style.fonts.regular[.label], name, f32(ui.font_size.label), 2)
    iconRect := rl.Rectangle{
        x = backGround.x +  padding * 2,
        y = backGround.y + textSize.y + padding * 2,
        width = height - (textSize.y + padding * 4),
        height = height - (textSize.y + padding * 4),
    }

    rl.DrawRectangleRec(backGround, style.colors.surface)
    rl.DrawRectangleRec(iconRect, style.colors.secondary)

    rl.DrawTextEx(style.fonts.regular[.label], name, {backGround.x + padding * 2, backGround.y + 2}, f32(ui.font_size.label), 2, style.colors.text)

    if rl.CheckCollisionPointRec(mousePos, backGround) {
        rl.DrawRectangleLinesEx(backGround, padding, style.colors.secondary_hover)
    }
}