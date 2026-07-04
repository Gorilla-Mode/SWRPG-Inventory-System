package inventory

ItemCategoryMask         :: distinct u32
WeaponSubCategoryMask    :: distinct u32
GearSubCategoryMask      :: distinct u32
ArmorSubCategoryMask     :: distinct u32
ContainerSubCategoryMask :: distinct u32

EquipmentSlotRule :: struct {
    categories: ItemCategoryMask,
    weapons:    WeaponSubCategoryMask,
    gear:       GearSubCategoryMask,
    armor:      ArmorSubCategoryMask,
    container:  ContainerSubCategoryMask,

    blacklist_categories: ItemCategoryMask,
    blacklist_weapons:    WeaponSubCategoryMask,
    blacklist_gear:       GearSubCategoryMask,
    blacklist_armor:      ArmorSubCategoryMask,
    blacklist_container:  ContainerSubCategoryMask,

    sub_override: bool,
    cat_override: bool
}

CATEGORY_GEAR      :: ItemCategoryMask(1 << u32(ItemCategory.Gear))
CATEGORY_WEAPON    :: ItemCategoryMask(1 << u32(ItemCategory.Weapon))
CATEGORY_ARMOR     :: ItemCategoryMask(1 << u32(ItemCategory.Armor))
CATEGORY_CONTAINER :: ItemCategoryMask(1 << u32(ItemCategory.Container))
CATEGORY_ALL       :: ItemCategoryMask(CATEGORY_GEAR | CATEGORY_WEAPON | CATEGORY_ARMOR | CATEGORY_CONTAINER)

WEAPON_PISTOL     :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Pistol))
WEAPON_BLADE      :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Blade))
WEAPON_RIFLE      :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Rifle))
WEAPON_BLUNT      :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Blunt))
WEAPON_EXPLOSIVE  :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Explosive))
WEAPON_GUNNERY    :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Gunnery))
WEAPON_LIGHTSABER :: WeaponSubCategoryMask(1 << u32(WeaponSubCategory.Lightsaber))
WEAPON_ALL        :: WeaponSubCategoryMask(WEAPON_PISTOL | WEAPON_BLADE | WEAPON_RIFLE | WEAPON_BLUNT | WEAPON_EXPLOSIVE | WEAPON_GUNNERY | WEAPON_LIGHTSABER)

CONTAINER_BACKPACK  :: ContainerSubCategoryMask(1 << u32(ContainerSubCategory.Backpack))
CONTAINER_BELT      :: ContainerSubCategoryMask(1 << u32(ContainerSubCategory.Belt))
CONTAINER_HOLSTER   :: ContainerSubCategoryMask(1 << u32(ContainerSubCategory.Holster))
CONTAINER_CONTAINER :: ContainerSubCategoryMask(1 << u32(ContainerSubCategory.Container))
CONTAINER_BANDOLIER :: ContainerSubCategoryMask(1 << u32(ContainerSubCategory.Bandolier))
CONTAINER_ALL       :: ContainerSubCategoryMask(CONTAINER_BACKPACK | CONTAINER_BELT | CONTAINER_HOLSTER | CONTAINER_CONTAINER | CONTAINER_BANDOLIER)

GEAR_TOOL        :: GearSubCategoryMask(1 << u32(GearSubCategory.Tool))
GEAR_MEDICAL     :: GearSubCategoryMask(1 << u32(GearSubCategory.Medical))
GEAR_ELECTRONICS :: GearSubCategoryMask(1 << u32(GearSubCategory.Electronics))
GEAR_SURVIVAL    :: GearSubCategoryMask(1 << u32(GearSubCategory.Survival))
GEAR_MISC        :: GearSubCategoryMask(1 << u32(GearSubCategory.Miscellaneous))
GEAR_ALL         :: GearSubCategoryMask(GEAR_TOOL | GEAR_MEDICAL | GEAR_ELECTRONICS | GEAR_SURVIVAL | GEAR_MISC)

SlotWhitelist := [EquipmentSlot]EquipmentSlotRule{
    .Backpack = {
        categories = CATEGORY_CONTAINER,
        container = CONTAINER_BACKPACK,
    },

    .Belt = {
        categories = CATEGORY_CONTAINER,
        container = CONTAINER_BELT,
    },

    .Holster = {
        categories = CATEGORY_WEAPON,
        weapons = WEAPON_PISTOL | WEAPON_BLADE | WEAPON_BLUNT,
    },

    .Back = {
        categories = CATEGORY_ALL,
        blacklist_categories = CATEGORY_CONTAINER,
        sub_override = true
    },

    .Armor = {
        categories = CATEGORY_ARMOR,
    },
}