package debug

import fmt "core:fmt"

HIGHLIGHT_WARN      ::  "\x1b[33m"
HIGHLIGHT_WARN_END  :: "\x1b[0m"
HIGHLIGHT_ERROR     :: "\x1b[31m"
HIGHLIGHT_ERROR_END :: "\x1b[0m"
HIGHLIGHT_DEBUG     :: "\x1b[36m"
HIGHLIGHT_DEBUG_END :: "\x1b[0m"

Debug :: proc(msg: string) {
    fmt.println(HIGHLIGHT_DEBUG, "[DEBUG]", HIGHLIGHT_DEBUG_END, msg)
}

Warn :: proc(msg: string) {
    fmt.println(HIGHLIGHT_WARN, "[WARN]", HIGHLIGHT_WARN_END, msg)
}

Error :: proc(msg: string) {
    fmt.println(HIGHLIGHT_ERROR, "[ERROR]", HIGHLIGHT_ERROR_END, msg)
}