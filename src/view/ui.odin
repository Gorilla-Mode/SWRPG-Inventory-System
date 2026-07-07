package view

import st "../core/state"
import ui "../ui"
import inv "../core/inventory"

DrawUI :: proc(state: ^st.state, style: ^ui.style, items: ^inv.ItemInstance) {
    DrawHeader(style, state)

    switch state.page {
    case st.page.Inventory:
        DrawGrid(items, state, style)
    case st.page.Debug:
        DrawDebug(state, style)
    case st.page.Character:
        DrawCharacter(state, style)
    case st.page.Catalog:
        DrawCatalog(state, style)
    case st.page.Shops:
        DrawWIPPage("Merchants", style)
    case st.page.Vehicles:
        DrawWIPPage("Vehicles", style)
    case st.page.Bases:
        DrawWIPPage("Bases", style)
    }
}