package inventory

ContainerType :: enum{
    Backpack,
    Belt,
    Clothing,
}

Container :: struct{
    id: string,
    width, height: i16,
    type: ContainerType,

    items: [dynamic]^Item
}