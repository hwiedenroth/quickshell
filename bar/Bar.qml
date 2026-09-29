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
                anchors.centerIn: parent
            }

            RightSection {
                anchors.right: parent.right
            }
        }
    }
}