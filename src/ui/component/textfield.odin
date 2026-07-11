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

UpdateTextField :: proc(field: ^TextField) -> bool{
    mousePos := rl.GetMousePosition()
    dt := rl.GetFrameTime()

    if rl.IsMouseButtonPressed(.LEFT)
    {
        if rl.CheckCollisionPointRec(mousePos, field.rect_clear) {
            TextFieldClear(field)
            return true
        }
        field.state.is_active = rl.CheckCollisionPointRec(mousePos, field.rect)
    }

    if !field.state.is_active do return false

    for {
        ch := rl.GetCharPressed()
        if ch == 0 do break
        if field.state.buffer_length >= field.max_length do break

        if ch >= 32 && ch <= 126 {
            append(&field.state.buffer, u8(ch))
            field.state.buffer_length += 1
        }
    }

    if rl.IsKeyPressed(.BACKSPACE) {
        DeleteCharTextField(field)
    }

    DeleteCharsTextField(field, dt)
    return true
}

DeleteCharTextField :: proc(field: ^TextField){
    if field.state.buffer_length > 0 {
        resize(&field.state.buffer, field.state.buffer_length - 1)
        field.state.buffer_length -= 1
    }
}

DeleteCharsTextField :: proc(field: ^TextField, dt: f32){
    if rl.IsKeyDown(.BACKSPACE) {
        field.state.backspace_timer += dt

        if !(field.state.backspace_timer >= st.BACKSPACE_DELAY) do return

        field.state.backspace_repeat_timer += dt

        if field.state.backspace_repeat_timer >= st.BACKSPACE_REPEAT {
            DeleteCharTextField(field)
            field.state.backspace_repeat_timer = 0
        }

    } else {
        field.state.backspace_timer = 0
        field.state.backspace_repeat_timer = 0
    }
}

DrawTextField :: proc(field: ^TextField, style: ^ui.style, temp: cstring){
    mousePos := rl.GetMousePosition()
    iconPadding: f32 = 8
    iconScale := ui.IconScale(field.rect.height - iconPadding)

    caretBlinkTime: f64 = 0.75 // seconds
    show_caret := (i32(rl.GetTime() / caretBlinkTime) % 2) == 0

    outlineCol := field.state.is_active ? style.colors.success : style.colors.surface
    textPos := rl.Vector2{field.rect.x + field.rect_image.width + iconPadding, field.rect.y + (field.rect.height - f32(ui.font_size.default)) / 2}
    textCol := style.colors.text
    text := field.state.buffer_length > 0 ? TextFieldToCString(field) : temp

    iconSearchPos := ui.IconGetCenterPos(field.rect_image, field.rect_image.height - iconPadding / 2)
    iconClearPos := ui.IconGetCenterPos(field.rect_clear, field.rect_clear.height - iconPadding / 2)
    IconClearCol := rl.CheckCollisionPointRec(mousePos, field.rect_clear) && field.state.buffer_length != 0 ? style.colors.error : style.colors.text
    iconClearPos.y -= 2 // Offset, looks goofy when properly aligned

    boxRectCollison := rl.CheckCollisionPointRec(mousePos, field.rect)
    clearRectCollision := rl.CheckCollisionPointRec(mousePos, {field.rect_clear.x - 2, field.rect_clear.y - 2, field.rect_clear.width + 4, field.rect_clear.height + 4})

    if (boxRectCollison &&
    !field.state.is_active &&
    !clearRectCollision) {
        outlineCol = style.colors.secondary_hover
    }

    if field.state.is_active && field.state.buffer_length == 0 {
        text = ""
    }

    if field.state.buffer_length == 0 {
        textCol.a = 128
    }

    if boxRectCollison && !clearRectCollision {
        rl.SetMouseCursor(.IBEAM)
    } else {
        rl.SetMouseCursor(.DEFAULT)
    }

    rl.DrawRectangleRec(field.rect, style.colors.surface)
    rl.DrawRectangleLinesEx(field.rect, 2, outlineCol)
    rl.DrawRectangleRec(field.rect_image, style.colors.secondary)
    rl.DrawRectangleRec(field.rect_clear, style.colors.secondary)

    rl.DrawTextureEx(field.image, iconSearchPos, 0, iconScale, style.colors.text)
    rl.DrawTextureEx(style.icons[ui.Icons.gui_trash], iconClearPos, 0, iconScale, IconClearCol)

    rl.DrawTextEx(style.fonts.regular[ui.font_size.default], text, textPos, f32(ui.font_size.default), 0, textCol)

    if clearRectCollision && field.state.buffer_length != 0 {
        rl.DrawTextEx(style.fonts.regular[ui.font_size.label], "Clear?",
        {mousePos.x + 4, mousePos.y - (f32(ui.font_size.label) / 2) - 4},
        f32(ui.font_size.label),
        1,
        style.colors.text)
    }

    if field.state.is_active && show_caret {
        text_width := rl.MeasureTextEx(style.fonts.regular[ui.font_size.default], text, f32(ui.font_size.default), 0)

        rl.DrawRectangle(
        i32(textPos.x + text_width.x) + 2,
        i32(textPos.y),
        1,
        i32(ui.font_size.default),
        style.colors.text,
        )
    }
}

TextFieldToCString :: proc(field: ^TextField) -> cstring {
    return str.clone_to_cstring(string(field.state.buffer[:]), context.temp_allocator)
}

TextFieldToString :: proc(field: ^TextField) -> string {
    return string(field.state.buffer[:])
}

TextBufferToString :: proc(buffer: [dynamic]u8) -> string {
    return string(buffer[:])
}

TextBufferToCString :: proc(buffer: [dynamic]u8) -> cstring {
    return str.clone_to_cstring(string(buffer[:]), context.temp_allocator)
}

TextFieldClear :: proc(field: ^TextField){
    resize(&field.state.buffer, 0)
    field.state.buffer_length = 0
    field.state.is_active = false
}

TextFieldSet :: proc(field: ^TextField, text: string){
    panic("Not implemented yet")
}

TextFieldCreate :: proc(rect: rl.Rectangle, style: ^ui.style, field: st.textField, state: ^st.state, image: rl.Texture2D) -> TextField {
    _, ok := state.textFields[field]
    if !ok {
        new_field := st.textFieldState{
            is_active = false,
            backspace_repeat_timer = 0.05,
            backspace_timer = 0.5
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
        max_length = i32(rect.width - (iconRectSize + 4) * 2 - 8) / rl.MeasureText("_", i32(ui.font_size.default)),
    }
}