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

  function bootstrap() {
    if (!bootstrapProcess.running) bootstrapProcess.running = true
  }

  function openPicker() {
    if (!pickerProcess.running) pickerProcess.running = true
  }

  Process {
    id: bootstrapProcess
    command: [root.controller, "bootstrap"]
    onExited: root.reconcile()
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

  Component.onCompleted: root.bootstrap()

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
