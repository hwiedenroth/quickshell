import QtQuick
import Quickshell
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

    TapHandler {
      cursorShape: Qt.PointingHandCursor
      onTapped: {
        calendarPopup.visible = !calendarPopup.visible
        if (calendarPopup.visible)
          calendarPanel.showCurrentMonth()
      }
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

  PopupWindow {
    id: calendarPopup

    anchor.window: clockWidget.QsWindow.window
    anchor.rect.x: clockWidget.mapToItem(null, (clockWidget.width - width) / 2, 0).x
    anchor.rect.y: clockWidget.mapToItem(null, 0, clockWidget.height).y + 4
    implicitWidth: calendarPanel.implicitWidth
    implicitHeight: calendarPanel.implicitHeight
    grabFocus: true
    color: "transparent"
    visible: false

    CalendarPanel {
      id: calendarPanel
      anchors.fill: parent
    }
  }
}