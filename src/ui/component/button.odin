package component

import rl "vendor:raylib"
import str "core:strings"
import ui ".."
import st "../../core/state"

Button :: struct {
    text: string,
    rect: rl.Rectangle,
    image: rl.Texture2D,
}

DrawButton :: proc(
    button: ^Button,
    style: ^ui.style,
    active: bool
) -> bool {
    mouse_pos := rl.GetMousePosition()
    hovered := rl.CheckCollisionPointRec(mouse_pos, button.rect)


    return ButtonGetDraw(button, style, active, hovered, mouse_pos,
    style.colors.secondary,
    style.colors.text,
    style.colors.surface,
    style.colors.secondary_hover,
    style.colors.secondary_active,
    )
}

DrawButtonCol :: proc(
    button: ^Button,
    style: ^ui.style,
    active: bool,
    col_rect: rl.Color,
    col_icon: rl.Color,
    col_icon_bg: rl.Color,
    col_hover: rl.Color,
    col_active: rl.Color,
    outline: bool = false,
    col_outline: rl.Color = rl.WHITE,
    col_outline_active: rl.Color = rl.WHITE,
) -> bool {
    mouse_pos := rl.GetMousePosition()
    hovered := rl.CheckCollisionPointRec(mouse_pos, button.rect)

    if outline do return ButtonGetDraw(button,
    style,
    active,
    hovered,
    mouse_pos,
    col_rect,
    col_icon,
    col_icon_bg,
    col_hover,
    col_active,
    outline,
    col_outline,
    col_outline_active)

    return ButtonGetDraw(button,
    style,
    active,
    hovered,
    mouse_pos,
    col_rect,
    col_icon,
    col_icon_bg,
    col_hover,
    col_active)
}

ButtonGetDraw :: proc(
    button: ^Button,
    style: ^ui.style,
    active: bool,
    hovered: bool,
    mouse_pos: rl.Vector2,
    col_rect: rl.Color,
    col_icon: rl.Color,
    col_icon_bg: rl.Color,
    col_hover: rl.Color,
    col_active: rl.Color,
    outline: bool = false,
    col_outline: rl.Color = rl.WHITE,
    col_outline_active: rl.Color = rl.WHITE,
) -> bool {
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

    if outline {
        rl.DrawRectangleRec(button.rect, col_rect)

        outline_color := col_outline

        if hovered {
            outline_color = col_hover
            rl.DrawRectangleLinesEx(button.rect, padding, outline_color)
        }

        if active {
            outline_color = col_outline_active
            rl.DrawRectangleLinesEx(button.rect, padding, outline_color)
        }

    } else {
        bg_color := col_rect

        if hovered {
            bg_color = col_hover
        }

        if active {
            bg_color = col_active
        }

        rl.DrawRectangleRec(button.rect, bg_color)
    }

    rl.DrawRectangleRec(icon_rect, col_icon_bg)

    rl.DrawTextureEx(
    button.image,
    icon_pos,
    0,
    scale,
    col_icon,
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
        image = image,
    }
}

LayoutButtonsHorizontal :: proc(
    buttons: []Button,
    center: rl.Vector2,
    spacing: f32,
) {
    if len(buttons) == 0 do return

    button_width  := buttons[0].rect.width
    button_height := buttons[0].rect.height

    total_width := f32(len(buttons))*button_width +
    f32(len(buttons)-1)*spacing

    start_x := center.x - total_width/2
    y := center.y - button_height/2

    for i in 0..<len(buttons) {
        buttons[i].rect.x = start_x + f32(i)*(button_width + spacing)
        buttons[i].rect.y = y
    }
}

LayoutButtonsHorizontalRect :: proc(
    buttons: [dynamic]Button,
    bounds: rl.Rectangle,
    target_y: f32,
    spacing: f32,
    padding_left: f32,
    padding_right: f32,
    offset_x: f32 = 0,
    offset_y: f32 = 0,
) {
    if len(buttons) == 0 do return

    button_width  := buttons[0].rect.width
    button_height := buttons[0].rect.height

    available_width := bounds.width - padding_left - padding_right

    total_width := f32(len(buttons)) * button_width +
    f32(len(buttons) - 1) * spacing

    start_x := bounds.x +
    padding_left +
    (available_width - total_width) / 2 +
    offset_x

    y := target_y - button_height / 2 + offset_y

    for i in 0..<len(buttons) {
        buttons[i].rect.x = start_x + f32(i) * (button_width + spacing)
        buttons[i].rect.y = y
    }
}