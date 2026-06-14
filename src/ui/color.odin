package ui
import rl "vendor:raylib"

// Define hexadecimal color values for the UI palette.
color_hex :: enum {
    surface   = 0x1c1c1c, // Black
    primary   = 0xf5f0f6, // White
    success   = 0x3E6C37, // green
    warning   = 0xE08300, // orange
    error     = 0xD00000, // red
}

// Struct to hold the color palette for the UI, with fields corresponding to the defined colors.
color_palette :: struct {
    surface:   rl.Color,
    primary:   rl.Color,
    success:   rl.Color,
    warning:   rl.Color,
    error:     rl.Color,
}