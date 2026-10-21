pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Item {
  id: notificationWidget

  property var notificationServer
  property int trackedCount: 0
  property bool hasUrgentNotifications: false
  property var toastNotifications: []
  readonly property int popupWidth: 360
  readonly property int popupMaxHeight: 480
  width: Theme.widgetWidth
  height: Theme.widgetHeight

  NotificationTheme { id: notificationTheme }

  function updateNotificationState() {
    trackedCount = notificationServer.trackedNotifications.values.length
    hasUrgentNotifications = false
    for (let index = 0; index < notificationServer.trackedNotifications.values.length; index++) {
      if (notificationServer.trackedNotifications.values[index].urgency === NotificationUrgency.Critical) {
        hasUrgentNotifications = true
        break
      }
    }
  }

  function dismissNotification(notification) {
    removeToast(notification)
    notification.dismiss()
    stateRefreshTimer.restart()
  }

  function addToast(notification) {
    const remainingToasts = toastNotifications.filter(item => item.id !== notification.id)
    toastNotifications = [notification].concat(remainingToasts)
    toastPopup.visible = true
  }

  function removeToast(notification) {
    toastNotifications = toastNotifications.filter(item => item !== notification)
    toastPopup.visible = toastNotifications.length > 0
  }

  function invokeAction(notification, action) {
    action.invoke()
    removeToast(notification)
  }

  Component.onCompleted: updateNotificationState()

  Connections {
    target: notificationWidget.notificationServer

    function onTrackedNotificationsChanged() {
      stateRefreshTimer.restart()
    }

    function onNotification(notification) {
      notificationWidget.addToast(notification)
      stateRefreshTimer.restart()
    }
  }

  Timer {
    id: stateRefreshTimer
    interval: 0
    onTriggered: notificationWidget.updateNotificationState()
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.borderRadius
    color: widgetHover.hovered ? Theme.surface1 : Theme.surface0

    HoverHandler { id: widgetHover }

    TapHandler {
      cursorShape: Qt.PointingHandCursor
      onTapped: notificationPopup.visible = !notificationPopup.visible
    }

    Text {
      anchors.centerIn: parent
      text: {
        if (notificationWidget.hasUrgentNotifications)
          return notificationTheme.urgentIcon
        if (notificationWidget.trackedCount > 0)
          return notificationTheme.unreadIcon
        return notificationTheme.emptyIcon
      }
      color: notificationWidget.hasUrgentNotifications ? notificationTheme.urgentColor : notificationTheme.normalUrgencyColor
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }

  PopupWindow {
    id: toastPopup

    anchor.window: notificationWidget.QsWindow.window
    anchor.rect.x: notificationWidget.mapToItem(null, (notificationWidget.width - width) / 2, 0).x
    anchor.rect.y: notificationWidget.mapToItem(null, 0, notificationWidget.height).y + 4
    implicitWidth: notificationWidget.popupWidth
    implicitHeight: Math.min(toastList.implicitHeight + Theme.popupMargin * 2, notificationWidget.popupMaxHeight)
    color: "transparent"
    visible: false

    Flickable {
      id: toastFlickable

      anchors.fill: parent
      anchors.margins: Theme.popupMargin
      contentWidth: width
      contentHeight: toastList.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: toastList
        width: toastFlickable.width
        spacing: Theme.popupSpacing

        Repeater {
          model: notificationWidget.toastNotifications

          delegate: Item {
            id: toastDelegate
            required property var modelData

            width: toastList.width
            implicitHeight: toastCard.implicitHeight

            NotificationCard {
              id: toastCard
              anchors.fill: parent
              notification: toastDelegate.modelData
              notificationTheme: notificationTheme
              onDismissRequested: notificationWidget.dismissNotification(toastDelegate.modelData)
              onActionInvoked: action => notificationWidget.invokeAction(toastDelegate.modelData, action)
            }

            Timer {
              interval: toastDelegate.modelData.expireTimeout > 0 ? toastDelegate.modelData.expireTimeout : 3000
              running: toastDelegate.modelData.expireTimeout !== -1
              onTriggered: notificationWidget.removeToast(toastDelegate.modelData)
            }
          }
        }
      }
    }
  }

  PopupWindow {
    id: notificationPopup

    anchor.window: notificationWidget.QsWindow.window
    anchor.rect.x: notificationWidget.mapToItem(null, (notificationWidget.width - width) / 2, 0).x
    anchor.rect.y: notificationWidget.mapToItem(null, 0, notificationWidget.height).y + 4
    implicitWidth: notificationWidget.popupWidth
    implicitHeight: Math.min(popupColumn.implicitHeight + Theme.popupMargin * 2, notificationWidget.popupMaxHeight)
    grabFocus: true
    color: "transparent"
    visible: false

    Rectangle {
      anchors.fill: parent
      radius: Theme.borderRadius
      color: Theme.base
      border.color: Theme.surface1

      ColumnLayout {
        id: popupColumn

        anchors.fill: parent
        anchors.margins: Theme.popupMargin
        spacing: Theme.popupSpacing

        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.popupSpacing

          Item { Layout.fillWidth: true }

          Repeater {
            model: [
              { icon: notificationTheme.dismissAllIcon, tooltip: "Dismiss all", urgentOnly: false },
              { icon: notificationTheme.dismissNonUrgentIcon, tooltip: "Dismiss non-urgent", urgentOnly: true }
            ]

            delegate: Rectangle {
              id: actionDelegate
              required property var modelData

              Layout.preferredWidth: Theme.fontSize + 4
              Layout.preferredHeight: Theme.fontSize + 4
              radius: Theme.borderRadius
              color: actionHover.hovered ? Theme.surface0 : "transparent"

              HoverHandler { id: actionHover }

              ToolTip.visible: actionHover.hovered
              ToolTip.text: actionDelegate.modelData.tooltip
              ToolTip.delay: 500

              TapHandler {
                cursorShape: Qt.PointingHandCursor
                onTapped: {
                  for (let index = notificationWidget.notificationServer.trackedNotifications.values.length - 1; index >= 0; index--) {
                    const notification = notificationWidget.notificationServer.trackedNotifications.values[index]
                    if (!actionDelegate.modelData.urgentOnly || notification.urgency !== NotificationUrgency.Critical)
                      notificationWidget.dismissNotification(notification)
                  }
                }
              }

              Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: actionDelegate.modelData.icon
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
              }
            }
          }
        }

        Flickable {
          id: notificationList

          Layout.fillWidth: true
          Layout.preferredHeight: Math.min(notificationColumn.implicitHeight, notificationWidget.popupMaxHeight - Theme.popupItemHeight - Theme.popupMargin * 2 - Theme.popupSpacing)
          clip: true
          contentWidth: width
          contentHeight: notificationColumn.implicitHeight
          boundsBehavior: Flickable.StopAtBounds

          Column {
            id: notificationColumn
            width: notificationList.width
            spacing: Theme.popupSpacing

            Repeater {
              model: notificationWidget.notificationServer.trackedNotifications

              delegate: NotificationCard {
                id: notificationDelegate
                required property var modelData

                width: notificationColumn.width
                notification: modelData
                notificationTheme: notificationTheme
                onDismissRequested: notificationWidget.dismissNotification(notificationDelegate.modelData)
                onActionInvoked: action => notificationWidget.invokeAction(notificationDelegate.modelData, action)
                onNotificationClosed: stateRefreshTimer.restart()
              }
            }

            Text {
              visible: notificationWidget.trackedCount === 0
              width: notificationColumn.width
              height: Theme.popupItemHeight
              text: "Keine ungelesenen Benachrichtigungen"
              color: Theme.subtext1
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
              wrapMode: Text.Wrap
            }
          }
        }
      }
    }
  }
}