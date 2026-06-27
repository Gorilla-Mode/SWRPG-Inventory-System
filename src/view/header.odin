package view

import ui "../ui"
import rl "vendor:raylib"
import st "../core/state"
import co "../ui/component"

DrawHeader :: proc(style: ^ui.style, state: ^st.state) {
    pos := rl.Vector2{5, 0}
    fontSize := f32(ui.font_size.title)
    header_y := pos.y + fontSize + 2

    rl.DrawTextEx(style.fonts.bold[ui.font_size.title],
    "SWIS",
    pos,
    fontSize,
    0,
    style.colors.text)

    ButtonInv := co.ButtonCreate(
    "Inventory",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    120,
    30,
    st.page.Inventory
    )

    ButtonDebug := co.ButtonCreate(
    "Debug",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    120,
    30,
    st.page.Debug
    )
    buttons := []co.Button{
        ButtonInv,
        ButtonDebug
    }

    co.LayoutButtonsHorizontal(
    buttons,
    rl.Vector2{state.window.width / 2, header_y / 2},
    5,
    )

    for i in 0..<len(buttons) {
        if co.DrawButton(&buttons[i], style, state.page) {
            state.page = buttons[i].page
        }
    }

    rl.DrawLine(0, i32(header_y), i32(state.window.width), i32(header_y), style.colors.secondary)
}