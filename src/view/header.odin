package view

import ui "../ui"
import rl "vendor:raylib"
import st "../core/state"
import co "../ui/component"
import cstr "../utils/cstrings"
import app "../core/app"

DrawHeader :: proc(style: ^ui.style, state: ^st.state) {
    pos := rl.Vector2{5, 0}
    fontSize := f32(ui.font_size.title)
    header_y := pos.y + fontSize + 2
    buttonHeight : f32 = 30
    buttonWidth : f32 = 110
    credits: cstring = cstr.Concat(cstr.FormatCurrency(state.character.credits, context.temp_allocator), " Cr", context.temp_allocator)
    creditsSize := rl.MeasureTextEx(style.fonts.semibold[ui.font_size.default], credits, f32(ui.font_size.default), 0)
    creditsPos := ui.SnapVector2({state.window.width - creditsSize.x - app.PADDING,(header_y / 2) - (creditsSize.y / 2)})
    creditsIconSize: f32 = 24
    creditsScale := ui.IconScale(creditsIconSize)

    rl.DrawTextEx(style.fonts.bold[ui.font_size.title],
    "SWIS",
    ui.SnapVector2(pos),
    fontSize,
    0,
    style.colors.text)

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.default],
    credits,
    creditsPos,
    f32(ui.font_size.default), 0, style.colors.text)

    rl.DrawTextureEx(style.icons[.economy_credit], { creditsPos.x - creditsIconSize - 2, header_y / 2 - creditsIconSize / 2 }, 0,  creditsScale, style.colors.text)

    ButtonInv := co.ButtonCreate(
    "Inventory",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_inventory]
    )

    ButtonDebug := co.ButtonCreate(
    "Debug",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_debug]
    )

    ButtonCharacter := co.ButtonCreate(
    "Character",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_character]
    )

    ButtonCatalog := co.ButtonCreate(
    "Catalog",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_catalog]
    )

    ButtonShop := co.ButtonCreate(
    "Merchants",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_shop]
    )

    ButtonVehicles := co.ButtonCreate(
    "Vehicles",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_vehicle]
    )

    ButtonBases := co.ButtonCreate(
    "Bases",
    rl.Vector2{f32(rl.GetScreenWidth() / 2), header_y / 2},
    buttonWidth,
    buttonHeight,
    style.icons[ui.Icons.page_bases]
    )

    buttons := []co.Button{
        ButtonCharacter,
        ButtonInv,
        ButtonShop,
        ButtonVehicles,
        ButtonBases,
        ButtonCatalog,
        ButtonDebug,
    }

    pages := []st.page{
        .Character,
        .Inventory,
        .Shops,
        .Vehicles,
        .Bases,
        .Catalog,
        .Debug,
    }

    co.LayoutButtonsHorizontal(
    buttons,
    rl.Vector2{state.window.width / 2, header_y / 2},
    2,
    )

    for i in 0..<len(buttons) {
        if co.DrawButton(&buttons[i], style, state.page == pages[i]) {
            state.page = pages[i]
        }
    }

    rl.DrawLine(0, i32(header_y), i32(state.window.width), i32(header_y), style.colors.secondary)
}