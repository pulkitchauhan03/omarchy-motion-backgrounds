import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  readonly property string home: Quickshell.env("HOME")
  readonly property string pluginDir: home + "/.config/omarchy/plugins/io.github.pulkitchauhan.motion-backgrounds"
  readonly property string controller: pluginDir + "/bin/motion-backgrounds"
  readonly property string themeNameFile: home + "/.local/state/omarchy/current/theme.name"

  function reconcile() {
    if (!reconcileProcess.running) reconcileProcess.running = true
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

  // The timer covers a first run where theme.name does not exist yet.
  Timer {
    interval: 500
    running: true
    repeat: false
    onTriggered: root.reconcile()
  }

  IpcHandler {
    target: "motion-backgrounds"

    function pick(): void {
      root.openPicker()
    }

    function reconcile(): void {
      root.reconcile()
    }
  }
}
