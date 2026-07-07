package inventory

import rl "vendor:raylib"
import ui "../../ui"
import str "core:strings"

DrawContainerGrid :: proc(
    item: ^Item,
    container_item: ^ItemInstance,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style
) {
    container_def, ok := item.data.(ContainerData)
    if !ok {
        return
    }

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header], str.clone_to_cstring(item.name, context.temp_allocator), ui.SnapVector2(rl.Vector2{origin_x, origin_y - 25}), f32(ui.font_size.header), 2, style.colors.text)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.caption], str.clone_to_cstring(ContainerSubCategoryString(container_def.sub_category), context.temp_allocator), ui.SnapVector2(rl.Vector2{origin_x, origin_y - 34}), f32(ui.font_size.caption), 2, style.colors.text)
    #partial switch storage in container_def.storage.storage {
    case ContainerGrid:
        for y in 0..<storage.height {
            for x in 0..<storage.width {

                px := origin_x + f32(x) * cell_size
                py := origin_y + f32(y) * cell_size

                rl.DrawRectangleLines(
                i32(px),
                i32(py),
                i32(cell_size),
                i32(cell_size),
                style.colors.primary,
                )
            }
        }

        container_items, items_ok := container_item.data.(ContainerInstanceData)
        if !items_ok {
            return
        }

        for item in container_items.items {
            DrawItem(item, origin_x, origin_y, cell_size, style)
        }
    }
}

DrawItem :: proc(
    item: ^ItemInstance,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style,
    static: bool = false
) {
    width : = f32(item.definition.width)
    height := f32(item.definition.height)

    rot: f32 = 0
    textVec: rl.Vector2
    bgColor := style.colors.primary
    textColor := style.colors.text
    outlineColor := style.colors.surface
    x:= origin_x
    y:= origin_y
    textVec = rl.Vector2{
        x + 5,
        y + 5,
    }

    if !static{
        x = origin_x + f32(item.pos_x) * cell_size
        y = origin_y + f32(item.pos_y) * cell_size
        width = f32(ItemGetWidth(item))
        height = f32(ItemGetHeight(item))


        switch item.rotated {
        case true:
            rot = 90
            textVec = rl.Vector2{
                x + width * cell_size - 5,
                y + 5,
            }
        case false:
            rot = 0
            textVec = rl.Vector2{
                x + 5,
                y + 5,
            }
        }

        if item.grabbed {
            bgColor.a = 128
            textColor.a = 128
            outlineColor.a = 128
        }
    }

    rl.DrawRectangle(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    bgColor,
    )

    rl.DrawTextPro(
        style.fonts.regular[ui.font_size.default],
        str.clone_to_cstring(item.definition.name, context.temp_allocator),
        ui.SnapVector2(textVec),
        rl.Vector2{0, 0},
        rot,
        f32(ui.font_size.default),
        1,
        textColor,
    )

    rl.DrawRectangleLines(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    outlineColor,
    )
}

DrawItemGhost :: proc(
    item: ^ItemInstance,
    x, y: f32,
    snap: bool,
    rotated: bool,
    valid: bool,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style
) {
    width := f32(rotated ? item.definition.height : item.definition.width)
    height := f32(rotated ? item.definition.width : item.definition.height)
    px, py: f32
    color := valid ? style.colors.success : style.colors.error
    bg_color := color
    bg_color.a = 32
    rot: f32
    textVec: rl.Vector2

    switch snap {
        case true:
            px = origin_x + x * cell_size
            py = origin_y + y * cell_size
            color.a = 128
        case false:
            px = x
            py = y
            bg_color = style.colors.primary
    }

    rl.DrawRectangle(
        i32(px),
        i32(py),
        i32(width * cell_size),
        i32(height * cell_size),
        bg_color,
    )

    switch rotated {
    case true:
        rot = 90
        textVec = rl.Vector2{
            px + width * cell_size - 5,
            py + 5,
        }
    case false:
        rot = 0
        textVec = rl.Vector2{
            px + 5,
            py + 5,
        }
    }

    if !snap {rl.DrawTextPro(
        style.fonts.regular[ui.font_size.default],
        str.clone_to_cstring(item.definition.name, context.temp_allocator),
        ui.SnapVector2(textVec),
        rl.Vector2{0, 0},
        rot,
        f32(ui.font_size.default),
        1,
        style.colors.text,
    )}

    rl.DrawRectangleLines(
        i32(px),
        i32(py),
        i32(width * cell_size),
        i32(height * cell_size),
        color,
    )
}

DrawItemCard :: proc(
    item: ^ItemInstance,
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


    str.write_string(&b, GetItemDataString(item.definition))

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

GetItemCardRect :: proc(x: f32, y: f32, origin_x, origin_y: f32, style: ^ui.style) -> rl.Rectangle {
    pos_x := x * style.grid.cell_size + origin_x + 5
    pos_y := y * style.grid.cell_size + origin_y + 5

    return rl.Rectangle{
        x = pos_x,
        y = pos_y,
        width = 300,
        height = 450,
    }
}