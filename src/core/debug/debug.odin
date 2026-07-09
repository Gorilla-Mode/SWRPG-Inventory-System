package debug

import fmt "core:fmt"

Debug :: proc(msg: string) {
    fmt.println("\x1b[36m[DEBUG]\x1b[0m", msg)
}

Warn :: proc(msg: string) {
    fmt.println("\x1b[33m[WARN]\x1b[0m ", msg)
}

Error :: proc(msg: string) {
    fmt.println("\x1b[31m[ERROR]\x1b[0m", msg)
}