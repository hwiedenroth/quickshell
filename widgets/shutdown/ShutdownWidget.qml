import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
  id: root

  implicitWidth: powerButton.implicitWidth
  implicitHeight: powerButton.implicitHeight
  focus: true

  Keys.onPressed: event => {
    if (!powerMenu.visible)
      return

    if (event.key === Qt.Key_Escape) {
      powerMenu.visible = false
      event.accepted = true
    } else if (event.key === Qt.Key_Up) {
      powerMenu.selectedIndex = Math.max(0, powerMenu.selectedIndex - 1)
      event.accepted = true
    } else if (event.key === Qt.Key_Down) {
      powerMenu.selectedIndex = Math.min(actions.count - 1, powerMenu.selectedIndex + 1)
      event.accepted = true
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      actions.itemAt(powerMenu.selectedIndex).activate()
      event.accepted = true
    }
  }

  Rectangle {
    id: powerButton

    implicitWidth: Theme.powerButtonWidth
    implicitHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: buttonMouseArea.containsMouse ? Theme.surface1 : Theme.surface0

    Text {
      anchors.centerIn: parent
      text: "⏻"
      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize + 2
    }

    MouseArea {
      id: buttonMouseArea

      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        powerMenu.visible = !powerMenu.visible
        if (powerMenu.visible)
          root.forceActiveFocus()
      }
    }
  }

  PopupWindow {
    id: powerMenu

    anchor.window: root.QsWindow.window
    anchor.rect.x: root.mapToItem(null, root.width - width, 0).x
    anchor.rect.y: root.mapToItem(null, 0, root.height).y + 4
    implicitWidth: Theme.popupWidth
    implicitHeight: actionColumn.implicitHeight + Theme.popupMargin * 2
    grabFocus: true
    color: "transparent"
    visible: false
    property int selectedIndex: 0


    Rectangle {
      anchors.fill: parent
      radius: Theme.borderRadius
      color: Theme.base
      border.color: Theme.surface1

      ColumnLayout {
        id: actionColumn

        anchors.fill: parent
        anchors.margins: Theme.popupMargin
        spacing: Theme.popupSpacing

        Repeater {
          id: actions

          model: [
            { label: "Lock", command: ["hyprlock"] },
            { label: "Logout", command: ["hyprctl", "dispatch", "exit"] },
            { label: "Reboot", command: ["systemctl", "reboot"] },
            { label: "Shutdown", command: ["systemctl", "poweroff"] }
          ]

          delegate: Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: Theme.popupItemHeight
            radius: 3
            color: actionMouseArea.containsMouse ? Theme.surface0 : "transparent"

            function activate() {
              powerMenu.visible = false
              actionProcess.running = true
            }

            Text {
              anchors.fill: parent
              anchors.leftMargin: 8
              verticalAlignment: Text.AlignVCenter
              text: modelData.label
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
            }

            Process {
              id: actionProcess
              command: modelData.command
            }

            MouseArea {
              id: actionMouseArea

              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: activate()
            }
          }
        }
      }
    }
  }
}