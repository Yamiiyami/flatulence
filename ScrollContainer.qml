import QtQuick
import QtQuick.Controls

Item {
    id: root

    default property alias content: pane.contentItem

    Flickable {
        anchors.fill: parent
        contentHeight: pane.implicitHeight
        flickableDirection: Flickable.AutoFlickIfNeeded
        clip: true

        Pane {
            id: pane
            width: parent.width
        }
        ScrollIndicator.vertical: ScrollIndicator {}
    }
}
