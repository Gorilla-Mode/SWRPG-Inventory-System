package view

import st "../core/state"
import ui "../ui"
import inv "../core/inventory"

DrawInventory :: proc(state: ^st.state, style: ^ui.style, containerItem: ^inv.Item) {
    DrawGrid(containerItem, state, style)
}