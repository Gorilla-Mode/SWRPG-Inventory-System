package inventory

//Calculate the area of an item
ItemArea :: proc(item: ^Item) -> i32
{
    return i32(item.width) * i32(item.height)
}

//Calculate the total price of an item, based on its base price, and restricted status
ItemTotalPrice :: proc(item: ^Item, rarity: i8) -> i64
{
    legality_mod: i64 = item.restricted ? 2 : 4
    return (i64(item.base_price) * i64(rarity)) / legality_mod
}