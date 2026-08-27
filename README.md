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
3. Activates Katana as the initial live wallpaper and writes
   `~/.local/state/motion-backgrounds/current.json`.
4. Connects Omarchy's Background menu action to the mixed-media picker.
5. Restores a saved global video selection when one exists.

Bootstrap is idempotent. Automatic Katana activation is limited to a genuinely
fresh installation, so plugin updates and later static-wallpaper selections are
not overridden. If `mpvpaper` is initially unavailable, activation remains
pending and completes on a later bootstrap after the dependency is installed.
Older installations using the previous bundled filename are migrated to
`Katana.mp4` without creating a duplicate.

## Use

Place wallpapers that should be available under every theme in:

```text
~/.config/motion-backgrounds/walls/
```

Open the picker with `Super+Ctrl+Space`, or choose **Style → Background** from the Omarchy menu. The directories are scanned each time the picker opens, so newly added files appear without a reload or restart.

To copy a new image or video into the global library and activate it
immediately, run:

```bash
motion-backgrounds add ~/Downloads/my-wallpaper.mp4
```

Remove a wallpaper from the global library by file name or library path:

```bash
motion-backgrounds remove my-wallpaper.mp4
```

Removal moves the file to the desktop trash, so it remains recoverable. The
command refuses paths outside the global library and asks you to select another
wallpaper before removing an active static image. Removing an active video
stops playback safely and clears its saved lock-screen state.

Bootstrap installs the short `motion-backgrounds` command in `~/.local/bin`.
If another file already owns that command name, the plugin leaves it untouched
and reports the conflict.

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
motion-backgrounds add /path/to/new-wallpaper.mp4
motion-backgrounds remove new-wallpaper.mp4
motion-backgrounds pick
motion-backgrounds apply /path/to/wallpaper.mp4
motion-backgrounds status
motion-backgrounds stop
motion-backgrounds reconcile
motion-backgrounds bootstrap
motion-backgrounds cleanup
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
motion-backgrounds cleanup
omarchy plugin remove io.github.pulkitchauhan.motion-backgrounds
```

Cleanup stops playback and removes the menu override, saved state, and thumbnail cache. It deliberately preserves `~/.config/motion-backgrounds/walls/` and every wallpaper stored there.

## Troubleshooting

- Remove separate `mpvpaper` autostart commands before enabling this plugin; competing processes can cover one another.
- Confirm the plugin is enabled with `omarchy plugin list`.
- Check live playback with `systemctl --user status motion-backgrounds-wallpaper.service`.
- Run the controller's `status` command to print the saved active-video path.
