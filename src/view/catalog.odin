package view
import st "../core/state"
import ui "../ui"
import app "../core/app"
import rl "vendor:raylib"
import comp "../ui/component"

DrawCatalog :: proc(state: ^st.state, style: ^ui.style) {
    layout := app.GetCatalogPageLayoutInfo(state, style.grid.cell_size)

    rect_left_x := layout.left.origin_x + app.PADDING
    rect_left := rl.Rectangle{
        x = rect_left_x,
        y = layout.top_y,
        width = layout.left.width - rect_left_x,
        height = f32(state.window.height) - layout.top_y
    }
    rect_right := rl.Rectangle{
        x = layout.right.origin_x,
        y = layout.top_y,
        width = layout.right.width - app.PADDING,
        height = f32(state.window.height) - layout.top_y
    }

    searchBar := comp.TextFieldCreate(
        rl.Rectangle{
            x = layout.left.origin_x + app.PADDING + 2,
            y = layout.top_y + 2,
            width = layout.left.width - 4 - app.PADDING,
            height = 32,
        },
        style,
    st.textField.Catalog_Search,
    state)

    rl.DrawRectangleRec(rect_left, style.colors.secondary)
    rl.DrawRectangleRec(rect_right, style.colors.secondary_active)

    comp.UpdateTextField(&searchBar)
    comp.DrawTextField(&searchBar, style)

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "Catalog",
    ui.SnapVector2({layout.left.origin_x + app.PADDING, layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "Statisitcs",
    ui.SnapVector2({layout.right.origin_x, layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "|",
    ui.SnapVector2({layout.right.center_x + app.PADDING, layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "|",
    ui.SnapVector2({layout.left.center_x - app.PADDING , layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)


}