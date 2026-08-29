import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import flatulence

ApplicationWindow {
    id: window
    width: 640
    height: 480
    minimumWidth: 200
    minimumHeight: 250
    visible: true
    title: qsTr("Flatulence")

    Button {
        text: "Phát tín hiệu"
        onClicked: Broadcaster.sendSignal("Hello ban")
    }
}
