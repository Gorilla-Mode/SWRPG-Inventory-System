package view

import ui "../ui"
import rl "vendor:raylib"
import st "../core/state"
import co "../ui/component"

DrawHeader :: proc(style: ^ui.style, state: ^st.state) {
    pos := rl.Vector2{5, 0}
    fontSize := f32(ui.font_size.title)
    header_y := pos.y + fontSize + 2
    buttonHeight : f32 = 30
    buttonWidth : f32 = 110

    rl.DrawTextEx(style.fonts.bold[ui.font_size.title],
    "SWIS",
    pos,
    fontSize,
    0,
    style.colors.text)

    ButtonInv := co.ButtonCreate(
    "Inventory",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.page_inventory]
    )

    ButtonDebug := co.ButtonCreate(
    "Debug",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    st.page.Debug,
    style.icons[ui.Icons.page_debug]
    )

    ButtonCharacter := co.ButtonCreate(
    "Character",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    st.page.Character,
    style.icons[ui.Icons.page_character]
    )

    ButtonCatalog := co.ButtonCreate(
    "Catalog",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    st.page.Catalog,
    style.icons[ui.Icons.page_catalog]
    )

    buttons := []co.Button{
        ButtonInv,
        ButtonCharacter,
        ButtonCatalog,
        ButtonDebug,
    }

    co.LayoutButtonsHorizontal(
    buttons,
    rl.Vector2{state.window.width / 2, header_y / 2},
    2,
    )

    for i in 0..<len(buttons) {
        if co.DrawButton(&buttons[i], style, state.page) {
            state.page = buttons[i].page
        }
    }

    rl.DrawLine(0, i32(header_y), i32(state.window.width), i32(header_y), style.colors.secondary)
}