import QtQuick

import "../../widgets/time"

Item {
    implicitWidth: clockWidget.implicitWidth
    implicitHeight: clockWidget.implicitHeight

    ClockWidget {
        id: clockWidget
        anchors.centerIn: parent
    }
}