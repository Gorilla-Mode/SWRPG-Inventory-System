package view
import st "../core/state"
import ui "../ui"
import app "../core/app"
import rl "vendor:raylib"
import comp "../ui/component"
import inv "../core/inventory"

DrawCatalog :: proc(state: ^st.state, style: ^ui.style) {
    layout := app.GetCatalogPageLayoutInfo(state, style.grid.cell_size)
    paddingElement: f32 = 2
    buttonWidth: f32 = (layout.left.width - app.PADDING - paddingElement * 5) / 4
    buttonHeight: f32 = 32

    f_bg_color := style.colors.surface
    f_hover_color := style.colors.secondary_hover
    f_active_color := style.colors.success
    f_icon_color := style.colors.text
    f_icon_bg_color := style.colors.secondary

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
            x = layout.left.origin_x + app.PADDING + paddingElement,
            y = layout.top_y + paddingElement,
            width = layout.left.width - (paddingElement * 2) - app.PADDING,
            height = 32,
        },
        style,
    st.textField.Catalog_Search,
    state,
    style.icons[ui.Icons.gui_search])

    buttonWeaponCat := comp.ButtonCreate(
    "Weapon",
    layout.left.center_x,
    buttonWidth,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_gunnery]
    )

    buttonGearCat := comp.ButtonCreate(
    "Gear",
    layout.left.center_x,
    buttonWidth,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_melee]
    )

    buttonArmorCat := comp.ButtonCreate(
    "Armor",
    layout.left.center_x,
    buttonWidth,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.gui_cart]
    )

    buttonContainerCat := comp.ButtonCreate(
    "Storage",
    layout.left.center_x,
    buttonWidth,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_melee]
    )

    buttonsCategory := []^comp.Button{
        &buttonWeaponCat,
        &buttonGearCat,
        &buttonArmorCat,
        &buttonContainerCat,
    }

    comp.LayoutButtonsHorizontalRect(
    buttonsCategory,
    rect_left,
    layout.top_y + searchBar.rect.height + app.PADDING,
    paddingElement,
    paddingElement,
    paddingElement,
    )

    rl.DrawRectangleRec(rect_left, style.colors.secondary)
    rl.DrawRectangleRec(rect_right, style.colors.secondary_active)

    comp.UpdateTextField(&searchBar)
    comp.DrawTextField(&searchBar, style, "Search catalog...")

    if comp.DrawButtonCol(&buttonWeaponCat,
    style,
    state.catalog.category == inv.ItemCategory.Weapon,
    f_bg_color,
    f_icon_color,
    f_icon_bg_color,
    f_hover_color,
    f_active_color,
    true,
    f_hover_color,
    f_active_color) {
        state.catalog.category = inv.ItemCategory.Weapon
    }
    if comp.DrawButtonCol(&buttonGearCat,
    style,
    state.catalog.category == inv.ItemCategory.Gear,
    f_bg_color,
    f_icon_color,
    f_icon_bg_color,
    f_hover_color,
    f_active_color,
    true,
    f_hover_color,
    f_active_color) {
        state.catalog.category = inv.ItemCategory.Gear
    }
    if comp.DrawButtonCol(&buttonArmorCat,
    style,
    state.catalog.category == inv.ItemCategory.Armor,
    f_bg_color,
    f_icon_color,
    f_icon_bg_color,
    f_hover_color,
    f_active_color,
    true,
    f_hover_color,
    f_active_color) {
        state.catalog.category = inv.ItemCategory.Armor
    }
    if comp.DrawButtonCol(&buttonContainerCat,
    style,
    state.catalog.category == inv.ItemCategory.Container,

    f_bg_color,
    f_icon_color,
    f_icon_bg_color,
    f_hover_color,
    f_active_color,
    true,
    f_hover_color,
    f_active_color) {
        state.catalog.category = inv.ItemCategory.Container
    }

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