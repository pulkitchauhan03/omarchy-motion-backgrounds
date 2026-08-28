# Motion Backgrounds

Motion Backgrounds adds video wallpapers to Omarchy's native full-screen wallpaper picker while preserving its normal image workflow, theme behavior, and reveal animation.

## Features

- Mixed image and video selection through Omarchy's existing wallpaper UI.
- Immediate wallpaper changes without restarting Hyprland or `omarchy-shell`.
- Native Omarchy reveal animation for image-to-image, image-to-video, and video-to-video changes.
- Silent, looping video playback with automatic hardware acceleration when
  supported, using Omarchy's signed Arch packages: Quickshell, Qt Multimedia,
  and FFmpeg.
- Generated and cached video thumbnails with a built-in fallback preview.
- A global wallpaper library available under every theme.
- Videos inside a theme's `backgrounds/` directory.
- Automatic restoration of saved global videos after shell startup.
- Optional live lock-screen integration with Botanical Lock.

Supported images: `jpg`, `jpeg`, `png`, `webp`, `gif`, and `bmp`.

Supported videos: `mp4`, `webm`, `mkv`, `mov`, and `m4v`.

## Requirements

Motion Backgrounds uses only packages from Arch's signed repositories. On a
standard Omarchy installation they are already present. If needed, install:

```bash
omarchy pkg add qt6-multimedia-ffmpeg ffmpeg
```

`qt6-multimedia-ffmpeg` installs Arch's Qt Multimedia module and its FFmpeg
playback backend. `ffmpeg` generates picker thumbnails. If either is
unavailable, static images continue to work and selecting a video displays an
actionable notification.

## Install

Use Omarchy's official plugin manager:

```bash
omarchy plugin add https://github.com/pulkitchauhan03/omarchy-motion-backgrounds.git --enable
```

On first enable, the plugin automatically:

1. Creates `~/.config/motion-backgrounds/walls/`.
2. Installs the bundled wallpaper library: 1080p `Katana.mp4` plus 25 original qylock MP4 backgrounds.
3. Activates Katana as the initial live wallpaper and writes
   `~/.local/state/motion-backgrounds/current.json`.
4. Connects Omarchy's Background menu action to the mixed-media picker.
5. Restores a saved global video selection when one exists.

Bootstrap is idempotent. Automatic Katana activation is limited to a genuinely
fresh installation, so plugin updates and later static-wallpaper selections are
not overridden. If Qt Multimedia is initially unavailable, activation remains
pending and completes on a later bootstrap after the dependency is installed.
Older installations using the previous bundled filename are migrated to
`Katana.mp4` without creating a duplicate. The expanded bundled collection is
copied once per installation; after that, wallpapers you remove stay removed.

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
motion-backgrounds list
motion-backgrounds remove my-wallpaper.mp4
```

`list` prints only the exact filenames accepted by `remove`, making the output
easy to copy, paste, or pass to another shell command.

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

For video selections, the plugin first passes a cached poster frame to Omarchy's
wallpaper command. Omarchy performs its native reveal, then a Quickshell
`PanelWindow` renders the video on Wayland's bottom layer using Qt Multimedia.
The poster also prevents an unrelated older wallpaper from flashing during
video-to-video changes.

Qt's FFmpeg backend automatically selects an available hardware decoder. The
wallpaper surface is part of `omarchy-shell`, is silent, loops indefinitely, and
is recreated per connected output.

## Botanical Lock integration

[Botanical Lock](https://github.com/pulkitchauhan03/omarchy-botanical-lock) can read the saved Motion Backgrounds state and play the active video directly inside its secure lock surface. Static lock-screen backgrounds require no integration setup.

## Commands

```bash
motion-backgrounds add /path/to/new-wallpaper.mp4
motion-backgrounds list
motion-backgrounds remove new-wallpaper.mp4
motion-backgrounds pick
motion-backgrounds apply /path/to/wallpaper.mp4
motion-backgrounds apply Katana.mp4
motion-backgrounds status
motion-backgrounds stop
motion-backgrounds reconcile
motion-backgrounds bootstrap
motion-backgrounds cleanup
```

`apply` accepts either a full path or the filename of a wallpaper in the global
library. For example, both forms below are valid:

```bash
motion-backgrounds apply "$HOME/.config/motion-backgrounds/walls/Katana.mp4"
motion-backgrounds apply Katana.mp4
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

- Remove separate wallpaper-player autostart commands before enabling this
  plugin; competing layer-shell surfaces can cover one another.
- Confirm the plugin is enabled with `omarchy plugin list`.
- Check live playback with `omarchy-shell motion-backgrounds status`.
- Run the controller's `status` command to print the saved active-video path.
