package inventory

//Calculate the area of an item
ItemArea :: proc(item: ^Item) -> i32
{
    return i32(item.width) * i32(item.height)
}

//Todo: Update to actual rarity price calculaton
//Calculate the total price of an item, based on its base price, and restricted status
ItemTotalPrice :: proc(item: ^Item) -> i32
{
    return item.base_price * i32(item.base_rarity)
}