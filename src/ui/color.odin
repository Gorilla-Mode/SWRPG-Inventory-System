package ui

color_scheme :: struct {
    surface:   u32,
    primary:   u32,
    success:   u32,
    warning:   u32,
    error:     u32,
}

color_scheme_instance : = color_scheme{
    surface   = 0x1c1c1c, // Black
    primary   = 0xf5f0f6, // White
    success   = 0x3E6C37, // green
    warning   = 0xE08300, // orange
    error     = 0xD00000, // red
}