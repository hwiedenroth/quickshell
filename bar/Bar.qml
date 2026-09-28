import Quickshell
import ".."

import "center"
import "left"
import "right"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            implicitHeight: Theme.barHeight
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            LeftSection {
                anchors.left: parent.left
            }

            CenterSection {
                anchors.centerIn: parent
            }

            RightSection {
                anchors.right: parent.right
            }
        }
    }
}