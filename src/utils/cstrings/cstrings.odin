package cstrings

import "core:mem"

Concat :: proc(a, b: cstring, allocator := context.allocator) -> (cstring) {
    len_a := len(a)
    len_b := len(b)

    buf := make([]u8, len_a + len_b + 1, allocator)

    mem.copy(&buf[0], ([^]u8)(a), len_a)
    mem.copy(&buf[len_a], ([^]u8)(b), len_b + 1)

    return cstring(&buf[0])
}