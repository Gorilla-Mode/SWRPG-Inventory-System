package component

import rl "vendor:raylib"
import inv "../../core/inventory"
//import str "core:strings"
import ui ".."

DrawItemList :: proc(definition: ^inv.Item, style: ^ui.style, width, height: f32, pos: rl.Vector2) {
    backGround := rl.Rectangle{pos.x, pos.y, width, height}
    rl.DrawRectangleRec(backGround, style.colors.success)
}