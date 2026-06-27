package view

import app "../core/app"
import inv "../core/inventory"
import ui "../ui"
import rl "vendor:raylib"

DrawGrid :: proc(item: ^inv.Item, state: ^app.State, style: ^ui.style){
    container, ok := item.data.(inv.ContainerData)
    if !ok {
        return
    }

    gridCenter := GridGetCenter(inv.ContainerGridPixelsXY(container.storage, style.grid.cell_size), state)
    style.grid.origin_x = gridCenter.x + style.grid.offset_x
    style.grid.origin_y = gridCenter.y + style.grid.offset_y

    inv.DrawContainerGrid(item, style.grid.origin_x, style.grid.origin_y, style.grid.cell_size, style)

    if state.grab.is_dragging && state.grab.dragged_item != nil {
        gw := state.ghost.rotated ? state.grab.dragged_item.definition.height : state.grab.dragged_item.definition.width
        gh := state.ghost.rotated ? state.grab.dragged_item.definition.width : state.grab.dragged_item.definition.height

        if inv.ContainerGridCheckBounds(container.storage, inv.Rect{
            pos_x = state.ghost.pos_x,
            pos_y = state.ghost.pos_y,
            width = gw,
            height = gh,
        })
        {
            inv.DrawItemGhost(state.grab.dragged_item,
            f32(state.ghost.pos_x),
            f32(state.ghost.pos_y),
            true,
            state.ghost.rotated,
            state.ghost.valid,
            style.grid.origin_x,
            style.grid.origin_y,
            style.grid.cell_size,
            style)
        }

        inv.DrawItemGhost(state.grab.dragged_item,
        state.ghost.unsnapped_x,
        state.ghost.unsnapped_y,
        false,
        state.ghost.rotated,
        state.ghost.valid,
        style.grid.origin_x,
        style.grid.origin_y,
        style.grid.cell_size,
        style)
    }

    if(app.ShowItemCard(container.storage, style, state) || state.grab.selected_item != nil){
        DrawItemCard(container.storage, state, style)
    }
}

DrawItemCard :: proc(container: ^inv.Container, state: ^app.State, style: ^ui.style){
    if state.grab.selected_item != nil {
        inv.DrawItemCard(state.grab.selected_item,
        f32(state.grab.selected_item.pos_x),
        f32(state.grab.selected_item.pos_y),
        style.grid.origin_x,
        style.grid.origin_y,
        style.grid.cell_size,
        style)
    }

    app.HideItemCard(container, style, state)
}

GridGetCenter :: proc(grid_size: rl.Vector2, state: ^app.State) -> rl.Vector2 {
    center := rl.Vector2{}
    center.x = (state.window.width - grid_size.x) /2
    center.y = (state.window.height - grid_size.y) / 2

    return center
}