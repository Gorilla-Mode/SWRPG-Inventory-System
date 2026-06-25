package app

import inv "../inventory"
import rl  "vendor:raylib"

InputMoveItem :: proc(state: ^State, item: ^inv.ItemInstance, container: ^inv.Container){
    if rl.IsKeyPressed(rl.KeyboardKey.RIGHT){
        inv.ContainerGridMoveItem(container, item, 1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.LEFT){
        inv.ContainerGridMoveItem(container, item, -1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.UP){
        inv.ContainerGridMoveItem(container, item, delta_y = -1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.DOWN){
        inv.ContainerGridMoveItem(container, item, delta_y = 1)
        state.InventoryGrid = inv.ContainerToString(container)
    }

    if rl.IsKeyPressed(rl.KeyboardKey.SPACE){
        inv.ContainerGridRotateItem(container, item)
        state.InventoryGrid = inv.ContainerToString(container)
    }
}