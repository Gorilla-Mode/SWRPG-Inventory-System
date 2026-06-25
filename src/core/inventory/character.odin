package inventory

EquipmentSlot :: enum{
    Backpack,
    Belt,
    Holster,
    Back,
    Armor
}

CharacterEquipment :: struct{
    slots: map[EquipmentSlot]^Container,
}

Character :: struct{
    id:   string,
    name: string,

    equipment: CharacterEquipment
}