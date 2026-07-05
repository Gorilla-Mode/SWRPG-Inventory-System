package inventory

ItemError :: struct{
    success: bool,
    error: ItemErrors,
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
) -> Item {
    weapon := baseItem

    weapon.data = WeaponData{
        damage = damage,
        range = range,
        crit = crit,
        rangeband = rangeband,
        skill = skill,
        scale = scale,
        sub_category = subCategory,
    }

    return weapon
}