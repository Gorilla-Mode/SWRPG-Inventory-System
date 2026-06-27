package component

import rl "vendor:raylib"
import str "core:strings"
import ui ".."
import st "../../core/state"

Button :: struct {
    text: string,
    rect: rl.Rectangle,

    page: st.page
}

DrawButton :: proc(
    button: ^Button,
    style: ^ui.style,
    current_page: st.page,
) -> bool {
    mouse_pos := rl.GetMousePosition()
    hovered := rl.CheckCollisionPointRec(mouse_pos, button.rect)
    color := style.colors.secondary

    if button.page == current_page {
        color = style.colors.accent
    } else if hovered {
        color = style.colors.accent
    }

    text := str.clone_to_cstring(button.text, context.temp_allocator)
    text_size := rl.MeasureTextEx(
    style.fonts.semibold[ui.font_size.default],
    text,
    f32(ui.font_size.default),
    0,
    )

    text_pos := rl.Vector2{
        button.rect.x + (button.rect.width - text_size.x) / 2,
        button.rect.y + (button.rect.height - text_size.y) / 2,
    }

    rl.DrawRectangleRec(button.rect, color)

    rl.DrawTextEx(
    style.fonts.semibold[ui.font_size.default],
    text,
    text_pos,
    f32(ui.font_size.default),
    0,
    style.colors.text,
    )

    return hovered && rl.IsMouseButtonPressed(rl.MouseButton.LEFT)
}
ButtonCreate :: proc(
    text: string,
    center: rl.Vector2,
    width, height: f32,
    page: st.page
) -> Button {
    return Button{
        text = text,
        rect = rl.Rectangle{
            x = center.x - width / 2,
            y = center.y - height / 2,
            width = width,
            height = height,
        },
        page = page,
    }
}

LayoutButtonsHorizontal :: proc(
    buttons: []Button,
    center: rl.Vector2,
    spacing: f32,
) {
    total_width: f32 = 0

    for button in buttons {
        total_width += button.rect.width
    }

    total_width += spacing * f32(len(buttons) - 1)

    x := center.x - total_width / 2

    for i in 0..<len(buttons) {
        buttons[i].rect.x = x
        buttons[i].rect.y = center.y - buttons[i].rect.height / 2

        x += buttons[i].rect.width + spacing
    }
}