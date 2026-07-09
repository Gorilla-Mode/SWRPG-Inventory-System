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

ContainerError :: struct{
    success: bool,
    error: ContainerErrors,
    message: string,
}

InstanceError :: struct{
    success: bool,
    error: InstanceErrors,
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

ContainerErrors :: enum{
    Success,
    InvalidData,
}

InstanceErrors :: enum{
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

CheckContainerGridItem :: proc(width, height: i16) -> (ContainerError) {
    if width < 1 {
        return ContainerError{ false, .InvalidData, "Container width must be greater than 0" }
    }

    if height < 1 {
        return ContainerError{ false, .InvalidData, "Container height must be greater than 0" }
    }

    return ContainerError{ true, .Success, "Success" }
}

CheckGearItem :: proc(item: Item) -> (GearError) {
//fr no checks for gear items, but to add later, and consistency with other item types, we have this function
    return GearError{ true, .Success, "Success" }
}

CheckBaseItemItem :: proc(item: Item) -> (ItemError) {
    baseItem := CheckBaseItem(item.base_rarity, item.hardpoints, item.base_price, item.width, item.height)
    if baseItem.success != true {
        return ItemError{ false, .InvalidRarity, "Base item data is invalid" }
    }

    return ItemError{ true, .Success, "Success" }
}

CheckWeaponItemItem :: proc(item: Item) -> (WeaponError) {
    baseItem := CheckBaseItemItem(item)
    if baseItem.success != true {
        return WeaponError{ false, .InvalidData, "Base item data is invalid" }
    }

    if item.category != .Weapon {
        return WeaponError{ false, .InvalidData, "Item is not a weapon" }
    }

    weapon := item.data.(WeaponData)
    return CheckWeaponItem(weapon.damage, weapon.range, weapon.crit)
}

CheckGearItemItem :: proc(item: Item) -> (GearError) {
    baseItem := CheckBaseItemItem(item)
    if baseItem.success != true {
        return GearError{ false, .InvalidData, "Base item data is invalid" }
    }

    if item.category != .Gear {
        return GearError{ false, .InvalidData, "Item is not a gear item" }
    }

    return CheckGearItem(item)
}

CheckContainerGridItemItem :: proc(item: Item) -> (ContainerError) {
    baseItem := CheckBaseItemItem(item)
    if baseItem.success != true {
        return ContainerError{ false, .InvalidData, "Base item data is invalid" }
    }

    if item.category != .Container {
        return ContainerError{ false, .InvalidData, "Item is not a container" }
    }

    containerGrid, ok := item.data.(ContainerData).containerDef.storage.(ContainerGrid)
    if !ok {
        return ContainerError{ false, .InvalidData, "Container storage is not a grid" }
    }

    return CheckContainerGridItem(containerGrid.width, containerGrid.height)
}

CheckWeaponItemInstance :: proc(itemDefinition: ^Item) -> (InstanceError) {
    _, ok := itemDefinition.data.(WeaponData)
    if !ok {
        return InstanceError{ false, .InvalidData, "Item definition is not a weapon" }
    }

    return InstanceError{ true, .Success, "Success" }
}

CheckGearItemInstance :: proc(itemDefinition: ^Item) -> (InstanceError) {
    _, ok := itemDefinition.data.(GearData)
    if !ok {
        return InstanceError{ false, .InvalidData, "Item definition is not a gear item" }
    }

    return InstanceError{ true, .Success, "Success" }
}