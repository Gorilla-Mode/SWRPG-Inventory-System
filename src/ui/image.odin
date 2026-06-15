package ui

import rl "vendor:raylib"

// Definiton of icons loaded, and to be used across the UI
icons :: enum {
    app_icon
}
// Struct to hold the file path for each icon to be loaded.
IconMetadata :: struct {
    path: cstring,
}

// Loads all icons defined in the icons enum, and returns a map of icons to their corresponding rl.Image objects.
LoadImages :: proc() -> map[icons]rl.Image {
    icon_paths := make(map[icons]IconMetadata)
    icon_paths[.app_icon] = {path = "src/assets/icon/app/app_icon.png"}

    images := make(map[icons]rl.Image)

    for icon, metadata in icon_paths {
        loaded_image := rl.LoadImage(metadata.path)
        rl.ImageFormat(&loaded_image, .UNCOMPRESSED_R8G8B8A8)
        images[icon] = loaded_image
    }

    return images
}