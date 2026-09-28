import QtQuick

import "../../widgets/workspace"

Item {
    implicitWidth: workspaceWidget.implicitWidth
    implicitHeight: workspaceWidget.implicitHeight

    WorkspaceWidget {
        id: workspaceWidget
        anchors.left: parent.left
    }
}