import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Rectangle {
    id: panel

    property var currentMenu: ({})
    property string currentPath: ""
    property int columns: 3
    property int panelWidth: 600
    property int panelHeight: 400

    signal keyClicked(string key)

    width: panelWidth
    height: panelHeight
    color: Color.mSurface
    radius: Style.radiusL
    border.color: Color.mOutline
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.marginL
        spacing: Style.marginM

        // Header
        NText {
            Layout.fillWidth: true
            text: currentPath || "Which Key"
            font.pointSize: Style.fontSizeL
            font.weight: Font.Bold
            color: Color.mPrimary
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Color.mOutline
        }

        // Key grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: panel.columns
            rowSpacing: Style.marginS
            columnSpacing: Style.marginM

            Repeater {
                model: Object.keys(currentMenu)

                delegate: Rectangle {
                    property string keyChar: modelData
                    property var entry: currentMenu[keyChar] ?? {}

                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: mouseArea.containsMouse ? Color.mSurfaceContainer : "transparent"
                    radius: Style.radiusM

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Style.marginS
                        spacing: Style.marginS

                        // Key badge
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Style.radiusS
                            color: Color.mPrimaryContainer

                            NText {
                                anchors.centerIn: parent
                                text: keyChar
                                font.pointSize: Style.fontSizeM
                                font.weight: Font.Bold
                                font.family: "monospace"
                                color: Color.mOnPrimaryContainer
                            }
                        }

                        // Description
                        NText {
                            Layout.fillWidth: true
                            text: entry.desc ?? ""
                            font.pointSize: Style.fontSizeM
                            color: Color.mOnSurface
                            elide: Text.ElideRight
                        }

                        // Submenu indicator
                        NIcon {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            visible: !!entry.submenu
                            icon: "chevron-right"
                            color: Color.mOutline
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: panel.keyClicked(keyChar)
                    }
                }
            }
        }

        // Footer hint
        NText {
            Layout.fillWidth: true
            text: "Press key to select • Esc to close • Backspace to go back"
            font.pointSize: Style.fontSizeS
            color: Color.mOutline
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
