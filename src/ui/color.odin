package ui

import rl "vendor:raylib"
import util "../utils"
import rt "base:runtime"
import fmt "core:fmt"
import ref "core:reflect"

// Define hexadecimal color values for the UI palette.
color_hex :: enum {
    surface   = 0x1c1c1c, // Black
    primary   = 0x292929, // black
    secondary = 0x233480, // Blue
    accent    = 0x262F55, // orange
    text      = 0xf5f0f6, // White
    success   = 0x3E6C37, // green
    warning   = 0xE08300, // orange
    error     = 0xD00000, // red
}

// Struct to hold the color palette for the UI, with fields corresponding to the defined colors.
color_palette :: struct {
    surface:   rl.Color,
    primary:   rl.Color,
    secondary: rl.Color,
    accent:    rl.Color,
    text:      rl.Color,
    success:   rl.Color,
    warning:   rl.Color,
    error:     rl.Color,
}

// Loads the color palette for the UI by converting hexadecimal color values to rl.Color
// and populating a color_palette struct.
LoadColorPalette :: proc() -> color_palette {
    palette := color_palette{}

    struct_info := type_info_of(color_palette)
    named_type := struct_info.variant.(rt.Type_Info_Named)
    struct_type := named_type.base.variant.(rt.Type_Info_Struct)

    enum_count := len(color_hex)
    assert(struct_type.field_count == i32(enum_count),
    "color_palette struct fields must match color_hex enum variants")

    for field, i in color_hex {
        field_name := struct_type.names[i]
        enum_name := ref.enum_field_names(color_hex)[i]
        assert(field_name == enum_name,
        fmt.tprintf("Field mismatch at index %d: expected '%s', got '%s'", i, enum_name, field_name))


        hex_value := u32(field)
        color := util.HexToCol(hex_value)
        field_ptr := cast(^rl.Color)(uintptr(&palette) + uintptr(i) * size_of(rl.Color))
        field_ptr^ = color
    }

    return palette
}

// Renders the current color palette as 100x100 rectangles.
DrawPalette :: proc(palette: color_palette, offset_x: i32 = 0, offset_y: i32 = 0) {
    rl.DrawText("Color palette", 20, 5 + offset_y, 24, palette.text)

    rl.DrawRectangle(20 + offset_x, 34 + offset_y, 100, 100, palette.primary)
    rl.DrawText("Primary", 25 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(130 + offset_x, 34 + offset_y, 100, 100, palette.secondary)
    rl.DrawText("Secondary", 135 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(240 + offset_x, 34 + offset_y, 100, 100, palette.accent)
    rl.DrawText("Accent", 245 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(350 + offset_x, 34 + offset_y, 100, 100, palette.success)
    rl.DrawText("Success", 355 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(460 + offset_x, 34 + offset_y, 100, 100, palette.warning)
    rl.DrawText("Warning", 465 + offset_x, 39 + offset_y, 12, palette.text)

    rl.DrawRectangle(570 + offset_x, 34 + offset_y, 100, 100, palette.error)
    rl.DrawText("Error", 575 + offset_x, 39 + offset_y, 12, palette.text)
}