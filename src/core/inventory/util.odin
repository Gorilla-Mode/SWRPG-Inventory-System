package inventory

import str "core:strings"
import fmt "core:fmt"

TestItemInstance :: proc(cell_size: f32, reg: ^ItemRegistry) -> struct{
    backpack: ^ItemInstance,
    sword_instance: ^ItemInstance,
    rifle_instance: ^ItemInstance,
    backpackInstance: ^ItemInstance}
{

    backpackInstance := new(ItemInstance)
    backpackInstance.definition = &reg.items["SPACER_DUFFEL"]
    backpackInstance.id = 100
    backpackInstance.data = ContainerInstanceData{
        items = make([dynamic]^ItemInstance, context.allocator),
    }

    rifle_instance := new(ItemInstance)
    rifle_instance.definition = &reg.items["RIFLE"]
    rifle_instance.pos_x = 0
    rifle_instance.pos_y = 1
    rifle_instance.id = 1
    rifle_instance.rotated = false

    sword_instance := new(ItemInstance)
    sword_instance.definition = &reg.items["RAPIER"]
    sword_instance.pos_x = 0
    sword_instance.pos_y = 0
    sword_instance.id = 2
    sword_instance.rotated = false

    knife_instance := new(ItemInstance)
    knife_instance.definition = &reg.items["KNIFE"]
    knife_instance.pos_x = 5
    knife_instance.pos_y = 0
    knife_instance.id = 3
    knife_instance.rotated = false

    canteen_instance := new(ItemInstance)
    canteen_instance.definition = &reg.items["CANTEEN"]
    canteen_instance.pos_x = 6
    canteen_instance.pos_y = 1
    canteen_instance.id = 4
    canteen_instance.rotated = false

    backpack_data := backpackInstance.data.(ContainerInstanceData)
    append_elem(&backpack_data.items, sword_instance)
    append_elem(&backpack_data.items, rifle_instance)
    append_elem(&backpack_data.items, knife_instance)
    append_elem(&backpack_data.items, canteen_instance)
    backpackInstance.data = backpack_data

    return{
        backpackInstance,
        sword_instance,
        rifle_instance,
        backpackInstance
    }
}

TestRegistry :: proc(registry: ^ItemRegistry){
    //TODO: detect where to place newlines, no hardcoding shit in this part of town (For now atleast we mus)
    rapierBase, _ := MakeItemBase("RAPIER",
    "Vibro Rapier",
    "A lightweight sword with a vibrating edge,\ndesigned for quick and precise strikes.",
    5,
    1,
    6,
    1,
    false,
    5000,
    { "Pierce 5", "Knockdown" },
    {  },
    ItemCategory.Weapon,
    { .Melee })
    rapier, _ := MakeItemWeapons(
    rapierBase,
    2,
    5,
    1,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Blade)

    rifleBase, _ := MakeItemBase("RIFLE",
    "A280C Blaster Rifle",
    "Carbine variant of the A280 blaster rifle,\nused by mostly by rebel troops",
    6,
    2,
    4,
    4,
    false,
    1200,
    { "Pierce 1", "Full-Auto" },
    {  },
    ItemCategory.Weapon,
    { .Blaster, .Ranged })
    rifle, _ := MakeItemWeapons(
    rifleBase,
    7,
    300,
    4,
    WeaponRangebands.Long,
    WeaponSkill.Heavy,
    WeaponScale.Personal,
    WeaponSubCategory.Rifle)

    knifeBase, _ := MakeItemBase("KNIFE",
    "Vibroknife",
    "A small, concealable knife with a\nvibrating edge, designed for stealthy\nattacks.",
    3,
    1,
    2,
    1,
    false,
    200,
    { "Pierce 2" },
    {  },
    ItemCategory.Weapon,
    { .Melee })
    knife, _ := MakeItemWeapons(
    knifeBase,
    2,
    1,
    2,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Blade)

    canteenBase, _ := MakeItemBase("CANTEEN",
    "Canteen",
    "A small container for carrying water or\nother liquids.",
    2,
    2,
    1,
    1,
    false,
    50,
    { "Breach 10" },
    { "Stores 1L of liquid" },
    ItemCategory.Gear,
    {  })
    canteen, _ := MakeItemGear(
    canteenBase,
    GearSubCategory.Survival)

    spacerDuffelBase, _ := MakeItemBase("SPACER_DUFFEL",
    "Spacer's Duffel",
    "A standard backpack for carrying items.",
    8,
    10,
    1,
    1,
    false,
    100,
    {  },
    {  },
    ItemCategory.Container,
    {  })
    spacerDuffel, _ := MakeItemContainerGrid(
    spacerDuffelBase,
    8,
    10,
    ContainerType.Backpack,
    ContainerSubCategory.Backpack)

    beltBase, _ := MakeItemBase("UTILITY_BELT",
    "Utility Belt",
    "A utility belt with various pouches and compartments.",
    4,
    1,
    1,
    1,
    false,
    150,
    {  },
    {  },
    ItemCategory.Container,
    {  })
    utilityBelt, _ := MakeItemContainerGrid(
    beltBase,
    4,
    1,
    ContainerType.Belt,
    ContainerSubCategory.Belt)

    ok := AddItemRegistry(registry, rapier)
    fmt.println("Added rapier to registry:", ok.success, "Error:", ok.message)

    ok = AddItemRegistry(registry, rifle)
    fmt.println("Added rifle to registry:", ok.success, "Error:", ok.message)

    ok = AddItemRegistry(registry, knife)
    fmt.println("Added knife to registry:", ok.success, "Error:", ok.message)

    ok = AddItemRegistry(registry, canteen)
    fmt.println("Added canteen to registry:", ok.success, "Error:", ok.message)

    ok = AddItemRegistry(registry, spacerDuffel)
    fmt.println("Added spacer duffel to registry:", ok.success, "Error:", ok.message)

    ok = AddItemRegistry(registry, utilityBelt)
    fmt.println("Added utility belt to registry:", ok.success, "Error:", ok.message)
}

TestCharacter :: proc(backpack: ^ItemInstance, reg: ^ItemRegistry) -> ^Character {
    char := new(Character)
    char.name = "Lord Holcrub"
    char.id = "1"

    char.equipment.slots = make(map[EquipmentSlot]^ItemInstance)
    char.equipment.slots[.Backpack] = backpack

    beltInstance := new(ItemInstance)
    beltInstance.definition = &reg.items["UTILITY_BELT"]
    beltInstance.id = 101
    beltInstance.data = ContainerInstanceData{
        items = make([dynamic]^ItemInstance, context.allocator),
    }

    beltInstance2 := new(ItemInstance)
    beltInstance2.definition = &reg.items["UTILITY_BELT"]
    beltInstance2.id = 102
    beltInstance2.data = ContainerInstanceData{
        items = make([dynamic]^ItemInstance, context.allocator),
    }

    char.equipment.slots[.Belt] = beltInstance
    char.equipment.slots[.Armor] = beltInstance2

    return char
}

//Test function to test the ContainerCanPlace function with various positions for the rifle item instance in the backpack container
TestInvGrid :: proc(backpack: ^ItemInstance, sword: ^Item, rifle: ^Item, sword_instance: ^ItemInstance, rifle_instance: ^ItemInstance)
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
ContainerToString :: proc(container: ^ItemInstance) -> string {
    builder := str.Builder{}
    str.builder_init(&builder, context.temp_allocator)

    container_data := container.definition.data.(ContainerData)
    grid_storage := container_data.containerDef.storage.(ContainerGrid)
    container_items := container.data.(ContainerInstanceData)

    grid := make([][]rune, grid_storage.height, context.temp_allocator)

    for y in 0..<grid_storage.height {
        grid[y] = make([]rune, grid_storage.width, context.temp_allocator)

        for x in 0..<grid_storage.width {
            grid[y][x] = '.'
        }
    }

    symbols := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    for item, i in container_items.items {
        symbol := rune(symbols[i % len(symbols)])
        b := GetBounds(item)

        for y in 0..<b.height {
            for x in 0..<b.width {

                gx := b.pos_x + x
                gy := b.pos_y + y

                if gx < 0 || gx >= grid_storage.width ||
                gy < 0 || gy >= grid_storage.height {
                    continue
                }

                grid[gy][gx] = symbol
            }
        }
    }

    for y in 0..<grid_storage.height {
        for x in 0..<grid_storage.width {
            str.write_rune(&builder, grid[y][x])
        }

        str.write_string(&builder, "\n")
    }

    return str.to_string(builder)
}