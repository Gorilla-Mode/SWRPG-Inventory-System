package component

import rl "vendor:raylib"
import inv "../../core/inventory"
import str "core:strings"
import ui ".."
import fmt "core:fmt"

DrawItemList :: proc(definition: ^inv.Item, style: ^ui.style, width, height: f32, pos: rl.Vector2, mousePos: rl.Vector2, icon: rl.Texture2D, active: bool = false) -> bool {
    itemRect := rl.Rectangle{pos.x, pos.y, width, height}
    padding: f32 = 2
    fontSize := f32(ui.font_size.label)
    font := style.fonts.regular[.label]

    iconScale := ui.IconScale(height - padding * 2)
    iconRect := rl.Rectangle{
        x = itemRect.x +  padding,
        y = itemRect.y + padding,
        width = height - padding * 2,
        height = height - padding * 2,
    }

    name := str.clone_to_cstring(definition.name, context.temp_allocator)
    price:= str.clone_to_cstring(fmt.tprint(definition.base_price), context.temp_allocator)
    rarity := str.clone_to_cstring(fmt.tprint(args = {definition.base_rarity}, sep = ""), context.temp_allocator)
    seperator: cstring = "//"

    infoTextSize := rl.MeasureTextEx(font, price, fontSize, 2)
    rarityTextSize := rl.MeasureTextEx(font, rarity, fontSize, 2)
    seperatorTextSize := rl.MeasureTextEx(font, seperator, fontSize, 2)
    nameTextSize := rl.MeasureTextEx(font, name, fontSize, 2)
    seperatorCol := rl.Color{style.colors.text.r, style.colors.text.g, style.colors.text.b, 64}
    priceIconScale := ui.IconScale(infoTextSize.y)

    textPos := rl.Vector2{itemRect.x + padding * 2 + iconRect.width, itemRect.y + padding}
    infoPos := rl.Vector2{itemRect.x + itemRect.width - infoTextSize.x - padding * 2, itemRect.y + padding}
    rarityPos := rl.Vector2{infoPos.x - infoTextSize.y - rarityTextSize.x - seperatorTextSize.x - padding * 4, infoPos.y}

    rl.DrawRectangleRec(itemRect, style.colors.surface)

    rl.DrawRectangleRec(iconRect, style.colors.secondary)
    rl.DrawTextureEx(icon, rl.Vector2{iconRect.x, iconRect.y}, 0, iconScale, style.colors.text)

    rl.DrawTextEx(font, name, textPos, fontSize, 2, style.colors.text)
    rl.DrawTextEx(font, price, infoPos, fontSize, 2, style.colors.text)
    rl.DrawTextureEx(style.icons[.economy_credit], {infoPos.x - padding - infoTextSize.y, infoPos.y}, 0, priceIconScale, style.colors.text)
    rl.DrawTextEx(font, seperator, {infoPos.x - seperatorTextSize.x - infoTextSize.y - padding * 2, infoPos.y}, fontSize, 2, seperatorCol)
    rl.DrawTextEx(font, rarity, {rarityPos.x, infoPos.y}, fontSize, 2, style.colors.text)
    rl.DrawTextureEx(style.icons[.economy_rarity], {rarityPos.x - padding - rarityTextSize.y, rarityPos.y}, 0, priceIconScale, style.colors.text)

    if definition.restricted do rl.DrawTextureEx(style.icons[.economy_restricted], {textPos.x + nameTextSize.x + padding, textPos.y}, 0, priceIconScale, style.colors.error)

    if active do rl.DrawRectangleLinesEx(itemRect, padding, style.colors.success)


    if rl.CheckCollisionPointRec(mousePos, itemRect) {
        if !active do rl.DrawRectangleLinesEx(itemRect, padding, style.colors.secondary_hover)

        if rl.IsMouseButtonPressed(.LEFT) do return true
    }

    return false
}