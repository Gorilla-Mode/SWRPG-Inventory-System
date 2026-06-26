package inventory

import rl "vendor:raylib"
import ui "../../ui"
import str "core:strings"

DrawContainerGrid :: proc(
    container: ^Container,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style
) {

    #partial switch storage in container.storage {
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

        for item in container.items {
            DrawItem(item, origin_x, origin_y, cell_size, style)
        }
    }
}

DrawItem :: proc(
    item: ^ItemInstance,
    origin_x, origin_y: f32,
    cell_size: f32,
    style: ^ui.style,
) {
    width := f32(ItemGetWidth(item))
    height := f32(ItemGetHeight(item))

    x := origin_x + f32(item.pos_x) * cell_size
    y := origin_y + f32(item.pos_y) * cell_size

    rot: f32
    textVec: rl.Vector2
    bgColor := style.colors.primary
    textColor := style.colors.text
    outlineColor := style.colors.surface

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

    rl.DrawRectangle(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    bgColor,
    )

    rl.DrawTextPro(
        style.fonts.regular[ui.font_size.default],
        str.clone_to_cstring(item.definition.name),
        textVec,
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
        str.clone_to_cstring(item.definition.name),
        textVec,
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

    builder: str.Builder
    str.builder_init(&builder)

    str.write_string(&builder, "Name: ")
    str.write_string(&builder, item.definition.name)
    str.write_string(&builder, "\n")

    str.write_string(&builder, "Description:\n")
    str.write_string(&builder, item.definition.description)
    str.write_string(&builder, "\n\n")

    str.write_string(&builder, "Width: ")
    str.write_int(&builder, int(item.definition.width))
    str.write_string(&builder, "\n")

    str.write_string(&builder, "Height: ")
    str.write_int(&builder, int(item.definition.height))
    str.write_string(&builder, "\n")

    s := str.to_string(builder)

    rect := rl.Rectangle{x = posX, y =  posY, width = width, height = height}
    rl.DrawRectangleRounded(rect, 0.1, 32, style.colors.surface)
    rl.DrawRectangleRoundedLines(rect, 0.1, 32, style.colors.primary)
    rl.DrawLine(i32(posX), i32(posY + headerSize) + 10, i32(posX + width), i32(posY + headerSize) + 10, style.colors.secondary)

    rl.DrawTextEx(header, str.clone_to_cstring(item.definition.name), {posX + 5, posY + 5}, headerSize, 0, style.colors.text)
    rl.DrawTextEx(regular, str.clone_to_cstring(s), {posX + 5, posY + headerSize + 15}, regularSize, 0, style.colors.text)
}