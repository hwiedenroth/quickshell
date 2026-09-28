import QtQuick
import "../../widgets/shutdown"

Item {
    implicitWidth: shutdownWidget.implicitWidth
    implicitHeight: shutdownWidget.implicitHeight

    ShutdownWidget {
        id: shutdownWidget
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}