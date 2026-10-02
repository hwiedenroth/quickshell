import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import ".."

Scope {
  id: launcher

  property bool opened: false
  property var filteredEntries: []
  property int selectedIndex: 0
  property var categories: []
  property var selectedCategories: []

  function ensureSelectedVisible() {
    if (!filteredEntries.length)
      return

    const rowTop = selectedIndex * 44
    const rowBottom = rowTop + 42

    if (rowTop < resultsFlickable.contentY)
      resultsFlickable.contentY = rowTop
    else if (rowBottom > resultsFlickable.contentY + resultsFlickable.height)
      resultsFlickable.contentY = rowBottom - resultsFlickable.height
  }

  function scoreEntry(entry, query) {
    const name = entry.name.toLowerCase()
    if (!query)
      return 0

    const directMatch = name.indexOf(query)
    if (directMatch >= 0)
      return directMatch + (name.length - query.length) * 0.01

    const searchable = [name, entry.genericName, entry.comment, entry.keywords.join(" ")]
      .join(" ").toLowerCase()
    let cursor = 0
    let gaps = 0

    for (let index = 0; index < query.length; index++) {
      const match = searchable.indexOf(query[index], cursor)
      if (match < 0)
        return -1
      gaps += match - cursor
      cursor = match + 1
    }

    return 100 + gaps + name.length * 0.01
  }

  function refreshMatches() {
    const query = searchField.text.trim().toLowerCase()
    const entries = DesktopEntries.applications.values
    const rankedEntries = []

    for (let index = 0; index < entries.length; index++) {
      const entry = entries[index]
      if (entry.noDisplay || !entry.name)
        continue

      const entryCategories = entry.categories || []
      const hasSelectedCategory = selectedCategories.length === 0
        || entryCategories.some(category => selectedCategories.indexOf(category) >= 0)
      if (!hasSelectedCategory)
        continue

      const score = scoreEntry(entry, query)
      if (score >= 0)
        rankedEntries.push({ entry: entry, score: score })
    }

    rankedEntries.sort((left, right) => left.score - right.score || left.entry.name.localeCompare(right.entry.name))
    filteredEntries = rankedEntries.map(item => item.entry)
    selectedIndex = 0
    Qt.callLater(() => resultsFlickable.contentY = 0)
  }

  function refreshCategories() {
    const categorySet = ({})
    const entries = DesktopEntries.applications.values

    for (let index = 0; index < entries.length; index++) {
      const entryCategories = entries[index].categories || []
      for (let categoryIndex = 0; categoryIndex < entryCategories.length; categoryIndex++) {
        const category = entryCategories[categoryIndex].trim()
        if (category)
          categorySet[category] = true
      }
    }

    categories = Object.keys(categorySet).sort((left, right) => left.localeCompare(right))
  }

  function toggleCategory(category) {
    const nextSelection = selectedCategories.slice()
    const index = nextSelection.indexOf(category)
    if (index >= 0)
      nextSelection.splice(index, 1)
    else
      nextSelection.push(category)

    selectedCategories = nextSelection
    refreshMatches()
  }

  function show() {
    opened = true
    searchField.text = ""
    refreshMatches()
    Qt.callLater(() => searchField.forceActiveFocus())
  }

  function hide() {
    opened = false
    selectedCategories = []
    refreshMatches()
  }

  IpcHandler {
    target: "launcher"

    function toggle() {
      if (launcher.opened)
        launcher.hide()
      else
        launcher.show()
    }
  }

  PanelWindow {
    id: launcherWindow

    screen: Quickshell.screens[0]
    visible: launcher.opened
    color: "transparent"
    implicitWidth: screen.width
    implicitHeight: screen.height

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: launcher.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-launcher"

    Rectangle {
      anchors.fill: parent
      color: "#99000000"

      TapHandler {
        onTapped: (eventPoint, button) => {
          const surfacePosition = launcherSurface.mapFromItem(parent, eventPoint.position)
          if (!launcherSurface.contains(surfacePosition))
            launcher.hide()
        }
      }
    }

    Rectangle {
      id: launcherSurface

      anchors.centerIn: parent
      width: Math.min(720, parent.width - 32)
      height: Math.min(420, parent.height - 48)
      radius: Theme.borderRadius
      color: Theme.base
      border.color: Theme.surface1

      RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 10

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: Theme.borderRadius
            color: Theme.mantle
            border.color: searchField.activeFocus ? Theme.blue : Theme.surface0

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 12
              anchors.rightMargin: 12
              spacing: 10

              Text {
                text: ">"
                color: Theme.blue
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.bold: true
              }

              TextInput {
                id: searchField

                Layout.fillWidth: true
                color: Theme.text
                selectionColor: Theme.blue
                selectedTextColor: Theme.base
                clip: true
                font.family: Theme.fontFamily
                font.pixelSize: 15
                verticalAlignment: TextInput.AlignVCenter
                focus: launcher.opened
                onTextChanged: launcher.refreshMatches()

                Text {
                  anchors.fill: parent
                  verticalAlignment: Text.AlignVCenter
                  text: "Anwendung suchen"
                  color: Theme.overlay0
                  font: searchField.font
                  visible: !searchField.text && !searchField.activeFocus
                }

                Keys.onPressed: event => {
                  if (event.key === Qt.Key_Escape) {
                    launcher.hide()
                    event.accepted = true
                  } else if (event.key === Qt.Key_Down) {
                    if (launcher.filteredEntries.length > 0) {
                      launcher.selectedIndex = (launcher.selectedIndex + 1) % launcher.filteredEntries.length
                      launcher.ensureSelectedVisible()
                    }
                    event.accepted = true
                  } else if (event.key === Qt.Key_Up) {
                    if (launcher.filteredEntries.length > 0) {
                      launcher.selectedIndex = (launcher.selectedIndex + launcher.filteredEntries.length - 1) % launcher.filteredEntries.length
                      launcher.ensureSelectedVisible()
                    }
                    event.accepted = true
                  } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (launcher.filteredEntries.length > 0) {
                      launcher.filteredEntries[launcher.selectedIndex].execute()
                      launcher.hide()
                    }
                    event.accepted = true
                  }
                }
              }

              Text {
                text: "ESC"
                color: Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: 10
              }
            }
          }

          Flickable {
            id: resultsFlickable

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: resultsColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            visible: launcher.filteredEntries.length > 0

            onHeightChanged: launcher.ensureSelectedVisible()

            ColumnLayout {
              id: resultsColumn

              width: resultsFlickable.width
              spacing: 2

              Repeater {
                model: launcher.filteredEntries

                delegate: Rectangle {
                  required property var modelData
                  required property int index

                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: 3
                color: index === launcher.selectedIndex || rowHover.hovered ? Theme.surface0 : "transparent"

              HoverHandler {
                id: rowHover
                cursorShape: Qt.PointingHandCursor
                onHoveredChanged: {
                  if (hovered)
                    launcher.selectedIndex = index
                }
              }

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                Rectangle {
                  Layout.preferredWidth: 26
                  Layout.preferredHeight: 26
                  radius: 4
                  color: index === launcher.selectedIndex ? Theme.teal : Theme.surface1

                  IconImage {
                    id: appIcon

                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    asynchronous: true
                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                  }

                  Text {
                    anchors.centerIn: parent
                    text: modelData.name.slice(0, 1).toUpperCase()
                    color: Theme.base
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    visible: appIcon.status !== Image.Ready
                  }
                }

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 1

                  Text {
                    Layout.fillWidth: true
                    text: modelData.name
                    color: Theme.text
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                  }

                  Text {
                    Layout.fillWidth: true
                    text: modelData.genericName || modelData.comment || modelData.id
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                  }
                }
              }

                TapHandler {
                  onTapped: {
                    modelData.execute()
                    launcher.hide()
                  }
                }
                }
              }
            }
          }

          Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Keine Anwendungen gefunden"
            color: Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            visible: launcher.filteredEntries.length === 0
          }
        }

        Rectangle {
          Layout.fillHeight: true
          Layout.preferredWidth: 176
          radius: Theme.borderRadius
          color: Theme.mantle

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
              Layout.fillWidth: true

              Text {
                Layout.fillWidth: true
                text: "Kategorien"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
              }

              Text {
                text: launcher.selectedCategories.length ? `${launcher.selectedCategories.length}` : "Alle"
                color: launcher.selectedCategories.length ? Theme.teal : Theme.overlay0
                font.family: Theme.fontFamily
                font.pixelSize: 10
              }
            }

            Flickable {
              Layout.fillWidth: true
              Layout.fillHeight: true
              clip: true
              contentWidth: width
              contentHeight: categoryColumn.implicitHeight
              boundsBehavior: Flickable.StopAtBounds

              ColumnLayout {
                id: categoryColumn

                width: parent.width
                spacing: 2

                Repeater {
                  model: launcher.categories

                  delegate: Rectangle {
                    required property string modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 3
                    color: launcher.selectedCategories.indexOf(modelData) >= 0 || categoryHover.hovered
                      ? Theme.surface0 : "transparent"

                    HoverHandler {
                      id: categoryHover
                      cursorShape: Qt.PointingHandCursor
                    }

                    Text {
                      anchors.fill: parent
                      anchors.leftMargin: 8
                      anchors.rightMargin: 6
                      verticalAlignment: Text.AlignVCenter
                      text: modelData
                      color: launcher.selectedCategories.indexOf(modelData) >= 0 ? Theme.teal : Theme.text
                      elide: Text.ElideRight
                      font.family: Theme.fontFamily
                      font.pixelSize: 11
                    }

                    TapHandler {
                      onTapped: launcher.toggleCategory(modelData)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  Component.onCompleted: {
    refreshCategories()
    refreshMatches()
  }
}