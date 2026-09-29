import QtQuick
import "../../widgets/workspace"
import "../.."

Item {
    implicitWidth: workspaceWidget.implicitWidth
    implicitHeight: Theme.widgetHeight

    WorkspaceWidget {
        id: workspaceWidget
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
    }
}