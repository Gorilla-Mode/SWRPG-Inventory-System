package inventory

//Top level category of the item, used for filtering and organization
ItemCategory :: enum{
    Weapon,
    Armor,
    Gear
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
    qualities:     []string,
    features:      []string,

    category:      ItemCategory,
    tags:          []ItemTag,

    data:          ItemData
}

//Union of all possible item data types, to be used in the Item struct
ItemData :: union{
    WeaponData,
}

WeaponData :: struct{
    damage:       i16,
    range:        i16,
    crit:         i8,
    type:         WeaponSkill,
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

//Damage scale of the weapon, e.g planetary damage at 10 is 100 damage at personal scale
WeaponScale :: enum{
    Personal,
    Planetary
}

WeaponRangebands :: enum{
    Engaged,
    Close,
    Short,
    Medium,
    Long,
    Extreme,
    Strategic
}

WeaponSubCategory :: enum{
    Pistol,
    Rifle,
    Carbine,
    Blade,
    Blunt,
}