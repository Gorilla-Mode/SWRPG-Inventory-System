package app

import inv "../inventory"
import rl "vendor:raylib"

State :: struct{
    grab:          Grab,
    ghost:         Ghost,
    window:        WindowState,
}

Grab :: struct{
    is_dragging: bool,
    dragged_item: ^inv.ItemInstance,
    hovered_item: ^inv.ItemInstance,
    offset_x: f32,
    offset_y: f32,
}

Ghost :: struct{
    pos_x: i16,
    pos_y: i16,
    unsnapped_x: f32,
    unsnapped_y: f32,
    rotated: bool,
    valid: bool,
}

WindowState :: struct{
    width:  f32,
    height: f32,
}

UpdateWindowState :: proc(state: ^State) {
    state.window.width = f32(rl.GetScreenWidth())
    state.window.height = f32(rl.GetScreenHeight())
}