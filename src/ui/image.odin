package ui

import rl "vendor:raylib"

icons :: enum {
    app,
}

// Loads the images for the application and returns a map of icons to their corresponding rl.Image objects.
load_images :: proc() -> map[icons]rl.Image{
    images := make(map[icons]rl.Image)
    defer delete(images)

    icon: rl.Image = rl.LoadImage("src/assets/icon/app/cryo-chamber.png")
    rl.ImageFormat(&icon, .UNCOMPRESSED_R8G8B8A8)
    images[.app] = icon

    return images
}