package inventory

//Calculate the area of an item
ItemArea :: proc(item: ^Item) -> i32
{
    return i32(item.width) * i32(item.height)
}

//Calculate the total price of an item, based on its base price, and restricted status
ItemTotalPrice :: proc(item: ^Item, rarity: i8) -> i32
{
    legality_mod: i32 = item.restricted ? 2 : 4
    return (item.base_price * i32(rarity)) / legality_mod
}