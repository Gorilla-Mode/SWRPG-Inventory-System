package inventory

EquipmentSlot :: enum{
    Backpack,
    Belt,
    Holster,
    Back,
    Armor
}

EquipmentSlotString := [EquipmentSlot]string{
    .Backpack = "Backpack",
    .Belt = "Belt",
    .Holster = "Holster",
    .Back = "Back",
    .Armor = "Armor"
}

Character :: struct{
    id:   string,
    name: string,

    equipment: CharacterEquipment
}

CharacterEquipment :: struct{
    slots: map[EquipmentSlot]^ItemInstance,
}

ItemCategoryMask :: distinct u32

CATEGORY_GEAR   :: ItemCategoryMask(1 << u32(ItemCategory.Gear))
CATEGORY_WEAPON :: ItemCategoryMask(1 << u32(ItemCategory.Weapon))
CATEGORY_ARMOR  :: ItemCategoryMask(1 << u32(ItemCategory.Armor))

SlotWhitelist := [EquipmentSlot]ItemCategoryMask{
    .Backpack = CATEGORY_GEAR,
    .Belt     = CATEGORY_GEAR,
    .Holster  = CATEGORY_WEAPON,
    .Back     = CATEGORY_WEAPON | CATEGORY_GEAR,
    .Armor    = CATEGORY_ARMOR,
}

CanEquipInSlot :: proc(slot: EquipmentSlot, item: ^ItemInstance) -> bool {
    if item == nil do return false

    allowed := SlotWhitelist[slot]
    item_mask := ItemCategoryMask(1 << u32(item.definition.category))

    return (allowed & item_mask) != 0
}

GetItemsFromContainer :: proc(container: ^Container, all_items: ^[dynamic]^ItemInstance) {
    if container == nil do return
    for item in container.items {
        append(all_items, item)
        container_data, ok := item.definition.data.(ContainerData)
        if !ok do continue

        GetItemsFromContainer(container_data.storage, all_items)
    }
}

GetAllCharacterItems :: proc(char: ^Character) -> [dynamic]^ItemInstance {
    all_items := make([dynamic]^ItemInstance, context.temp_allocator)
    for _, item in char.equipment.slots {
        if item == nil do continue

        container_data, ok := item.definition.data.(ContainerData)
        if !ok do continue

        GetItemsFromContainer(container_data.storage, &all_items)
    }
    return all_items
}

FindContainerForItem :: proc(char: ^Character, item_to_find: ^ItemInstance) -> ^Container {
    for _, item in char.equipment.slots {
        if item == nil do continue

        container_data, ok := item.definition.data.(ContainerData)
        if !ok do continue

        found := FindInContainerRecursive(container_data.storage, item_to_find)
        if found == nil do continue

        return found
    }
    return nil
}

FindInContainerRecursive :: proc(container: ^Container, item_to_find: ^ItemInstance) -> ^Container {
    if container == nil do return nil
    for item in container.items {
        if item == item_to_find do return container

        container_data, ok := item.definition.data.(ContainerData)
        if !ok do continue

        found := FindInContainerRecursive(container_data.storage, item_to_find)
        if found == nil do continue

        return found
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

RemoveItemFromCurrentLocation :: proc(char: ^Character, item: ^ItemInstance) {
    if old_container := FindContainerForItem(char, item); old_container != nil {
        RemoveItemFromContainer(old_container, item)
    }
    if old_slot, found := FindSlotForItem(char, item); found {
        delete_key(&char.equipment.slots, old_slot)
    }
}

IsContainerInItem :: proc(item: ^ItemInstance, target: ^Container) -> bool {
    data, ok := item.definition.data.(ContainerData)
    if !ok do return false

    if data.storage == target do return true

    for sub_item in data.storage.items {
        if !IsContainerInItem(sub_item, target) do continue
        return true
    }
    return false
}

EquipItem :: proc(char: ^Character, slot: EquipmentSlot, item: ^ItemInstance) -> bool {
    if !CanEquipInSlot(slot, item) {
        return false
    }
    
    RemoveItemFromCurrentLocation(char, item)
    char.equipment.slots[slot] = item
    return true
}

MoveItemToContainer :: proc(char: ^Character, container: ^Container, item: ^ItemInstance, x, y: i16, rotated: bool) {
    if IsContainerInItem(item, container) do return

    RemoveItemFromCurrentLocation(char, item)
    item.pos_x = x
    item.pos_y = y
    item.rotated = rotated
    append(&container.items, item)
}