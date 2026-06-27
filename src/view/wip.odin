package view

import ui "../ui"
import str "core:strings"
import rl "vendor:raylib"

DrawWIPPage :: proc(pageName: string, style: ^ui.style) {

    b := str.Builder{}
    str.builder_init(&b, context.temp_allocator)
    str.write_string(&b, "The ")
    str.write_string(&b, pageName)
    str.write_string(&b, " page is not yet implemented.")

    s := str.to_string(b)
    text := str.clone_to_cstring(s, context.temp_allocator)

    font := style.fonts.bold[ui.font_size.title]
    font_size := f32(ui.font_size.title)

    text_size := rl.MeasureTextEx(font, text, font_size, 0)

    pos := rl.Vector2{
        f32(rl.GetScreenWidth()) / 2 - text_size.x / 2,
        100,
    }

    rl.DrawTextEx(
    font,
    text,
    pos,
    font_size,
    0,
    style.colors.error,
    )
}