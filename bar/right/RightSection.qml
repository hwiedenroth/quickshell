import QtQuick
import "../../widgets/scale"
import "../../widgets/idle"
import "../../widgets/shutdown"
import "../.."

Item {
    implicitWidth: scaleWidget.implicitWidth + scaleWidget.anchors.rightMargin
                    + idleInhibitorWidget.implicitWidth + idleInhibitorWidget.anchors.rightMargin
                    + shutdownWidget.implicitWidth + shutdownWidget.anchors.leftMargin
    implicitHeight: Theme.widgetHeight

    ScaleWidget {
        id: scaleWidget
        anchors {
            right: idleInhibitorWidget.left
            rightMargin: Theme.widgetSpacing
            verticalCenter: parent.verticalCenter
        }
    }

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