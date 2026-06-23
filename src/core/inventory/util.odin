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
        height = 9
    }

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
    rifle_instance.rotated = false

    sword_instance := new(ItemInstance)
    sword_instance.definition = sword
    sword_instance.pos_x = 0
    sword_instance.pos_y = 0
    sword_instance.id = 2
    sword_instance.rotated = false

    append_elem(&backpack.items, sword_instance)

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