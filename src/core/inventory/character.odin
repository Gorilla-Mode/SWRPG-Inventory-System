package inventory

EquipmentSlot :: enum{
    Backpack,
    Belt,
    Holster,
    Back,
    Armor
}

CharacterEquipment :: struct{
    slots: map[EquipmentSlot]^ItemInstance,
}

Character :: struct{
    id:   string,
    name: string,

    equipment: CharacterEquipment
}

GetItemsFromContainer :: proc(container: ^Container, all_items: ^[dynamic]^ItemInstance) {
    if container == nil do return
    for item in container.items {
        append(all_items, item)
        if container_data, ok := item.definition.data.(ContainerData); ok {
            GetItemsFromContainer(container_data.storage, all_items)
        }
    }
}

GetAllCharacterItems :: proc(char: ^Character) -> [dynamic]^ItemInstance {
    all_items := make([dynamic]^ItemInstance, context.temp_allocator)
    for _, item in char.equipment.slots {
        if item == nil do continue
        if container_data, ok := item.definition.data.(ContainerData); ok {
            GetItemsFromContainer(container_data.storage, &all_items)
        }
    }
    return all_items
}

FindContainerForItem :: proc(char: ^Character, item_to_find: ^ItemInstance) -> ^Container {
    for _, item in char.equipment.slots {
        if item == nil do continue
        if container_data, ok := item.definition.data.(ContainerData); ok {
            if found := FindInContainerRecursive(container_data.storage, item_to_find); found != nil {
                return found
            }
        }
    }
    return nil
}

FindInContainerRecursive :: proc(container: ^Container, item_to_find: ^ItemInstance) -> ^Container {
    if container == nil do return nil
    for item in container.items {
        if item == item_to_find do return container
        if container_data, ok := item.definition.data.(ContainerData); ok {
            if found := FindInContainerRecursive(container_data.storage, item_to_find); found != nil {
                return found
            }
        }
    }
    return nil
}

RemoveItemFromContainer :: proc(container: ^Container, item: ^ItemInstance) {
    for i in 0..<len(container.items) {
        if container.items[i] == item {
            ordered_remove(&container.items, i)
            return
        }
    }
}

FindSlotForItem :: proc(char: ^Character, item: ^ItemInstance) -> (EquipmentSlot, bool) {
    for slot, equipped_item in char.equipment.slots {
        if equipped_item == item {
            return slot, true
        }
    }
    return {}, false
}