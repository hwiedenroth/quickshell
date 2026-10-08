pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../.."

Item {
  id: calendarPanel

  implicitWidth: 320
  implicitHeight: contentColumn.implicitHeight + 20

  property var displayedMonth: new Date(Time.currentDate.getFullYear(), Time.currentDate.getMonth(), 1)
  property bool selectingMonth: false
  property int selectionYear: displayedMonth.getFullYear()
  readonly property int weekStart: Time.locale.firstDayOfWeek % 7
  readonly property var monthStart: new Date(displayedMonth.getFullYear(), displayedMonth.getMonth(), 1)
  readonly property var gridStart: new Date(
    monthStart.getFullYear(),
    monthStart.getMonth(),
    1 - ((monthStart.getDay() - weekStart + 7) % 7)
  )

  function showCurrentMonth() {
    displayedMonth = new Date(Time.currentDate.getFullYear(), Time.currentDate.getMonth(), 1)
    selectingMonth = false
  }

  function changeMonth(amount) {
    displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + amount, 1)
  }

  function changeHeaderPeriod(amount) {
    if (selectingMonth)
      selectionYear += amount
    else
      changeMonth(amount)
  }

  function openMonthSelection() {
    selectionYear = displayedMonth.getFullYear()
    selectingMonth = true
  }

  function selectMonth(month) {
    displayedMonth = new Date(selectionYear, month, 1)
    selectingMonth = false
  }

  function selectCurrentMonth() {
    showCurrentMonth()
    selectingMonth = false
  }

  function monthName(month) {
    return Time.locale.toString(new Date(selectionYear, month, 1), "MMM")
  }

  function weekdayName(offset) {
    const day = (weekStart + offset) % 7
    return Time.locale.toString(new Date(2023, 0, day + 1), "ddd")
  }

  function isoWeekNumber(date) {
    const thursday = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
    const weekday = thursday.getUTCDay() || 7
    thursday.setUTCDate(thursday.getUTCDate() + 4 - weekday)
    const yearStart = Date.UTC(thursday.getUTCFullYear(), 0, 1)
    return Math.ceil(((thursday.getTime() - yearStart) / 86400000 + 1) / 7)
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.borderRadius
    color: Theme.base
    border.color: Theme.surface1
  }

  ColumnLayout {
    id: contentColumn

    anchors.fill: parent
    anchors.margins: 10
    spacing: 4

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 34
      spacing: 4

      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 30
        radius: 3
        color: previousMonthHover.hovered ? Theme.surface0 : "transparent"

        HoverHandler { id: previousMonthHover }
        TapHandler { onTapped: calendarPanel.changeHeaderPeriod(-1) }

        Text {
          anchors.centerIn: parent
          text: "‹"
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: 22
        }
      }

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        TapHandler {
          cursorShape: Qt.PointingHandCursor
          onTapped: calendarPanel.openMonthSelection()
        }

        Text {
          anchors.centerIn: parent
          text: calendarPanel.selectingMonth
            ? calendarPanel.selectionYear.toString()
            : Time.locale.toString(calendarPanel.displayedMonth, "MMMM yyyy")
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          font.weight: Font.Bold
        }
      }

      Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 30
        radius: 3
        color: nextMonthHover.hovered ? Theme.surface0 : "transparent"

        HoverHandler { id: nextMonthHover }
        TapHandler { onTapped: calendarPanel.changeHeaderPeriod(1) }

        Text {
          anchors.centerIn: parent
          text: "›"
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: 22
        }
      }
    }

    RowLayout {
      visible: !calendarPanel.selectingMonth
      Layout.fillWidth: true
      Layout.preferredHeight: 26
      spacing: 0

      Text {
        Layout.preferredWidth: 34
        horizontalAlignment: Text.AlignHCenter
        text: "KW"
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
      }

      Repeater {
        model: 7

        Text {
          required property int index
          Layout.preferredWidth: 38
          horizontalAlignment: Text.AlignHCenter
          text: calendarPanel.weekdayName(index)
          color: Theme.subtext0
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
        }
      }
    }

    Repeater {
      visible: !calendarPanel.selectingMonth
      model: 6

      RowLayout {
        id: weekRow
        required property int index
        visible: !calendarPanel.selectingMonth
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        spacing: 0

        readonly property var rowStart: new Date(
          calendarPanel.gridStart.getFullYear(),
          calendarPanel.gridStart.getMonth(),
          calendarPanel.gridStart.getDate() + index * 7
        )
        readonly property var weekDate: new Date(
          rowStart.getFullYear(),
          rowStart.getMonth(),
          rowStart.getDate() + ((4 - rowStart.getDay() + 7) % 7)
        )

        Text {
          Layout.preferredWidth: 34
          horizontalAlignment: Text.AlignHCenter
          text: calendarPanel.isoWeekNumber(weekRow.weekDate).toString()
          color: Theme.overlay1
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 2
        }

        Repeater {
          model: 7

          Rectangle {
            required property int index
            Layout.preferredWidth: 38
            Layout.preferredHeight: 28
            radius: 3

            readonly property var cellDate: new Date(
              weekRow.rowStart.getFullYear(),
              weekRow.rowStart.getMonth(),
              weekRow.rowStart.getDate() + index
            )
            readonly property bool inDisplayedMonth: cellDate.getMonth() === calendarPanel.displayedMonth.getMonth()
              && cellDate.getFullYear() === calendarPanel.displayedMonth.getFullYear()
            readonly property bool isToday: cellDate.getFullYear() === Time.currentDate.getFullYear()
              && cellDate.getMonth() === Time.currentDate.getMonth()
              && cellDate.getDate() === Time.currentDate.getDate()

            color: isToday ? Theme.surface1 : "transparent"

            Text {
              anchors.centerIn: parent
              text: parent.cellDate.getDate().toString()
              color: parent.inDisplayedMonth ? Theme.text : Theme.overlay0
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
            }
          }
        }
      }
    }

    GridLayout {
      visible: calendarPanel.selectingMonth
      Layout.fillWidth: true
      columns: 3
      rowSpacing: 4
      columnSpacing: 4

      Repeater {
        model: 12

        Rectangle {
          id: monthCell
          required property int index
          Layout.fillWidth: true
          Layout.preferredHeight: 34
          radius: 3

          color: monthHover.hovered ? Theme.surface1 : "transparent"

          HoverHandler { id: monthHover }
          TapHandler {
            cursorShape: Qt.PointingHandCursor
            onTapped: calendarPanel.selectMonth(monthCell.index)
          }

          Text {
            anchors.centerIn: parent
            text: calendarPanel.monthName(monthCell.index)
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
          }
        }
      }
    }

    Rectangle {
      visible: calendarPanel.selectingMonth
      Layout.fillWidth: true
      Layout.preferredHeight: 30
      radius: 3
      color: currentMonthHover.hovered ? Theme.surface0 : "transparent"

      HoverHandler { id: currentMonthHover }
      TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: calendarPanel.selectCurrentMonth()
      }

      Text {
        anchors.centerIn: parent
        text: "Aktueller Monat"
        color: Theme.blue
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }
    }
  }
}