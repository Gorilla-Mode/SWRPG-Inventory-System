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
                rl.BLACK,
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

    rl.DrawRectangle(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    rl.DARKGRAY,
    )

    rl.DrawTextEx(style.fonts.regular[ui.font_size.header],
    str.clone_to_cstring(item.definition.name),
    { x + 5, y + 5 },
    f32(ui.font_size.header),
    0,
    style.colors.primary)

    rl.DrawRectangleLines(
    i32(x),
    i32(y),
    i32(width * cell_size),
    i32(height * cell_size),
    rl.WHITE,
    )
}