package inventory

import str "core:strings"

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
    }
    return ""
}

GetItemWeaponString :: proc(item: ^Item) -> string {
    data, ok := item.data.(WeaponData)
    if !ok {
        return ""
    }

    b: str.Builder
    str.builder_init(&b)

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
    str.builder_init(&b)

    str.write_string(&b, "Storage Type: ")
    str.write_string(&b, ContainerSubCategoryString(data.sub_category))
    str.write_string(&b, "\n")


    return str.to_string(b)
}