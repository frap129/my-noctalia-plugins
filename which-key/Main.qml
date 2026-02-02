import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Widgets

Item {
    id: root
    property var pluginApi: null

    // Menu state
    property var rootKeymap: keymap.root
    property var currentMenu: rootKeymap
    property var menuStack: []
    property string currentPath: ""
    property bool isOpen: false

    // Keymap definition
    property var keymap: ({
        root: {
            "w": { desc: "Windows", icon: "window-maximize", submenu: {
                "h": { desc: "focus left",  cmd: "mmsg -d focusdir,l" },
                "j": { desc: "focus down",  cmd: "mmsg -d focusdir,d" },
                "k": { desc: "focus up",    cmd: "mmsg -d focusdir,u" },
                "l": { desc: "focus right", cmd: "mmsg -d focusdir,r" },
                "q": { desc: "close",       cmd: "mmsg -d killclient" }
            }},
            "o": { desc: "Open", icon: "rocket", submenu: {
                "t": { desc: "terminal",   cmd: "foot" },
                "b": { desc: "browser",    cmd: "firefox" },
                "f": { desc: "files",      cmd: "thunar" }
            }},
            "t": { desc: "Tags", icon: "tag", submenu: {
                "1": { desc: "tag 1", cmd: "mmsg -t 1" },
                "2": { desc: "tag 2", cmd: "mmsg -t 2" },
                "n": { desc: "next",  cmd: "mmsg -d viewtoright" },
                "p": { desc: "prev",  cmd: "mmsg -d viewtoleft" }
            }}
        }
    })

    // Timer for auto-close (0 = disabled)
    Timer {
        id: timeoutTimer
        interval: pluginApi?.pluginSettings?.timeoutMs ?? 0
        running: interval > 0 && isOpen
        onTriggered: root.closePanel()
    }

    function openPanel() {
        currentMenu = rootKeymap
        menuStack = []
        currentPath = ""
        isOpen = true
        if (pluginApi) {
            pluginApi.withCurrentScreen(function(screen) {
                whichKeyWindow.screen = screen
                whichKeyWindow.visible = true
                whichKeyWindow.forceActiveFocus()
            })
        } else {
            whichKeyWindow.visible = true
            whichKeyWindow.forceActiveFocus()
        }
        timeoutTimer.restart()
    }

    function closePanel() {
        isOpen = false
        whichKeyWindow.visible = false
        currentMenu = rootKeymap
        menuStack = []
        currentPath = ""
        timeoutTimer.stop()
    }

    function handleKey(key: string) {
        if (!isOpen) return
        timeoutTimer.restart()

        if (key === "Escape" || key === "BackSpace") {
            if (menuStack.length > 0) {
                currentMenu = menuStack.pop()
                var pathParts = currentPath.split(" → ")
                pathParts.pop()
                currentPath = pathParts.join(" → ")
            } else {
                closePanel()
            }
            return
        }

        var entry = currentMenu[key]
        if (!entry) return

        if (entry.submenu) {
            menuStack.push(currentMenu)
            currentMenu = entry.submenu
            currentPath = currentPath ? currentPath + " → " + entry.desc : entry.desc
        } else if (entry.cmd) {
            execProcess.command = ["sh", "-c", entry.cmd]
            execProcess.running = true
            closePanel()
        }
    }

    Process {
        id: execProcess
        running: false
    }

    // IPC Handler
    IpcHandler {
        target: "plugin:which-key"

        function open() { root.openPanel() }
        function close() { root.closePanel() }
        function toggle() {
            if (root.isOpen) root.closePanel()
            else root.openPanel()
        }
        function pressKey(key: string) { root.handleKey(key) }
    }

    // ========== CUSTOM PANEL WINDOW ==========
    PanelWindow {
        id: whichKeyWindow
        visible: false

        // Layer-shell configuration (Wayland)
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "noctalia-which-key"

        // Window properties
        color: "transparent"
        width: panelContent.width
        height: panelContent.height

        // Default to primary screen
        screen: Quickshell.screens[0]

        // Keyboard handling
        Keys.onPressed: function(event) {
            var keyText = event.text
            if (keyText && keyText.length > 0) {
                root.handleKey(keyText)
            }
            event.accepted = true
        }

        Keys.onEscapePressed: function(event) {
            root.handleKey("Escape")
            event.accepted = true
        }

        Keys.onBackPressed: function(event) {
            root.handleKey("BackSpace")
            event.accepted = true
        }

        // Panel content
        WhichKeyPanel {
            id: panelContent
            currentMenu: root.currentMenu
            currentPath: root.currentPath
            columns: root.pluginApi?.pluginSettings?.columns ?? 3
            panelWidth: root.pluginApi?.pluginSettings?.panelWidth ?? 600
            panelHeight: root.pluginApi?.pluginSettings?.panelHeight ?? 400
            onKeyClicked: function(key) { root.handleKey(key) }
        }
    }
}
