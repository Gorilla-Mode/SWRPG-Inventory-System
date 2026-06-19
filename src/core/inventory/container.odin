package inventory

import fmt "core:fmt"

ContainerType :: enum{
    Backpack,
    Belt,
    Clothing,
}

Container :: struct{
    id: string,
    width, height: i16,
    type: ContainerType,

    items: [dynamic]^ItemInstance
}

ContainerCanPlace :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    if item.pos_x < 0 || item.pos_y < 0 {
        return false
    }

    if item.pos_x + item.definition.width > container.width {
        return false
    }

    if item.pos_y + item.definition.height > container.height {
        return false
    }

    for existing in container.items{
        if RectOverlap(item.pos_x,
        item.pos_y,
        item.definition.width,
        item.definition.height,
        existing.pos_x,
        existing.pos_y,
        existing.definition.width,
        existing.definition.height){
            return false
        }
    }
    return true

}

RectOverlap :: proc(
ax, ay, aw, ah: i16,
bx, by, bw, bh: i16,
) -> bool {
    return !(ax + aw <= bx ||
        bx + bw <= ax ||
        ay + ah <= by ||
        by + bh <= ay)
}

TestInv :: proc(){

    backpack := Container{
        width = 8,
        height = 6,
    }

    sword := Item{
        name = "Sword",
        width = 1,
        height = 4,
    }

    rifle := Item{
        name = "Rifle",
        width = 2,
        height = 3,
    }

    rifle_instance := ItemInstance{
        definition = &rifle,
        pos_y = 0,
        pos_x = 0,
    }

    sword_instance := ItemInstance{
        definition = &sword,
        pos_y = 0,
        pos_x = 0,
    }

    append_elem(&backpack.items, &sword_instance)

    fmt.println()

    fmt.println("Expected: false")
    fmt.println("Actual:", ContainerCanPlace(&backpack, &rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 1
    rifle_instance.pos_y = 2
    fmt.println("Expected: true")
    fmt.println("Actual:", ContainerCanPlace(&backpack, &rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 2
    rifle_instance.pos_y = 0
    fmt.println("Expected: true")
    fmt.println("Actual:", ContainerCanPlace(&backpack, &rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 7
    rifle_instance.pos_y = 0
    fmt.println("Expected: false")
    fmt.println("Actual:", ContainerCanPlace(&backpack, &rifle_instance))

    fmt.println()

    rifle_instance.pos_x = -1
    rifle_instance.pos_y = 0
    fmt.println("Expected: false")
    fmt.println("Actual:", ContainerCanPlace(&backpack, &rifle_instance))

    fmt.println()
}