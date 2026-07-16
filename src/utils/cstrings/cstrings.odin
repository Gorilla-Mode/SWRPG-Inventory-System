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

Wrap :: proc(
    text: cstring,
    max_width: f32,
    font: rl.Font,
    spacing: f32,
    allocator := context.allocator,
) -> cstring {

    if text == nil do return nil

    p := ([^]u8)(text)

    wrapped := make([dynamic]u8, 0, len(text)+1, allocator)

    line_start := 0
    last_space := -1

    for i := 0; p[i] != 0; i += 1 {

        append(&wrapped, p[i])

        if p[i] == ' ' {
            last_space = len(wrapped) - 1
        }

        append(&wrapped, 0)

        width := rl.MeasureTextEx(font, cstring(&wrapped[line_start]), f32(font.baseSize), spacing, ).x

        _ = pop(&wrapped)

        if width > max_width {

            if last_space >= line_start {
                wrapped[last_space] = '\n'
                line_start = last_space + 1
                last_space = -1
            } else {
                append(&wrapped, 0)

                for j := len(wrapped)-1; j > line_start; j -= 1 {
                    wrapped[j] = wrapped[j-1]
                }

                wrapped[line_start] = '\n'

                _ = pop(&wrapped)

                line_start += 1
            }
        }
    }

    append(&wrapped, 0)

    return cstring(&wrapped[0])
}