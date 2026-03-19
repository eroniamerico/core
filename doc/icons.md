# Free 3D Icon Resources

This document lists free resources where 3D icons can be obtained for use
in Harbour GUI applications (e.g. `gtwvg`, `gtwvw`).

## Icon Formats Supported by Harbour

Harbour GUI terminals accept `.ico` files via `HB_GTI_ICONFILE`, and icon
resources embedded in executables via `HB_GTI_ICONRES`.

## Free 3D Icon Sources

The following websites offer free 3D icons suitable for use in desktop
applications:

| Site | License | Notes |
|------|---------|-------|
| <https://icon-icons.com> | Various (CC, Free) | Large collection of 3D-style icons in ICO, PNG, SVG |
| <https://www.iconfinder.com> | Various (Free tier available) | Filter by "3D" style; download in ICO/PNG |
| <https://icons8.com> | Free with attribution | 3D icon packs available in multiple sizes |
| <https://www.flaticon.com> | Free with attribution | 3D icon sets in PNG/SVG (convert to ICO with tools below) |
| <https://iconarchive.com> | Various (mostly free) | Browse and download `.ico` files directly |
| <https://www.iconsdb.com> | CC0 / Public domain | Download icons directly as `.ico` |
| <https://freeiconshop.com> | Free | Windows `.ico` format available |

## Converting PNG/SVG to ICO

If a site only provides PNG or SVG files, you can convert them to `.ico`
using free tools:

- **ImageMagick** (command-line, cross-platform):
  ```
  magick input.png -define icon:auto-resize=256,128,64,48,32,16 output.ico
  ```
- **GIMP** (graphical editor, cross-platform): File → Export As → `.ico`
- **ConvertICO** (<https://convertico.com>): Online converter, no software required

## Using Icons in Harbour Applications

```harbour
// Set window icon from a file
hb_gtInfo( HB_GTI_ICONFILE, "myicon.ico" )

// Set window icon from an embedded resource
hb_gtInfo( HB_GTI_ICONRES, "MYICON" )
```

See `contrib/gtwvg/tests/` for working examples of icon usage in Harbour
GUI applications.
