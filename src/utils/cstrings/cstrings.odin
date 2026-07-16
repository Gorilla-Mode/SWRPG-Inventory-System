package cstrings

import "core:mem"
import rl "vendor:raylib"

Concat :: proc(a, b: cstring, allocator := context.allocator) -> (cstring) {
    len_a := len(a)
    len_b := len(b)

    buf := make([]u8, len_a + len_b + 1, allocator)

    mem.copy(&buf[0], ([^]u8)(a), len_a)
    mem.copy(&buf[len_a], ([^]u8)(b), len_b + 1)

    return cstring(&buf[0])
}

Wrap :: proc(text: cstring, max_width: f32, font: rl.Font, spacing: f32, allocator := context.allocator) -> (cstring) {
    if text == nil do return nil

    wrapped := make([dynamic]u8, 0, len(text), allocator)
    p := ([^]u8)(text)
    line_num := 0

    for i := 0; p[i] != 0; i += 1 {
        _ = append(&wrapped, p[i])
        if p[i] == ' ' {
            line_width := rl.MeasureTextEx(font, cstring(&wrapped[line_num]), f32(font.baseSize), spacing).x
            if line_width > max_width {
                wrapped[len(wrapped) - 1] = '\n'
                line_num = i
            }
        }
    }
    
    return cstring(&wrapped[0])
}