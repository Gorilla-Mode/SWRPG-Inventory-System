package view
import st "../core/state"
import ui "../ui"
import app "../core/app"
import rl "vendor:raylib"
import comp "../ui/component"
import inv "../core/inventory"

CreateCategoryButtons :: proc(
    layout: app.CatalogPageLayout,
    style: ^ui.style,
    button_width: f32,
    button_height: f32,
) -> [dynamic]comp.Button {

    buttons := make([dynamic]comp.Button)

    append(&buttons, comp.ButtonCreate(
    "Weapon",
    layout.left.center_x,
    button_width,
    button_height,
    style.icons[ui.Icons.category_weapons]))

    append(&buttons, comp.ButtonCreate(
    "Gear",
    layout.left.center_x,
    button_width,
    button_height,
    style.icons[ui.Icons.category_gear]))

    append(&buttons, comp.ButtonCreate(
    "Armor",
    layout.left.center_x,
    button_width,
    button_height,
    style.icons[ui.Icons.category_clothing]))

    append(&buttons, comp.ButtonCreate(
    "Storage",
    layout.left.center_x,
    button_width,
    button_height,
    style.icons[ui.Icons.category_storage]))

    return buttons
}

CreateWeaponButtons :: proc(
    layout: app.CatalogPageLayout,
    style: ^ui.style,
    width: f32,
    height: f32,
) -> [dynamic]CatalogButton {
    buttons := make([dynamic]CatalogButton)

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Pistol",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_pistol],
        ),
        value = inv.WeaponSubCategory.Pistol,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Rifle",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_rifle],
        ),
        value = inv.WeaponSubCategory.Rifle,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Gunnery",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_gunnery],
        ),
        value = inv.WeaponSubCategory.Gunnery,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Explosive",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_explosive],
        ),
        value = inv.WeaponSubCategory.Explosive,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Blade",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_blade],
        ),
        value = inv.WeaponSubCategory.Blade,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Blunt",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_blunt],
        ),
        value = inv.WeaponSubCategory.Blunt,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Lightsaber",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.item_weapon_type_lightsaber],
        ),
        value = inv.WeaponSubCategory.Lightsaber
    })

    return buttons
}

CreateContainerButtons :: proc(
    layout: app.CatalogPageLayout,
    style: ^ui.style,
    width: f32,
    height: f32,
) -> [dynamic]CatalogButton {
    buttons := make([dynamic]CatalogButton)

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Belt",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_belt],
        ),
        value = inv.ContainerSubCategory.Belt,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Backpack",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_storage],
        ),
        value = inv.ContainerSubCategory.Backpack,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Holster",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_holster],
        ),
        value = inv.ContainerSubCategory.Holster,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Bandolier",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_bandolier],
        ),
        value = inv.ContainerSubCategory.Bandolier,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Container",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_container],
        ),
        value = inv.ContainerSubCategory.Container,
    })

    return buttons
}

CreateGearButtons :: proc(
    layout: app.CatalogPageLayout,
    style: ^ui.style,
    width: f32,
    height: f32,
) -> [dynamic]CatalogButton {
    buttons := make([dynamic]CatalogButton)

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Tool",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_gear],
        ),
        value = inv.GearSubCategory.Tool,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Electronic",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_gear],
        ),
        value = inv.GearSubCategory.Electronics,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Medical",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_medical],
        ),
        value = inv.GearSubCategory.Medical,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Survival",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_survival],
        ),
        value = inv.GearSubCategory.Survival,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Misc",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_gear],
        ),
        value = inv.GearSubCategory.Miscellaneous,
    })

    return buttons
}

CreateClothingButtons :: proc(
    layout: app.CatalogPageLayout,
    style: ^ui.style,
    width: f32,
    height: f32,
) -> [dynamic]CatalogButton {
    buttons := make([dynamic]CatalogButton)

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Clothing",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_clothing],
        ),
        value = inv.ArmorSubCategory.Clothing,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Full-Body",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_clothing],
        ),
        value = inv.ArmorSubCategory.Full_Body,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Half-Body",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_clothing],
        ),
        value = inv.ArmorSubCategory.Half_Body,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Sealed",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_clothing],
        ),
        value = inv.ArmorSubCategory.Sealed,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Powered",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_clothing],
        ),
        value = inv.ArmorSubCategory.Powered,
    })

    append(&buttons, CatalogButton{
        button = comp.ButtonCreate(
        "Gear",
        layout.left.center_x,
        width,
        height,
        style.icons[ui.Icons.category_clothing],
        ),
        value = inv.ArmorSubCategory.Gear,
    })

    return buttons
}

LayoutCatalogButtons :: proc(
    buttons: ^CatalogButtons,
    rect_left: rl.Rectangle,
    layout: app.CatalogPageLayout,
    subcat_y: f32,
    cat_y: f32,
    padding: f32,
) {
    LayoutCatalogButtonGroup(buttons.weapons, rect_left, subcat_y, padding)
    LayoutCatalogButtonGroup(buttons.containers, rect_left, subcat_y, padding)
    LayoutCatalogButtonGroup(buttons.gear, rect_left, subcat_y, padding)
    LayoutCatalogButtonGroup(buttons.clothing, rect_left, subcat_y, padding)

    comp.LayoutButtonsHorizontalRect(buttons.category, rect_left, cat_y, padding, padding, padding)
}

DrawCatalogButtons :: proc(
    state: ^st.state,
    style: ^ui.style,
    buttons: ^CatalogButtons,
    bgColor: rl.Color,
    iconColor: rl.Color,
    iconBgColor: rl.Color,
    hoverColor: rl.Color,
    activeColor: rl.Color,
    font_size_sub: ui.font_size = ui.font_size.label,
) {
    for i in 0..<len(buttons.category) {
        category := inv.ItemCategory(i)

        if comp.DrawButtonCol(
        &buttons.category[i],
        style,
        state.catalog.category == category,
        bgColor,
        iconColor,
        iconBgColor,
        hoverColor,
        activeColor,
        true,
        hoverColor,
        activeColor,
        ) {
            state.catalog.category = category
            state.catalog.sub_category = st.NoSubCategory.None
            state.catalog.scroll_offset = 0
            state.catalog.selected_item = nil
        }
    }
    subButtons: [dynamic]CatalogButton

    switch state.catalog.category {
    case .Weapon:
        subButtons = buttons.weapons
    case .Container:
        subButtons = buttons.containers
    case .Gear:
        subButtons = buttons.gear
    case .Armor:
        subButtons = buttons.clothing
    }

    for i in 0..<len(subButtons) {
        if comp.DrawButtonCol(
        &subButtons[i].button,
        style,
        state.catalog.sub_category == subButtons[i].value,
        bgColor,
        iconColor,
        iconBgColor,
        hoverColor,
        activeColor,
        true,
        hoverColor,
        activeColor,
        font_size_sub,
        ) {
            if state.catalog.sub_category == subButtons[i].value {
                state.catalog.sub_category = st.NoSubCategory.None
            } else {
                state.catalog.sub_category = subButtons[i].value
                state.catalog.scroll_offset = 0
                state.catalog.selected_item = nil
            }
        }
    }
}

CalcButtonWidth :: proc(total_width: f32, count: int, padding: f32) -> f32 {
    return (total_width - padding * f32(count + 1)) / f32(count)
}

LayoutCatalogButtonGroup :: proc(
    buttons: [dynamic]CatalogButton,
    rect: rl.Rectangle,
    y: f32,
    padding: f32,
) {
    temp := make([dynamic]comp.Button, len(buttons))
    defer delete(temp)

    for i in 0..<len(buttons) {
        temp[i] = buttons[i].button
    }

    comp.LayoutButtonsHorizontalRect(temp, rect, y, padding, padding, padding)

    for i in 0..<len(buttons) {
        buttons[i].button = temp[i]
    }
}