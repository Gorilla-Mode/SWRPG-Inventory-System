package view

import st "../core/state"
import ui "../ui"
import inv "../core/inventory"

DrawUI :: proc(state: ^st.state, style: ^ui.style, items: ^inv.Item) {
    DrawHeader(style, state)

    switch state.page {
    case st.page.Inventory:
        DrawGrid(items, state, style)
    case st.page.Debug:
        DrawDebug(state, style)
    case st.page.Character:
        DrawWIPPage("Character", style)
    case st.page.Catalog:
        DrawWIPPage("Catalog", style)
    }
}