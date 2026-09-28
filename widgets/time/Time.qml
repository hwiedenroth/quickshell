pragma Singleton

import Quickshell
import QtQuick
import "../.."

Singleton {
  readonly property string localeName: Theme.localeName
  readonly property var locale: Qt.locale(localeName)
  readonly property string time: locale.toString(clock.date, "HH:mm")
  readonly property string date: locale.toString(clock.date, "ddd, d. MMM")

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}