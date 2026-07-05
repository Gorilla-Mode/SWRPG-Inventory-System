package inventory

import str "core:strings"
import fmt "core:fmt"

// Test function to create a backpack, and some items, and test the ContainerCanPlace function
TestItem :: proc(cell_size: f32, reg: ^ItemRegistry) -> struct{
    backpack: ^Container,
    rifle: ^Item,
    sword_instance: ^ItemInstance,
    rifle_instance: ^ItemInstance,
    backpackItem: ^Item,
    backpackInstance: ^ItemInstance}
{
    backpack := new(Container)
    backpack.type = ContainerType.Backpack
    backpack.storage = ContainerGrid{
        width  = 8,
        height = 10
    }

    backpackItem := new(Item)
    backpackItem.name = "Spacers duffel"
    backpackItem.width = 8
    backpackItem.height = 10
    backpackItem.description = "A standard backpack for carrying items."
    backpackItem.base_rarity = 1
    backpackItem.base_price = 100
    backpackItem.qualities = nil
    backpackItem.category = ItemCategory.Container
    backpackItem.data = ContainerData{
        storage = backpack,
        sub_category = ContainerSubCategory.Backpack
    }

    backpackInstance := new(ItemInstance)
    backpackInstance.definition = backpackItem
    backpackInstance.id = 100

    //TODO: detect where to place newlines, no hardcoding shit in this part of town (For now atleast we mus)

    rifle := new(Item)
    rifle.name = "A280C Blaster Rifle"
    rifle.width = 6
    rifle.height = 2
    rifle.description = "Carbine variant of the A280 blaster rifle,\nused by mostly by rebel troops"
    rifle.base_rarity = 4
    rifle.base_price = 1200
    rifle.qualities = nil
    rifle.category = ItemCategory.Weapon
    append_elems(&rifle.qualities, "Pirece 1", "Full-Auto")
    rifle.hardpoints = 4
    rifle.data = WeaponData {
        skill = WeaponSkill.Heavy,
        crit = 4,
        damage = 7,
        scale = WeaponScale.Personal,
        range = 300,
        rangeband = WeaponRangebands.Long,
        sub_category = WeaponSubCategory.Rifle
    }

    knife := new(Item)
    knife.name = "Vibroknife"
    knife.description = "A small, concealable knife with a\nvibrating edge, designed for stealthy\nattacks."
    knife.width = 3
    knife.height = 1
    knife.base_price = 200
    knife.base_rarity = 2
    knife.qualities = nil
    knife.category = ItemCategory.Weapon
    append_elem(&knife.qualities, "Pierce 2")
    knife.hardpoints = 1
    knife.data = WeaponData {
        skill = WeaponSkill.Melee,
        crit = 2,
        damage = 2,
        scale = WeaponScale.Personal,
        rangeband = WeaponRangebands.Engaged,
        sub_category = WeaponSubCategory.Blade
    }

    canteen := new(Item)
    canteen.name = "Canteen"
    canteen.description = "A small container for carrying water or\nother liquids."
    canteen.width = 2
    canteen.height = 2
    canteen.base_price = 50
    canteen.base_rarity = 1
    canteen.features = nil
    canteen.category = ItemCategory.Gear
    canteen.data = GearData {
        sub_category = GearSubCategory.Survival
    }
    append_elem(&canteen.features, "Can contain 1L of liquid")

    rifle_instance := new(ItemInstance)
    rifle_instance.definition = rifle
    rifle_instance.pos_x = 0
    rifle_instance.pos_y = 1
    rifle_instance.id = 1
    rifle_instance.rotated = false

    sword_instance := new(ItemInstance)
    sword_instance.definition = &reg.items["1"]
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
        rifle,
        sword_instance,
        rifle_instance,
        backpackItem,
        backpackInstance
    }
}

TestRegistry :: proc(registry: ^ItemRegistry){
    rapierBase, _ := MakeItemBase("1",
    "Vibro Rapier",
    "A lightweight sword with a vibrating edge,\ndesigned for quick and precise strikes.",
    5,
    1,
    6,
    1,
    false,
    5000,
    nil,
    nil,
    ItemCategory.Weapon,
    nil)

    rapier := MakeItemWeapons(
    rapierBase,
    2,
    5,
    1,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Blade)

    AddItemRegistry(registry, rapier)
}

TestCharacter :: proc(backpack: ^ItemInstance) -> ^Character {
    char := new(Character)
    char.name = "Lord Holcrub"
    char.id = "1"

    char.equipment.slots = make(map[EquipmentSlot]^ItemInstance)
    char.equipment.slots[.Backpack] = backpack

    belt_container := new(Container)
    belt_container.type = .Belt
    belt_container.storage = ContainerGrid{
        width = 4,
        height = 1,
    }

    beltItem := new(Item)
    beltItem.name = "Utility Belt"
    beltItem.height = 1
    beltItem.width = 4
    beltItem.description = "A utility belt with various pouches and compartments."
    beltItem.category = ItemCategory.Container
    beltItem.data = ContainerData{
        storage = belt_container,
        sub_category = .Belt
    }

    beltInstance := new(ItemInstance)
    beltInstance.definition = beltItem
    beltInstance.id = 101

    char.equipment.slots[.Belt] = beltInstance

    return char
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
    str.builder_init(&builder, context.temp_allocator)

    grid := make([][]rune, container.storage.(ContainerGrid).height, context.temp_allocator)

    for y in 0..<container.storage.(ContainerGrid).height {
        grid[y] = make([]rune, container.storage.(ContainerGrid).width, context.temp_allocator)

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