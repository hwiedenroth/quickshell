import QtQuick

import "../.."

Rectangle {
  implicitWidth: clockText.implicitWidth + 16
  implicitHeight: clockText.implicitHeight + 8
  color: Theme.surface0
  radius: Theme.borderRadius

  HoverHandler {
    id: hoverHandler
  }

  Text {
    id: clockText
    anchors.centerIn: parent
    color: Theme.text
    text: hoverHandler.hovered ? Time.date + " " + Time.time : Time.time
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.bold: true
  }
}