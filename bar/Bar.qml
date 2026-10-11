import Quickshell
import Quickshell.Services.Notifications
import ".."

import "center"
import "left"
import "right"

Scope {
    NotificationServer {
        id: barNotificationServer
        persistenceSupported: true
        actionsSupported: true
        onNotification: notification => notification.tracked = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            color: "transparent"

            implicitWidth: screen.width
            implicitHeight: Theme.widgetHeight

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                left: Theme.widgetSpacing
                right: Theme.widgetSpacing
                top: Theme.widgetSpacing
            }

            LeftSection {
                anchors.left: parent.left
            }

            CenterSection {
                notificationServer: barNotificationServer
                anchors.centerIn: parent
            }

            RightSection {
                anchors.right: parent.right
            }
        }
    }
}