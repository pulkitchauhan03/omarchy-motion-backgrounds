# Motion Backgrounds

Motion Backgrounds adds video wallpapers to Omarchy's native full-screen wallpaper picker while preserving its normal image workflow, theme behavior, and reveal animation.

## Features

- Mixed image and video selection through Omarchy's existing wallpaper UI.
- Immediate wallpaper changes without restarting Hyprland or `omarchy-shell`.
- Native Omarchy reveal animation for image-to-image, image-to-video, and video-to-video changes.
- Hardware-accelerated, silent, looping video playback through `mpvpaper`.
- Generated and cached video thumbnails with a built-in fallback preview.
- A global wallpaper library available under every theme.
- Videos inside a theme's `backgrounds/` directory.
- Automatic restoration of saved global videos after shell startup.
- Optional live lock-screen integration with Botanical Lock.

Supported images: `jpg`, `jpeg`, `png`, `webp`, `gif`, and `bmp`.

Supported videos: `mp4`, `webm`, `mkv`, `mov`, and `m4v`.

## Requirements

Install `mpvpaper` before using video backgrounds:

```bash
omarchy pkg aur add mpvpaper
```

This also provides the playback and thumbnail dependencies used by the plugin. Without `mpvpaper`, the plugin remains installed and static images continue to work, but selecting a video displays an actionable notification.

## Install

Use Omarchy's official plugin manager:

```bash
omarchy plugin add https://github.com/pulkitchauhan03/omarchy-motion-backgrounds.git --enable
```

On first enable, the plugin automatically:

1. Creates `~/.config/motion-backgrounds/walls/`.
2. Installs the bundled 1080p `Katana.mp4` when it is absent.
3. Connects Omarchy's Background menu action to the mixed-media picker.
4. Restores a saved global video selection when one exists.

Bootstrap is idempotent. Plugin updates do not overwrite wallpapers already in the global library. Older installations using the previous bundled filename are migrated to `Katana.mp4` without creating a duplicate.

## Use

Place wallpapers that should be available under every theme in:

```text
~/.config/motion-backgrounds/walls/
```

Open the picker with `Super+Ctrl+Space`, or choose **Style → Background** from the Omarchy menu. The directories are scanned each time the picker opens, so newly added files appear without a reload or restart.

### Wallpaper scope

- Files in `~/.config/motion-backgrounds/walls/` are global and remain active across theme changes.
- Files in the active theme's `backgrounds/` directory are theme-scoped.
- A theme-scoped video stops when you switch away from the theme that owns it.
- Static images continue through Omarchy's normal wallpaper command.

### Video transitions

For video selections, the plugin first passes a cached poster frame to Omarchy's wallpaper command. Omarchy performs its native reveal, then `mpvpaper` starts the video on Wayland's bottom layer. The poster also prevents an unrelated older wallpaper from flashing during video-to-video changes.

Playback runs as a transient systemd user service:

```text
motion-backgrounds-wallpaper.service
```

## Botanical Lock integration

[Botanical Lock](https://github.com/pulkitchauhan03/omarchy-botanical-lock) can read the saved Motion Backgrounds state and play the active video directly inside its secure lock surface. Static lock-screen backgrounds require no integration setup.

## Commands

```bash
controller="$HOME/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds"

"$controller" pick
"$controller" apply /path/to/wallpaper.mp4
"$controller" status
"$controller" stop
"$controller" reconcile
"$controller" bootstrap
"$controller" cleanup
```

## Storage

```text
~/.config/motion-backgrounds/walls/       Global wallpaper library
~/.local/state/motion-backgrounds/        Saved live-wallpaper selection
~/.cache/motion-backgrounds/thumbnails/   Disposable video previews
```

## Update

```bash
omarchy plugin update io.github.pulkitchauhan.motion-backgrounds
```

## Remove

Run cleanup while the controller is still installed, then use Omarchy's plugin manager:

```bash
"$HOME/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds/bin/motion-backgrounds" cleanup
omarchy plugin remove io.github.pulkitchauhan.motion-backgrounds
```

Cleanup stops playback and removes the menu override, saved state, and thumbnail cache. It deliberately preserves `~/.config/motion-backgrounds/walls/` and every wallpaper stored there.

## Troubleshooting

- Remove separate `mpvpaper` autostart commands before enabling this plugin; competing processes can cover one another.
- Confirm the plugin is enabled with `omarchy plugin list`.
- Check live playback with `systemctl --user status motion-backgrounds-wallpaper.service`.
- Run the controller's `status` command to print the saved active-video path.
