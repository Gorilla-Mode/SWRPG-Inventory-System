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

    reg.items[item.id] = item
    return RegistryError{ true, .Success, "Success" }
}