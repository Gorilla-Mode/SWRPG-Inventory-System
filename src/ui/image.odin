package ui

import rl "vendor:raylib"
import os "core:os"
import "core:path/filepath"
import strings "core:strings"


// Struct to hold the file path for each icon to be loaded.
IconMetadata :: struct {
    path: cstring,
}

// Loads all icons defined in the icons enum, and returns a map of icons to their corresponding rl.Image objects.
LoadImages :: proc() -> map[Icons]rl.Texture2D {
    icon_paths := make(map[Icons]IconMetadata)
    defer delete(icon_paths)
    Get_Icons(&icon_paths, "src/assets/icon")

    images := make(map[Icons]rl.Texture2D)

    for icon, metadata in icon_paths {
        loaded_image : = rl.LoadImage(metadata.path)
        rl.ImageResize(&loaded_image, 64, 64)
        tex := rl.LoadTextureFromImage(loaded_image)

        rl.GenTextureMipmaps(&tex)
        rl.SetTextureFilter(tex, rl.TextureFilter.TRILINEAR)

        images[icon] = tex
    }

    free_all(context.temp_allocator)
    return images
}

// Unloads all images in the provided map of icons to their corresponding rl.Image objects, and frees the memory allocated for the map itself.
FreeImages :: proc(images: map[Icons]rl.Texture2D) {
    for _, img in images {
        rl.UnloadTexture(img)
    }
    delete(images)
}

// Recursively searches the specified directory for image files matching the defined icons, and populates a map of icons to their corresponding file paths.
Get_Icons :: proc(icon_paths: ^map[Icons]IconMetadata, icon_dir: string) {
    handle, err := os.open(icon_dir)
    if err != os.ERROR_NONE {
        return
    }

    defer os.close(handle)

    entries, read_err := os.read_dir(handle, -1, context.temp_allocator)
    if read_err != os.ERROR_NONE {
        return
    }

    for file in entries {
        if file.type == os.File_Type.Directory {
            sub_dir, join_err := filepath.join([]string{icon_dir, file.name}, context.temp_allocator)
            if join_err != nil {
                return
            }

            Get_Icons(icon_paths, sub_dir) // Recursively search subdirectories for icons
        }

        filename := strings.trim_suffix(file.name, filepath.ext(file.name))

        for icon in Icons {
            if !strings.equal_fold(filename, Icon_names[icon]){
                continue
            }

            full_path, join_err := filepath.join([]string{icon_dir, file.name}, context.temp_allocator)
            if join_err != nil {
                return
            }

            icon_paths[icon] = {path = strings.clone_to_cstring(full_path, context.temp_allocator)}
        }
    }
}