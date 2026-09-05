import QtQuick
import QtQuick.Controls

SplitView {
    id: root
    anchors.fill: parent
    orientation: Qt.Horizontal

    property alias leftView: leftContainer.children
    property alias rightView: rightContainer.children

    property real leftPreferredWidth: 250
    property real leftMinWidth: 100

    handle: Rectangle {
        implicitWidth: 4
        color: SplitHandle.pressed ? "#0078d4" : (SplitHandle.hovered ? "#2b88d8" : "#e0e0e0")
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    Item {
        id: leftContainer
        SplitView.preferredWidth: root.leftPreferredWidth
        SplitView.minimumWidth: root.leftMinWidth
    }

    Item {
        id: rightContainer
        SplitView.fillWidth: true
    }
}
