package state

import inv "../inventory"
import rl "vendor:raylib"

state :: struct{
    grab:          grab,
    ghost:         ghost,
    window:        windowState,
}

grab :: struct{
    is_dragging: bool,
    dragged_item: ^inv.ItemInstance,
    selected_item: ^inv.ItemInstance,
    offset_x: f32,
    offset_y: f32,
}

ghost :: struct{
    pos_x: i16,
    pos_y: i16,
    unsnapped_x: f32,
    unsnapped_y: f32,
    rotated: bool,
    valid: bool,
}

windowState :: struct{
    width:  f32,
    height: f32,
}

UpdateWindowState :: proc(state: ^state) {
    state.window.width = f32(rl.GetScreenWidth())
    state.window.height = f32(rl.GetScreenHeight())
}