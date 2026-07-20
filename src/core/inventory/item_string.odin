package inventory

import str "core:strings"
import fmt "core:fmt"
import dbug "../debug"

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

ItemQualityString :: proc(quality: Quality) -> string {
    quality_name := ""
    switch quality.type {
    case .Pirece:
        quality_name = "Pierce"
    case .Stun_Setting:
        quality_name = "Stun Setting"
    case .Breach:
        quality_name = "Breach"
    case .Accurate:
        quality_name = "Accurate"
    case .Sunder:
        quality_name = "Sunder"
    case .Vicious:
        quality_name = "Vicious"
    case .Disorient:
        quality_name = "Disorient"
    case .Defensive:
        quality_name = "Defensive"
    case .Blast:
        quality_name = "Blast"
    case .Cumbersome:
        quality_name = "Cumbersome"
    case .Guided:
        quality_name = "Guided"
    case .Prepare:
        quality_name = "Prepare"
    case .Limited_Ammo:
        quality_name = "Limited Ammo"
    case .Full_Auto:
        quality_name = "Full-Auto"
    case .Knockdown:
        quality_name = "Knockdown"
    }

    if quality.count == 0 {
        return quality_name
    }

    return fmt.tprint(args = {quality_name, " ", quality.count}, sep = "")
}

CreateItemCstring :: proc(item: ^Item, debug: bool) -> ItemCstring {
    base := CreateItemBaseCstring(item, debug)
    switch _ in item.data{
    case WeaponData:
        return CreateItemWeaponCstring(item, base, debug)
    case ContainerData:
        return CreateItemContainerCstring(item, base, debug)
    case GearData:
        return CreateItemGearCstring(item, base, debug)
    }

    dbug.Debug(fmt.tprint(args = {"Item data type not recognized for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
    return {}
}

CreateItemBaseCstring :: proc(item: ^Item, debug: bool) -> ItemCstring {
    strings := ItemCstring{}

    strings.base_rarity = str.clone_to_cstring(fmt.tprint(item.base_rarity), context.allocator)
    strings.base_price  = str.clone_to_cstring(fmt.tprint(args = { item.base_price, "cr" }, sep = ""), context.allocator)
    strings.hardpoints  = str.clone_to_cstring(fmt.tprint(item.hardpoints), context.allocator)
    strings.width       = str.clone_to_cstring(fmt.tprint(item.width), context.allocator)
    strings.height      = str.clone_to_cstring(fmt.tprint(item.height), context.allocator)
    strings.id          = str.clone_to_cstring(item.id, context.allocator)
    strings.name        = str.clone_to_cstring(item.name, context.allocator)
    strings.description = str.clone_to_cstring(item.description, context.allocator)
    strings.mass_g      = str.clone_to_cstring(fmt.tprint(args = { item.mass_g, "g" }, sep = ""), context.allocator)
    strings.mass_kg     = str.clone_to_cstring(fmt.tprint(args = { item.mass_g / 1000, "kg" }, sep = ""), context.allocator)

    if item.restricted do strings.restricted = "Restricted"
    else do strings.restricted = "Legal"

    qualites_dyn, quality_err := make([dynamic]cstring)
    if quality_err != nil do panic("Failed to create qualities array")
    for q in item.qualities {
        append(&qualites_dyn, str.clone_to_cstring(ItemQualityString(q), context.allocator))
    }

    tags_dyn, tag_err := make([dynamic]cstring)
    if tag_err != nil do panic("Failed to create tags array")
    for t in item.tags {
        append(&tags_dyn, str.clone_to_cstring(fmt.tprint(t), context.allocator))
    }

    features_dyn, feature_err := make([dynamic]cstring)
    if feature_err != nil do panic("Failed to create features array")
    for f in item.features {
        append(&features_dyn, str.clone_to_cstring(f, context.allocator))
    }

    strings.qualities = qualites_dyn
    strings.tags = tags_dyn
    strings.features = features_dyn

    if debug do dbug.Debug(fmt.tprint(args = {"Created ItemCstring for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))

    return strings
}

CreateItemWeaponCstring :: proc(item: ^Item, base: ItemCstring, debug: bool) -> ItemCstring {
    weapon := base

    itemData, ok := item.data.(WeaponData)
    if !ok {
        dbug.Warn(fmt.tprint(args = {"Item data type not recognized for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
        return base
    }

    weapon.category = "Weapon"
    weapon.sub_category = str.clone_to_cstring(WeaponSubCategoryString(itemData.sub_category), context.allocator)
    weapon.data = WeaponDataCstring{
        damage = str.clone_to_cstring(fmt.tprint(itemData.damage), context.allocator),
        range = str.clone_to_cstring(fmt.tprint(itemData.range), context.allocator),
        rangeband = str.clone_to_cstring(fmt.tprint(itemData.rangeband), context.allocator),
        crit = str.clone_to_cstring(fmt.tprint(itemData.crit), context.allocator),
        skill = str.clone_to_cstring(fmt.tprint(itemData.skill), context.allocator),
        scale = str.clone_to_cstring(fmt.tprint(itemData.scale), context.allocator),
    }


    if debug do dbug.Debug(fmt.tprint(args = {"Created Weapon ItemCstring for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
    return weapon
}

CreateItemContainerCstring :: proc(item: ^Item, base: ItemCstring, debug: bool) -> ItemCstring {
    Container := base
    itemData, ok := item.data.(ContainerData)
    if !ok {
        dbug.Warn(fmt.tprint(args = {"Item data type not recognized for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
        return base
    }

    Container.category = "Container"
    Container.sub_category = str.clone_to_cstring(ContainerSubCategoryString(itemData.sub_category), context.allocator)
    Container.data = ContainerDataCstring{
        width = str.clone_to_cstring(fmt.tprint(itemData.containerDef.storage.(ContainerGrid).width), context.allocator),
        height = str.clone_to_cstring(fmt.tprint(itemData.containerDef.storage.(ContainerGrid).height), context.allocator),
    }

    if debug do dbug.Debug(fmt.tprint(args = {"Created Container ItemCstring for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
    return Container
}

CreateItemGearCstring :: proc(item: ^Item, base: ItemCstring, debug: bool) -> ItemCstring {
    Gear := base
    itemData, ok := item.data.(GearData)
    if !ok {
        dbug.Warn(fmt.tprint(args = {"Item data type not recognized for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
        return base
    }

    Gear.category = "Gear"
    Gear.sub_category = str.clone_to_cstring(GearSubCategoryString(itemData.sub_category), context.allocator)
    Gear.data = GearDataCstring{ }

    if debug do dbug.Debug(fmt.tprint(args = {"Created Gear ItemCstring for item: ", dbug.HIGHLIGHT_DEBUG, item.id, dbug.HIGHLIGHT_DEBUG_END}, sep = ""))
    return Gear
}