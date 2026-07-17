package view

import st "../core/state"
import ui "../ui"
import comp "../ui/component"
import rl "vendor:raylib"
import dbug "../core/debug"
import fmt "core:fmt"

DrawDebug :: proc(state: ^st.state, style: ^ui.style) {
    buttonWidth: f32 = 110
    buttonHeight: f32 = 30

    debugButton := comp.ButtonCreate("Debug",
    rl.Vector2{state.window.width / 2, state.window.height / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_debug])

    ui.DrawPalette(style.colors, offset_y = 34)
    
    if comp.DrawButton(&debugButton, style, state.debug == true) {
        state.debug = !state.debug
        dbug.Debug(fmt.tprint("Debug mode:", state.debug))
    }
}