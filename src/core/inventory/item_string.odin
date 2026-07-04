package inventory

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
    case WeaponSubCategory.Blade:
        return "Blade"
    case WeaponSubCategory.Blunt:
        return "Blunt"
    case WeaponSubCategory.Explosive:
        return "Explosive"
    case WeaponSubCategory.Gunnery:
        return "Gunnery"
    case WeaponSubCategory.Lightsaber:
        return "Lightsaber"
    }
    return ""
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