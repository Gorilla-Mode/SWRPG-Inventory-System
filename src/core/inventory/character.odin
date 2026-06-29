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

ItemCategoryMask      :: distinct u32
WeaponSubCategoryMask :: distinct u32
GearSubCategoryMask   :: distinct u32
ArmorSubCategoryMask  :: distinct u32

CATEGORY_GEAR   :: ItemCategoryMask(1 << u32(ItemCategory.Gear))
CATEGORY_WEAPON :: ItemCategoryMask(1 << u32(ItemCategory.Weapon))
CATEGORY_ARMOR  :: ItemCategoryMask(1 << u32(ItemCategory.Armor))
CATEGORY_ALL    :: ItemCategoryMask(CATEGORY_GEAR | CATEGORY_WEAPON | CATEGORY_ARMOR)

WEAPON_PISTOL  :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Pistol))
WEAPON_BLADE   :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Blade))
WEAPON_CARBINE :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Carbine))
WEAPON_RIFLE   :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Rifle))
WEAPON_BLUNT   :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Blunt))
WEAPON_ALL     :: WeaponSubCategoryMask(WEAPON_PISTOL | WEAPON_BLADE | WEAPON_CARBINE | WEAPON_RIFLE | WEAPON_BLUNT)

CONTAINER_BACKPACK :: GearSubCategoryMask(1 << u32(ContainerSubCategory.Backpack))
CONTAINER_BELT     :: GearSubCategoryMask(1 << u32(ContainerSubCategory.Belt))
CONTAINER_CLOTHING :: GearSubCategoryMask(1 << u32(ContainerSubCategory.Clothing))
CONTAINER_POUCH    :: GearSubCategoryMask(1 << u32(ContainerSubCategory.Pouch))
CONTAINER_ALL      :: GearSubCategoryMask(CONTAINER_BACKPACK | CONTAINER_BELT | CONTAINER_CLOTHING | CONTAINER_POUCH)



EquipmentSlotRule :: struct {
    categories: ItemCategoryMask,
    weapons:  WeaponSubCategoryMask,
    gear:     GearSubCategoryMask,
    armor:    ArmorSubCategoryMask,

    blacklist_categories: ItemCategoryMask,
    blacklist_weapons:  WeaponSubCategoryMask,
    blacklist_gear:     GearSubCategoryMask,
    blacklist_armor:    ArmorSubCategoryMask,

    sub_override: bool,
    cat_override: bool,
}

SlotWhitelist := [EquipmentSlot]EquipmentSlotRule{
    .Backpack = {
        categories = CATEGORY_GEAR,
        gear = CONTAINER_BACKPACK,
    },

    .Belt = {
        categories = CATEGORY_GEAR,
        gear = CONTAINER_BELT,
    },

    .Holster = {
        categories = CATEGORY_WEAPON,
        weapons = WEAPON_PISTOL | WEAPON_BLADE | WEAPON_BLUNT,
    },

    .Back = {
        categories = CATEGORY_ALL,
        weapons = WEAPON_ALL,

        blacklist_gear = CONTAINER_ALL
    },

    .Armor = {
        categories = CATEGORY_ARMOR,
    },
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
        gear_mask := GearSubCategoryMask(1 << u32(data.sub_category))

        if (rule.blacklist_gear & gear_mask) != 0 do return false
        return (rule.gear & gear_mask) != 0
    }

    return true //true if item has no sub data
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
    if !CanEquipInSlot(char, slot, item) do return false
    
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