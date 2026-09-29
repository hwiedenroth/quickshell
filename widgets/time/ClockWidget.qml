import QtQuick
import "../.."

Item {
  id: clockWidget

  implicitWidth: clockText.implicitWidth + 12
  height: Theme.widgetHeight

  Rectangle {

    anchors {
      fill: parent
      centerIn: parent
    }
    radius: Theme.borderRadius
    color: Theme.surface0

    HoverHandler {
      id: hoverHandler
    }

    Text {
      id: clockText
      anchors.centerIn: parent
      text: hoverHandler.hovered ? Time.date + " " + Time.time : Time.time
      color: Theme.text
      font {
          family: Theme.fontFamily
          pixelSize: Theme.fontSize
      }
    }
  }
}