package view

import st "../core/state"
import ui "../ui"

DrawDebug :: proc(state: ^st.state, style: ^ui.style) {
        ui.DrawPalette(style.colors, offset_y = 34)
}