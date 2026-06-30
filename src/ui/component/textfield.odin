package component

import rl "vendor:raylib"
import ui "../"
import st "../../core/state"

TextField :: struct {
    state: ^st.textFieldState,

    image: rl.Texture2D,
    rect:  rl.Rectangle,
}

UpdateTextField :: proc(field: ^TextField){
    mousePos := rl.GetMousePosition()

    if rl.IsMouseButtonPressed(.LEFT)
    {
        field.state.is_active = rl.CheckCollisionPointRec(mousePos, field.rect)
    }
}

DrawTextField :: proc(field: ^TextField, style: ^ui.style){
    icon := field.image
    outline := field.state.is_active ? style.colors.success : style.colors.primary
    rl.DrawRectangleRec(field.rect, style.colors.surface)
    rl.DrawRectangleLinesEx(field.rect, 2, outline)
    rl.DrawTextureEx(icon, rl.Vector2{field.rect.x + 2, field.rect.y + 2}, 0, f32(field.rect.height - 4) / f32(icon.height), style.colors.text)

}

TextFieldText :: proc(field: ^TextField) -> string {
    return "balls"
}

TextFieldClear :: proc(field: ^TextField){

}

TextFieldSet :: proc(field: ^TextField, text: string){

}

TextFieldCreate :: proc(rect: rl.Rectangle, style: ^ui.style, field: st.textField, state: ^st.state) -> TextField {
    _, ok := state.textFields[field]
    if !ok {
        new_field := st.textFieldState{
            is_active = false,
        }
        state.textFields[field] = new_field
    }

    return TextField{
        state = &state.textFields[field],
        image = style.icons[ui.Icons.item_weapon_type_melee],
        rect = rect,
    }
}