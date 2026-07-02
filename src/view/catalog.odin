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

    // - padding times elements +1 and divide by number of elements
    buttonWidthBase: f32 = (layout.left.width - app.PADDING )
    buttonWidthCat: f32 = (buttonWidthBase - paddingElement * 5) / 4
    buttonWidthWeapon: f32 = (buttonWidthBase - paddingElement * 6) / 5
    buttonwidthContainer: f32 = (buttonWidthBase - paddingElement * 3) / 2
    buttonWidthGear: f32 = (buttonWidthBase - paddingElement * 2) / 1
    buttonWidthClothing: f32 = (buttonWidthBase - paddingElement * 2) / 1
    buttonHeight: f32 = 32
    buttonSubHeight: f32 = 26

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

    textCategory: cstring = "Category"
    textCategorySize := rl.MeasureTextEx(style.fonts.semibold[ui.font_size.label], textCategory, f32(ui.font_size.label), 1)
    iconCategoryPos := rl.Vector2{layout.left.origin_x + app.PADDING + (paddingElement * 2), layout.top_y + searchBar.rect.height + (paddingElement * 3)}
    categoryFilterRect := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING + paddingElement,
        y = layout.top_y + searchBar.rect.height + (paddingElement * 2),
        width = layout.left.width - app.PADDING - (paddingElement * 2),
        height = textCategorySize.y + (paddingElement * 2),
    }

    buttonWeaponCat := comp.ButtonCreate(
    "Weapon",
    layout.left.center_x,
    buttonWidthCat,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_weapons]
    )

    buttonGearCat := comp.ButtonCreate(
    "Gear",
    layout.left.center_x,
    buttonWidthCat,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_gear]
    )

    buttonArmorCat := comp.ButtonCreate(
    "Clothing",
    layout.left.center_x,
    buttonWidthCat,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_clothing]
    )

    buttonContainerCat := comp.ButtonCreate(
    "Storage",
    layout.left.center_x,
    buttonWidthCat,
    buttonHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_storage]
    )

    buttonsCategory := []^comp.Button{
        &buttonWeaponCat,
        &buttonGearCat,
        &buttonArmorCat,
        &buttonContainerCat,
    }

    iconSubCategoryPos := rl.Vector2{layout.left.origin_x + app.PADDING + (paddingElement * 2), layout.top_y + searchBar.rect.height + (paddingElement * 5) + categoryFilterRect.height + searchBar.rect.height}
    categorySubFilterRect := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING + paddingElement,
        y = layout.top_y + searchBar.rect.height + (paddingElement * 4) + categoryFilterRect.height + searchBar.rect.height,
        width = layout.left.width - app.PADDING - (paddingElement * 2),
        height = textCategorySize.y + (paddingElement * 2),
    }
    textSubCategory: cstring = "Sub-Category"

    buttonWeaponPistol := comp.ButtonCreate(
    "Pistol",
    layout.left.center_x,
    buttonWidthWeapon,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_pistol]
    )

    buttonWeaponRifle := comp.ButtonCreate(
    "Rifle",
    layout.left.center_x,
    buttonWidthWeapon,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_rifle]
    )

    buttonWeaponMelee := comp.ButtonCreate(
    "Melee",
    layout.left.center_x,
    buttonWidthWeapon,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_melee]
    )


    buttonWeaponShotgun := comp.ButtonCreate(
    "Scatter",
    layout.left.center_x,
    buttonWidthWeapon,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_shotgun]
    )

    buttonWeaponGunnery := comp.ButtonCreate(
    "Gunnery",
    layout.left.center_x,
    buttonWidthWeapon,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.item_weapon_type_gunnery]
    )

    buttonContainerBelt := comp.ButtonCreate(
    "Belt",
    layout.left.center_x,
    buttonwidthContainer,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_gear]
    )

    buttonContainerBackpack := comp.ButtonCreate(
    "Backpack",
    layout.left.center_x,
    buttonwidthContainer,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_storage]
    )

    buttonGearTools := comp.ButtonCreate(
    "Tools",
    layout.left.center_x,
    buttonWidthGear,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_gear]
    )

    buttonClothingSpacesuit := comp.ButtonCreate(
    "Spacesuit",
    layout.left.center_x,
    buttonWidthClothing,
    buttonSubHeight,
    st.page.Inventory,
    style.icons[ui.Icons.category_clothing]
    )

    buttonsWeapons := []^comp.Button{
        &buttonWeaponPistol,
        &buttonWeaponRifle,
        &buttonWeaponMelee,
        &buttonWeaponShotgun,
        &buttonWeaponGunnery
    }

    buttonsContainer := []^comp.Button{
        &buttonContainerBelt,
        &buttonContainerBackpack,
    }

    buttonsGear := []^comp.Button{
        &buttonGearTools,
    }

    buttonsClothing := []^comp.Button{
        &buttonClothingSpacesuit,
    }

    subCat_y: f32 = iconSubCategoryPos.y + categorySubFilterRect.height + (buttonHeight / 2) - ((buttonHeight - buttonSubHeight) / 2)

    comp.LayoutButtonsHorizontalRect(
    buttonsCategory,
    rect_left,
    layout.top_y + searchBar.rect.height + app.PADDING + textCategorySize.y + (paddingElement * 3),
    paddingElement,
    paddingElement,
    paddingElement,
    )

    comp.LayoutButtonsHorizontalRect(
    buttonsWeapons,
    rect_left,
    subCat_y,
    paddingElement,
    paddingElement,
    paddingElement,
    )

    comp.LayoutButtonsHorizontalRect(
    buttonsContainer,
    rect_left,
    subCat_y,
    paddingElement,
    paddingElement,
    paddingElement,
    )

    comp.LayoutButtonsHorizontalRect(
    buttonsGear,
    rect_left,
    subCat_y,
    paddingElement,
    paddingElement,
    paddingElement,
    )

    comp.LayoutButtonsHorizontalRect(
    buttonsClothing,
    rect_left,
    subCat_y,
    paddingElement,
    paddingElement,
    paddingElement,
    )

    rl.DrawRectangleRec(rect_left, style.colors.secondary)
    rl.DrawRectangleRec(rect_right, style.colors.secondary_active)

    comp.UpdateTextField(&searchBar)
    comp.DrawTextField(&searchBar, style, "Search catalog...")

    rl.DrawRectangleRec(categoryFilterRect, style.colors.surface)
    rl.DrawTextureEx(style.icons[ui.Icons.gui_filter], iconCategoryPos, 0, ui.IconScale(textCategorySize.y), style.colors.text)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], textCategory, { iconCategoryPos.x + textCategorySize.y + paddingElement, iconCategoryPos.y }, f32(ui.font_size.label), 2, style.colors.text)

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

    rl.DrawRectangleRec(categorySubFilterRect, style.colors.surface)
    rl.DrawTextureEx(style.icons[ui.Icons.gui_filter], iconSubCategoryPos, 0, ui.IconScale(textCategorySize.y), style.colors.text)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], textSubCategory, { iconSubCategoryPos.x + textCategorySize.y + paddingElement, iconSubCategoryPos.y }, f32(ui.font_size.label), 2, style.colors.text)

    switch state.catalog.category {
    case .Weapon:
        if comp.DrawButtonCol(&buttonWeaponRifle,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

        if comp.DrawButtonCol(&buttonWeaponPistol,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

        if comp.DrawButtonCol(&buttonWeaponShotgun,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

        if comp.DrawButtonCol(&buttonWeaponGunnery,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

        if comp.DrawButtonCol(&buttonWeaponMelee,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

    case .Container:
        if comp.DrawButtonCol(&buttonContainerBelt,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }
        if comp.DrawButtonCol(&buttonContainerBackpack,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

    case .Gear:
        if comp.DrawButtonCol(&buttonGearTools,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }

    case .Armor:
        if comp.DrawButtonCol(&buttonClothingSpacesuit,
        style,
        false,
        f_bg_color,
        f_icon_color,
        f_icon_bg_color,
        f_hover_color,
        f_active_color,
        true,
        f_hover_color,
        f_active_color){ }
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
}