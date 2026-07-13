package inventory

WeaponSkillString :: proc(skill: WeaponSkill) -> string {
    return WeaponSkillStrings[skill]
}

WeaponScaleString :: proc(scale: WeaponScale) -> string {
    return WeaponScaleStrings[scale]
}

WeaponRangebandString :: proc(rangeband: WeaponRangebands) -> string {
    return WeaponRangebandStrings[rangeband]
}

WeaponSubCategoryString :: proc(sub_category: WeaponSubCategory) -> string {
    return WeaponSubCategoryStrings[sub_category]
}

ContainerSubCategoryString :: proc(sub_category: ContainerSubCategory) -> string {
    return ContainerSubCategoryStrings[sub_category]
}

GearSubCategoryString :: proc(sub_category: GearSubCategory) -> string {
    return GearSubCategoryStrings[sub_category]
}

GearSubCategoryStrings := [GearSubCategory]string{
    GearSubCategory.Tool = "Tool",
    GearSubCategory.Medical = "Medical",
    GearSubCategory.Electronics = "Electronics",
    GearSubCategory.Survival = "Survival",
    GearSubCategory.Miscellaneous = "Miscellaneous",
}

ContainerSubCategoryStrings := [ContainerSubCategory]string{
    ContainerSubCategory.Backpack = "Backpack",
    ContainerSubCategory.Belt = "Belt",
    ContainerSubCategory.Holster = "Holster",
    ContainerSubCategory.Container = "Container",
    ContainerSubCategory.Bandolier = "Bandolier",
}

WeaponSubCategoryStrings := [WeaponSubCategory]string{
    WeaponSubCategory.Pistol = "Pistol",
    WeaponSubCategory.Rifle = "Rifle",
    WeaponSubCategory.Blade = "Blade",
    WeaponSubCategory.Blunt = "Blunt",
    WeaponSubCategory.Explosive = "Explosive",
    WeaponSubCategory.Gunnery = "Gunnery",
    WeaponSubCategory.Lightsaber = "Lightsaber",
}

WeaponRangebandStrings := [WeaponRangebands]string{
    WeaponRangebands.Engaged = "Engaged",
    WeaponRangebands.Close = "Close",
    WeaponRangebands.Short = "Short",
    WeaponRangebands.Medium = "Medium",
    WeaponRangebands.Long = "Long",
    WeaponRangebands.Extreme = "Extreme",
    WeaponRangebands.Strategic = "Strategic",
}

WeaponSkillStrings := [WeaponSkill]string{
    WeaponSkill.Light = "Light",
    WeaponSkill.Heavy = "Heavy",
    WeaponSkill.Gunnery = "Gunnery",
    WeaponSkill.Brawl = "Brawl",
    WeaponSkill.Melee = "Melee",
    WeaponSkill.Mechanics = "Mechanics",
}

WeaponScaleStrings := [WeaponScale]string{
    WeaponScale.Personal = "Personal",
    WeaponScale.Planetary = "Planetary",
}