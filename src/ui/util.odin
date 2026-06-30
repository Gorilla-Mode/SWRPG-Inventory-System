package ui

import rl "vendor:raylib"

// Renders the current color palette as 100x100 rectangles.
DrawPalette :: proc(palette: color_palette, offset_x: i32 = 0, offset_y: i32 = 0) {

    rl.DrawText("Color palette", 20, 5 + offset_y, 24, palette.text)

    rl.DrawRectangle(20 + offset_x, 34 + offset_y, 100, 100, palette.primary)
    rl.DrawText("Primary", 25 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(130 + offset_x, 34 + offset_y, 100, 100, palette.secondary)
    rl.DrawText("Secondary", 135 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(240 + offset_x, 34 + offset_y, 100, 100, palette.secondary_hover)
    rl.DrawText("Secondary\nhover", 245 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(350 + offset_x, 34 + offset_y, 100, 100, palette.success)
    rl.DrawText("Success", 355 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(460 + offset_x, 34 + offset_y, 100, 100, palette.warning)
    rl.DrawText("Warning", 465 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(570 + offset_x, 34 + offset_y, 100, 100, palette.error)
    rl.DrawText("Error", 575 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(680 + offset_x, 34 + offset_y, 100, 100, palette.surface)
    rl.DrawRectangleLines(680 + offset_x, 34 + offset_y, 100, 100, palette.text)
    rl.DrawText("Surface", 685 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(790 + offset_x, 34 + offset_y, 100, 100, palette.text)
    rl.DrawText("Text", 795 + offset_x, 39 + offset_y, 12, palette.surface)

    rl.DrawRectangle(900 + offset_x, 34 + offset_y, 100, 100, palette.secondary_active)
    rl.DrawText("Secondary\nactive", 905 + offset_x, 39 + offset_y, 12, palette.text)
}

// Converts a hexadecimal color value to an rl.Color struct, with an optional alpha component.
HexToCol :: proc (hex: u32, alpha: u8 = 255) -> rl.Color
{
    r := u8((hex >> 16) & 0xFF)
    g := u8((hex >> 8) & 0xFF)
    b := u8(hex & 0xFF)

    return rl.Color{r, g, b, alpha}
}

SnapVector2 :: proc(v: rl.Vector2) -> rl.Vector2 {
    return {f32(i32(v.x)), f32(i32(v.y))}
}

CenterIconInSquare :: proc(square: rl.Rectangle, icon_size: f32) -> rl.Vector2 {
    return {
         square.x + (square.width  - icon_size) * 0.5,
         square.y + (square.height - icon_size) * 0.5,
    }
}

DEFAULT_ICON_SIZE :: 64.0

IconScale :: proc(target_size: f32) -> f32 {
    return target_size / DEFAULT_ICON_SIZE
}