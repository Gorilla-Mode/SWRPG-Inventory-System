package ui

import rl "vendor:raylib"
import os "core:os"
import "core:path/filepath"
import strings "core:strings"

// region Image Definitions
// Definiton of icons loaded, and to be used across the UI
// Names should correspond to file path of the icon
icons :: enum {
    app_icon,
    character_user,
    character_party,
    item_weapon_stat_crit,
    item_weapon_stat_dmg,
    item_weapon_type_pistol,
    item_weapon_type_rifle,
    item_weapon_type_gunnery,
    item_weapon_type_shotgun,
    item_weapon_type_melee,
    item_generic_hardpoint,
    item_weapon_stat_range,
    economy_wallet,
    economy_credit,
    economy_rarity,
    effect_restricted,
}

// Array of icon names corresponding to the icons enum variants, used for matching file names when loading icons.
// The order of names in this array should match the order of variants in the icons enum. And name correspond to the file name
// excluding the file extension.
ICON_NAMES := [?]string{
    "app_icon",
    "user",
    "party",
    "crit",
    "damage",
    "pistol",
    "rifle",
    "gunnery",
    "shotgun",
    "melee",
    "hardpoint",
    "range",
    "wallet",
    "credit",
    "rarity",
    "restricted",
}
//endregion

// Struct to hold the file path for each icon to be loaded.
IconMetadata :: struct {
    path: cstring,
}

// Loads all icons defined in the icons enum, and returns a map of icons to their corresponding rl.Image objects.
LoadImages :: proc() -> map[icons]rl.Image {
    icon_paths := make(map[icons]IconMetadata)
    Get_Icons(&icon_paths, "src/assets/icon")

    images := make(map[icons]rl.Image)

    for icon, metadata in icon_paths {
        loaded_image := rl.LoadImage(metadata.path)
        rl.ImageFormat(&loaded_image, .UNCOMPRESSED_R8G8B8A8)
        images[icon] = loaded_image
    }

    return images
}

// Recursively searches the specified directory for image files matching the defined icons, and populates a map of icons to their corresponding file paths.
Get_Icons :: proc(icon_paths: ^map[icons]IconMetadata, icon_dir: string) {
    handle, err := os.open(icon_dir)
    if err != os.ERROR_NONE {
        return
    }

    defer os.close(handle)

    entries, read_err := os.read_dir(handle, -1, context.allocator)
    if read_err != os.ERROR_NONE {
        return
    }

    for file in entries {
        if file.type == os.File_Type.Directory {
            sub_dir, join_err := filepath.join([]string{icon_dir, file.name}, context.allocator)
            if join_err != nil {
                return
            }

            Get_Icons(icon_paths, sub_dir) // Recursively search subdirectories for icons
        }

        filename := strings.trim_suffix(file.name, filepath.ext(file.name))

        for icon in icons {
            if !strings.equal_fold(filename, ICON_NAMES[icon]){
                continue
            }

            full_path, join_err := filepath.join([]string{icon_dir, file.name}, context.allocator)
            if join_err != nil {
                return
            }

            icon_paths[icon] = {path = strings.clone_to_cstring(full_path)}
        }
    }
}