package ui

import util "../utils"
import rl "vendor:raylib"

// Loads the color palette for the UI by converting hexadecimal color values to rl.Color
// structs and populating a color_palette struct.
load_color_palette :: proc() -> color_palette {
    palette := color_palette{}

    for field, i in color_hex {
        hex_value := u32(field)
        color := util.hex_to_col(hex_value)
        field_ptr := cast(^rl.Color)(uintptr(&palette) + uintptr(i) * size_of(rl.Color))
        field_ptr^ = color
    }

    return palette
}