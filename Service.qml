import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string pluginDir: home + "/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds"
  readonly property string controller: pluginDir + "/bin/motion-backgrounds"
  readonly property string themeNameFile: home + "/.local/state/omarchy/current/theme.name"
  readonly property string playbackStateFile: home + "/.local/state/motion-backgrounds/current.json"

  property string liveVideoPath: ""
  property bool playbackStateLoaded: false
  property int playingOutputs: 0
  property string lastPlaybackError: ""

  function mediaUrl(path) {
    if (!path) return ""
    return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
  }

  function loadPlaybackState(contents) {
    var next = ""

    try {
      var state = JSON.parse(String(contents || ""))
      if (state && typeof state.path === "string") next = state.path
    } catch (error) {
      next = ""
    }

    playbackStateLoaded = true
    play(next)
  }

  function play(path) {
    var next = String(path || "")
    if (next === liveVideoPath) return
    lastPlaybackError = ""
    liveVideoPath = next
  }

  function stopPlayback() {
    liveVideoPath = ""
    lastPlaybackError = ""
  }

  function refreshPlaybackState() {
    playbackState.reload()
  }

  function reconcile() {
    if (!reconcileProcess.running) reconcileProcess.running = true
  }

  function bootstrap() {
    // The first clone triggers Omarchy's plugin file watcher. Run bootstrap
    // detached so that an immediate shell/plugin reload cannot terminate it.
    Quickshell.execDetached([root.controller, "bootstrap"])
    bootstrapReconcile.restart()
  }

  function openPicker() {
    if (!pickerProcess.running) pickerProcess.running = true
  }

  Process {
    id: reconcileProcess
    command: [root.controller, "reconcile"]
  }

  Process {
    id: pickerProcess
    command: [root.controller, "pick"]
  }

  FileView {
    id: themeName
    path: root.themeNameFile
    watchChanges: true
    printErrors: false
    onLoaded: root.reconcile()
    onFileChanged: reload()
  }

  FileView {
    id: playbackState
    path: root.playbackStateFile
    watchChanges: true
    printErrors: false
    onLoaded: root.loadPlaybackState(text())
    onFileChanged: reload()
    onLoadFailed: {
      root.playbackStateLoaded = false
      root.stopPlayback()
    }
  }

  // A fresh installation may not have state until bootstrap activates the
  // bundled wallpaper. Retry only while absent because FileView cannot watch a
  // path which did not exist when the plugin loaded.
  Timer {
    interval: 1000
    repeat: true
    running: !root.playbackStateLoaded
    onTriggered: playbackState.reload()
  }

  Component.onCompleted: root.bootstrap()

  Timer {
    id: bootstrapReconcile
    interval: 1000
    repeat: false
    onTriggered: root.reconcile()
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: wallpaperWindow
      required property var modelData
      property bool reportedPlaying: false
      property bool remapping: false

      screen: modelData
      visible: root.liveVideoPath.length > 0 && !remapping
      anchors { top: true; bottom: true; left: true; right: true }
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      updatesEnabled: true

      Timer {
        id: remapSettleTimer
        interval: 200
        onTriggered: wallpaperWindow.remapping = true
      }

      Timer {
        interval: 50
        running: wallpaperWindow.remapping
        onTriggered: wallpaperWindow.remapping = false
      }

      Connections {
        target: wallpaperWindow.screen
        function onXChanged() { remapSettleTimer.restart() }
        function onYChanged() { remapSettleTimer.restart() }
      }

      WlrLayershell.namespace: "motion-backgrounds"
      // Omarchy's static wallpaper occupies Background. Bottom places the
      // video above that poster while remaining below normal windows.
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

      function updatePlayingCount() {
        var playing = wallpaperPlayer.playbackState === MediaPlayer.PlayingState
        if (playing === reportedPlaying) return
        reportedPlaying = playing
        root.playingOutputs = Math.max(0, root.playingOutputs + (playing ? 1 : -1))
      }

      MediaPlayer {
        id: wallpaperPlayer
        source: root.mediaUrl(root.liveVideoPath)
        videoOutput: wallpaperVideo
        loops: MediaPlayer.Infinite
        autoPlay: root.liveVideoPath.length > 0

        onPlaybackStateChanged: wallpaperWindow.updatePlayingCount()
        onErrorOccurred: function(error, errorString) {
          root.lastPlaybackError = String(errorString || "Video playback failed")
          console.warn("motion-backgrounds: " + root.lastPlaybackError)
        }
      }

      VideoOutput {
        id: wallpaperVideo
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        opacity: wallpaperPlayer.playbackState === MediaPlayer.PlayingState ? 1 : 0

        Behavior on opacity {
          NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
      }

      Component.onDestruction: {
        if (reportedPlaying) root.playingOutputs = Math.max(0, root.playingOutputs - 1)
      }
    }
  }

  IpcHandler {
    target: "motion-backgrounds"

    function pick(): void {
      root.openPicker()
    }

    function reconcile(): void {
      root.reconcile()
    }

    function bootstrap(): void {
      root.bootstrap()
    }

    function play(path: string): string {
      root.play(path)
      return "ok"
    }

    function stopPlayback(): string {
      root.stopPlayback()
      return "ok"
    }

    function refreshPlayback(): string {
      root.refreshPlaybackState()
      return "ok"
    }

    function status(): string {
      return JSON.stringify({
        path: root.liveVideoPath,
        requested: root.liveVideoPath.length > 0,
        screens: Quickshell.screens.length,
        playingOutputs: root.playingOutputs,
        error: root.lastPlaybackError
      })
    }
  }
}
