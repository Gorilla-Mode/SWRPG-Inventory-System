package view

import st "../core/state"
import ui "../ui"
import app "../core/app"
import rl "vendor:raylib"
import comp "../ui/component"
import inv "../core/inventory"
import str "core:strings"
import cstr "../utils/cstrings"

CatalogButton :: struct {
    button: comp.Button,
    value:  st.subCategory,
}

CatalogButtons :: struct {
    category:   [dynamic]comp.Button,
    weapons:    [dynamic]CatalogButton,
    containers: [dynamic]CatalogButton,
    gear:       [dynamic]CatalogButton,
    clothing:   [dynamic]CatalogButton,
}

DrawCatalog :: proc(state: ^st.state, style: ^ui.style) {
    layout := app.GetCatalogPageLayoutInfo(state, style.grid.cell_size)
    paddingElement: f32 = 2
    rect_left_x := layout.left.origin_x + app.PADDING
    rect_right := rl.Rectangle{
        x = layout.right.origin_x,
        y = layout.top_y,
        width = layout.right.width - app.PADDING,
        height = f32(state.window.height) - layout.top_y
    }
    rect_left := rl.Rectangle{
        x = rect_left_x,
        y = layout.top_y,
        width = layout.left.width - rect_left_x,
        height = f32(state.window.height) - layout.top_y
    }

    DrawCatalogItemStat(state, style, rect_right, layout)
    explorerBounds := DrawCatalogExplorer(state, style, layout, paddingElement, rect_left)
    DrawCatalogItemResults(state, style, layout, paddingElement, explorerBounds, rect_left)
}

DrawCatalogExplorer :: proc (state: ^st.state, style: ^ui.style, layout: app.CatalogPageLayout, paddingElement: f32, rect_left: rl.Rectangle) -> rl.Rectangle {
    bg_color      := style.colors.surface
    hover_color   := style.colors.secondary_hover
    active_color  := style.colors.success
    icon_color    := style.colors.text
    icon_bg_color := style.colors.secondary

    buttonWidthBase: f32 = (layout.left.width - app.PADDING )
    buttonHeight:    f32 = 32
    buttonSubHeight: f32 = 24

    buttonWidthCat       := CalcButtonWidth(buttonWidthBase, 4, paddingElement)
    buttonWidthWeapon    := CalcButtonWidth(buttonWidthBase, 7, paddingElement)
    buttonWidthContainer := CalcButtonWidth(buttonWidthBase, 5, paddingElement)
    buttonWidthGear      := CalcButtonWidth(buttonWidthBase, 5, paddingElement)
    buttonWidthClothing  := CalcButtonWidth(buttonWidthBase, 1, paddingElement)

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

    iconSubCategoryPos := rl.Vector2{layout.left.origin_x + app.PADDING + (paddingElement * 2), layout.top_y + searchBar.rect.height + (paddingElement * 5) + categoryFilterRect.height + searchBar.rect.height}
    categorySubFilterRect := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING + paddingElement,
        y = layout.top_y + searchBar.rect.height + (paddingElement * 4) + categoryFilterRect.height + searchBar.rect.height,
        width = layout.left.width - app.PADDING - (paddingElement * 2),
        height = textCategorySize.y + (paddingElement * 2),
    }
    textSubCategory: cstring = "Sub-Category"
    subCat_y: f32 = iconSubCategoryPos.y + categorySubFilterRect.height + (buttonHeight / 2) - ((buttonHeight - buttonSubHeight) / 2)
    cat_Y: f32 = layout.top_y + searchBar.rect.height + app.PADDING + textCategorySize.y + (paddingElement * 3)

    buttons := CatalogButtons{
        category   = CreateCategoryButtons(layout, style, buttonWidthCat, buttonHeight),
        weapons    = CreateWeaponButtons(layout, style, buttonWidthWeapon, buttonSubHeight),
        containers = CreateContainerButtons(layout, style, buttonWidthContainer, buttonSubHeight),
        gear       = CreateGearButtons(layout, style, buttonWidthGear, buttonSubHeight),
        clothing   = CreateClothingButtons(layout, style, buttonWidthClothing, buttonSubHeight),
    }
    defer{
        delete(buttons.category)
        delete(buttons.weapons)
        delete(buttons.containers)
        delete(buttons.gear)
        delete(buttons.clothing)
    }

    LayoutCatalogButtons(&buttons, rect_left, layout, subCat_y, cat_Y, paddingElement)

    rl.DrawRectangleRec(rect_left, style.colors.secondary)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "Catalog",
    ui.SnapVector2({layout.left.origin_x + app.PADDING, layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)

    if comp.UpdateTextField(&searchBar) do state.catalog.scroll_offset = 0
    comp.DrawTextField(&searchBar, style, "Search catalog...")

    rl.DrawRectangleRec(categoryFilterRect, style.colors.surface)
    rl.DrawTextureEx(style.icons[ui.Icons.gui_filter], iconCategoryPos, 0, ui.IconScale(textCategorySize.y), style.colors.text)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], textCategory, { iconCategoryPos.x + textCategorySize.y + paddingElement, iconCategoryPos.y }, f32(ui.font_size.label), 2, style.colors.text)

    rl.DrawRectangleRec(categorySubFilterRect, style.colors.surface)
    rl.DrawTextureEx(style.icons[ui.Icons.gui_filter], iconSubCategoryPos, 0, ui.IconScale(textCategorySize.y), style.colors.text)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], textSubCategory, { iconSubCategoryPos.x + textCategorySize.y + paddingElement, iconSubCategoryPos.y }, f32(ui.font_size.label), 2, style.colors.text)

    DrawCatalogButtons(state, style, &buttons, bg_color, icon_color, icon_bg_color, hover_color, active_color)

    bounds := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING,
        y = layout.top_y + searchBar.rect.height + (paddingElement * 2),
        width = layout.left.width - app.PADDING,
        height = ((paddingElement * 3) + categoryFilterRect.height + categorySubFilterRect.height + buttonHeight + buttonSubHeight),
    }

    return bounds
}

DrawCatalogItemResults :: proc(state: ^st.state, style: ^ui.style, layout: app.CatalogPageLayout, paddingElement: f32, filterBounds: rl.Rectangle, leftRect: rl.Rectangle) {
    posY: f32 = filterBounds.y + filterBounds.height + paddingElement + state.catalog.scroll_offset
    mousePos:= rl.GetMousePosition()
    entryHeight: f32 = 68
    keys := GetQueryRegistryKeys(state)
    defer delete(keys)

    if len(keys) == 0 do return

    bounds := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING,
        y = posY,
        width = layout.left.width - app.PADDING,
        height = paddingElement,
    }

    rl.BeginScissorMode(i32(leftRect.x),i32(filterBounds.y + filterBounds.height + paddingElement), i32(bounds.width), i32(state.window.height))
    defer rl.EndScissorMode()

    for key in keys {
        definition := &state.ItemDefinitionRegistry.items[key]
        if comp.DrawItemList(definition,
        style,
        state,
        layout.left.width - app.PADDING - paddingElement * 2,
        entryHeight,
        rl.Vector2{app.PADDING + paddingElement,
        posY}, mousePos,
    style.icons[definition.icon_enum],
        state.catalog.selected_item == definition) {
            if state.catalog.selected_item == definition do state.catalog.selected_item = nil
            else do state.catalog.selected_item = definition
        }

        posY += entryHeight + paddingElement
        bounds.height += entryHeight + paddingElement
    }


    if rl.CheckCollisionPointRec(mousePos, leftRect) {
        state.catalog.scroll_offset += rl.GetMouseWheelMove() * 30
        if state.catalog.scroll_offset >= 0 do state.catalog.scroll_offset = 0
        if (-1 * state.catalog.scroll_offset + 5) >= bounds.height do state.catalog.scroll_offset = -1 * (bounds.height - paddingElement - 5)
    }

}

GetQueryRegistryKeys :: proc(state: ^st.state) -> [dynamic]string{
    queryString := comp.TextBufferToString(state.textFields[.Catalog_Search].buffer)
    queryString = str.to_lower(queryString)
    keys: [dynamic]string

    for item in state.ItemDefinitionRegistry.items {
        itemName := str.to_lower(state.ItemDefinitionRegistry.items[item].name, context.temp_allocator)

        if state.ItemDefinitionRegistry.items[item].category != state.catalog.category{
            continue
        }

        if state.catalog.sub_category != st.NoSubCategory.None {
            switch data in state.ItemDefinitionRegistry.items[item].data {
            case inv.WeaponData:
                if state.catalog.sub_category != data.sub_category {
                    continue
                }
            case inv.ContainerData:
                if state.catalog.sub_category != data.sub_category {
                    continue
                }
            case inv.GearData:
                if state.catalog.sub_category != data.sub_category {
                    continue
                }
            }
        }

        if !str.contains(itemName, queryString) && queryString != "" {
            continue
        }

        append_elem(&keys, item)
    }

    return keys
}

DrawCatalogItemStat :: proc(state: ^st.state, style: ^ui.style, rect_right: rl.Rectangle, layout: app.CatalogPageLayout){
    padding: f32 = 2
    headerText := style.fonts.semibold[ui.font_size.header]
    headerTextSize := f32(ui.font_size.header)
    bounds := rl.Rectangle{
        x = rect_right.x + app.PADDING,
        y = rect_right.y,
        width = rect_right.width - app.PADDING,
        height = rect_right.height,
    }

    rl.DrawTextEx(headerText,
    "Statisitcs",
    ui.SnapVector2({bounds.x + padding, bounds.y - headerTextSize - 2}),
    headerTextSize,
    2,
    style.colors.text)

    DrawCatalogBaseItemStat(state, style, bounds, layout)

}

DrawCatalogBaseItemStat :: proc(state: ^st.state, style: ^ui.style, rect: rl.Rectangle, layout: app.CatalogPageLayout) -> rl.Rectangle{
    bounds          := rect
    item            := state.catalog.selected_item
    headerFont      := style.fonts.semibold[ui.font_size.header]
    headerFontSize  := f32(headerFont.baseSize)
    padding         : f32 = 2
    textCol         := style.colors.text
    secondaryCol    := style.colors.secondary
    nameRect := rl.Rectangle{bounds.x, bounds.y, bounds.width, 32}
    itemViewRect := rl.Rectangle{nameRect.x, nameRect.y + nameRect.height + (padding * 3), 256, 512}
    defaultFont     := style.fonts.regular[ui.font_size.default]
    defaultFontSize := f32(defaultFont.baseSize)
    captionFont     := style.fonts.regular[ui.font_size.caption]
    captionFontSize := f32(captionFont.baseSize)

    rl.DrawLineEx({nameRect.x, nameRect.y + (padding / 2)}, {nameRect.x + nameRect.width, nameRect.y + (padding / 2)}, 2, style.colors.secondary)
    if item == nil{
        errorText: cstring = "No item selected"
        errorTextSize := rl.MeasureTextEx(style.fonts.semibold[ui.font_size.default], errorText, f32(ui.font_size.default), 2)
        rl.DrawTextEx(headerFont,
        errorText,
        ui.SnapVector2({layout.right.center_x - (errorTextSize.x / 2), bounds.height / 2}),
        headerFontSize,
        2,
        { textCol.r, textCol.g, textCol.b, 100 })

        return bounds
    }

    itemStr := state.CStringRegistry.items[item.id]

    rl.DrawTextEx(headerFont,
    itemStr.name,
    ui.SnapVector2({nameRect.x, nameRect.y - (headerFontSize / 2) + (nameRect.height / 2)}),
    headerFontSize,
    4,
    style.colors.text)
    rl.DrawLineEx({nameRect.x, nameRect.y + nameRect.height + padding + (padding / 2)},
    {nameRect.x + nameRect.width, nameRect.y + nameRect.height + padding + (padding / 2)},
    2,
    { secondaryCol.r, secondaryCol.g, secondaryCol.b, 128 })

    rl.DrawRectangleLinesEx(itemViewRect, 2, style.colors.primary)
    rl.DrawTextureEx(style.icons[item.icon_enum], {itemViewRect.x + (padding * 2), itemViewRect.y + (padding * 2)}, 0, ui.IconScale(itemViewRect.width - (padding * 4)), textCol)

    descriptionText := itemStr.description
    descriptionTextSize := rl.MeasureTextEx(defaultFont, descriptionText, defaultFontSize, 0)
    textPos := ui.SnapVector2({itemViewRect.x + itemViewRect.width + padding, itemViewRect.y})

    rl.DrawTextEx(defaultFont, descriptionText, textPos, defaultFontSize, 0, textCol)
    rl.DrawLineEx({textPos.x, textPos.y + descriptionTextSize.y + padding},
    {bounds.x + bounds.width, textPos.y + descriptionTextSize.y + padding},
    2,
    style.colors.primary)

    baseItemDataHeight: f32 = 72
    baseItemDataWidth: f32 = 156
    itemEconomyRect := rl.Rectangle{textPos.x, textPos.y + descriptionTextSize.y + (padding * 2 + 1), baseItemDataWidth, baseItemDataHeight}
    economyStrings := CatalogItemStatGetEconomyStrings(itemStr)
    priceSize := rl.MeasureTextEx(defaultFont, economyStrings.restricted, defaultFontSize, 0)
    if (priceSize.x + padding * 4) > itemEconomyRect.width do itemEconomyRect.width = priceSize.x + padding * 4

    itemSizeRect := rl.Rectangle{textPos.x + itemEconomyRect.width + padding, textPos.y + descriptionTextSize.y + (padding * 2 + 1), baseItemDataWidth, baseItemDataHeight}
    itemMetaRect := rl.Rectangle{textPos.x + itemEconomyRect.width + itemSizeRect.width + (padding * 2), textPos.y + descriptionTextSize.y + (padding * 2 + 1), baseItemDataWidth, baseItemDataHeight}
    economyTextPos := ui.SnapVector2({itemEconomyRect.x + (padding * 2), itemEconomyRect.y + padding + defaultFontSize})

    rl.DrawRectangleLinesEx(itemEconomyRect, 2, style.colors.primary)
    rl.DrawTextEx(captionFont, "Economy", {itemEconomyRect.x + (padding * 2), itemEconomyRect.y + padding }, captionFontSize, 2, textCol)
    rl.DrawTextEx(defaultFont,  economyStrings.base_price, economyTextPos, defaultFontSize, 0, textCol)
    rl.DrawTextEx(defaultFont,  economyStrings.rarity, {economyTextPos.x, economyTextPos.y + defaultFontSize }, defaultFontSize, 0, textCol)
    rl.DrawTextEx(defaultFont,  economyStrings.restricted, {economyTextPos.x, economyTextPos.y + (defaultFontSize * 2) + padding}, defaultFontSize, 0, textCol)

    rl.DrawRectangleLinesEx(itemSizeRect, 2, style.colors.primary)
    rl.DrawTextEx(captionFont, "Size", {itemSizeRect.x + (padding * 2), itemSizeRect.y + padding }, captionFontSize, 2, textCol)
    rl.DrawTextEx(defaultFont,  itemStr.width, {itemSizeRect.x + (padding * 2), itemSizeRect.y + padding + defaultFontSize }, defaultFontSize, 0, textCol)
    rl.DrawTextEx(defaultFont,  itemStr.height, {itemSizeRect.x + (padding * 2), itemSizeRect.y + padding + (defaultFontSize * 2)}, defaultFontSize, 0, textCol)

    rl.DrawRectangleLinesEx(itemMetaRect, 2, style.colors.primary)
    rl.DrawTextEx(captionFont, "Metadata", {itemMetaRect.x + (padding * 2), itemMetaRect.y + padding }, captionFontSize, 2, textCol)
    rl.DrawTextEx(defaultFont,  itemStr.category, {itemMetaRect.x + (padding * 2), itemMetaRect.y + padding + defaultFontSize }, defaultFontSize, 0, textCol)
    rl.DrawTextEx(defaultFont,  itemStr.sub_category, {itemMetaRect.x + (padding * 2), itemMetaRect.y + padding + (defaultFontSize * 2)}, defaultFontSize, 0, textCol)

//    rl.DrawTextEx(defaultFont,  itemStr.hardpoints, {textPos.x, textPos.y + (descriptionTextSize.y * 4) + (padding * 2)}, defaultFontSize, 0, textCol)
//    rl.DrawTextEx(defaultFont,  itemStr.width, {textPos.x, textPos.y + (descriptionTextSize.y * 5) + (padding * 2)}, defaultFontSize, 0, textCol)
//    rl.DrawTextEx(defaultFont,  itemStr.height, {textPos.x, textPos.y + (descriptionTextSize.y * 6) + (padding * 2)}, defaultFontSize, 0, textCol)

    return bounds
}

CatalogItemStatGetEconomyStrings :: proc(itemStr: inv.ItemCstring) -> struct{
    base_price,
    proj_price,
    rarity,
    restricted: cstring
}{
    return {
        base_price = cstr.Concat("Price: ", itemStr.base_price, context.temp_allocator),
        proj_price = cstr.Concat("Price: ", itemStr.base_price, context.temp_allocator), //TODO: Implement projected price calculation
        rarity     = cstr.Concat("Rarity: ", itemStr.base_rarity, context.temp_allocator),
        restricted = cstr.Concat("Legality: ", itemStr.restricted, context.temp_allocator)
    }
}