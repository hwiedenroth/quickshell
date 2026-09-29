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

To start it automatically with Hyprland, add this to `~/.config/hypr/hyprland.lua`, replacing the path with the absolute path to this checkout:

```lua
hl.on("hyprland.start", function () 
    hl.exec_cmd("quickshell --path $PWD/shell.qml")
end)
```

To start it as systemd service, add tge file `~/.config/systemd/user/quickshell.service`, add the content:

```
[Unit]
Description=Quickshell Desktop Shell
Documentation=https://quickshell.org/
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/quickshell --path $PWD/shell.qml
ExecReload=kill -SIGUSR2 $MAINPID
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```

Execute:

```shell
systemctl --user start quickshell.service
systemctl --user enable quickshell.service
```

