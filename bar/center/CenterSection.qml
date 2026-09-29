import QtQuick
import "../../widgets/time"
import "../.."

Item {
    implicitWidth: clockWidget.implicitWidth
    implicitHeight: Theme.widgetHeight

    ClockWidget {
        id: clockWidget
        anchors {
            centerIn: parent
            verticalCenter: parent.verticalCenter
        }
    }
}