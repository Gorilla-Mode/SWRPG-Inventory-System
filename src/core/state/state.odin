package state

import inv "../inventory"
import rl "vendor:raylib"

BACKSPACE_DELAY  :: 0.5
BACKSPACE_REPEAT :: 0.02

state :: struct{
    grab:          grab,
    ghost:         ghost,
    window:        windowState,
    page:          page,
    character:     ^inv.Character,
    textFields :   map[textField]textFieldState,
    catalog:       catalogState,
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

textFieldState :: struct{
    is_active:     bool,
    buffer:        [dynamic]u8,
    buffer_length: i32,

    backspace_timer: f32,
    backspace_repeat_timer: f32,
}

catalogState :: struct{
    category: inv.ItemCategory,
    sub_category: subCategory,
}

subCategory :: union {
    inv.ItemCategory,
    inv.WeaponSubCategory,
    inv.GearSubCategory,
    inv.ContainerSubCategory,
}

page :: enum{
    Inventory,
    Debug,
    Character,
    Catalog,
    Shops,
    Vehicles,
    Bases
}

textField :: enum {
    Catalog_Search,
}

UpdateWindowState :: proc(state: ^state) {
    state.window.width = f32(rl.GetScreenWidth())
    state.window.height = f32(rl.GetScreenHeight())
}