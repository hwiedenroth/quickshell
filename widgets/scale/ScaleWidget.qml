pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
  id: scaleWidget

  width: Theme.widgetWidth
  height: Theme.widgetHeight
  property int selectedScaleIndex: 0
  property var scaleOptions: [
    { label: "1x", description: "100%  5120x2160", command: ["1.0"] },
    { label: "1.6x", description: "160%  3200x1350", command: ["1.6"] },
    { label: "2x", description: "200%  2560x1080", command: ["2.0"] }
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
    implicitWidth: Theme.popupWidth
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
            color: scaleHover.hovered ? Theme.surface0 : "transparent"

            function activate() {
              scaleWidget.selectedScaleIndex = scaleDelegate.index
              scaleMenu.visible = false
              Hyprland.dispatch(`hl.monitor({ output="DP-1", scale=${scaleDelegate.modelData.command[0]} })`);
            }

            HoverHandler { id: scaleHover }

            TapHandler {
              cursorShape: Qt.PointingHandCursor
              onTapped: {
                scaleDelegate.activate()
              }
            }

            Text {
              anchors.fill: parent
              anchors.leftMargin: 8
              verticalAlignment: Text.AlignVCenter
              text: scaleDelegate.modelData.description
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
              font.weight: scaleHover.hovered ? Font.Bold : Font.Normal
            }
          }
        }
      }
    }
  }
}