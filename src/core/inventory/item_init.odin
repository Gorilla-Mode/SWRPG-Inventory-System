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
    qualities: [dynamic]string,
    features: [dynamic]string,
    category: ItemCategory,
    tags: [dynamic]ItemTag,
) -> (Item, ItemError) {

    ok := CheckBaseItem(base_rarity, hardpoints, base_price, width, height)
    if !ok.success {
        return Item{}, ok
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
        qualities = qualities,
        features = features,
        category = category,
        tags = tags,
    }, ok
}