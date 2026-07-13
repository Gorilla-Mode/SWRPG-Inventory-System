package inventory

import str "core:strings"
import fmt "core:fmt"
import dbug "../debug"

//Calculate the area of an item
ItemArea :: proc(item: ^Item) -> i32
{
    return i32(item.width) * i32(item.height)
}

//Todo: Update to actual rarity price calculaton
//Calculate the total price of an item, based on its base price, and restricted status
ItemTotalPrice :: proc(item: ^Item) -> i32
{
    return item.base_price * i32(item.base_rarity)
}

GetItemDataString :: proc(item: ^Item) -> string {
    switch _ in item.data{
        case WeaponData:
            return GetItemWeaponString(item)
        case ContainerData:
            return GetItemContainerString(item)
        case GearData:
            return GetItemGearString(item)
    }
    return ""
}

GetItemWeaponString :: proc(item: ^Item) -> string {
    data, ok := item.data.(WeaponData)
    if !ok {
        return ""
    }

    b: str.Builder
    str.builder_init(&b, context.temp_allocator)

    str.write_string(&b, "Damage: ")
    if data.skill == WeaponSkill.Melee{
        str.write_string(&b, "+")
    }
    str.write_int(&b, int(data.damage))
    str.write_string(&b, "\n")

    if data.range > 0 {
        str.write_string(&b, "Range: ")
        str.write_int(&b, int(data.range))
        str.write_string(&b, "ft")
        str.write_string(&b, "\n")
    }

    str.write_string(&b, "Rangeband: ")
    str.write_string(&b, WeaponRangebandString(data.rangeband))
    str.write_string(&b, "\n")

    str.write_string(&b, "Crit: ")
    str.write_int(&b, int(data.crit))
    str.write_string(&b, "\n")

    str.write_string(&b, "Skill: ")
    str.write_string(&b, WeaponSkillString(data.skill))
    str.write_string(&b, "\n")

    str.write_string(&b, "Category: ")
    str.write_string(&b, WeaponSubCategoryString(data.sub_category))
    str.write_string(&b, "\n\n")

    return str.to_string(b)
}

//TODO: complete this function to return a string representation of the container data
GetItemContainerString :: proc(item: ^Item) -> string {
    data, ok := item.data.(ContainerData)
    if !ok {
        return ""
    }

    b: str.Builder
    str.builder_init(&b, context.temp_allocator)

    str.write_string(&b, "Storage Type: ")
    str.write_string(&b, ContainerSubCategoryString(data.sub_category))
    str.write_string(&b, "\n")

    return str.to_string(b)
}

GetItemGearString :: proc(item: ^Item) -> string {
    data, ok := item.data.(GearData)
    if !ok {
        return ""
    }

    b: str.Builder
    str.builder_init(&b, context.temp_allocator)

    str.write_string(&b, "Gear Type: ")
    str.write_string(&b, GearSubCategoryString(data.sub_category))
    str.write_string(&b, "\n")

    return str.to_string(b)
}

CreateItemCstring :: proc(item: Item, debug: bool) -> ItemCstring {
    strings := ItemCstring{}

    strings.icon_enum   = str.clone_to_cstring(fmt.tprint(item.icon_enum), context.allocator)
    strings.base_rarity = str.clone_to_cstring(fmt.tprint(item.base_rarity), context.allocator)
    strings.base_price  = str.clone_to_cstring(fmt.tprint(item.base_price), context.allocator)
    strings.hardpoints  = str.clone_to_cstring(fmt.tprint(item.hardpoints), context.allocator)
    strings.width       = str.clone_to_cstring(fmt.tprint(item.width), context.allocator)
    strings.height      = str.clone_to_cstring(fmt.tprint(item.height), context.allocator)
    strings.id          = str.clone_to_cstring(item.id, context.allocator)
    strings.name        = str.clone_to_cstring(item.name, context.allocator)
    strings.description = str.clone_to_cstring(item.description, context.allocator)

    if item.restricted do strings.restricted = "Restricted"
    else do strings.restricted = "Unrestricted"


    qualites_dyn, quality_err := make([dynamic]cstring)
    if quality_err != nil do panic("Failed to create qualities array")
    for q in item.qualities {
        append(&qualites_dyn, str.clone_to_cstring(q, context.allocator))
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