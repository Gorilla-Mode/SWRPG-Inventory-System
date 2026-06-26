package view

import app "../core/app"
import inv "../core/inventory"
import ui "../ui"
import rl "vendor:raylib"

DrawGrid :: proc(container: ^inv.Container, state: ^app.State, style: ^ui.style){
    inv.DrawContainerGrid(container, style.grid.origin_x, style.grid.origin_y, style.grid.cell_size, style)

    if state.grab.is_dragging && state.grab.dragged_item != nil {
        if inv.ContainerGridCheckBounds(container, inv.Rect{
            pos_x = state.ghost.pos_x,
            pos_y = state.ghost.pos_y,
            width = (state.ghost.rotated ? inv.ItemGetHeight(state.grab.dragged_item) : inv.ItemGetWidth(state.grab.dragged_item)),
            height = (state.ghost.rotated ? inv.ItemGetWidth(state.grab.dragged_item) : inv.ItemGetHeight(state.grab.dragged_item)),
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

    if app.GetItemAtMousePos(container, style.grid.origin_x, style.grid.origin_y, style.grid.cell_size) != nil && rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
        state.grab.hovered_item = app.GetItemAtMousePos(container, style.grid.origin_x, style.grid.origin_y, style.grid.cell_size)
    }

    if state.grab.hovered_item != nil {

        inv.DrawItemCard(state.grab.hovered_item, f32(state.grab.hovered_item.pos_x), f32(state.grab.hovered_item.pos_y), style.grid.origin_x, style.grid.origin_y, style.grid.cell_size, style)
        if rl.IsMouseButtonPressed(rl.MouseButton.MIDDLE) || state.grab.hovered_item.grabbed
        {
            state.grab.hovered_item = nil
        }
    }
}