import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
  id: card

  required property var notification
  required property var notificationTheme

  signal dismissRequested()
  signal actionInvoked(var action)

  implicitHeight: contentLayout.implicitHeight + 12
  radius: Theme.borderRadius
  color: cardHover.hovered ? Theme.surface0 : Theme.base
  border.color: urgencyColor(notification)

  function urgencyColor() {
    return notificationTheme.urgencyColor(notification.urgency)
  }

  function appIconSource() {
    return notification.appIcon ? Quickshell.iconPath(notification.appIcon, "application-x-executable") : ""
  }

  function notificationMetadata() {
    const metadata = []
    if (notification.hints.category)
      metadata.push(notification.hints.category)
    if (notification.transient)
      metadata.push("Transient")
    return metadata.join(" / ")
  }

  function senderLabel() {
    const hints = notification.hints
    const senderPid = hints["sender-pid"] ?? hints.sender_pid ?? hints.pid
    const appName = notification.appName || "Unknown app"
    return senderPid !== undefined && senderPid !== null
      ? appName + " (" + senderPid + ")" : appName
  }

  function hintText() {
    const hiddenHints = ["category", "urgency", "desktop-entry", "image-path", "image_path", "image-data", "action-icons", "resident", "transient", "sender-pid", "sender_pid", "pid"]
    const entries = []
    const keys = Object.keys(notification.hints)
    for (let index = 0; index < keys.length; index++) {
      const key = keys[index]
      const value = notification.hints[key]
      if (hiddenHints.indexOf(key) === -1 && ["string", "number", "boolean"].indexOf(typeof value) !== -1)
        entries.push(key + ": " + value)
    }
    return entries.join(" / ")
  }

  HoverHandler { id: cardHover }

  TapHandler {
    acceptedButtons: Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onTapped: card.dismissRequested()
  }

  Connections {
    target: card.notification
    function onClosed() { card.notificationClosed() }
  }

  signal notificationClosed()

  RowLayout {
    id: contentLayout

    anchors.fill: parent
    anchors.margins: 6
    spacing: 8

    Item {
      Layout.alignment: Qt.AlignTop
      Layout.preferredWidth: Theme.fontSize
      Layout.preferredHeight: Theme.fontSize

      Image {
        id: notificationImage
        anchors.centerIn: parent
        width: Theme.fontSize
        height: Theme.fontSize
        source: card.notification.image
        fillMode: Image.PreserveAspectFit
        sourceSize.width: Theme.fontSize * 2
        sourceSize.height: Theme.fontSize * 2
        visible: status === Image.Ready
      }

      IconImage {
        id: appIcon
        anchors.centerIn: parent
        width: Theme.fontSize
        height: Theme.fontSize
        visible: notificationImage.status !== Image.Ready && card.notification.appIcon.length > 0
        source: card.appIconSource()
      }

      Text {
        anchors.centerIn: parent
        visible: notificationImage.status !== Image.Ready && appIcon.status !== Image.Ready
        text: card.notification.urgency === NotificationUrgency.Critical
          ? card.notificationTheme.urgentIcon : card.notificationTheme.unreadIcon
        color: card.urgencyColor()
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      Text {
        Layout.fillWidth: true
        text: card.notification.summary || "Notification"
        color: card.urgencyColor()
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        wrapMode: Text.Wrap
      }

      Text {
        Layout.fillWidth: true
        visible: card.notificationMetadata().length > 0
        text: card.notificationMetadata()
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        text: card.notification.body
        visible: text.length > 0
        color: Theme.subtext1
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        wrapMode: Text.Wrap
      }

      Text {
        Layout.fillWidth: true
        visible: card.hintText().length > 0
        text: card.hintText()
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        wrapMode: Text.Wrap
      }

      Flow {
        Layout.fillWidth: true
        visible: card.notification.actions.length > 0
        spacing: Theme.popupSpacing

        Repeater {
          model: card.notification.actions

          delegate: Rectangle {
            id: actionDelegate
            required property var modelData

            width: actionLabel.implicitWidth + 16
            height: Theme.popupItemHeight
            radius: Theme.borderRadius
            color: actionHover.hovered ? Theme.surface1 : Theme.surface0

            HoverHandler { id: actionHover }

            TapHandler {
              cursorShape: Qt.PointingHandCursor
              onTapped: card.actionInvoked(actionDelegate.modelData)
            }

            Text {
              id: actionLabel
              anchors.centerIn: parent
              text: actionDelegate.modelData.text
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
            }
          }
        }
      }

      Text {
        Layout.alignment: Qt.AlignRight
        Layout.fillWidth: true
        text: card.senderLabel()
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
      }
    }
  }
}
