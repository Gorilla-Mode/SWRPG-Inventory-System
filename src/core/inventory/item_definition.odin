package inventory

//Top level category of the item, used for filtering and organization
ItemCategory :: enum{
    Weapon,
    Gear,
    Armor,
    Container
}

//Tags for the item, used for filtering and organization
ItemTag :: enum{
    Blaster,
    Slugthrower,
    Ranged,
    Melee,
}

//Item model, as it exists in database
Item :: struct{
    id:            string,
    name:          string,
    description:   string,
    width, height: i16,
    base_rarity:   i8,
    hardpoints:    i8,
    restricted:    bool,
    base_price:    i32,
    qualities:     [dynamic]string,
    features:      [dynamic]string,

    category:      ItemCategory,
    tags:          [dynamic]ItemTag,

    data:          ItemData
}

//Union of all possible item data types, to be used in the Item struct
ItemData :: union{
    WeaponData,
    ContainerData,
    GearData
}

WeaponData :: struct{
    damage:       i16,
    range:        i16,
    rangeband:    WeaponRangebands,
    crit:         i8,
    skill:        WeaponSkill,
    scale:        WeaponScale,

    sub_category: WeaponSubCategory,
}

//The skill used to operate the weapon
WeaponSkill :: enum{
    Light,
    Heavy,
    Gunnery,
    Brawl,
    Melee,
    Mechanics
}

WeaponSkillString :: proc(skill: WeaponSkill) -> string {
    switch skill {
        case WeaponSkill.Light:
            return "Light"
        case WeaponSkill.Heavy:
            return "Heavy"
        case WeaponSkill.Gunnery:
            return "Gunnery"
        case WeaponSkill.Brawl:
            return "Brawl"
        case WeaponSkill.Melee:
            return "Melee"
        case WeaponSkill.Mechanics:
            return "Mechanics"
    }
    return ""
}

WeaponScaleString :: proc(scale: WeaponScale) -> string {
    switch scale {
        case WeaponScale.Personal:
            return "Personal"
        case WeaponScale.Planetary:
            return "Planetary"
    }
    return ""
}

WeaponRangebandString :: proc(rangeband: WeaponRangebands) -> string {
    switch rangeband {
        case WeaponRangebands.Engaged:
            return "Engaged"
        case WeaponRangebands.Close:
            return "Close"
        case WeaponRangebands.Short:
            return "Short"
        case WeaponRangebands.Medium:
            return "Medium"
        case WeaponRangebands.Long:
            return "Long"
        case WeaponRangebands.Extreme:
            return "Extreme"
        case WeaponRangebands.Strategic:
            return "Strategic"
    }
    return ""
}

WeaponSubCategoryString :: proc(sub_category: WeaponSubCategory) -> string {
    switch sub_category {
        case WeaponSubCategory.Pistol:
            return "Pistol"
        case WeaponSubCategory.Rifle:
            return "Rifle"
        case WeaponSubCategory.Carbine:
            return "Carbine"
        case WeaponSubCategory.Blade:
            return "Blade"
        case WeaponSubCategory.Blunt:
            return "Blunt"
    }
    return ""
}

ContainerData :: struct{
    storage: ^Container,

    sub_category: ContainerSubCategory
}

ContainerSubCategoryString :: proc(sub_category: ContainerSubCategory) -> string {
    switch sub_category {
        case ContainerSubCategory.Backpack:
            return "Backpack"
        case ContainerSubCategory.Belt:
            return "Belt"
        case ContainerSubCategory.Clothing:
            return "Clothing"
        case ContainerSubCategory.Pouch:
            return "Pouch"
    }
    return ""
}

GearData :: struct{
    sub_category: GearSubCategory
}

GearSubCategoryString :: proc(sub_category: GearSubCategory) -> string {
    switch sub_category {
        case GearSubCategory.Tool:
            return "Tool"
        case GearSubCategory.Medical:
            return "Medical"
        case GearSubCategory.Electronics:
            return "Electronics"
        case GearSubCategory.Survival:
            return "Survival"
        case GearSubCategory.Miscellaneous:
            return "Miscellaneous"
    }
    return ""
}