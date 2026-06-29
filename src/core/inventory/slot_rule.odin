package inventory

ItemCategoryMask      :: distinct u32
WeaponSubCategoryMask :: distinct u32
GearSubCategoryMask   :: distinct u32
ArmorSubCategoryMask  :: distinct u32

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
    cat_override: bool
}

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