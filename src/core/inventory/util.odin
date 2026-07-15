package inventory

import str "core:strings"
import fmt "core:fmt"

TestItemInstance :: proc(cell_size: f32, reg: ^ItemDefinitionRegistry, instanceReg: ^ItemInstanceRegistry, debug: bool) -> struct{
    backpackInstance: ^ItemInstance, }
{
    backpackInstance, _ := MakeContainerInstance(&reg.items["SPACER_DUFFEL"], instanceReg, debug)

    rifle_instance, _ := MakeWeaponInstance(&reg.items["RIFLE"], instanceReg, debug, 0, 1)

    sword_instance, _ := MakeWeaponInstance(&reg.items["RAPIER"], instanceReg, debug)

    knife_instance, _ := MakeWeaponInstance(&reg.items["KNIFE"], instanceReg, debug, 5)

    canteen_instance, _ := MakeGearInstance(&reg.items["CANTEEN"], instanceReg, debug, 6, 1)


    ContainerAddItem(instanceReg.items[backpackInstance], instanceReg.items[rifle_instance])
    ContainerAddItem(instanceReg.items[backpackInstance], instanceReg.items[sword_instance])
    ContainerAddItem(instanceReg.items[backpackInstance], instanceReg.items[knife_instance])
    ContainerAddItem(instanceReg.items[backpackInstance], instanceReg.items[canteen_instance])

    return{
        backpackInstance = instanceReg.items[backpackInstance],
    }
}

TestRegistry :: proc(registry: ^ItemDefinitionRegistry, strReg: ^ItemCstringRegistry, debug: bool){
    //TODO: detect where to place newlines, no hardcoding shit in this part of town (For now atleast we mus)
    rapierBase, _ := MakeItemBase("RAPIER",
    "Vibro Rapier",
    "A lightweight sword with a vibrating edge, designed for quick and precise strikes.",
    5,
    1,
    6,
    1,
    false,
    5000,
    { "Pierce 5", "Knockdown" },
    {  },
    ItemCategory.Weapon,
    { .Melee },
    800,
    debug,
    .item_weapon_type_blade
    )
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
    "Carbine variant of the A280 blaster rifle, used by mostly by rebel troops",
    6,
    2,
    4,
    4,
    false,
    1200,
    { "Pierce 1", "Full-Auto" },
    {  },
    ItemCategory.Weapon,
    { .Blaster, .Ranged },
    2500,
    debug,
    .item_weapon_type_rifle)
    rifle, _ := MakeItemWeapons(
    rifleBase,
    7,
    300,
    4,
    WeaponRangebands.Long,
    WeaponSkill.Heavy,
    WeaponScale.Personal,
    WeaponSubCategory.Rifle)

    lancerPistolBase, _ := MakeItemBase("LANCER_PISTOL",
    "X-30 Lancer",
    "A compact blaster pistol with a high rate of fire, designed for close-quarters combat.",
    4,
    2,
    5,
    3,
    false,
    1000,
    { "Pierce 2", "Accurate 1" },
    {  },
    ItemCategory.Weapon,
    { .Blaster, .Ranged },
    1200,
    debug,
    .item_weapon_type_pistol)
    lancerPistol, _ := MakeItemWeapons(
    lancerPistolBase,
    5,
    100,
    4,
    WeaponRangebands.Long,
    WeaponSkill.Light,
    WeaponScale.Personal,
    WeaponSubCategory.Pistol)

    dl44HeavyPistolBase, _ := MakeItemBase("DL44_HEAVY_PISTOL",
    "DL-44 Heavy Blaster Pistol",
    "A powerful blaster pistol with a high stopping power, favored by smugglers and bounty hunters.",
    7,
    3,
    6,
    3,
    false,
    700,
    {  },
    { "May run out of ammo with 2 threat or one despair" },
    ItemCategory.Weapon,
    { .Blaster, .Ranged },
    1400,
    debug,
    .item_weapon_type_pistol)
    dl44HeavyPistol, _ := MakeItemWeapons(
    dl44HeavyPistolBase,
    6,
    150,
    4,
    WeaponRangebands.Medium,
    WeaponSkill.Light,
    WeaponScale.Personal,
    WeaponSubCategory.Pistol)

    m300HuntingBlasterBase, _ := MakeItemBase("M300_HUNTING_BLASTER",
    "M-300 Hunting Blaster",
    "A hunting blaster with a high rate of fire, designed for taking down large game.",
    5,
    2,
    6,
    1,
    false,
    1600,
    { "Pierce 2", "Accurate 1", "Cumbersome 2", "Stun Setting" },
    { "May reduce difficulty of combat checks at extreme or long range" },
    ItemCategory.Weapon,
    { .Blaster, .Ranged },
    2800,
    debug,
    .item_weapon_type_rifle)
    m300HuntingBlaster, _ := MakeItemWeapons(
    m300HuntingBlasterBase,
    8,
    200,
    3,
    WeaponRangebands.Long,
    WeaponSkill.Heavy,
    WeaponScale.Personal,
    WeaponSubCategory.Rifle)

    heavyRepeaterBase, _ := MakeItemBase("HEAVY_REPEATER",
    "E-Web Heavy Repeater",
    "A heavy repeating blaster with a high rate of fire, designed for sustained combat.",
    10,
    5,
    8,
    4,
    true,
    6000,
    { "Pierce 2", "Full-Auto", "Cumbersome 5", "Vicious 1" },
    {  },
    ItemCategory.Weapon,
    { .Blaster, .Ranged },
    18000,
    debug,
    .item_weapon_type_gunnery)
    heavyRepeater, _ := MakeItemWeapons(
    heavyRepeaterBase,
    15,
    200,
    2,
    WeaponRangebands.Long,
    WeaponSkill.Gunnery,
    WeaponScale.Personal,
    WeaponSubCategory.Gunnery)

    missileTube, _ := MakeItemBase("MISSILE_TUBE",
    "PLX-2M Missile Tube",
    "A missile tube for launching guided missiles.",
    8,
    4,
    9,
    4,
    true,
    7500,
    { "Breach 1", "Blast 10", "Cumbersome 3", "Guided 3", "Limited Ammo 6", "Prepare 1" },
    {  },
    ItemCategory.Weapon,
    { .Ranged },
    15000,
    debug,
    .item_weapon_type_explosive)
    missileLauncher, _ := MakeItemWeapons(
    missileTube,
    20,
    100,
    2,
    WeaponRangebands.Extreme,
    WeaponSkill.Gunnery,
    WeaponScale.Personal,
    WeaponSubCategory.Gunnery)

    shapedChargeBase, _ := MakeItemBase("SHAPED_CHARGE",
    "Shaped Charge",
    "A shaped charge explosive device, designed for breaching armored targets.",
    2,
    2,
    4,
    0,
    false,
    500,
    { "Breach 1", "Vicious 1" },
    { "+5 Damage and +1 Breach and Vicious per additional charge" },
    ItemCategory.Weapon,
    {  },
    1500,
    debug,
    .item_weapon_type_explosive)
    shapedCharge, _ := MakeItemWeapons(
    shapedChargeBase,
    15,
    5,
    4,
    WeaponRangebands.Engaged,
    WeaponSkill.Mechanics,
    WeaponScale.Personal,
    WeaponSubCategory.Explosive)

    antiVehicleMineBase, _ := MakeItemBase("ANTI_VEHICLE_MINE",
    "Anti-Vehicle Mine",
    "A mine designed to disable or destroy armored vehicles.",
    3,
    3,
    6,
    0,
    true,
    1400,
    { "Breach 4", "Blast 2" },
    {  },
    ItemCategory.Weapon,
    {  },
    5000,
    debug,
    .item_weapon_type_explosive)
    antiVehicleMine, _ := MakeItemWeapons(
    antiVehicleMineBase,
    25,
    15,
    2,
    WeaponRangebands.Engaged,
    WeaponSkill.Mechanics,
    WeaponScale.Personal,
    WeaponSubCategory.Explosive)

    truncheonBase, _ := MakeItemBase("TRUNCHEON",
    "Truncheon",
    "A short, heavy club",
    4,
    1,
    1,
    0,
    false,
    15,
    { "Disorient 2" },
    {  },
    ItemCategory.Weapon,
    { .Melee },
    1200,
    debug,
    .item_weapon_type_blunt)
    truncheon, _ := MakeItemWeapons(
    truncheonBase,
    2,
    1,
    5,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Blunt)

    gaffiStick, _ := MakeItemBase("GAFFI_STICK",
    "Gaffi Stick",
    "A traditional melee weapon used by the Tusken Raiders of Tatooine.",
    6,
    2,
    2,
    0,
    false,
    100,
    { "Defensive 1", "Disorient 3" },
    { "Two Handed" },
    ItemCategory.Weapon,
    { .Melee },
    2000,
    debug,
    .item_weapon_type_blunt)
    gaffiStickInstance, _ := MakeItemWeapons(
    gaffiStick,
    2,
    2,
    3,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Blunt)

    lightsaberBase, _ := MakeItemBase("CROSSGUARD_LIGHTSABER",
    "Lightsaber",
    "A lightsaber with a crossguard hilt, designed for both offense and defense.",
    3,
    1,
    5,
    10,
    true,
    10000,
    { "Breach 1", "Sunder", "Vicious 2" },
    {  },
    ItemCategory.Weapon,
    { .Melee },
    500,
    debug,
    .item_weapon_type_lightsaber)
    Lightsaber, _ := MakeItemWeapons(
    lightsaberBase,
    10,
    1,
    1,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Lightsaber)

    shotoLightsaberBase, _ := MakeItemBase("SHOTO_LIGHTSABER",
    "Shoto Lightsaber",
    "A shorter variant of the traditional lightsaber, designed for quick and agile combat.",
    2,
    1,
    10,
    8,
    true,
    9300,
    { "Breach 1", "Sunder", "Accurate 1" },
    {  },
    ItemCategory.Weapon,
    { .Melee },
    400,
    debug,
    .item_weapon_type_lightsaber)
    ShotoLightsaber, _ := MakeItemWeapons(
    shotoLightsaberBase,
    4,
    1,
    2,
    WeaponRangebands.Engaged,
    WeaponSkill.Melee,
    WeaponScale.Personal,
    WeaponSubCategory.Lightsaber)

    knifeBase, _ := MakeItemBase("KNIFE",
    "Vibro Knife",
    "A small, concealable knife with a vibrating edge, designed for stealthy attacks.",
    3,
    1,
    2,
    1,
    false,
    200,
    { "Pierce 2" },
    {  },
    ItemCategory.Weapon,
    { .Melee },
    400,
    debug,
    .item_weapon_type_blade)
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
    "A small container for carrying water or other liquids.",
    2,
    2,
    1,
    1,
    false,
    50,
    { "Breach 10" },
    { "Stores 1L of liquid" },
    ItemCategory.Gear,
    {  },
    1000,
    debug,
    .category_gear)
    canteen, _ := MakeItemGear(
    canteenBase,
    GearSubCategory.Survival,)

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
    {  },
    2500,
    debug,
    .category_storage)
    spacerDuffel, _ := MakeItemContainerGrid(
    spacerDuffelBase,
    8,
    10,
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
    {  },
    800,
    debug,
    .category_belt)
    utilityBelt, _ := MakeItemContainerGrid(
    beltBase,
    4,
    1,
    ContainerSubCategory.Belt)

    AddItemRegistry(registry, strReg, rapier, debug)
    AddItemRegistry(registry, strReg, rifle, debug)
    AddItemRegistry(registry, strReg, knife, debug)
    AddItemRegistry(registry, strReg, canteen, debug)
    AddItemRegistry(registry, strReg, spacerDuffel, debug)
    AddItemRegistry(registry, strReg, utilityBelt, debug)
    AddItemRegistry(registry, strReg, lancerPistol, debug)
    AddItemRegistry(registry, strReg, dl44HeavyPistol, debug)
    AddItemRegistry(registry, strReg, m300HuntingBlaster, debug)
    AddItemRegistry(registry, strReg, heavyRepeater, debug)
    AddItemRegistry(registry, strReg, missileLauncher, debug)
    AddItemRegistry(registry, strReg, shapedCharge, debug)
    AddItemRegistry(registry, strReg, antiVehicleMine, debug)
    AddItemRegistry(registry, strReg, truncheon, debug)
    AddItemRegistry(registry, strReg, gaffiStickInstance, debug)
    AddItemRegistry(registry, strReg, Lightsaber, debug)
    AddItemRegistry(registry, strReg, ShotoLightsaber, debug)
}

TestCharacter :: proc(backpack: ^ItemInstance, reg: ^ItemDefinitionRegistry, instanceReg: ^ItemInstanceRegistry, debug: bool) -> ^Character {
    char := new(Character)
    char.name = "Lord Holcrub"
    char.id = "1"

    char.equipment.slots = make(map[EquipmentSlot]^ItemInstance)
    char.equipment.slots[.Backpack] = backpack

    belt1ID, _ := MakeContainerInstance(&reg.items["UTILITY_BELT"], instanceReg, debug)
    belt2ID, _ := MakeContainerInstance(&reg.items["UTILITY_BELT"], instanceReg, debug)

    char.equipment.slots[.Belt] = instanceReg.items[belt1ID]
    char.equipment.slots[.Armor] = instanceReg.items[belt2ID]

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