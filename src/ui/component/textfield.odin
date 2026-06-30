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
    rect_image: rl.Rectangle,
    max_length: i32
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
        if field.state.buffer_length >= field.max_length do break

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
    iconPadding: f32 = 8
    iconScale := ui.IconScale(field.rect.height - iconPadding)

    outline := field.state.is_active ? style.colors.success : style.colors.surface
    textPos := rl.Vector2{field.rect.x + field.rect_image.width + iconPadding, field.rect.y + (field.rect.height - f32(ui.font_size.default)) / 2}

    iconSearchPos := ui.IconGetCenterPos(field.rect_image, field.rect_image.height - iconPadding / 2)
    iconClearPos := ui.IconGetCenterPos(field.rect_clear, field.rect_clear.height - iconPadding / 2)
    iconClearPos.y -= 2 // Offset, looks goofy when prop aligned

    rl.DrawRectangleRec(field.rect, style.colors.surface)
    rl.DrawRectangleLinesEx(field.rect, 2, outline)
    rl.DrawRectangleRec(field.rect_image, style.colors.secondary)
    rl.DrawRectangleRec(field.rect_clear, style.colors.secondary)

    rl.DrawTextureEx(field.image, iconSearchPos, 0, iconScale, style.colors.text)
    rl.DrawTextureEx(style.icons[ui.Icons.gui_trash], iconClearPos, 0, iconScale, style.colors.text)

    rl.DrawTextEx(style.fonts.regular[ui.font_size.default], TextFieldText(field), textPos, f32(ui.font_size.default), 0, style.colors.text)
}

TextFieldText :: proc(field: ^TextField) -> cstring {
    return str.clone_to_cstring(string(field.state.buffer[:]), context.temp_allocator)
}

TextFieldClear :: proc(field: ^TextField){

}

TextFieldSet :: proc(field: ^TextField, text: string){

}

TextFieldCreate :: proc(rect: rl.Rectangle, style: ^ui.style, field: st.textField, state: ^st.state, image: rl.Texture2D) -> TextField {
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
        image = image,
        rect = rect,
        rect_clear = rl.Rectangle{
            x = rect.x + rect.width - iconRectSize - 2,
            y = rect.y + 2,
            width = iconRectSize,
            height = iconRectSize,
        },
        rect_image = rl.Rectangle{
            x = rect.x + 2,
            y = rect.y + 2,
            width = iconRectSize,
            height = iconRectSize,
        },
        max_length = i32((rect.width - (iconRectSize + 4) * 2 - 8) / f32(rl.MeasureText("_", i32(ui.font_size.default)))),
    }
}