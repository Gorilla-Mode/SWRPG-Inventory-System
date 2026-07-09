package inventory

import fmt "core:fmt"
import m "core:math/rand"
import dbug "../debug"

ItemDefinitionRegistry :: struct{
    items: map[string]Item
}

ItemInstanceRegistry :: struct{
    items: map[u64]ItemInstance
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

AddItemRegistry :: proc(reg: ^ItemDefinitionRegistry, item: Item, debug: bool) -> RegistryError {
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

MakeItemInstanceRegistry :: proc() -> ItemInstanceRegistry {
    reg := ItemInstanceRegistry{
        items = make(map[u64]ItemInstance)
    }

    return reg
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

MakeWeaponInstance :: proc(definition: ^Item, reg: ^ItemInstanceRegistry, debug: bool) -> (^ItemInstance, InstanceError) {
    ok := CheckWeaponItemInstance(definition)
    if !ok.success {
        if debug do dbug.Warn(fmt.tprint("Failed to create weapon instance for item definition:", definition.id,
        "\n\t\t", ok.message))
        return nil, ok
    }

    id: u64 = GenerateInstanceID(reg, debug)

    instance := ItemInstance{
        id = id,
        definition = definition,
        rotated = false,
        data = WeaponInstanceData{
            attachments = make([dynamic]^ItemInstance)
        },
    }

    reg.items[instance.id] = instance
    if debug do dbug.Debug(fmt.tprint("Created weapon instance for item definition:", definition.id,
    "\n\t\tInstance ID:", instance.id))

    return &reg.items[id], ok
}