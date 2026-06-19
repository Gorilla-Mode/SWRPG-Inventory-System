package app

import inv "../inventory"
import rl  "vendor:raylib"

InputMoveItem :: proc(state: ^State, item: ^inv.ItemInstance, container: ^inv.Container){
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT){
        inv.ContainerMovieItem(container, item, 1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.LEFT){
        inv.ContainerMovieItem(container, item, -1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.UP){
        inv.ContainerMovieItem(container, item, delta_y = -1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.DOWN){
        inv.ContainerMovieItem(container, item, delta_y = 1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.SPACE){
        if item.rotated {
            item.rotated = false
        } else {
            item.rotated = true
        }
        state.InventoryGrid = inv.ContainerToString(container)
    }
}