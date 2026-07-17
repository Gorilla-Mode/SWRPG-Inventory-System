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

CanEquipInSlot :: proc(char: ^Character, slot: EquipmentSlot, item: ^ItemInstance) -> bool {
    if item == nil do return false
    if char == nil do return false
    if char.equipment.slots[slot] != nil do return false

    rule := SlotWhitelist[slot]
    item_cat := ItemCategoryMask(1 << u32(item.definition.category))

    if rule.cat_override == true do return true

    if (rule.categories & item_cat) == 0 do return false
    if (rule.blacklist_categories & item_cat) != 0 do return false

    return CheckSubCategory(item, rule)
}

CheckSubCategory :: proc(item: ^ItemInstance, rule: EquipmentSlotRule) -> bool {
    if rule.sub_override == true do return true

    switch data in item.definition.data {
    case WeaponData:
        weapon_mask := WeaponSubCategoryMask(1 << u32(data.sub_category))

        if (rule.blacklist_weapons & weapon_mask) != 0 do return false
        return (rule.weapons & weapon_mask) != 0
    case ContainerData:
        gear_mask := ContainerSubCategoryMask(1 << u32(data.sub_category))

        if (rule.blacklist_container & gear_mask) != 0 do return false
        return (rule.container & gear_mask) != 0
    case GearData:
        gear_mask := GearSubCategoryMask(1 << u32(data.sub_category))

        if (rule.blacklist_gear & gear_mask) != 0 do return false
        return (rule.gear & gear_mask) != 0
    }

    return false
}

GetItemsFromContainer :: proc(container: ^ItemInstance, all_items: ^[dynamic]^ItemInstance) {
    if container == nil do return

    container_data, container_ok := container.data.(ContainerInstanceData)
    if !container_ok do return

    for item in container_data.items {
        append(all_items, item)
        _, is_container := item.definition.data.(ContainerData)
        if !is_container do continue

        GetItemsFromContainer(item, all_items)
    }
}

GetAllCharacterItems :: proc(char: ^Character) -> [dynamic]^ItemInstance {
    all_items := make([dynamic]^ItemInstance, context.temp_allocator)
    for _, item in char.equipment.slots {
        if item == nil do continue

        _, is_container := item.definition.data.(ContainerData)
        if !is_container do continue

        GetItemsFromContainer(item, &all_items)
    }
    return all_items
}

FindContainerForItem :: proc(char: ^Character, item_to_find: ^ItemInstance) -> ^ItemInstance {
    for _, item in char.equipment.slots {
        if item == nil do continue

        _, is_container := item.definition.data.(ContainerData)
        if !is_container do continue

        found := FindInContainerRecursive(item, item_to_find)
        if found == nil do continue

        return found
    }
    return nil
}

FindInContainerRecursive :: proc(container: ^ItemInstance, item_to_find: ^ItemInstance) -> ^ItemInstance {
    if container == nil do return nil
    container_data, container_ok := container.data.(ContainerInstanceData)
    if !container_ok do return nil

    for item in container_data.items {
        if item == item_to_find do return container

        _, is_container := item.definition.data.(ContainerData)
        if !is_container do continue

        found := FindInContainerRecursive(item, item_to_find)
        if found == nil do continue

        return found
    }
    return nil
}

RemoveItemFromContainer :: proc(container: ^ItemInstance, item: ^ItemInstance) {
    container_data, container_ok := container.data.(ContainerInstanceData)
    if !container_ok do return

    for i in 0..<len(container_data.items) {
        if container_data.items[i] == item {
            ordered_remove(&container_data.items, i)
            container.data = container_data
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

IsContainerInItem :: proc(item: ^ItemInstance, target: ^ItemInstance) -> bool {
    _, container_type_ok := item.definition.data.(ContainerData)
    if !container_type_ok do return false

    if item == target do return true

    container_data, container_data_ok := item.data.(ContainerInstanceData)
    if !container_data_ok do return false

    for sub_item in container_data.items {
        if !IsContainerInItem(sub_item, target) do continue
        return true
    }
    return false
}

EquipItem :: proc(char: ^Character, slot: EquipmentSlot, item: ^ItemInstance) -> bool {
    if !CanEquipInSlot(char, slot, item) do return false
    
    RemoveItemFromCurrentLocation(char, item)
    char.equipment.slots[slot] = item
    return true
}

MoveItemToContainer :: proc(char: ^Character, container: ^ItemInstance, item: ^ItemInstance, x, y: i16, rotated: bool) {
    if IsContainerInItem(item, container) do return

    RemoveItemFromCurrentLocation(char, item)
    item.pos_x = x
    item.pos_y = y
    item.rotated = rotated
    container_data, ok := container.data.(ContainerInstanceData)
    if !ok do return

    append(&container_data.items, item)
    container.data = container_data
}