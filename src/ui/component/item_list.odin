package component

import rl "vendor:raylib"
import inv "../../core/inventory"
import str "core:strings"
import ui ".."

DrawItemList :: proc(definition: ^inv.Item, style: ^ui.style, width, height: f32, pos: rl.Vector2, mousePos: rl.Vector2, active: bool = false) -> bool {
    itemRect := rl.Rectangle{pos.x, pos.y, width, height}
    padding: f32 = 2
    b := str.Builder{}
    str.builder_init(&b)
    name := str.clone_to_cstring(definition.name, context.temp_allocator)
    textSize := rl.MeasureTextEx(style.fonts.regular[.label], name, f32(ui.font_size.label), 2)
    iconRect := rl.Rectangle{
        x = itemRect.x +  padding * 2,
        y = itemRect.y + textSize.y + padding * 2,
        width = height - (textSize.y + padding * 4),
        height = height - (textSize.y + padding * 4),
    }

    rl.DrawRectangleRec(itemRect, style.colors.surface)
    rl.DrawRectangleRec(iconRect, style.colors.secondary)

    rl.DrawTextEx(style.fonts.regular[.label], name, {itemRect.x + padding * 2, itemRect.y + 2}, f32(ui.font_size.label), 2, style.colors.text)

    if active do rl.DrawRectangleLinesEx(itemRect, padding, style.colors.success)

    if rl.CheckCollisionPointRec(mousePos, itemRect) {
        if !active do rl.DrawRectangleLinesEx(itemRect, padding, style.colors.secondary_hover)

        if rl.IsMouseButtonPressed(.LEFT) do return true
    }


    return false
}