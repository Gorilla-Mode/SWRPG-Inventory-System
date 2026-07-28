package view

import st "../core/state"
import ui "../ui"
import app "../core/app"
import rl "vendor:raylib"
import comp "../ui/component"
import inv "../core/inventory"
import str "core:strings"
import "core:strconv"
import "core:fmt"
import cstr "../utils/cstrings"
import m "core:math"

@(private)
CatalogButton :: struct {
    button: comp.Button,
    value:  st.subCategory,
}

@(private)
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

@(private="file")
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
    buttonWidthClothing  := CalcButtonWidth(buttonWidthBase, 6, paddingElement)

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

@(private="file")
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
            CatalogResetPurchaseState(state)
        }

        posY += entryHeight + paddingElement
        bounds.height += entryHeight + paddingElement
    }


    if rl.CheckCollisionPointRec(mousePos, leftRect) {
        state.catalog.scroll_offset += rl.GetMouseWheelMove() * 30
        if state.catalog.scroll_offset >= 0 do state.catalog.scroll_offset = 0
        if m.abs(state.catalog.scroll_offset) + 5 >= bounds.height do state.catalog.scroll_offset = -(bounds.height - paddingElement - 5)
    }

}

@(private="file")
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
            case inv.ArmorData:
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

@(private="file")
DrawCatalogItemStat :: proc(state: ^st.state, style: ^ui.style, rect_right: rl.Rectangle, layout: app.CatalogPageLayout) {
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

    boundsHeader, itemSelected := DrawItemCatalogHeader(bounds, style, state, layout, state.debug)
    if itemSelected {
        boundsView     := DrawCatalogItemView(boundsHeader, style, state, state.debug)
        boxesBounds    := DrawCatalogStatBoxes(state, style, boundsView, layout, state.debug)
        dataBounds     := DrawCatalogItemData(state, style, boxesBounds, layout, state.debug)
        sectionsBounds := DrawCatalogQualitiesAndFeatures(state, style, dataBounds, layout, boxesBounds.width, state.debug)
        _ = DrawCatalogDescription(state, style, sectionsBounds, layout, boxesBounds.width, state.debug)
        _ = DrawCatalogPurchaseControls(state, style, boundsView)
    }
}

@(private="file")
DrawItemCatalogHeader :: proc(rect: rl.Rectangle, style: ^ui.style, state: ^st.state, layout: app.CatalogPageLayout, debug: bool = false) -> (rl.Rectangle, bool){
    nameRect       := rl.Rectangle{rect.x, rect.y, rect.width, 32}
    bounds         := nameRect
    textCol        := style.colors.text
    item           := state.catalog.selected_item
    headerFont     := style.fonts.semibold[ui.font_size.header]
    headerFontSize := f32(headerFont.baseSize)
    padding        : f32 = 2
    secondaryCol   := style.colors.secondary

    rl.DrawLineEx({nameRect.x, nameRect.y + (padding / 2)}, {nameRect.x + nameRect.width, nameRect.y + (padding / 2)}, 2, style.colors.secondary)
    if item == nil{
        errorText: cstring = "No item selected"
        errorTextSize := rl.MeasureTextEx(style.fonts.semibold[ui.font_size.default], errorText, f32(ui.font_size.default), 2)
        errorPos := ui.SnapVector2({layout.right.center_x - (errorTextSize.x / 2), rect.height / 2})
        rl.DrawTextEx(headerFont,
        errorText,
        errorPos,
        headerFontSize,
        2,
        { textCol.r, textCol.g, textCol.b, 100 })

        bounds.height = rect.height / 2 - headerFontSize - nameRect.height
        if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
        return bounds, false
    }

    itemStr := state.CStringRegistry.items[item.id]

    rl.DrawTextEx(headerFont,
    itemStr.name,
    ui.SnapVector2({nameRect.x, nameRect.y - (headerFontSize / 2) + (nameRect.height / 2)}),
    headerFontSize,
    4,
    style.colors.text)
    rl.DrawLineEx({nameRect.x, nameRect.y + nameRect.height },
    {nameRect.x + nameRect.width, nameRect.y + nameRect.height },
    2,
    { secondaryCol.r, secondaryCol.g, secondaryCol.b, 128 })


    bounds.height += padding / 2
    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds, true
}

@(private="file")
DrawCatalogItemView :: proc(rect: rl.Rectangle, style: ^ui.style, state: ^st.state, debug: bool = false) -> rl.Rectangle {
    padding : f32 = 2
    bounds  := rl.Rectangle{rect.x, rect.y + rect.height + padding, 256, 512}
    item    := state.catalog.selected_item
    textCol := style.colors.text

    rl.DrawRectangleLinesEx(bounds, 2, style.colors.primary)
    rl.DrawTextureEx(style.icons[item.icon_enum], {bounds.x + (padding * 2), bounds.y + (padding * 2)}, 0, ui.IconScale(bounds.width - (padding * 4)), textCol)

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
DrawCatalogStatBoxes :: proc(state: ^st.state, style: ^ui.style, rect: rl.Rectangle, layout: app.CatalogPageLayout, debug: bool = false) -> rl.Rectangle {
    item            := state.catalog.selected_item
    padding         : f32 = 2
    textCol         := style.colors.text
    defaultFont     := style.fonts.regular[ui.font_size.default]
    defaultFontSize := f32(defaultFont.baseSize)
    captionFont     := style.fonts.regular[ui.font_size.caption]
    captionFontSize := f32(captionFont.baseSize)

    itemStr := state.CStringRegistry.items[item.id]
    textPos := ui.SnapVector2({rect.x + rect.width + padding * 2, rect.y})

    baseItemDataHeight: f32 = 92
    baseItemDataWidth: f32 = (state.window.width - textPos.x - app.PADDING - (padding * 2)) / 3
    maxItemDataWidth: f32 = (1920 - textPos.x - app.PADDING - (padding * 2)) / 3
    if baseItemDataWidth > maxItemDataWidth do baseItemDataWidth = maxItemDataWidth
    itemEconomyRect := rl.Rectangle{textPos.x, textPos.y, baseItemDataWidth, baseItemDataHeight}
    itemSizeRect := rl.Rectangle{}
    itemMetaRect := rl.Rectangle{}

    economyStrings := CatalogItemStatGetEconomyStrings(itemStr, state.catalog.selected_item)
    sizeStrings    := CatalogItemStatGetSizeStrings(itemStr, state.catalog.selected_item)
    metaStrings    := CatalogItemStatGetMetaStrings(itemStr)

    restrictedSize := rl.MeasureTextEx(defaultFont, economyStrings.restricted, defaultFontSize, 0)
    prizeSize := rl.MeasureTextEx(defaultFont, economyStrings.proj_price, defaultFontSize, 0)
    economySize := prizeSize.x > restrictedSize.x ? prizeSize.x : restrictedSize.x
    subCatSize := rl.MeasureTextEx(defaultFont, metaStrings.sub_category, defaultFontSize, 0)

    if (economySize + padding * 6 + defaultFontSize) > baseItemDataWidth{
        itemEconomyRect.width = economySize + padding * 6 + defaultFontSize
        diff := itemEconomyRect.width - baseItemDataWidth
        itemSizeRect.width -= diff
    }

    itemSizeRect = rl.Rectangle{textPos.x + itemEconomyRect.width + padding, textPos.y, baseItemDataWidth + itemSizeRect.width, baseItemDataHeight}
    itemMetaRect = rl.Rectangle{textPos.x + itemEconomyRect.width + itemSizeRect.width + (padding * 2), textPos.y, baseItemDataWidth, baseItemDataHeight}
    if (subCatSize.x + padding * 6 + defaultFontSize) > itemMetaRect.width do itemMetaRect.width = subCatSize.x + padding * 6 + defaultFontSize

    massStr := item.mass_g <= 1000 ? sizeStrings.mass_g : sizeStrings.mass_kg

    rl.DrawRectangleLinesEx(itemEconomyRect, 2, style.colors.primary)
    rl.DrawTextEx(captionFont, "Economy", {itemEconomyRect.x + (padding * 2), itemEconomyRect.y + padding }, captionFontSize, 2, textCol)
    economyTextPos := ui.SnapVector2({itemEconomyRect.x + (padding * 2), itemEconomyRect.y + padding + captionFontSize + padding})
    CatalogItemStatDrawField(style, ui.Icons.economy_restricted, defaultFont, economyStrings.restricted, economyTextPos, textCol, textCol)
    CatalogItemStatDrawField(style, ui.Icons.economy_rarity, defaultFont,  economyStrings.rarity, {economyTextPos.x, economyTextPos.y + defaultFontSize + padding}, textCol, textCol)
    CatalogItemStatDrawField(style, ui.Icons.economy_credit, defaultFont,  economyStrings.base_price, {economyTextPos.x, economyTextPos.y + (defaultFontSize + padding) * 2}, textCol, textCol)
    projPriceSeperatorLine := rl.Vector2{itemEconomyRect.x + (padding * 2),  itemEconomyRect.y + padding + captionFontSize + (padding * 3) + (defaultFontSize * 3) + padding}
    rl.DrawLineEx(projPriceSeperatorLine, {projPriceSeperatorLine.x + itemEconomyRect.width - (padding * 4), projPriceSeperatorLine.y}, 2, style.colors.primary)
    CatalogItemStatDrawField(style, ui.Icons.economy_credit, defaultFont,  economyStrings.proj_price, {economyTextPos.x, economyTextPos.y + (defaultFontSize + padding) * 3 + padding}, textCol, textCol)
    defer comp.ToolTipVec2("Projected price calculated from rarity, legality and base price\nPrice = (Base price * rarity) / 4 or 2 if restricted",
    {economyTextPos.x, economyTextPos.y + (defaultFontSize + padding) * 3 + padding},
    rl.MeasureTextEx(defaultFont, economyStrings.proj_price, defaultFontSize, 0) + defaultFontSize,
    style,
    false)

    rl.DrawRectangleLinesEx(itemSizeRect, 2, style.colors.primary)
    rl.DrawTextEx(captionFont, "Size", {itemSizeRect.x + (padding * 2), itemSizeRect.y + padding }, captionFontSize, 2, textCol)
    sizeTextPos := ui.SnapVector2({itemSizeRect.x + (padding * 2), itemSizeRect.y + padding + captionFontSize + padding})
    CatalogItemStatDrawField(style, .item_generic_width, defaultFont, sizeStrings.width, sizeTextPos, textCol, textCol)
    CatalogItemStatDrawField(style, .item_generic_height, defaultFont, sizeStrings.height, {sizeTextPos.x, sizeTextPos.y + defaultFontSize + padding}, textCol, textCol)
    CatalogItemStatDrawField(style, .item_generic_area, defaultFont,  sizeStrings.area, {sizeTextPos.x, sizeTextPos.y + (defaultFontSize + padding) * 2}, textCol, textCol)
    CatalogItemStatDrawField(style, .item_generic_mass, defaultFont,  massStr, {sizeTextPos.x, sizeTextPos.y + (defaultFontSize + padding) * 3}, textCol, textCol)

    rl.DrawRectangleLinesEx(itemMetaRect, 2, style.colors.primary)
    rl.DrawTextEx(captionFont, "Meta", {itemMetaRect.x + (padding * 2), itemMetaRect.y + padding }, captionFontSize, 2, textCol)
    metaTextPos := ui.SnapVector2({itemMetaRect.x + (padding * 2), itemMetaRect.y + padding + captionFontSize + padding})
    CatalogItemStatDrawField(style, CatalogItemStatGetCategoryIcon(item.category), defaultFont,  metaStrings.category, metaTextPos, textCol, textCol)
    CatalogItemStatDrawField(style, CatalogItemStatGetSubCategoryIcon(item), defaultFont, metaStrings.sub_category, {metaTextPos.x, metaTextPos.y + defaultFontSize + padding}, textCol, textCol)

    contentRight := itemEconomyRect.x + itemEconomyRect.width
    if (itemSizeRect.x + itemSizeRect.width) > contentRight do contentRight = itemSizeRect.x + itemSizeRect.width
    if (itemMetaRect.x + itemMetaRect.width) > contentRight do contentRight = itemMetaRect.x + itemMetaRect.width

    bounds := rl.Rectangle{
        x = textPos.x,
        y = textPos.y,
        width = contentRight - textPos.x,
        height = baseItemDataHeight,
    }

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
DrawCatalogQualitiesAndFeatures :: proc(state: ^st.state, style: ^ui.style, rect: rl.Rectangle, layout: app.CatalogPageLayout, max_width: f32, debug: bool = false) -> rl.Rectangle {
    item            := state.catalog.selected_item
    itemStr         := state.CStringRegistry.items[item.id]
    padding         : f32 = 2
    textCol         := style.colors.text
    defaultFont     := style.fonts.regular[ui.font_size.default]
    defaultFontSize := f32(defaultFont.baseSize)
    captionFont     := style.fonts.regular[ui.font_size.caption]
    captionFontSize := f32(captionFont.baseSize)

    sectionsY := rect.y + rect.height + (padding * 2)
    sectionBottom: f32 = 0
    hasSections := false

    columnWidth := max_width / 3

    if len(itemStr.qualities) > 0 {
        qualitiesTextPos := ui.SnapVector2({rect.x + padding, sectionsY})
        qualitiesText := cstr.FormatArray(itemStr.qualities, "- ", "\n", context.temp_allocator)
        qualitiesTextSize := rl.MeasureTextEx(defaultFont, qualitiesText, defaultFontSize, 0)
        rl.DrawTextEx(captionFont, "Qualities", {qualitiesTextPos.x, qualitiesTextPos.y + padding}, captionFontSize, 2, textCol)
        rl.DrawTextEx(defaultFont, qualitiesText, {qualitiesTextPos.x, qualitiesTextPos.y + captionFontSize + padding}, defaultFontSize, 0, textCol)
        sectionBottom = qualitiesTextSize.y + (padding * 2)
        hasSections = true
    }

    if len(itemStr.features) > 0 {
        featuresTextPos := ui.SnapVector2({rect.x + columnWidth + padding, sectionsY})
        featuresText := cstr.FormatArray(itemStr.features, "", "\n", context.temp_allocator, (columnWidth * 2 - padding * 2), defaultFont, 2)
        featuresTextSize := rl.MeasureTextEx(defaultFont, featuresText, defaultFontSize, 0)
        rl.DrawTextEx(captionFont, "Features", {featuresTextPos.x, featuresTextPos.y + padding}, captionFontSize, 2, textCol)
        rl.DrawTextEx(defaultFont, featuresText, {featuresTextPos.x + rl.MeasureTextEx(defaultFont, "-", defaultFontSize, 0).x, featuresTextPos.y + captionFontSize + padding }, defaultFontSize, 0, textCol)
        featuresSectionHeight := featuresTextSize.y + (padding * 2)
        if featuresSectionHeight > sectionBottom do sectionBottom = featuresSectionHeight
        hasSections = true
    }

    if !hasSections do return rl.Rectangle{rect.x, rect.y + rect.height, rect.width, 0}

    rl.DrawLineEx({rect.x, rect.y + rect.height + sectionBottom}, {rect.x + max_width, rect.y + rect.height + sectionBottom}, 2, style.colors.primary)

    bounds := rl.Rectangle{
        x = rect.x,
        y = sectionsY,
        width = max_width,
        height = sectionBottom,
    }

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
DrawCatalogDescription :: proc(state: ^st.state, style: ^ui.style, rect: rl.Rectangle, layout: app.CatalogPageLayout, max_width: f32, debug: bool = false) -> rl.Rectangle {
    item            := state.catalog.selected_item
    itemStr         := state.CStringRegistry.items[item.id]
    padding         : f32 = 2
    textCol         := style.colors.text
    defaultFont     := style.fonts.regular[ui.font_size.default]
    defaultFontSize := f32(defaultFont.baseSize)
    captionFont     := style.fonts.regular[ui.font_size.caption]
    captionFontSize := f32(captionFont.baseSize)

    descriptionText := cstr.WrapMono(itemStr.description, max_width, defaultFont, 0, context.temp_allocator)
    descriptionTextY := rect.y + rect.height + padding
    descriptionPos := rl.Vector2{rect.x + padding * 2, descriptionTextY + captionFontSize}
    descriptionSize := rl.MeasureTextEx(defaultFont, descriptionText, defaultFontSize, 0)
    rl.DrawTextEx(captionFont, "Description", {rect.x + padding, descriptionTextY}, captionFontSize, 2, textCol)
    rl.DrawTextEx(defaultFont, descriptionText, descriptionPos, defaultFontSize, 0, textCol)

    bounds := rl.Rectangle{
        x = rect.x,
        y = descriptionTextY,
        width = max_width,
        height = (descriptionPos.y + descriptionSize.y) - descriptionTextY,
    }

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
CatalogItemStatDrawField :: proc(style: ^ui.style, icon: ui.Icons, font: rl.Font, text: cstring, pos: rl.Vector2, textCol: rl.Color, iconCol: rl.Color, gap: f32 = 2) {
    iconSize := f32(font.baseSize)
    iconPos := ui.SnapVector2(pos)
    rl.DrawTextureEx(style.icons[icon], iconPos, 0, ui.IconScale(iconSize), iconCol)
    rl.DrawTextEx(font, text, {iconPos.x + iconSize + gap, iconPos.y}, f32(font.baseSize), 0, textCol)
}

@(private="file")
CatalogItemStatGetCategoryIcon :: proc(category: inv.ItemCategory) -> ui.Icons {
    switch category {
    case .Weapon:
        return ui.Icons.category_weapons
    case .Gear:
        return ui.Icons.category_gear
    case .Armor:
        return ui.Icons.category_clothing
    case .Container:
        return ui.Icons.category_container
    }
    return ui.Icons.gui_info
}

@(private="file")
CatalogItemStatGetSubCategoryIcon :: proc(item: ^inv.Item) -> ui.Icons {
    switch data in item.data {
    case inv.WeaponData:
        switch data.sub_category {
        case .Pistol:
            return ui.Icons.item_weapon_type_pistol
        case .Rifle:
            return ui.Icons.item_weapon_type_rifle
        case .Gunnery:
            return ui.Icons.item_weapon_type_gunnery
        case .Explosive:
            return ui.Icons.item_weapon_type_explosive
        case .Blade:
            return ui.Icons.item_weapon_type_blade
        case .Blunt:
            return ui.Icons.item_weapon_type_blunt
        case .Lightsaber:
            return ui.Icons.item_weapon_type_lightsaber
        }
    case inv.ContainerData:
        switch data.sub_category {
        case .Belt:
            return ui.Icons.category_belt
        case .Backpack:
            return ui.Icons.category_storage
        case .Holster:
            return ui.Icons.category_holster
        case .Bandolier:
            return ui.Icons.category_bandolier
        case .Container:
            return ui.Icons.category_container
        }
    case inv.GearData:
        return ui.Icons.category_gear
    case inv.ArmorData:
        return ui.Icons.category_clothing
    }
    return ui.Icons.gui_info
}

@(private="file")
CatalogItemStatGetEconomyStrings :: proc(itemStr: inv.ItemCstring, item: ^inv.Item) -> struct{
    base_price,
    proj_price,
    rarity,
    restricted: cstring
}{
    return {
        base_price = cstr.Concat("Price:    ", itemStr.base_price, context.temp_allocator),
        proj_price = cstr.Concat(cstr.Concat("Projected:", cstr.FormatCurrency(inv.ItemTotalPrice(item, item.base_rarity)), context.temp_allocator), "cr", context.temp_allocator), // Milde moses
        rarity     = cstr.Concat("Rarity:   ", itemStr.base_rarity, context.temp_allocator),
        restricted = cstr.Concat("Status:   ", itemStr.restricted, context.temp_allocator)
    }
}

@(private="file")
CatalogItemStatGetSizeStrings :: proc(itemStr: inv.ItemCstring, item: ^inv.Item) -> struct{
    width,
    height,
    mass_g,
    mass_kg,
    area: cstring
}{
    return {
        width   = cstr.Concat("Width: ", itemStr.width, context.temp_allocator),
        height  = cstr.Concat("Height:", itemStr.height, context.temp_allocator),
        mass_g  = cstr.Concat("Mass:  ", itemStr.mass_g, context.temp_allocator),
        mass_kg = cstr.Concat("Mass:  ", itemStr.mass_kg, context.temp_allocator),
        area    = cstr.Concat("Area:  ", cstr.IntToCString(inv.ItemArea(item), context.temp_allocator), context.temp_allocator)
    }
}

@(private="file")
CatalogItemStatGetMetaStrings :: proc(itemStr: inv.ItemCstring) -> struct{
    category,
    sub_category: cstring
}{
    return {
        category     = cstr.Concat("Category:", itemStr.category, context.temp_allocator),
        sub_category = cstr.Concat("Sub-Cat: ", itemStr.sub_category, context.temp_allocator),
    }
}

@(private="file")
DrawCatalogItemData :: proc(state: ^st.state, style: ^ui.style, rect: rl.Rectangle, layout: app.CatalogPageLayout, debug: bool = false) -> rl.Rectangle {
    item := state.catalog.selected_item
    if item == nil do return rl.Rectangle{}

    padding: f32 = 2
    bounds := rl.Rectangle{rect.x, rect.y + rect.height + padding, rect.width, 0}

    headerText: cstring = "Data"
    boxSize: f32 = 68
    rl.DrawTextEx(style.fonts.semibold[.default], headerText, {bounds.x + padding, bounds.y}, f32(ui.font_size.default), 2, style.colors.text)
    bounds.height += rl.MeasureTextEx(style.fonts.semibold[.default], headerText, f32(ui.font_size.default), 2).y + padding
//  rl.DrawLineEx({bounds.x, bounds.y + bounds.height - padding / 2}, {bounds.x + bounds.width, bounds.y + bounds.height - padding / 2}, 2, style.colors.primary)

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})

    switch data in item.data {
    case inv.WeaponData:
        return DrawCatalogWeaponData(state, style, item, bounds, layout, boxSize, debug)
    case inv.ContainerData:
        return DrawCatalogContainerData(state, style, item, bounds, layout, boxSize, debug)
    case inv.GearData:
        return DrawCatalogGearData(state, style, item, bounds, layout, boxSize, debug)
    case inv.ArmorData:
        return DrawCatalogArmorData(state, style, item, bounds, layout, boxSize, debug)
    case:
        return bounds
    }
}

@(private="file")
DrawCatalogWeaponData :: proc(state: ^st.state, style: ^ui.style, item: ^inv.Item, rect: rl.Rectangle, layout: app.CatalogPageLayout, box_size: f32, debug: bool = false) -> rl.Rectangle {
    padding: f32 = 2
    bounds := rl.Rectangle{rect.x, rect.y + rect.height + padding, box_size, box_size}
    itemStrings := state.CStringRegistry.items[item.id]
    fontCount := style.fonts.bold[.title]
    fontText := style.fonts.semibold[.default]
    weaponDataStr := itemStrings.data.(inv.WeaponDataCstring)

    comp.DrawStatBox({bounds.x, bounds.y}, style, box_size, fontCount, "Damage", weaponDataStr.damage, debug)
    bounds.width += padding

    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Critical", weaponDataStr.crit, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Range", weaponDataStr.range, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Hardpoint", itemStrings.hardpoints, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontText, "Skill", weaponDataStr.skill, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontText, "Band", weaponDataStr.rangeband, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontText, "Scale", weaponDataStr.scale, debug).width

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
DrawCatalogContainerData :: proc(state: ^st.state, style: ^ui.style, item: ^inv.Item, rect: rl.Rectangle, layout: app.CatalogPageLayout, box_size: f32, debug: bool = false) -> rl.Rectangle {
    padding: f32 = 2
    bounds := rl.Rectangle{rect.x, rect.y + rect.height + padding, box_size, box_size}
    itemStrings := state.CStringRegistry.items[item.id]
    fontCount := style.fonts.bold[.title]
    containerDataStr := itemStrings.data.(inv.ContainerDataCstring)
    containerData := item.data.(inv.ContainerData).containerDef.storage.(inv.ContainerGrid)

    comp.DrawStatBox({bounds.x, bounds.y}, style, box_size, fontCount, "Width", containerDataStr.width, debug)
    bounds.width += padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Height", containerDataStr.height, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Area", cstr.IntToCString(i32(containerData.width * containerData.height), context.temp_allocator), debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Hardpoint", itemStrings.hardpoints, debug).width

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
DrawCatalogGearData :: proc(state: ^st.state, style: ^ui.style, item: ^inv.Item, rect: rl.Rectangle, layout: app.CatalogPageLayout, box_size: f32, debug: bool = false) -> rl.Rectangle {
    padding: f32 = 2
    bounds := rl.Rectangle{rect.x, rect.y + rect.height + padding, box_size, box_size}
    itemStrings := state.CStringRegistry.items[item.id]
    fontCount := style.fonts.bold[.title]
//    gearDataStr := itemStrings.data.(inv.ContainerDataCstring)

    comp.DrawStatBox({bounds.x, bounds.y}, style, box_size, fontCount, "Hardpoint", itemStrings.hardpoints, debug)

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
DrawCatalogArmorData :: proc(state: ^st.state, style: ^ui.style, item: ^inv.Item, rect: rl.Rectangle, layout: app.CatalogPageLayout, box_size: f32, debug: bool = false) -> rl.Rectangle {
    padding: f32 = 2
    bounds := rl.Rectangle{rect.x, rect.y + rect.height + padding, box_size, box_size}
    itemStrings := state.CStringRegistry.items[item.id]
    fontCount := style.fonts.bold[.title]
    armorDataStr := itemStrings.data.(inv.ArmorDataCstring)

    comp.DrawStatBox({bounds.x, bounds.y}, style, box_size, fontCount, "Soak", armorDataStr.soak, debug)
    bounds.width += padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Ranged Def", armorDataStr.defense_ranged, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Melee Def", armorDataStr.defense_melee, debug).width + padding
    bounds.width += comp.DrawStatBox({bounds.x + bounds.width, bounds.y}, style, box_size, fontCount, "Hardpoint", itemStrings.hardpoints, debug).width

    if debug do rl.DrawRectangleRec(bounds, {255, 0, 0, 64})
    return bounds
}

@(private="file")
CatalogUpdateTextFields :: proc(state: ^st.state) {
	priceStr := fmt.tprintf("%d", state.catalog.purchase_at)
	markupStr := fmt.tprintf("%.0f", state.catalog.purchase_markup)

	if _, ok := state.textFields[.Catalog_Purchase_Price]; !ok {
		state.textFields[.Catalog_Purchase_Price] = {
			is_active              = false,
			backspace_repeat_timer = 0.05,
			backspace_timer        = 0.5,
		}
	}
	if _, ok := state.textFields[.Catalog_Purchase_Markup]; !ok {
		state.textFields[.Catalog_Purchase_Markup] = {
			is_active              = false,
			backspace_repeat_timer = 0.05,
			backspace_timer        = 0.5,
		}
	}

	fieldPrice := comp.TextField{
		state = &state.textFields[.Catalog_Purchase_Price],
	}
	comp.TextFieldSet(&fieldPrice, priceStr)

	fieldMarkup := comp.TextField{
		state = &state.textFields[.Catalog_Purchase_Markup],
	}
	comp.TextFieldSet(&fieldMarkup, markupStr)
}

CatalogResetPurchaseState :: proc(state: ^st.state) {
	if state.catalog.selected_item != nil {
		state.catalog.purchase_rarity = state.catalog.selected_item.base_rarity
		if state.catalog.purchase_rarity < 1 do state.catalog.purchase_rarity = 1
		state.catalog.purchase_restricted = state.catalog.selected_item.restricted
		state.catalog.purchase_markup = 100
		state.catalog.purchase_at = CalculatePurchasePrice(state)
	} else {
		state.catalog.purchase_rarity = 1
		state.catalog.purchase_restricted = false
		state.catalog.purchase_markup = 100
		state.catalog.purchase_at = 0
	}
	CatalogUpdateTextFields(state)
}

@(private="file")
CalculatePurchasePrice :: proc(state: ^st.state) -> i64 {
	item := state.catalog.selected_item
	if item == nil do return 0

	base := inv.ItemTotalPrice(item, state.catalog.purchase_rarity)
	return i64(f32(base) * (state.catalog.purchase_markup / 100.0))
}

@(private="file")
DrawCatalogPurchaseControls :: proc(state: ^st.state, style: ^ui.style, rect: rl.Rectangle) -> rl.Rectangle {
	padding: f32 = 2
	item := state.catalog.selected_item
	if item == nil do return rl.Rectangle{}

	controlHeight: f32 = 32
	labelHeight := f32(ui.font_size.label)
	labelFont := style.fonts.semibold[ui.font_size.label]

	innerPadding: f32 = 2

	h: f32 = innerPadding
	h += labelHeight + padding + controlHeight
	h += padding
	h += labelHeight + padding + 32
	h += padding
	h += labelHeight + padding + controlHeight
	h += padding
	h += controlHeight
	h += innerPadding

	bounds := rl.Rectangle{rect.x, rect.y + rect.height + padding, rect.width, h}

	rl.DrawRectangleRec(bounds, style.colors.secondary)

	currentY := bounds.y + innerPadding
	currentX := bounds.x + innerPadding
	innerWidth := bounds.width - innerPadding * 2

    priceLabelText: cstring = "Price"
    priceLabelTextSize := rl.MeasureTextEx(labelFont, priceLabelText, labelHeight, 1)
    rl.DrawRectangleRec({currentX, currentY, innerWidth, priceLabelTextSize.y}, style.colors.surface)
	rl.DrawTextEx(labelFont, priceLabelText, {currentX + padding, currentY}, labelHeight, 1, style.colors.text)
	currentY += labelHeight + padding

	resetBtnWidth: f32 = 72
	priceFieldRect := rl.Rectangle{currentX, currentY, innerWidth - resetBtnWidth - padding, controlHeight}
	priceField := comp.TextFieldCreate(priceFieldRect, style, .Catalog_Purchase_Price, state, style.icons[.economy_credit])
	if comp.UpdateTextField(&priceField) {
		val, ok := strconv.parse_i64(comp.TextFieldToString(&priceField))
		if ok {
			state.catalog.purchase_at = val
		}
	}
	comp.DrawTextField(&priceField, style, "Price")

	resetBtn := comp.ButtonCreate("Reset", {currentX + priceFieldRect.width + padding + resetBtnWidth / 2, currentY + controlHeight / 2}, resetBtnWidth, controlHeight)
	if comp.DrawButtonCol(&resetBtn, style, false, style.colors.surface, style.colors.text, style.colors.surface, style.colors.primary, style.colors.primary) {
		CatalogResetPurchaseState(state)
	}
	currentY += controlHeight + padding

    rarityLabelStr := fmt.tprintf("Rarity - %d", state.catalog.purchase_rarity)
    rarityLabelText := str.clone_to_cstring(rarityLabelStr, context.temp_allocator)
    rarityLabelTextSize := rl.MeasureTextEx(labelFont, rarityLabelText, labelHeight, 1)
    rl.DrawRectangleRec({currentX, currentY, innerWidth, rarityLabelTextSize.y}, style.colors.surface)
	rl.DrawTextEx(labelFont, rarityLabelText, {currentX + padding, currentY}, labelHeight, 1, style.colors.text)
	currentY += labelHeight + padding

	btnSize: f32 = 32

	restrictedIconCol := state.catalog.purchase_restricted ? style.colors.error : style.colors.text
	btnRestricted := comp.ButtonCreate("", {currentX + innerWidth - btnSize / 2, currentY + btnSize / 2}, btnSize, btnSize, style.icons[.economy_restricted])

    remainingWidth := innerWidth - btnSize - padding
    rarityBtnWidth := (remainingWidth - padding) / 2
    
    btnDown := comp.ButtonCreate("Decrease", {0, 0}, rarityBtnWidth, btnSize)
    btnUp := comp.ButtonCreate("Increase", {0, 0}, rarityBtnWidth, btnSize)
    
    rarityButtons := make([dynamic]comp.Button, context.temp_allocator)
    append(&rarityButtons, btnDown, btnUp)
    comp.LayoutButtonsHorizontalRect(rarityButtons, {currentX, currentY, remainingWidth, btnSize}, currentY + btnSize / 2, padding, 0, 0)

	if comp.DrawButtonCol(&rarityButtons[0], style, false, style.colors.surface, style.colors.text, style.colors.surface, style.colors.primary, style.colors.primary) {
		state.catalog.purchase_rarity -= 1
		if state.catalog.purchase_rarity < 1 do state.catalog.purchase_rarity = 1
		state.catalog.purchase_at = CalculatePurchasePrice(state)
		CatalogUpdateTextFields(state)
	}

    if comp.DrawButtonCol(&rarityButtons[1], style, false, style.colors.surface, style.colors.text, style.colors.surface, style.colors.primary, style.colors.primary) {
		state.catalog.purchase_rarity += 1
		state.catalog.purchase_at = CalculatePurchasePrice(state)
		CatalogUpdateTextFields(state)
	}

	if comp.DrawButtonCol(&btnRestricted, style, state.catalog.purchase_restricted, style.colors.surface, restrictedIconCol, style.colors.surface, style.colors.primary, style.colors.primary) {
		state.catalog.purchase_restricted = !state.catalog.purchase_restricted
		state.catalog.purchase_at = CalculatePurchasePrice(state)
		CatalogUpdateTextFields(state)
	}
	currentY += btnSize + padding

    markupLabelText: cstring = "Markup"
    markupLabelTextSize := rl.MeasureTextEx(labelFont, markupLabelText, labelHeight, 1)
    rl.DrawRectangleRec({currentX, currentY, innerWidth, markupLabelTextSize.y}, style.colors.surface)
	rl.DrawTextEx(labelFont, "Markup", {currentX + padding, currentY}, labelHeight, 1, style.colors.text)
	currentY += labelHeight + padding

	markupFieldRect := rl.Rectangle{currentX, currentY, innerWidth, controlHeight}
	markupField := comp.TextFieldCreate(markupFieldRect, style, .Catalog_Purchase_Markup, state, style.icons[.economy_rarity])
	if comp.UpdateTextField(&markupField) {
		val, ok := strconv.parse_f32(comp.TextFieldToString(&markupField))
		if ok {
            if val < 0 {
                val = 0
                comp.TextFieldSet(&markupField, "0")
            }
			state.catalog.purchase_markup = val
			state.catalog.purchase_at = CalculatePurchasePrice(state)

			pStr := fmt.tprintf("%d", state.catalog.purchase_at)
			pField := comp.TextField{
				state = &state.textFields[.Catalog_Purchase_Price],
			}
			comp.TextFieldSet(&pField, pStr)
		}
	}
	comp.DrawTextField(&markupField, style, "Markup %")
	currentY += controlHeight + padding

	purchaseBtn := comp.ButtonCreate("Purchase", {currentX + innerWidth / 2, currentY + controlHeight / 2}, innerWidth, controlHeight, style.icons[.gui_buy])
	if comp.DrawButtonCol(&purchaseBtn, style, false, style.colors.surface, style.colors.text, style.colors.secondary, style.colors.success, style.colors.success, true) {
		// Implementation later
	}

	return bounds
}
