package view

import st "../core/state"
import ui "../ui"
import app "../core/app"
import rl "vendor:raylib"
import comp "../ui/component"
import inv "../core/inventory"
import str "core:strings"


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

    DrawCatalogItemStat(state, style, layout, rect_right)
    explorerBounds := DrawCatalogExplorer(state, style, layout, paddingElement, rect_left)
    DrawCatalogItemResults(state, style, layout, paddingElement, explorerBounds, rect_left)
}

DrawCatalogExplorer :: proc (state: ^st.state, style: ^ui.style, layout: app.CatalogPageLayout, paddingElement: f32, rect_left: rl.Rectangle) -> rl.Rectangle {
    f_bg_color      := style.colors.surface
    f_hover_color   := style.colors.secondary_hover
    f_active_color  := style.colors.success
    f_icon_color    := style.colors.text
    f_icon_bg_color := style.colors.secondary

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

    DrawCatalogButtons(state, style, &buttons, f_bg_color, f_icon_color, f_icon_bg_color, f_hover_color, f_active_color)

    bounds := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING,
        y = layout.top_y + searchBar.rect.height + (paddingElement * 2),
        width = layout.left.width - app.PADDING,
        height = ((paddingElement * 3) + categoryFilterRect.height + categorySubFilterRect.height + buttonHeight + buttonSubHeight),
    }

    return bounds
}

DrawCatalogItemStat :: proc(state: ^st.state, style: ^ui.style, layout: app.CatalogPageLayout, rect_right: rl.Rectangle){
    rl.DrawRectangleRec(rect_right, style.colors.secondary_active)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "Statisitcs",
    ui.SnapVector2({layout.right.origin_x, layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)
}

DrawCatalogItemResults :: proc(state: ^st.state, style: ^ui.style, layout: app.CatalogPageLayout, paddingElement: f32, filterBounds: rl.Rectangle, leftRect: rl.Rectangle) {
    posY: f32 = filterBounds.y + filterBounds.height + paddingElement + state.catalog.scroll_offset
    mousePos:= rl.GetMousePosition()
    entryHeight: f32 = 100
    queryString := comp.TextBufferToString(state.textFields[.Catalog_Search].buffer)
    queryString = str.to_lower(queryString)

    bounds := rl.Rectangle{
        x = layout.left.origin_x + app.PADDING,
        y = posY,
        width = layout.left.width - app.PADDING,
        height = paddingElement,
    }

    rl.BeginScissorMode(i32(leftRect.x),i32(filterBounds.y + filterBounds.height + paddingElement), i32(bounds.width), i32(state.window.height))
    for item in state.ItemDefinitionRegistry.items {
        itemName := str.to_lower(state.ItemDefinitionRegistry.items[item].name)

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

        if comp.DrawItemList(&state.ItemDefinitionRegistry.items[item],
        style,
        layout.left.width - app.PADDING - paddingElement * 2,
        entryHeight,
        rl.Vector2{app.PADDING + paddingElement,
        posY}, mousePos,
        state.catalog.selected_item == &state.ItemDefinitionRegistry.items[item]) {
            state.catalog.selected_item = &state.ItemDefinitionRegistry.items[item]
        }

        posY += entryHeight + paddingElement
        bounds.height += entryHeight + paddingElement
    }

    if rl.CheckCollisionPointRec(mousePos, leftRect) {
        state.catalog.scroll_offset += rl.GetMouseWheelMove() * 15
        if state.catalog.scroll_offset > 0 do state.catalog.scroll_offset = 0
        if (-1 * state.catalog.scroll_offset + 5) >= bounds.height do state.catalog.scroll_offset = -1 * (bounds.height - paddingElement - 5)
    }

    rl.EndScissorMode()
}