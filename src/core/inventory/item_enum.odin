package inventory

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

ContainerSubCategory :: enum{
    Backpack,
    Belt,
    Clothing,
    Pouch,
}

GearSubCategory :: enum{
    Tool,
    Medical,
    Electronics,
    Survival,
    Miscellaneous,
}