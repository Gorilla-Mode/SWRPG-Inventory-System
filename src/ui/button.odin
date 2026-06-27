package ui

import rl "vendor:raylib"
import str "core:strings"

Button :: struct {
    text: string,
    rect: rl.Rectangle,
}

DrawButton :: proc(button: ^Button, style: ^style) -> bool {
    mouse_pos := rl.GetMousePosition()
    hovered := rl.CheckCollisionPointRec(mouse_pos, button.rect)

    text := str.clone_to_cstring(button.text)
    text_size := rl.MeasureTextEx(
    style.fonts.semibold[font_size.default],
    text,
    f32(font_size.default),
    0,
    )

    text_pos := rl.Vector2{
        button.rect.x + (button.rect.width - text_size.x) / 2,
        button.rect.y + (button.rect.height - text_size.y) / 2,
    }

    color := hovered ? style.colors.accent : style.colors.secondary

    rl.DrawRectangleRounded(button.rect, 0.1, 16, color)
    rl.DrawTextEx(
    style.fonts.semibold[font_size.default],
    text,
    text_pos,
    f32(font_size.default),
    0,
    style.colors.text,
    )

    return hovered && rl.IsMouseButtonPressed(rl.MouseButton.LEFT)
}

ButtonCreate :: proc(
    text: string,
    center: rl.Vector2,
    width, height: f32,
) -> Button {
    return Button{
        text = text,
        rect = rl.Rectangle{
            x = center.x - width / 2,
            y = center.y - height / 2,
            width = width,
            height = height,
        },
    }
}