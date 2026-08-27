# Motion Backgrounds

Motion Backgrounds extends Omarchy's native wallpaper picker with video wallpapers while preserving normal image backgrounds.

## Features

- Uses the existing Omarchy full-screen wallpaper picker.
- Supports `jpg`, `jpeg`, `png`, `webp`, `gif`, `bmp`, `mp4`, `webm`, `mkv`, `mov`, and `m4v` files.
- Shows generated thumbnails for videos.
- Applies image and video selections immediately without restarting Hyprland or `omarchy-shell`.
- Restores the last global live wallpaper when the Omarchy shell starts.
- Includes wallpapers from the current theme, including video files placed in its `backgrounds/` directory.
- Makes `~/.config/motion-backgrounds/walls/` available in every theme.

## Install

From a checkout of this repository:

```bash
./plugins/motion-backgrounds/install.sh
```

The installer:

1. Installs `ffmpeg` and `mpvpaper` if they are missing.
2. Copies the complete plugin to `~/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/`.
3. Creates `~/.config/motion-backgrounds/walls/`.
4. Overrides the user-level `style.background` menu action to use the mixed-media picker.
5. Validates, discovers, and enables the plugin without restarting the shell.

If `omarchy-shell` is not running during installation, enable the plugin after logging into Omarchy:

```bash
omarchy plugin enable io.github.pulkitchauhan.motion-backgrounds
```

## Use

Add global wallpapers here:

```text
~/.config/motion-backgrounds/walls/
```

Open the picker with `Super+Ctrl+Space`, or choose **Style → Background** in the Omarchy menu. Selecting a different wallpaper takes effect immediately.

You can also put a supported video in a theme's `backgrounds/` directory. It appears only while that theme is active. A video from the global walls directory remains active across theme changes; a theme-scoped video stops when you switch away from its theme.

## Commands

The controller is installed with the plugin:

```bash
~/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds pick
~/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds apply /path/to/wallpaper.mp4
~/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds stop
~/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds status
```

## Storage

```text
~/.config/motion-backgrounds/walls/       Global wallpaper library
~/.local/state/motion-backgrounds/        Current live-wallpaper selection
~/.cache/motion-backgrounds/thumbnails/   Disposable video thumbnails
```

The plugin runs video wallpapers through `mpvpaper` on the Wayland `bottom` layer, above Omarchy's static background and below application windows.

## Existing mpvpaper autostart entries

Motion Backgrounds restores live wallpapers itself. Remove any old `mpvpaper` line from `~/.config/hypr/autostart.lua` to avoid starting two competing wallpaper processes. The installer detects this and prints a warning but does not edit your Hyprland configuration.
