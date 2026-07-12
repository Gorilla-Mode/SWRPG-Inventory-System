package component

import rl "vendor:raylib"
import inv "../../core/inventory"
import str "core:strings"
import ui ".."
import fmt "core:fmt"

DrawItemList :: proc(definition: ^inv.Item, style: ^ui.style, width, height: f32, pos: rl.Vector2, mousePos: rl.Vector2, icon: rl.Texture2D, active: bool = false) -> bool {
    itemRect := rl.Rectangle{pos.x, pos.y, width, height}
    padding: f32 = 2
    iconScale := ui.IconScale(height - padding * 2)
    iconRect := rl.Rectangle{
        x = itemRect.x +  padding,
        y = itemRect.y + padding,
        width = height - padding * 2,
        height = height - padding * 2,
    }

    name := str.clone_to_cstring(definition.name, context.temp_allocator)
    price:= str.clone_to_cstring(fmt.tprint(definition.base_price), context.temp_allocator)
    rarity := str.clone_to_cstring(fmt.tprint(definition.base_rarity), context.temp_allocator)

    infoTextSize := rl.MeasureTextEx(style.fonts.regular[.label], price, f32(ui.font_size.label), 2)
    priceIconScale := ui.IconScale(infoTextSize.y)

    textPos := rl.Vector2{itemRect.x + padding * 2 + iconRect.width, itemRect.y + padding}
    infoPos := rl.Vector2{itemRect.x + itemRect.width - infoTextSize.x - padding * 2, itemRect.y + padding}

    rl.DrawRectangleRec(itemRect, style.colors.surface)

    rl.DrawRectangleRec(iconRect, style.colors.secondary)
    rl.DrawTextureEx(icon, rl.Vector2{iconRect.x, iconRect.y}, 0, iconScale, style.colors.text)

    rl.DrawTextEx(style.fonts.regular[.label], name, textPos, f32(ui.font_size.label), 2, style.colors.text)
    rl.DrawTextEx(style.fonts.regular[.label], price, infoPos, f32(ui.font_size.label), 2, style.colors.text)
    rl.DrawTextureEx(style.icons[.economy_credit], {infoPos.x - padding - infoTextSize.y, infoPos.y}, 0, priceIconScale, style.colors.text)
    rl.DrawTextEx(style.fonts.regular[.label], rarity, {infoPos.x, infoPos.y + padding + infoTextSize.y}, f32(ui.font_size.label), 2, style.colors.text)
    rl.DrawTextureEx(style.icons[.economy_rarity], {infoPos.x - padding - infoTextSize.y, infoPos.y + padding + infoTextSize.y}, 0, priceIconScale, style.colors.text)

    if active do rl.DrawRectangleLinesEx(itemRect, padding, style.colors.success)

    if rl.CheckCollisionPointRec(mousePos, itemRect) {
        if !active do rl.DrawRectangleLinesEx(itemRect, padding, style.colors.secondary_hover)

        if rl.IsMouseButtonPressed(.LEFT) do return true
    }

    return false
}