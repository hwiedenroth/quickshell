import Quickshell.Services.Notifications
import QtQuick
import "../.."

QtObject {
  readonly property string emptyIcon: "󰆂"
  readonly property string unreadIcon: "󰆉"
  readonly property string urgentIcon: "󰅾"
  readonly property string dismissAllIcon: "󰱢"
  readonly property string dismissNonUrgentIcon: "󰃢"

  readonly property color urgentColor: Theme.red
  readonly property color lowUrgencyColor: Theme.text
  readonly property color normalUrgencyColor: Theme.text

  function urgencyColor(urgency) {
    if (urgency === NotificationUrgency.Critical)
      return urgentColor
    if (urgency === NotificationUrgency.Low)
      return lowUrgencyColor
    return normalUrgencyColor
  }
}
