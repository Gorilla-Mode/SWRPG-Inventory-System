package inventory

import fmt "core:fmt"
import strings "core:strings"

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
        if existing.id == item.id {
            continue
        }

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

ContainerCanPlaceAt :: proc(container: ^Container, Item: ^Item, x: i16, y: i16, id: u64) -> bool{
    temp_instance := new(ItemInstance)
    defer free(temp_instance)

    temp_instance.definition = Item
    temp_instance.pos_x      = x
    temp_instance.pos_y      = y
    temp_instance.id         = id

    return ContainerCanPlace(container, temp_instance)
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

ContainerAddItem :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    if ContainerCanPlace(container, item) {
        append_elem(&container.items, item)
        return true
    }
    return false
}

TestItem :: proc() -> struct{
     backpack: ^Container,
     sword: ^Item,
     rifle: ^Item,
     sword_instance: ^ItemInstance,
     rifle_instance: ^ItemInstance }
{
    backpack := new(Container)
    backpack.height = 6
    backpack.width = 8

    sword := new(Item)
    sword.name = "Sword"
    sword.width = 1
    sword.height = 4

    rifle := new(Item)
    rifle.name = "Rifle"
    rifle.width = 2
    rifle.height = 3


    rifle_instance := new(ItemInstance)
    rifle_instance.definition = rifle
    rifle_instance.pos_x = 0
    rifle_instance.pos_y = 0
    rifle_instance.id = 1

    sword_instance := new(ItemInstance)
    sword_instance.definition = sword
    sword_instance.pos_x = 0
    sword_instance.pos_y = 0
    sword_instance.id = 2

    append_elem(&backpack.items, sword_instance)

    return{
        backpack,
        sword,
        rifle,
        sword_instance,
        rifle_instance
    }
}

TestInvGrid :: proc(backpack: ^Container, sword: ^Item, rifle: ^Item, sword_instance: ^ItemInstance, rifle_instance: ^ItemInstance)
{
    fmt.println()

    fmt.println("Expected: false")
    fmt.println("Actual:", ContainerCanPlace(backpack, rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 1
    rifle_instance.pos_y = 2
    fmt.println("Expected: true")
    fmt.println("Actual:", ContainerCanPlace(backpack, rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 2
    rifle_instance.pos_y = 0
    fmt.println("Expected: true")
    fmt.println("Actual:", ContainerCanPlace(backpack, rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 7
    rifle_instance.pos_y = 0
    fmt.println("Expected: false")
    fmt.println("Actual:", ContainerCanPlace(backpack, rifle_instance))

    fmt.println()

    rifle_instance.pos_x = -1
    rifle_instance.pos_y = 0
    fmt.println("Expected: false")
    fmt.println("Actual:", ContainerCanPlace(backpack, rifle_instance))

    fmt.println()

    rifle_instance.pos_x = 1
    rifle_instance.pos_y = 0
    ContainerAddItem(backpack, rifle_instance)
}

ContainerToString :: proc(container: ^Container) -> string {
    builder := strings.Builder{}
    defer strings.builder_destroy(&builder)

    grid := make([][]rune, container.height)
    defer {
        for row in grid {
            delete(row)
        }
        delete(grid)
    }

    for y in 0..<container.height {
        grid[y] = make([]rune, container.width)

        for x in 0..<container.width {
            grid[y][x] = '.'
        }
    }

    symbols := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    for item, i in container.items {
        symbol := rune(symbols[i % len(symbols)])

        for y in 0..<item.definition.height {
            for x in 0..<item.definition.width {
                gx := item.pos_x + x
                gy := item.pos_y + y

                grid[gy][gx] = symbol
            }
        }
    }

    for y in 0..<container.height {
        for x in 0..<container.width {
            strings.write_rune(&builder, grid[y][x])
        }

        strings.write_string(&builder, "\n")
    }

    return strings.to_string(builder)
}