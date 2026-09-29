import QtQuick
import "../../widgets/idle"
import "../../widgets/shutdown"

Item {
    implicitWidth: idleInhibitorWidget.implicitWidth + 4 + shutdownWidget.implicitWidth
    implicitHeight: shutdownWidget.implicitHeight

    IdleInhibitorWidget {
        id: idleInhibitorWidget
        anchors.right: shutdownWidget.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
    }

    ShutdownWidget {
        id: shutdownWidget
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}