package view

import app "../core/app"
import inv "../core/inventory"
import ui "../ui"
import rl "vendor:raylib"
import st "../core/state"
import comp "../ui/component"

DrawGrid :: proc(item: ^inv.ItemInstance, state: ^st.state, style: ^ui.style){
    container, ok := item.definition.data.(inv.ContainerData)
    if !ok {
        return
    }

    gridCenter := GridGetCenter(inv.ContainerGridPixelsXY(item, style.grid.cell_size), state)
    style.grid.origin_x = gridCenter.x + style.grid.offset_x
    style.grid.origin_y = gridCenter.y + style.grid.offset_y

    inv.DrawContainerGrid(item.definition, item, style.grid.origin_x, style.grid.origin_y, style.grid.cell_size, style)

    if state.grab.is_dragging && state.grab.dragged_item != nil {
        gw := state.ghost.rotated ? state.grab.dragged_item.definition.height : state.grab.dragged_item.definition.width
        gh := state.ghost.rotated ? state.grab.dragged_item.definition.width : state.grab.dragged_item.definition.height

        if inv.ContainerGridCheckBounds(&container.containerDef, inv.Rect{
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

    if(app.ShowItemCard(item, style.grid.origin_x, style.grid.origin_y, style, state) || state.grab.selected_item != nil){
        DrawItemCard(item, style.grid.origin_x, style.grid.origin_y, state, style)
    }
}

DrawItemCard :: proc(container: ^inv.ItemInstance, origin_x, origin_y: f32, state: ^st.state, style: ^ui.style){
    if state.grab.selected_item != nil do app.HideItemCard(container, origin_x, origin_y, style, state)

    is_in_container := false
    container_data, ok := container.data.(inv.ContainerInstanceData)
    if !ok do return

    for item in container_data.items {
        if item == state.grab.selected_item {
            is_in_container = true
            break
        }
    }

    if is_in_container {
        comp.DrawItemCard(state.grab.selected_item,
        f32(state.grab.selected_item.pos_x),
        f32(state.grab.selected_item.pos_y),
        origin_x,
        origin_y,
        style.grid.cell_size,
        style)
    }
}

GridGetCenter :: proc(grid_size: rl.Vector2, state: ^st.state) -> rl.Vector2 {
    center := rl.Vector2{}
    //Cursed wobbly ahh text fix
    center.x = f32(i32((state.window.width - grid_size.x) / 2))
    center.y = f32(i32((state.window.height - grid_size.y) / 2))

    return center
}