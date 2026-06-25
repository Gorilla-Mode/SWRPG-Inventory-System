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
    style: ^ui.style
) {
    width := f32(ItemGetWidth(item))
    height := f32(ItemGetHeight(item))

    x := origin_x + f32(item.pos_x) * cell_size
    y := origin_y + f32(item.pos_y) * cell_size

    rot: f32
    textVec: rl.Vector2

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

    rl.DrawRectangle(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    style.colors.primary,
    )

    rl.DrawTextPro(
        style.fonts.regular[ui.font_size.default],
        str.clone_to_cstring(item.definition.name),
        textVec,
        rl.Vector2{0, 0},
        rot,
        f32(ui.font_size.default),
        1,
        style.colors.text,
    )

    rl.DrawRectangleLines(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    style.colors.surface,
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
    bg_color.a = 128
    rot: f32
    textVec: rl.Vector2

    switch snap {
        case true:
            px = origin_x + x * cell_size
            py = origin_y + y * cell_size
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