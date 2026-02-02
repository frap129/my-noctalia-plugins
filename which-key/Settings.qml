import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    property var pluginApi: null

    spacing: Style.marginM

    NText {
        text: "Which Key Settings"
        font.pointSize: Style.fontSizeL
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    // Timeout
    RowLayout {
        Layout.fillWidth: true
        NText { text: "Auto-close timeout (ms, 0=disabled)"; color: Color.mOnSurface }
        NTextInput {
            Layout.preferredWidth: 80
            text: pluginApi?.pluginSettings?.timeoutMs ?? "0"
            onTextChanged: {
                pluginApi.pluginSettings.timeoutMs = parseInt(text) || 0
                pluginApi.saveSettings()
            }
        }
    }

    // Columns
    RowLayout {
        Layout.fillWidth: true
        NText { text: "Columns"; color: Color.mOnSurface }
        NTextInput {
            Layout.preferredWidth: 60
            text: pluginApi?.pluginSettings?.columns ?? "3"
            onTextChanged: {
                pluginApi.pluginSettings.columns = parseInt(text) || 3
                pluginApi.saveSettings()
            }
        }
    }

    // Panel width
    RowLayout {
        Layout.fillWidth: true
        NText { text: "Panel width"; color: Color.mOnSurface }
        NTextInput {
            Layout.preferredWidth: 80
            text: pluginApi?.pluginSettings?.panelWidth ?? "600"
            onTextChanged: {
                pluginApi.pluginSettings.panelWidth = parseInt(text) || 600
                pluginApi.saveSettings()
            }
        }
    }

    // Panel height
    RowLayout {
        Layout.fillWidth: true
        NText { text: "Panel height"; color: Color.mOnSurface }
        NTextInput {
            Layout.preferredWidth: 80
            text: pluginApi?.pluginSettings?.panelHeight ?? "400"
            onTextChanged: {
                pluginApi.pluginSettings.panelHeight = parseInt(text) || 400
                pluginApi.saveSettings()
            }
        }
    }

    // Reset to defaults
    NButton {
        text: "Reset to Defaults"
        onClicked: {
            var defaults = pluginApi.manifest.metadata.defaultSettings
            pluginApi.pluginSettings.timeoutMs = defaults.timeoutMs
            pluginApi.pluginSettings.columns = defaults.columns
            pluginApi.pluginSettings.panelWidth = defaults.panelWidth
            pluginApi.pluginSettings.panelHeight = defaults.panelHeight
            pluginApi.saveSettings()
        }
    }
}
