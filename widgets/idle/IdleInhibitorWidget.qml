import Quickshell
import Quickshell.Wayland
import QtQuick
import "../.."

Item {
  id: root

  implicitWidth: inhibitorButton.implicitWidth
  implicitHeight: inhibitorButton.implicitHeight

  IdleInhibitor {
    window: root.QsWindow.window
    enabled: inhibitorButton.inhibited
  }

  Rectangle {
    id: inhibitorButton

    property bool inhibited: false

    implicitWidth: Theme.powerButtonWidth
    implicitHeight: Theme.widgetHeight
    anchors.centerIn: parent
    radius: Theme.borderRadius
    color: buttonMouseArea.containsMouse ? Theme.surface1 : Theme.surface0

    Text {
      anchors.centerIn: parent
      text: inhibitorButton.inhibited ? "" : ""
      color: inhibitorButton.inhibited ? Theme.blue : Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize + 2
    }

    MouseArea {
      id: buttonMouseArea

      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: inhibitorButton.inhibited = !inhibitorButton.inhibited
    }
  }
}