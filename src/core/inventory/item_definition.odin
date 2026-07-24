package inventory
import ui "../../ui"

Item :: struct{
    id:            string,
    name:          string,
    description:   string,
    width, height: i16,
    base_rarity:   i8,
    hardpoints:    i8,
    restricted:    bool,
    base_price:    i32,
    qualities:     [dynamic]Quality,
    features:      [dynamic]string,
    mass_g:        f32,

    category:      ItemCategory,
    tags:          [dynamic]ItemTag,
    icon_enum:     ui.Icons,

    data:          ItemData
}

ItemData :: union{
    WeaponData,
    ContainerData,
    GearData,
    ArmorData
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

ContainerData :: struct{
    containerDef: ContainerDefinition,

    sub_category: ContainerSubCategory
}

GearData :: struct{
    sub_category: GearSubCategory
}

ArmorData :: struct{
    Soak:    i16,
    defense: i8,

    sub_category: ArmorSubCategory
}

ItemCstring :: struct{
    id,
    name,
    description,
    width,
    height,
    base_rarity,
    hardpoints,
    restricted,
    base_price,
    mass_g,
    mass_kg: cstring,

    features,
    tags,
    qualities: [dynamic]cstring,

    data: ItemCstringData,
    category,
    sub_category: cstring
}

ItemCstringData :: union{
    WeaponDataCstring,
    ContainerDataCstring,
    GearDataCstring,
    ArmorDataCstring
}

WeaponDataCstring :: struct{
    damage,
    range,
    rangeband,
    crit,
    skill,
    scale: cstring,
}

ContainerDataCstring :: struct{
    width,
    height: cstring,
}

GearDataCstring :: struct{
    //Empty for now, kept for future expansion
}

ArmorDataCstring :: struct{
    soak,
    defense: cstring,
}