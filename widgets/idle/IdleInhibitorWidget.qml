import Quickshell
import Quickshell.Wayland
import QtQuick
import "../.."

Item {
  id: idleInhibitorWidget

  width: Theme.widgetWidth
  height: Theme.widgetHeight

  IdleInhibitor {
    window: idleInhibitorWidget.QsWindow.window
    enabled: inhibitorButton.inhibited
  }

  Rectangle {
    id: inhibitorButton

    property bool inhibited: false

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
        inhibitorButton.inhibited = !inhibitorButton.inhibited
      }
    }

    Text {
      anchors.centerIn: parent
      text: inhibitorButton.inhibited ? "" : ""
      color: inhibitorButton.inhibited ? Theme.blue : Theme.text
      font {
          family: Theme.fontFamily
          pixelSize: Theme.fontSize
      }
    }
  }
}