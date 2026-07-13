package inventory

import fmt "core:fmt"
import m "core:math/rand"
import dbug "../debug"

//TODO: Consider taking pointers or some other ds, can fuck memory if map resizes
ItemDefinitionRegistry :: struct{
    items: map[string]Item
}

ItemCstringRegistry :: struct{
    items: map[string]ItemCstring
}

ItemInstanceRegistry :: struct{
    items: map[u64]^ItemInstance
}

RegistryError :: struct{
    success: bool,
    error: RegistryErrors,
    message: string,
}

RegistryErrors :: enum{
    Success,
    BaseItemError,
    ItemAlreadyExists,
}

MakeItemDefinitionRegistry :: proc() -> ItemDefinitionRegistry {
    reg := ItemDefinitionRegistry{
        items = make(map[string]Item)
    }

    return reg
}

MakeCstringRegistry :: proc() -> ItemCstringRegistry {
    reg := ItemCstringRegistry{
        items = make(map[string]ItemCstring)
    }

    return reg
}

AddItemRegistry :: proc(reg: ^ItemDefinitionRegistry, strReg: ^ItemCstringRegistry, item: Item, debug: bool) -> RegistryError {
    ok := CheckBaseItemItem(item)
    if !ok.success {
        if debug do dbug.Warn(fmt.tprint("Failed to add item to registry:", item.id,
        "\n\t\t", ok.message))

        return RegistryError{ false, .BaseItemError, ok.message }
    }

    if item.id in reg.items {
        if debug do dbug.Warn(fmt.tprint("Failed to add item to registry:", item.id,
        "\n\t\tItem with id already exists in registry"))

        return RegistryError{ false, .ItemAlreadyExists, "Item with id id already exists" }
    }

    //TODO: Fill in rest
    #partial switch _ in item.data {
    case WeaponData:
        weapon_ok := CheckWeaponItemItem(item)
        if !weapon_ok.success {
            if debug do dbug.Warn(fmt.tprint("Failed to add weapon item to registry:", item.id,
            "\n\t\t", weapon_ok.message))

            return RegistryError{ false, .BaseItemError, weapon_ok.message }
        }
    case GearData:
        gear_ok := CheckGearItemItem(item)
        if !gear_ok.success {
            if debug do dbug.Warn(fmt.tprint("Failed to add gear item to registry:", item.id,
            "\n\t\t", gear_ok.message))

            return RegistryError{ false, .BaseItemError, gear_ok.message }
        }
    case ContainerData:
        container_ok := CheckContainerGridItemItem(item)
        if !container_ok.success {
            if debug do dbug.Warn(fmt.tprint("Failed to add container item to registry:", item.id,
            "\n\t\t", container_ok.message))

            return RegistryError{ false, .BaseItemError, container_ok.message }
        }
    }

    reg.items[item.id] = item
    if debug do dbug.Debug(fmt.tprint("Added item to registry:", item.id))

    return RegistryError{ true, .Success, "Success" }
}

GenerateItemCstringRegistry :: proc(reg: ^ItemDefinitionRegistry, strReg: ^ItemCstringRegistry, debug: bool) {
    for key in reg.items {
        item := reg.items[key]
        strItem := CreateItemCstring(&item, debug)
        strReg.items[key] = strItem
    }
}

MakeItemInstanceRegistry :: proc() -> ItemInstanceRegistry {
    reg := ItemInstanceRegistry{
        items = make(map[u64]^ItemInstance, context.allocator,)
    }

    return reg
}

DeleteItemInstanceRegistry :: proc(reg: ^ItemInstanceRegistry) {
    for _, instance in reg.items {
        free(instance)
    }

    delete(reg.items)
}

GenerateInstanceID :: proc(reg: ^ItemInstanceRegistry, debug: bool, depth: u16 = 0) -> u64 {
    if depth > 100 {
        panic("Failed to generate unique instance ID after 100 attempts")
    }

    id : u64 = m.uint64()

    if id in reg.items {
        if debug do dbug.Warn(fmt.tprint("Failed to generate unique instance ID:", id,
        "\n\t\tID already exists in registry, retrying..."))
        return GenerateInstanceID(reg, debug, depth + 1)
    }

    if debug do dbug.Debug(fmt.tprint("Generated unique instance ID:", id))

    return id
}

MakeWeaponInstance :: proc(definition: ^Item, reg: ^ItemInstanceRegistry, debug: bool, posX: i16 = 0, posY: i16 = 0) -> (u64, InstanceError) {
    ok := CheckWeaponItemInstance(definition)
    if !ok.success {
        if debug do dbug.Warn(fmt.tprint("Failed to create weapon instance for item definition:", definition.id,
        "\n\t\t", ok.message))
        return 0, ok
    }

    id: u64 = GenerateInstanceID(reg, debug)

    instance := new(ItemInstance)
    instance.id = id
    instance.definition = definition
    instance.data = WeaponInstanceData{
        attachments = make([dynamic]^ItemInstance, context.allocator),
    }
    instance.pos_x = posX
    instance.pos_y = posY

    reg.items[instance.id] = instance
    if debug do dbug.Debug(fmt.tprint("Created weapon instance for item definition:", definition.id,
    "\n\t\tInstance ID:", instance.id))

    return id, ok
}

MakeGearInstance :: proc(definition: ^Item, reg: ^ItemInstanceRegistry, debug: bool, posX: i16 = 0, posY: i16 = 0) -> (u64, InstanceError) {
    ok := CheckGearItemInstance(definition)
    if !ok.success {
        if debug do dbug.Warn(fmt.tprint("Failed to create gear instance for item definition:", definition.id,
        "\n\t\t", ok.message))
        return 0, ok
    }

    id: u64 = GenerateInstanceID(reg, debug)

    instance := new(ItemInstance)
    instance.id = id
    instance.definition = definition
    instance.rotated = false
    instance.pos_x = posX
    instance.pos_y = posY
    instance.data = GearInstanceData{
        attachments = make([dynamic]^ItemInstance)
    }

    reg.items[instance.id] = instance
    if debug do dbug.Debug(fmt.tprint("Created gear instance for item definition:", definition.id,
    "\n\t\tInstance ID:", instance.id))

    return id, ok
}

MakeContainerInstance :: proc(definition: ^Item, reg: ^ItemInstanceRegistry, debug: bool, posX: i16 = 0, posY: i16 = 0) -> (u64, InstanceError) {
    ok := CheckContainerGridItemInstance(definition)
    if !ok.success {
        if debug do dbug.Warn(fmt.tprint("Failed to create container instance for item definition:", definition.id,
        "\n\t\t", ok.message))
        return 0, ok
    }

    id: u64 = GenerateInstanceID(reg, debug)

    instance := new(ItemInstance)
    instance.id = id
    instance.definition = definition
    instance.rotated = false
    instance.pos_x = posX
    instance.pos_y = posY
    instance.data = ContainerInstanceData{
        items = make([dynamic]^ItemInstance, context.allocator),
    }

    reg.items[instance.id] = instance
    if debug do dbug.Debug(fmt.tprint("Created container instance for item definition:", definition.id,
    "\n\t\tInstance ID:", instance.id))

    return id, ok
}