package component

import rl "vendor:raylib"
import ui "../../ui"
import inv "../../core/inventory"
import str "core:strings"

DrawItemCard :: proc(
    item: ^inv.ItemInstance,
    x, y: f32,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style,
    strReg: ^inv.ItemCstringRegistry
) {
    offset: f32 = 5
    posX:= x * cell_size + origin_x + offset
    posY:= y * cell_size + origin_y + offset
    height: f32 = 450
    width: f32 = 300
    padding: f32 = 2
    margin_left: f32 = 5
    section_padding: f32 = 15
    header := style.fonts.bold[ui.font_size.header]
    headerSize := f32(ui.font_size.header)
    regular := style.fonts.regular[ui.font_size.default]
    regularSize := f32(ui.font_size.default)
    defID := item.definition.id
    itemStrings := strReg.items[defID]
    dataStr := inv.GetItemDataString(item.definition)
    descriptionSize := rl.MeasureTextEx(regular, itemStrings.description, regularSize, 0)

    rect := rl.Rectangle{x = posX, y =  posY, width = width, height = height}
    rl.DrawRectangleRounded(rect, 0.1, 32, style.colors.surface)
    rl.DrawRectangleRoundedLines(rect, 0.1, 32, style.colors.primary)
    rl.DrawLine(i32(posX), i32(posY + headerSize) + i32(padding), i32(posX + width), i32(posY + headerSize) + i32(padding), style.colors.secondary)

    rl.DrawTextEx(header, itemStrings.name, ui.SnapVector2({posX + margin_left, posY + padding}), headerSize, 0, style.colors.text)
    rl.DrawTextEx(regular, itemStrings.description, ui.SnapVector2({posX + margin_left, posY + headerSize + section_padding}), regularSize, 0, style.colors.text)
    rl.DrawTextEx(regular, itemStrings.base_rarity, ui.SnapVector2({posX + margin_left, posY + headerSize + descriptionSize.y + section_padding * 2}), regularSize, 0, style.colors.text)
    rl.DrawTextEx(regular, itemStrings.base_price, ui.SnapVector2({posX + margin_left, posY + headerSize + descriptionSize.y + regularSize + section_padding * 2}), regularSize, 0, style.colors.text)
    rl.DrawTextEx(regular, itemStrings.restricted, ui.SnapVector2({posX + margin_left, posY + headerSize + descriptionSize.y + regularSize * 2 + section_padding * 2}), regularSize, 0, style.colors.text)
    rl.DrawTextEx(regular, str.clone_to_cstring(dataStr), ui.SnapVector2({posX + margin_left, posY + headerSize + descriptionSize.y + regularSize * 3 + section_padding * 3}), regularSize, 0, style.colors.text)
}