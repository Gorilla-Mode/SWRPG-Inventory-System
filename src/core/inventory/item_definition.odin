package inventory

//Item model, as it exists in database
//Todo: add filtering support, tags, cateogy, subcategory
Item :: struct{
    id:            string,
    name:          string,
    description:   string,
    width, height: i8,
    base_rarity:   i8,
    base_price:    i32,
    restricted:    bool,
    qualities:     []string,
    features:      []string,

    data:          ItemData
}

//Union of all possible item data types, to be used in the Item struct
ItemData :: union{
    WeaponData,

}

WeaponData :: struct{
    damage: i16,
    range:  i16,
    crit:   i8,
    type:   WeaponType,
    scale:  WeaponScale
}

//The skill used to operate the weapon
WeaponType :: enum{
    Light,
    Heavy,
    Gunnery,
    Brawl
}

//Damage scale of the weapon, e.g planetary damage at 10 is 100 damage at personal scale
WeaponScale :: enum{
    Personal,
    Planetary
}