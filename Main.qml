import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import flatulence

ApplicationWindow {
    id: window
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 450
    visible: true
    title: qsTr("Flatulence")
    color: "#1e1e2e"

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        Rectangle {
            id: viewDevice
            SplitView.preferredWidth: 260
            SplitView.minimumWidth: 80
            SplitView.maximumWidth: 400
            SplitView.fillHeight: true

            Rectangle {
                id: deviceHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 40
                color: "gray"
                Text {
                    text: "Thiết bị"
                }
            }
            ListModel {
                id: deviceModel
                ListElement {
                    name: "Bill Smith"
                    ip: "555 3264"
                }
                ListElement {
                    name: "John Brown"
                    ip: "555 8426"
                }
                ListElement {
                    name: "Sam Wise"
                    ip: "555 0473"
                }
            }

            ListView {
                anchors.top: deviceHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                model: deviceModel

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 50

                    color: "orange"

                    Image {
                        id: imageDevice

                        width: 40
                        height: 40

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        source: ""
                    }

                    Column {
                        anchors.left: imageDevice.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: name
                        }

                        Text {
                            text: ip
                        }
                    }
                }
            }
        }

        Rectangle {
            id: viewFile

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            color: "#1f1f1f"

            FileDialog {
                id: fileDialog
                title: "Chọn file"
                nameFilters: ["Audio files (*.mp3 *.wav *.flac *.m4a)", "All files (*)"]
                onAccepted: {
                    console.log("Đã chọn:", selectedFile);
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1

                    spacing: 0

                    Rectangle {
                        id: layoutFile

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        color: "#292929"

                        DropArea {
                            anchors.fill: parent

                            onEntered: {
                                layoutFile.color = "#333333";
                            }

                            onExited: {
                                layoutFile.color = "#292929";
                            }

                            onDropped: function (drop) {
                                layoutFile.color = "#292929";

                                if (!drop.hasUrls)
                                    return;
                                for (var i = 0; i < drop.urls.length; i++) {
                                    console.log("Dropped:", drop.urls[i]);
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Kéo & thả file vào đây"
                                color: "white"

                                font.pixelSize: 18
                                font.bold: true
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "hoặc"
                                color: "#888888"
                                font.pixelSize: 14
                            }

                            Button {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Chọn file"
                                onClicked: {
                                    fileDialog.open();
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Layout.preferredWidth: 1
                        color: "#292929"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Text {
                                text: "Files"
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }

                            ListView {
                                id: fileList

                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                clip: true
                                model: ListModel {
                                    ListElement {
                                        name: "anh cua toi"
                                    }
                                    ListElement {
                                        name: "anh cua toi"
                                    }
                                    ListElement {
                                        name: "anh cua toi"
                                    }
                                }
                                delegate: Rectangle {

                                    width: fileList.width
                                    height: 48
                                    radius: 4
                                    color: "#333333"

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12

                                        anchors.verticalCenter: parent.verticalCenter
                                        text: model.name
                                        color: "white"
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.preferredHeight: 1
                    color: "#292929"
                    radius: 4

                    border.width: 1
                    border.color: "#444444"

                    Text {
                        anchors.centerIn: parent
                        text: "Thông tin file / trạng thái"
                        color: "#888888"
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
