# Motion Backgrounds

Motion Backgrounds extends Omarchy's native wallpaper picker with video wallpapers while preserving normal image backgrounds.

## Features

- Uses the existing Omarchy full-screen wallpaper picker.
- Supports `jpg`, `jpeg`, `png`, `webp`, `gif`, `bmp`, `mp4`, `webm`, `mkv`, `mov`, and `m4v` files.
- Shows generated thumbnails for videos.
- Uses Omarchy's native reveal animation when changing images or videos.
- Applies selections immediately without restarting Hyprland or `omarchy-shell`.
- Restores the last global live wallpaper when the Omarchy shell starts.
- Includes wallpapers from the current theme, including videos in its `backgrounds/` directory.
- Makes `~/.config/motion-backgrounds/walls/` available in every theme.

## Requirements

Install `mpvpaper` before enabling video playback:

```bash
omarchy pkg aur add mpvpaper
```

The package brings the `mpv` and `ffmpeg` dependencies used for playback and thumbnails. If it is missing, Motion Backgrounds remains installed and shows an actionable notification instead of failing silently.

## Install

Install and enable the plugin with Omarchy's official plugin manager:

```bash
omarchy plugin add https://github.com/pulkitchauhan03/omarchy-motion-backgrounds.git --enable
```

On first enable, the service automatically:

1. Creates `~/.config/motion-backgrounds/walls/`.
2. Adds the bundled katana video if that filename is absent.
3. Integrates the mixed-media picker with Omarchy's Background menu action.
4. Restores a saved global live wallpaper when one exists.

The bootstrap is idempotent and runs again after plugin updates without overwriting user wallpapers.

## Use

Add global wallpapers here:

```text
~/.config/motion-backgrounds/walls/
```

Open the picker with `Super+Ctrl+Space`, or choose **Style → Background** in the Omarchy menu. Selecting a wallpaper takes effect immediately.

The bundled 1080p `samurai-katana-in-forest-cinematic-4k-live-wallpaper.mp4` is installed into the global directory by default. Videos placed in a theme's `backgrounds/` directory appear only while that theme is active. A global video remains active across theme changes; a theme-scoped video stops when you switch away from its theme.

## Commands

```bash
controller="$HOME/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds"

"$controller" pick
"$controller" apply /path/to/wallpaper.mp4
"$controller" stop
"$controller" status
"$controller" bootstrap
"$controller" cleanup
```

## Update

```bash
omarchy plugin update io.github.pulkitchauhan.motion-backgrounds
```

## Remove

Run cleanup while the controller still exists, then remove the Git-managed plugin:

```bash
"$HOME/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds" cleanup
omarchy plugin remove io.github.pulkitchauhan.motion-backgrounds
```

Cleanup removes the menu override, player service, saved live-wallpaper state, and generated thumbnails. It preserves `~/.config/motion-backgrounds/walls/` and every wallpaper in it.

## Storage

```text
~/.config/motion-backgrounds/walls/       Global wallpaper library
~/.local/state/motion-backgrounds/        Current live-wallpaper selection
~/.cache/motion-backgrounds/thumbnails/   Disposable video thumbnails
```

Video playback runs through `mpvpaper` in a transient systemd user service on the Wayland `bottom` layer. During a change, the cached video thumbnail acts as a handoff frame so Omarchy can complete its native reveal before live playback begins.

Remove any separate `mpvpaper` autostart entry before using this plugin to avoid competing wallpaper processes.
