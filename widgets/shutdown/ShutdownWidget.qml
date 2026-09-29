import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
  id: shutdownWidget

  width: Theme.widgetWidth
  height: Theme.widgetHeight

  Rectangle {
    id: powerButton

    anchors {
      fill: parent
      centerIn: parent
    }
    radius: Theme.borderRadius
    color: hover.hovered ? Theme.surface1 : Theme.surface0

    HoverHandler { id: hover }

    TapHandler {
      cursorShape: Qt.PointingHandCursor
      onTapped: {
        powerMenu.visible = !powerMenu.visible
        if (powerMenu.visible)
          shutdownWidget.forceActiveFocus()
      }
    }

    Text {
      anchors.centerIn: parent
      text: "⏻"
      color: powerMenu.visible ? Theme.blue : Theme.text
      font {
          family: Theme.fontFamily
          pixelSize: Theme.fontSize
      }
    }
  }

  PopupWindow {
    id: powerMenu

    anchor.window: shutdownWidget.QsWindow.window
    anchor.rect.x: shutdownWidget.mapToItem(null, shutdownWidget.width - width, 0).x
    anchor.rect.y: shutdownWidget.mapToItem(null, 0, shutdownWidget.height).y + 4
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
            color: hover.hovered ? Theme.surface0 : "transparent"

            function activate() {
              powerMenu.visible = false
              actionProcess.running = true
            }

            HoverHandler { id: hover }

            TapHandler {
              cursorShape: Qt.PointingHandCursor
              onTapped: {
                activate()
              }
            }

            Text {
              anchors.fill: parent
              anchors.leftMargin: 8
              verticalAlignment: Text.AlignVCenter
              text: modelData.label
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
              font.weight: hover.hovered ? Font.Bold : Font.Normal
            }

            Process {
              id: actionProcess
              command: modelData.command
            }
          }
        }
      }
    }
  }
}