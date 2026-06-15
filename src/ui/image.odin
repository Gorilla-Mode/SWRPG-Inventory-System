package ui

import rl "vendor:raylib"

icons :: enum {
    app,
}

IconMetadata :: struct {
    path: cstring,
}

LoadImages :: proc() -> map[icons]rl.Image {
    icon_paths := make(map[icons]IconMetadata)
    icon_paths[.app] = {path = "src/assets/icon/app/cryo-chamber.png"}

    images := make(map[icons]rl.Image)

    for icon, metadata in icon_paths {
        loaded_image := rl.LoadImage(metadata.path)
        rl.ImageFormat(&loaded_image, .UNCOMPRESSED_R8G8B8A8)
        images[icon] = loaded_image
    }

    return images
}