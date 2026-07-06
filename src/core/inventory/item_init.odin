package inventory

ItemError :: struct{
    success: bool,
    error: ItemErrors,
    message: string,
}

WeaponError :: struct{
    success: bool,
    error: WeaponErrors,
    message: string,
}

GearError :: struct{
    success: bool,
    error: GearErrors,
    message: string,
}

ItemErrors :: enum{
    Success,
    InvalidRarity,
    InvalidPrice,
    InvalidWidth,
    InvalidHeight,
    InvalidHardpoints,
}

WeaponErrors :: enum{
    Success,
    InvalidDamage,
    InvalidRange,
    InvalidCrit,
    InvalidData,
}

GearErrors :: enum{
    Success,
    InvalidData,
}

CheckBaseItem :: proc(base_rarity, hardpoints: i8, base_price: i32, width, height: i16) -> (ItemError) {
    if base_rarity < 1 || base_rarity > 10 {
        return ItemError{ false, .InvalidRarity, "Base rarity must be between 1 and 5" }
    }

    if base_price < 0 {
        return ItemError{ false, .InvalidPrice, "Base price must be greater than or equal to 0" }
    }

    if width < 1 {
        return ItemError{ false, .InvalidWidth, "Width must be greater than 0" }
    }

    if height < 1 {
        return ItemError{ false, .InvalidHeight, "Height must be greater than 0" }
    }

    if hardpoints < 0 {
        return ItemError{ false, .InvalidHardpoints, "Hardpoints must be greater than or equal to 0" }
    }

    return ItemError{ true, .Success, "Success" }
}

CheckWeaponItem :: proc(damage, range: i16, crit: i8) -> (WeaponError) {
    if damage < 1 {
        return WeaponError{ false, .InvalidDamage, "Weapon damage must be greater than or equal to 1" }
    }

    if range < 0 {
        return WeaponError{ false, .InvalidRange, "Weapon range must be greater than or equal to 0" }
    }

    if crit < 1 {
        return WeaponError{ false, .InvalidCrit, "Weapon crit must be greater than or equal to 1" }
    }

    return WeaponError{ true, .Success, "Success" }
}

CheckGearItem :: proc(item: Item) -> (GearError) {
    //fr no checks for gear items, but to add later, and consistency with other item types, we have this function
    return GearError{ true, .Success, "Success" }
}

CheckBaseItemItem :: proc(item: Item) -> (ItemError) {
    return CheckBaseItem(item.base_rarity, item.hardpoints, item.base_price, item.width, item.height)
}

CheckWeaponItemItem :: proc(item: Item) -> (WeaponError) {
    if item.category != .Weapon {
        return WeaponError{ false, .InvalidData, "Item is not a weapon" }
    }

    weapon := item.data.(WeaponData)
    return CheckWeaponItem(weapon.damage, weapon.range, weapon.crit)
}

CheckGearItemItem :: proc(item: Item) -> (GearError) {
    if item.category != .Gear {
        return GearError{ false, .InvalidData, "Item is not a gear item" }
    }

    return CheckGearItem(item)
}

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
    qualities: []string,
    features: []string,
    category: ItemCategory,
    tags: []ItemTag,
) -> (Item, ItemError) {

    ok := CheckBaseItem(base_rarity, hardpoints, base_price, width, height)
    if !ok.success {
        return Item{}, ok
    }

    qualities_dyn := make([dynamic]string)
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
        category = category,
        tags = tags_dyn,
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