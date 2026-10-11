import QtQuick
import "../../widgets/notification"
import "../../widgets/time"
import "../.."

Item {
    property var notificationServer

    implicitWidth: notificationWidget.implicitWidth + Theme.widgetSpacing + clockWidget.implicitWidth
    implicitHeight: Theme.widgetHeight

    NotificationWidget {
        id: notificationWidget
        notificationServer: parent.notificationServer
        anchors {
            right: clockWidget.left
            rightMargin: Theme.widgetSpacing
            verticalCenter: parent.verticalCenter
        }
    }

    ClockWidget {
        id: clockWidget
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }
}