package inventory

ItemRegistry :: struct{
    items: map[string]Item
}

MakeItemRegistry :: proc() -> ItemRegistry {
    reg := ItemRegistry{
        items = make(map[string]Item)
    }

    return reg
}

AddItemRegistry :: proc(reg: ^ItemRegistry, item: Item) {
    reg.items[item.id] = item
}