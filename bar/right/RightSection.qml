import QtQuick
import "../../widgets/idle"
import "../../widgets/shutdown"
import "../.."

Item {
    implicitWidth: idleInhibitorWidget.implicitWidth + idleInhibitorWidget.anchors.rightMargin
                    + shutdownWidget.implicitWidth + shutdownWidget.anchors.leftMargin
    implicitHeight: Theme.widgetHeight

    IdleInhibitorWidget {
        id: idleInhibitorWidget
        anchors {
            right: shutdownWidget.left
            rightMargin: Theme.widgetSpacing
            verticalCenter: parent.verticalCenter
        }
    }

    ShutdownWidget {
        id: shutdownWidget
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }
}