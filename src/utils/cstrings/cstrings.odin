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

WrapMono :: proc(text: cstring, max_width: f32, font: rl.Font, spacing: f32, allocator := context.allocator) -> cstring {
    if text == nil do return nil

    char_width := rl.MeasureTextEx(font, "M", f32(font.baseSize), spacing, ).x
    chars_per_line := int(max_width / char_width)

    if chars_per_line <= 0 do return text

    length := len(text)
    wrapped := make([dynamic]u8, 0, length + length / chars_per_line + 1, allocator)
    p := ([^]u8)(text)
    line_start := 0

    for i in 0..<length {
        append(&wrapped, p[i])
    }

    for line_start + chars_per_line < len(wrapped) {

        break_pos := line_start + chars_per_line

        has_newline := false
        for i := line_start; i < break_pos; i += 1 {
            if wrapped[i] == '\n' {
                line_start = i + 1
                has_newline = true
                break
            }
        }

        if has_newline {
            continue
        }

        space := break_pos
        for space > line_start && wrapped[space] != ' ' && wrapped[space] != '\n' {
            space -= 1
        }

        if wrapped[space] == '\n' {
            line_start = space + 1
            continue
        }

        if space == line_start {
            space = break_pos
        }

        wrapped[space] = '\n'
        line_start = space + 1
    }

    append(&wrapped, 0)
    return cstring(&wrapped[0])
}

FormatArray :: proc(arr: [dynamic]cstring,
    prefix: cstring = "",
    separator: cstring = "",
    allocator := context.allocator,
    max_line_len: f32 = 0,
    font: rl.Font = {},
    spacing: f32 = 0
) -> cstring {
    if len(arr) == 0 do return nil

    buf: cstring
    for str in arr {
        if str == nil do continue
        entry: cstring = (Concat(prefix, str, allocator))
        entry = (Concat(entry, separator, allocator))
        if max_line_len != 0 do entry = (WrapMono(entry, max_line_len, font, spacing, allocator))

        buf = (Concat(buf, entry, allocator))
    }

    return buf
}