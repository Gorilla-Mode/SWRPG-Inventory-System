package inventory

import ui "../../ui"
import dbug "../../core/debug"
import fmt "core:fmt"

MakeItemBase :: proc(
    id: string,
    name: string,
    description: string,
    width: i16,
    height: i16,
    base_rarity: i8,
    hardpoints: i8,
    restricted: bool,
    base_price: i32,
    qualities: []Quality,
    features: []string,
    category: ItemCategory,
    tags: []ItemTag,
    mass: f32,
    debug: bool,
    icon_enum: ui.Icons = nil,
) -> (Item, ItemError) {
   icon := icon_enum
   if icon == nil {
       if debug do dbug.Warn(fmt.tprint(args = {"Item ", dbug.HIGHLIGHT_WARN, id, dbug.HIGHLIGHT_WARN_END, " has no icon_enum set, defaulting to gui_square" }, sep = ""))
       icon = ui.Icons.gui_square
   }

    ok := CheckBaseItem(base_rarity, hardpoints, base_price, mass, width, height )
    if !ok.success {
        return Item{}, ok
    }

    qualities_dyn := make([dynamic]Quality)
    for q in qualities {
        append(&qualities_dyn, q)
    }

    features_dyn := make([dynamic]string)
    for f in features {
        append(&features_dyn, f)
    }

    tags_dyn := make([dynamic]ItemTag)
    for t in tags {
        append(&tags_dyn, t)
    }

    return Item{
        id = id,
        name = name,
        description = description,
        width = width,
        height = height,
        base_rarity = base_rarity,
        hardpoints = hardpoints,
        restricted = restricted,
        base_price = base_price,
        qualities = qualities_dyn,
        features = features_dyn,
        mass_g = mass,
        category = category,
        tags = tags_dyn,
        icon_enum = icon,
    }, ok
}

MakeItemWeapons :: proc (baseItem: Item,
    damage, range: i16,
    crit: i8,
    rangeband: WeaponRangebands,
    skill: WeaponSkill,
    scale: WeaponScale,
    subCategory: WeaponSubCategory
) -> (Item, WeaponError) {
    weapon := baseItem

    ok := CheckWeaponItem(damage, range, crit)
    if !ok.success {
        return Item{}, ok
    }

    weapon.data = WeaponData{
        damage = damage,
        range = range,
        crit = crit,
        rangeband = rangeband,
        skill = skill,
        scale = scale,
        sub_category = subCategory,
    }

    return weapon, ok
}

MakeItemGear :: proc (baseItem: Item,
    subCategory: GearSubCategory
) -> (Item, GearError) {
    gear := baseItem

    ok := CheckGearItem(gear)
    if !ok.success {
        return Item{}, ok
    }

    gear.data = GearData{
        sub_category = subCategory,
    }

    return gear, ok
}

MakeItemContainerGrid :: proc(baseItem: Item,
    width, height: i16,
    subCategory: ContainerSubCategory
) -> (Item, ContainerError) {
    container := baseItem

    baseItem := CheckBaseItem(container.base_rarity, container.hardpoints, container.base_price, container.mass_g, width, height)
    if !baseItem.success {
        return Item{}, ContainerError{ false, .InvalidData, "Base item data is invalid" }
    }

    ok := CheckContainerGridItem(width, height)
    if !ok.success {
        return Item{}, ok
    }

    container.data = ContainerData{
        containerDef = ContainerDefinition{
            storage = ContainerGrid{
                width = width,
                height = height,
            },
        },
        sub_category = subCategory,
    }

    return container, ok
}