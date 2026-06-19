package ui

import rl "vendor:raylib"

// Definiton of font sizes loaded, and to be used across the UI
font_size :: enum {
    caption = 12,
    label   = 14,
    default = 16,
    header  = 24,
    title   = 32
}

// Struct to hold maps of font sizes to their corresponding rl.Font objects for each weight (regular, medium, semibold, bold).
fonts :: struct {
    regular:  map[font_size]rl.Font,
    medium:   map[font_size]rl.Font,
    semibold: map[font_size]rl.Font,
    bold:     map[font_size]rl.Font
}

// Loads all font weights in all the defined font sizes, and returns a fonts struct containing maps of font sizes to their corresponding rl.Font objects for each weight.
LoadFont :: proc () -> fonts{
    fnts := fonts{
        regular =  make(map[font_size]rl.Font),
        medium =   make(map[font_size]rl.Font),
        semibold = make(map[font_size]rl.Font),
        bold =     make(map[font_size]rl.Font)
    }

    for size in font_size {
        fnts.regular[size] =  rl.LoadFontEx("src/assets/font/Inconsolata-Regular.ttf", i32(size), nil, 0)
        fnts.medium[size] =   rl.LoadFontEx("src/assets/font/Inconsolata-Medium.ttf", i32(size), nil, 0)
        fnts.semibold[size] = rl.LoadFontEx("src/assets/font/Inconsolata-SemiBold.ttf", i32(size), nil, 0)
        fnts.bold[size] =     rl.LoadFontEx("src/assets/font/Inconsolata-Bold.ttf", i32(size), nil, 0)
    }

    return fnts
}

// Unloads all fonts in the provided fonts struct, and frees the memory allocated for the maps of font sizes to their corresponding rl.Font objects for each weight.
FreeFont :: proc (fnts: fonts) {
    for size in font_size {
        rl.UnloadFont(fnts.regular[size])
        rl.UnloadFont(fnts.medium[size])
        rl.UnloadFont(fnts.semibold[size])
        rl.UnloadFont(fnts.bold[size])
    }

    delete(fnts.regular)
    delete(fnts.medium)
    delete(fnts.semibold)
    delete(fnts.bold)
}