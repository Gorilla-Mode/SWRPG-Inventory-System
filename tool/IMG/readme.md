# Image Manifest Gen (IMG)

A command-line tool that automatically scans image directories and generates Odin code (enum and array) for convenient asset management in the SWIS project.

## Purpose

IMG eliminates the manual entires of defintions and filenames into the icon manifest. While also making sure index and values match.

## Output

This scans the `icon` directory and generates an Odin file with:

```odin
package ui

icons :: enum {
character_user,
character_party,
item_weapon_stat_crit,
}

ICON_NAMES := [?]string{
"user",
"party",
"crit",
}
```