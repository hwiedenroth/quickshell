pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
  id: scaleWidget

  width: 44
  implicitWidth: width
  height: Theme.widgetHeight
  property int selectedScaleIndex: 1
  property var scaleOptions: [
    { label: "1x", description: "100%  5120x2160", scale: 1.0 },
    { label: "1.25x", description: "125%  4096x1728 (default)", scale: 1.25 },
    { label: "1.6x", description: "160%  3200x1350", scale: 1.6 },
    { label: "2x", description: "200%  2560x1080", scale: 2.0 }
  ]

  Rectangle {
    id: scaleButton

    anchors {
      fill: parent
      centerIn: parent
    }
    radius: Theme.borderRadius
    color: scaleWidgetHover.hovered ? Theme.surface1 : Theme.surface0

    HoverHandler { id: scaleWidgetHover }

    TapHandler {
      cursorShape: Qt.PointingHandCursor
      onTapped: {
        scaleMenu.visible = !scaleMenu.visible
        if (scaleMenu.visible)
          scaleWidget.forceActiveFocus()
      }
    }

    Text {
      anchors.centerIn: parent
      text: scaleWidget.scaleOptions[scaleWidget.selectedScaleIndex].label
      color: scaleMenu.visible ? Theme.blue : Theme.text
      font {
          family: Theme.fontFamily
          pixelSize: Theme.fontSize
      }
    }
  }

  PopupWindow {
    id: scaleMenu

    anchor.window: scaleWidget.QsWindow.window
    anchor.rect.x: scaleWidget.mapToItem(null, scaleWidget.width - width, 0).x
    anchor.rect.y: scaleWidget.mapToItem(null, 0, scaleWidget.height).y + 4
    implicitWidth: 220
    implicitHeight: actionColumn.implicitHeight + Theme.popupMargin * 2
    grabFocus: true
    color: "transparent"
    visible: false


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

          model: scaleWidget.scaleOptions

          delegate: Rectangle {
            id: scaleDelegate
            required property var modelData
            required property int index

            Layout.fillWidth: true
            Layout.preferredHeight: Theme.popupItemHeight
            radius: 3
            color: scaleHover.hovered || scaleDelegate.index === scaleWidget.selectedScaleIndex ? Theme.surface0 : "transparent"

            function activate() {
              scaleWidget.selectedScaleIndex = scaleDelegate.index
              scaleMenu.visible = false
              scaleProcess.running = true
            }

            HoverHandler { id: scaleHover }

            TapHandler {
              cursorShape: Qt.PointingHandCursor
              onTapped: {
                scaleDelegate.activate()
              }
            }

            Process {
              id: scaleProcess
              command: ["hyprctl", "eval", `hl.monitor({ output = "DP-1", mode = "5120x2160@120", position = "auto", scale = ${scaleDelegate.modelData.scale} })`]
            }

            Text {
              anchors.fill: parent
              anchors.leftMargin: 8
              verticalAlignment: Text.AlignVCenter
              text: scaleDelegate.modelData.description
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
              font.weight: scaleHover.hovered || scaleDelegate.index === scaleWidget.selectedScaleIndex ? Font.Bold : Font.Normal
            }
          }
        }
      }
    }
  }
}