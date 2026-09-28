# Quickshell

A small Quickshell status bar for Hyprland with workspace switching, a clock, and a power menu.

Quickshell documentation: [quickshell.org/docs](https://quickshell.org/docs/)

## Requirements

- Hyprland
- Quickshell with its Qt Quick and Hyprland QML modules
- JetBrainsMono Nerd Font (used by the theme)
- `hyprlock` for the Lock menu action (optional)

## Run

From the project directory, start the shell with:

```sh
quickshell -p "$PWD/shell.qml"
```

To start it automatically with Hyprland, add this to `~/.config/hypr/hyprland.conf`, replacing the path with the absolute path to this checkout:

```ini
exec-once = quickshell -p /absolute/path/to/quickshell/shell.qml
```
