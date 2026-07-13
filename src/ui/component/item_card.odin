package component

import rl "vendor:raylib"
import ui "../../ui"
import str "core:strings"
import inv "../../core/inventory"

DrawItemCard :: proc(
    item: ^inv.ItemInstance,
    x, y: f32,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style
) {
    offset: f32 = 5
    posX:= x * cell_size + origin_x + offset
    posY:= y * cell_size + origin_y + offset
    height: f32 = 450
    width: f32 = 300
    header := style.fonts.bold[ui.font_size.header]
    headerSize := f32(ui.font_size.header)
    regular := style.fonts.regular[ui.font_size.default]
    regularSize := f32(ui.font_size.default)

    b: str.Builder
    str.builder_init(&b, context.temp_allocator)

    str.write_string(&b, item.definition.description)
    str.write_string(&b, "\n\n")


    str.write_string(&b, inv.GetItemDataString(item.definition))

    if len(item.definition.qualities) > 0 {
        str.write_string(&b, "Qualities: ")
        for quality in item.definition.qualities {

            str.write_string(&b, quality)
            if quality != item.definition.qualities[len(item.definition.qualities) - 1] {
                str.write_string(&b, ", ")
            }
        }
        str.write_string(&b, "\n")
    }

    if len(item.definition.features) > 0 {
        str.write_string(&b, "Features: ")
        for feature in item.definition.features {

            str.write_string(&b, feature)
            if feature != item.definition.features[len(item.definition.features) - 1] {
                str.write_string(&b, ", ")
            }
        }
        str.write_string(&b, "\n")
    }
    str.write_string(&b, "\n")

    str.write_string(&b, "Base rarity: ")
    str.write_int(&b, int(item.definition.base_rarity))
    str.write_string(&b, "\n")

    str.write_string(&b, "Base price: ")
    str.write_int(&b, int(item.definition.base_price))
    str.write_string(&b, "\n")


    s := str.to_string(b)

    rect := rl.Rectangle{x = posX, y =  posY, width = width, height = height}
    rl.DrawRectangleRounded(rect, 0.1, 32, style.colors.surface)
    rl.DrawRectangleRoundedLines(rect, 0.1, 32, style.colors.primary)
    rl.DrawLine(i32(posX), i32(posY + headerSize) + 10, i32(posX + width), i32(posY + headerSize) + 10, style.colors.secondary)

    rl.DrawTextEx(header, str.clone_to_cstring(item.definition.name, context.temp_allocator), ui.SnapVector2({posX + 5, posY + 5}), headerSize, 0, style.colors.text)
    rl.DrawTextEx(regular, str.clone_to_cstring(s, context.temp_allocator), ui.SnapVector2({posX + 5, posY + headerSize + 15}), regularSize, 0, style.colors.text)
}