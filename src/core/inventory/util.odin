package inventory

import str "core:strings"
import fmt "core:fmt"

// Test function to create a backpack, and some items, and test the ContainerCanPlace function
TestItem :: proc() -> struct{
    backpack: ^Container,
    sword: ^Item,
    rifle: ^Item,
    sword_instance: ^ItemInstance,
    rifle_instance: ^ItemInstance }
{
    backpack := new(Container)
    backpack.type = ContainerType.Backpack
    backpack.storage = ContainerGrid{
        width  = 8,
        height = 10
    }

    sword := new(Item)
    sword.name = "Sword"
    sword.width = 5
    sword.height = 1

    rifle := new(Item)
    rifle.name = "Rifle"
    rifle.width = 6
    rifle.height = 2

    knife := new(Item)
    knife.name = "Knife"
    knife.width = 3
    knife.height = 1

    canteen := new(Item)
    canteen.name = "Canteen"
    canteen.width = 2
    canteen.height = 2

    rifle_instance := new(ItemInstance)
    rifle_instance.definition = rifle
    rifle_instance.pos_x = 0
    rifle_instance.pos_y = 1
    rifle_instance.id = 1
    rifle_instance.rotated = false

    sword_instance := new(ItemInstance)
    sword_instance.definition = sword
    sword_instance.pos_x = 0
    sword_instance.pos_y = 0
    sword_instance.id = 2
    sword_instance.rotated = false

    knife_instance := new(ItemInstance)
    knife_instance.definition = knife
    knife_instance.pos_x = 5
    knife_instance.pos_y = 0
    knife_instance.id = 3
    knife_instance.rotated = false

    canteen_instance := new(ItemInstance)
    canteen_instance.definition = canteen
    canteen_instance.pos_x = 6
    canteen_instance.pos_y = 1
    canteen_instance.id = 4
    canteen_instance.rotated = false

    append_elem(&backpack.items, sword_instance)
    append_elem(&backpack.items, rifle_instance)
    append_elem(&backpack.items, knife_instance)
    append_elem(&backpack.items, canteen_instance)

    return{
        backpack,
        sword,
        rifle,
        sword_instance,
        rifle_instance
    }
}

//Test function to test the ContainerCanPlace function with various positions for the rifle item instance in the backpack container
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

// Function to convert the container and its items into a string representation for debugging/ease of use purposes
ContainerToString :: proc(container: ^Container) -> string {
    builder := str.Builder{}

    grid := make([][]rune, container.storage.(ContainerGrid).height)
    defer {
        for row in grid {
            delete(row)
        }
        delete(grid)
    }

    for y in 0..<container.storage.(ContainerGrid).height {
        grid[y] = make([]rune, container.storage.(ContainerGrid).width)

        for x in 0..<container.storage.(ContainerGrid).width {
            grid[y][x] = '.'
        }
    }

    symbols := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    for item, i in container.items {
        symbol := rune(symbols[i % len(symbols)])
        b := GetBounds(item)

        for y in 0..<b.height {
            for x in 0..<b.width {

                gx := b.pos_x + x
                gy := b.pos_y + y

                if gx < 0 || gx >= container.storage.(ContainerGrid).width ||
                gy < 0 || gy >= container.storage.(ContainerGrid).height {
                    continue
                }

                grid[gy][gx] = symbol
            }
        }
    }

    for y in 0..<container.storage.(ContainerGrid).height {
        for x in 0..<container.storage.(ContainerGrid).width {
            str.write_rune(&builder, grid[y][x])
        }

        str.write_string(&builder, "\n")
    }

    return str.to_string(builder)
}