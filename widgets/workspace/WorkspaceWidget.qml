import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../.."

Item {
    id: workspaceWidget
    property int wheelAccumulator: 0
    property int wheelStep: 120

    implicitWidth: panel.implicitWidth + 4
    height: Theme.widgetHeight

    // Funktion zum Zappen NUR durch die tatsächlich existierenden Workspaces
    function scrollWorkspace(delta) {
        if (workspaceWidget.wheelAccumulator !== 0 && ((workspaceWidget.wheelAccumulator > 0 && delta < 0) || (workspaceWidget.wheelAccumulator < 0 && delta > 0))) {
            workspaceWidget.wheelAccumulator = 0;
        }

        workspaceWidget.wheelAccumulator += delta;

        if (Math.abs(workspaceWidget.wheelAccumulator) < workspaceWidget.wheelStep) return;

        let stepDirection = workspaceWidget.wheelAccumulator > 0 ? -1 : 1;
        workspaceWidget.wheelAccumulator = 0;

        let list = Array.from(Hyprland.workspaces.values);
        if (list.length <= 1) return; // Kein Zappen nötig bei 0 oder 1 Workspace

        // Sortiert die aktuell geöffneten Workspaces strikt numerisch nach ID
        list.sort((a, b) => a.id - b.id);

        // Ermittelt den Index des aktuell fokussierten Workspace in dieser Liste
        let currentIndex = list.findIndex(w => w.id === Hyprland.focusedWorkspace?.id);
        if (currentIndex === -1) return;

        let nextIndex = currentIndex;
        if (stepDirection > 0) {
            // Mausrad nach oben -> Vorheriger belegter Workspace (mit Endlos-Wrap)
            nextIndex = (currentIndex - 1 + list.length) % list.length;
        } else if (stepDirection < 0) {
            // Mausrad nach unten -> Nächster belegter Workspace (mit Endlos-Wrap)
            nextIndex = (currentIndex + 1) % list.length;
        }

        // Führt den nativen Wechsel aus
        list[nextIndex].activate();
    }

    // Funktion zum Erstellen eines neuen Workspace am Ende
    function createNewWorkspace() {
        let list = Hyprland.workspaces.values;
        let nextId = 1;

        if (list.length > 0) {
            // Finde die höchste aktuell existierende ID
            let maxId = Math.max(...list.map(w => w.id));
            nextId = maxId + 1;
        }

        // Sendet den Befehl nativ über Quickshell an Hyprland und fokussiert ihn direkt
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${nextId} })`);
    }

    Rectangle {
        id: panel
        anchors {
        fill: parent
        centerIn: parent
        }
        implicitWidth: workspaces.implicitWidth + 12 // Integriertes Padding für die Ränder
        implicitHeight: workspaces.implicitHeight
        radius: Theme.borderRadius
        color: Theme.surface0

        // Fängt Mausrad-Bewegungen über dem gesamten Widget ab
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => workspaceWidget.scrollWorkspace(event.angleDelta.y)
        }

        RowLayout {
            id: workspaces
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: Hyprland.workspaces.values

                delegate: Rectangle {
                    required property var modelData
                    readonly property var workspace: modelData
                    readonly property bool isActive: workspace === Hyprland.focusedWorkspace

                    implicitWidth: label.implicitWidth + 10
                    implicitHeight: 26
                    color: hover.hovered ? Theme.surface1 : "transparent"

                    // Moderne Alternative zu MouseArea (Speichersparend, kein anchors.fill nötig)
                    HoverHandler { id: hover }

                    TapHandler {
                        cursorShape: Qt.PointingHandCursor
                        onTapped: workspace.activate()
                    }

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: workspace.name || workspace.id
                        color: Theme.text
                        font {
                            family: Theme.fontFamily
                            pixelSize: Theme.fontSize
                        }
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 3
                        color: isActive ? Theme.lavender : "transparent"
                    }
                }
            }


            // Plus-Button für neue Workspaces im exakt selben Design
            Rectangle {
                width: 26
                height: 26
                color: plusHover.hovered ? Theme.surface1 : "transparent"

                HoverHandler { id: plusHover }

                TapHandler {
                    cursorShape: Qt.PointingHandCursor
                    onTapped: workspaceWidget.createNewWorkspace()
                }

                Text {
                    anchors.centerIn: parent
                    text: "" 
                    color: Theme.text
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize
                    }
                }
            }
        }
    }
}