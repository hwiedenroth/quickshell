import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    implicitWidth: panel.implicitWidth + 4
    implicitHeight: panel.implicitHeight + 4

    Rectangle {
        id: panel
        anchors.fill: parent
        anchors.margins: 2
        implicitWidth: workspaces.implicitWidth
        implicitHeight: workspaces.implicitHeight
        radius: Theme.borderRadius
        color: Theme.surface0

        RowLayout {
            id: workspaces
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: Hyprland.workspaces.values

                delegate: Rectangle {
                    required property var modelData

                    property var workspace: modelData
                    property bool isActive: Hyprland.focusedWorkspace?.id === workspace.id

                    implicitWidth: label.implicitWidth + 10
                    implicitHeight: 26
                    color: "transparent"

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: workspace.name || workspace.id
                        color: Theme.text
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.fontSize
                            weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 3
                        color: mouseArea.containsMouse ? Theme.yellow
                            : isActive ? Theme.lavender : "transparent"
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: workspace.activate()
                    }
                }
            }
        }
    }
}