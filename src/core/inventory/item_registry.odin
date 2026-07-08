package inventory

ItemRegistry :: struct{
    items: map[string]Item
}

RegistryError :: struct{
    success: bool,
    error: RegistryErrors,
    message: string,
}

RegistryErrors :: enum{
    Success,
    BaseItemError,
    ItemAlreadyExists,
}

MakeItemRegistry :: proc() -> ItemRegistry {
    reg := ItemRegistry{
        items = make(map[string]Item)
    }

    return reg
}

AddItemRegistry :: proc(reg: ^ItemRegistry, item: Item) -> RegistryError {
    ok := CheckBaseItemItem(item)
    if !ok.success {
        return RegistryError{ false, .BaseItemError, ok.message }
    }

    if item.id in reg.items {
        return RegistryError{ false, .ItemAlreadyExists, "Item with id id already exists" }
    }

    //TODO: Fill in rest
    #partial switch _ in item.data {
    case WeaponData:
        weapon_ok := CheckWeaponItemItem(item)
        if !weapon_ok.success {
            return RegistryError{ false, .BaseItemError, weapon_ok.message }
        }
    case GearData:
        gear_ok := CheckGearItemItem(item)
        if !gear_ok.success {
            return RegistryError{ false, .BaseItemError, gear_ok.message }
        }
    case ContainerData:
        container_ok := CheckContainerGridItemItem(item)
        if !container_ok.success {
            return RegistryError{ false, .BaseItemError, container_ok.message }
        }
    }

    reg.items[item.id] = item
    return RegistryError{ true, .Success, "Success" }
}