package inventory

ItemCategory :: enum{
    Weapon,
    Gear,
    Armor,
    Container
}

ItemTag :: enum{
    Blaster,
    Slugthrower,
    Ranged,
    Melee,
}

WeaponSkill :: enum{
    Light,
    Heavy,
    Gunnery,
    Brawl,
    Melee,
    Mechanics
}

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
    Blade,
    Blunt,
    Explosive,
    Gunnery,
    Lightsaber
}

ContainerSubCategory :: enum{
    Backpack,
    Belt,
    Holster,
    Container,
    Bandolier
}

GearSubCategory :: enum{
    Tool,
    Medical,
    Electronics,
    Survival,
    Miscellaneous,
}