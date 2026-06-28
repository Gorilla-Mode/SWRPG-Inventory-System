package component

import rl "vendor:raylib"
import str "core:strings"
import ui ".."
import st "../../core/state"

Button :: struct {
    text: string,
    rect: rl.Rectangle,
    image: rl.Texture2D,

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
        color = style.colors.secondary_active
    } else if hovered {
        color = style.colors.secondary_hover
    }

    padding: f32 = 2
    target_size: f32 = button.rect.height - padding * 2
    scale := target_size / f32(button.image.width)
    icon_height := f32(button.image.height) * scale

    icon_pos := rl.Vector2{
        button.rect.x + padding,
        button.rect.y + (button.rect.height - icon_height) / 2,
    }

    text := str.clone_to_cstring(button.text, context.temp_allocator)
    text_size := rl.MeasureTextEx(
    style.fonts.semibold[ui.font_size.default],
    text,
    f32(ui.font_size.default),
    0,
    )

    icon_rect := rl.Rectangle{
        x = button.rect.x + padding,
        y = button.rect.y + padding,
        width = target_size,
        height = target_size,
    }

    text_area := rl.Rectangle{
        x = icon_rect.x + icon_rect.width + padding,
        y = button.rect.y,
        width = button.rect.width - (icon_rect.width + padding * 2),
        height = button.rect.height,
    }

    text_pos := rl.Vector2{
        text_area.x + (text_area.width - text_size.x) / 2,
        text_area.y + (text_area.height - text_size.y) / 2,
    }

    rl.DrawRectangleRec(button.rect, color)
    rl.DrawRectangleRec(icon_rect, style.colors.surface)
    rl.DrawTextureEx(
    button.image,
    icon_pos,
    0,
    scale,
    style.colors.text,
    )

    rl.DrawTextEx(
    style.fonts.semibold[ui.font_size.default],
    text,
    ui.SnapVector2(text_pos),
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
    page: st.page,
    image: rl.Texture2D = rl.Texture2D{}
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
        image = image,
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