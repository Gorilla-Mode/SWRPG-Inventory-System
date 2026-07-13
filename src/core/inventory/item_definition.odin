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
    qualities:     [dynamic]string,
    features:      [dynamic]string,

    category:      ItemCategory,
    tags:          [dynamic]ItemTag,
    icon_enum:     ui.Icons,

    data:          ItemData
}

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

ContainerData :: struct{
    containerDef: ContainerDefinition,

    sub_category: ContainerSubCategory
}

GearData :: struct{
    sub_category: GearSubCategory
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
    icon_enum: cstring,

    features,
    tags,
    qualities: [dynamic]cstring
}