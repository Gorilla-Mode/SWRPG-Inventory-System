package utils

import rl "vendor:raylib"

// Converts a hexadecimal color value to an rl.Color struct, with an optional alpha component.
hex_to_col :: proc (hex: u32, alpha: u8 = 255) -> rl.Color
{
    r := u8((hex >> 16) & 0xFF)
    g := u8((hex >> 8) & 0xFF)
    b := u8(hex & 0xFF)

    return rl.Color{r, g, b, alpha}
}