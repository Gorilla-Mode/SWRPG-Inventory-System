package component

import rl "vendor:raylib"
import ui "../"
import st "../../core/state"
import str "core:strings"

TextField :: struct {
    state: ^st.textFieldState,

    image:      rl.Texture2D,
    rect:       rl.Rectangle,
    rect_clear: rl.Rectangle,
}

UpdateTextField :: proc(field: ^TextField){
    mousePos := rl.GetMousePosition()

    if rl.IsMouseButtonPressed(.LEFT)
    {
        if rl.CheckCollisionPointRec(mousePos, field.rect_clear) {
            resize(&field.state.buffer, 0)
            field.state.buffer_length = 0
            field.state.is_active = false
            return
        }
        field.state.is_active = rl.CheckCollisionPointRec(mousePos, field.rect)
    }

    if !field.state.is_active do return

    for {
        ch := rl.GetCharPressed()
        if ch == 0 do break

        if ch >= 32 && ch <= 126 {
            append(&field.state.buffer, u8(ch))
            field.state.buffer_length += 1
        }
    }

    if rl.IsKeyPressed(.BACKSPACE) && field.state.buffer_length > 0 {
        resize(&field.state.buffer, field.state.buffer_length - 1)
        field.state.buffer_length -= 1
    }
}

DrawTextField :: proc(field: ^TextField, style: ^ui.style){
    icon := field.image
    outline := field.state.is_active ? style.colors.success : style.colors.surface
    textPos := rl.Vector2{field.rect.x + field.rect.height, field.rect.y + (field.rect.height - f32(ui.font_size.default)) / 2}
    iconSearchPos := rl.Vector2{field.rect.x + 2, field.rect.y + 2}
    iconClearPos := rl.Vector2{field.rect_clear.x, field.rect_clear.y }
    iconScale := f32(field.rect.height - 4) / f32(icon.height)

    rl.DrawRectangleRec(field.rect, style.colors.surface)
    rl.DrawRectangleLinesEx(field.rect, 2, outline)
    rl.DrawTextureEx(icon, iconSearchPos, 0, iconScale, style.colors.text)
    rl.DrawTextureEx(style.icons[ui.Icons.item_weapon_type_melee], iconClearPos, 0, iconScale, style.colors.text)
    rl.DrawTextEx(style.fonts.regular[ui.font_size.default], TextFieldText(field), textPos, f32(ui.font_size.default), 0, style.colors.text)

}

TextFieldText :: proc(field: ^TextField) -> cstring {
    return str.clone_to_cstring(string(field.state.buffer[:]), context.temp_allocator)
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
    iconRectSize: f32 = 28

    return TextField{
        state = &state.textFields[field],
        image = style.icons[ui.Icons.item_weapon_type_melee],
        rect = rect,
        rect_clear = rl.Rectangle{
            x = rect.x + rect.width - iconRectSize,
            y = rect.y + 2,
            width = iconRectSize,
            height = iconRectSize,
        }
    }
}