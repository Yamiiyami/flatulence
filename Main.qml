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

    property string selectedFileName: ""
    property string selectedFilePath: ""
    property int selectedFileSize: 0

    Dialog {
        id: myDialog
        title: "Cài đặt Kết nối"
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string pendingIp: ""
        property string pendingDeviceName: ""
        property string pendingFileName: ""
        property int pendingSize: 0
        Column {
            spacing: 10
            width: parent.width

            Text {
                id: textDialog
                text: "Nhập số Port để lắng nghe:"
            }
        }

        onAccepted: {
            var listeningPort = TransferReceiverTest.startListening();
            if (listeningPort === 0) {
                console.log("Không mở được port để lắng nghe");
                return;
            }
            networkManager.sendPortReply(myDialog.pendingIp, listeningPort);
        }
        onRejected: {
            console.log("Người dùng bấm Cancel hoặc đóng Dialog");
        }
    }
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
            TranferSenderTest {
                id: transferSender
            }
            NetworkManagerTest {
                id: networkManager

                onPeerDiscovered: function (name, ip) {
                    for (var i = 0; i < deviceModel.count; i++) {
                        if (deviceModel.get(i).ip === ip) {
                            return;
                        }
                    }

                    deviceModel.append({
                        "name": name,
                        "ip": ip
                    });
                }

                onFileOfferReceived: function (reciveIp, dname, fname, size) {
                    myDialog.pendingIp = reciveIp;
                    myDialog.pendingDeviceName = dname;
                    myDialog.pendingFileName = fname;
                    myDialog.pendingSize = size;
                    textDialog.text = "Máy: " + dname + "/n" + "file: " + fname;
                    myDialog.open();
                }
                onPortReceived: function (ip, port) {
                    transferSender.sendFile(ip, port, window.selectedFilePath); // cần lưu full path lúc chọn file
                }
                Component.onCompleted: discoverPeers()
            }

            ListModel {
                id: deviceModel
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
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (window.selectedFileName === "") {
                                console.log("Chưa chọn file để gửi");
                                return;
                            }
                            networkManager.announceFile(ip, window.selectedFileName, window.selectedFileSize);
                        }
                    }
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
            FileHelper {
                id: fileHelper
            }
            FileDialog {
                id: fileDialog
                title: "Chọn file"
                nameFilters: ["All files (*)"]
                onAccepted: {
                    console.log("Đã chọn:", selectedFile);
                    var info = fileHelper.getFileInfo(selectedFile);

                    window.selectedFileName = info.name;
                    window.selectedFileSize = info.size;
                    window.selectedFilePath = info.path;

                    listFile.append({
                        "name": info.name,
                        "size": info.size
                    });
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
                                    id: listFile
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

                ListModel {
                    id: transferModel
                }

                // helper: tìm index theo fileName, trả -1 nếu chưa có
                function findTransferIndex(name) {
                    for (var i = 0; i < transferModel.count; i++) {
                        if (transferModel.get(i).fileName === name)
                            return i;
                    }
                    return -1;
                }

                Connections {
                    target: transferSender
                    function onStarted(fileName, size) {
                        transferModel.append({
                            fileName: fileName,
                            totalSize: size,
                            sentBytes: 0,
                            status: "Đang gửi",
                            direction: "up"
                        });
                    }
                    function onProgressChanged(sent, total) {
                        // vì hiện tại chỉ có 1 transfer/lúc, lấy entry cuối cùng đang "Đang gửi"
                        var idx = transferModel.count - 1;
                        if (idx >= 0) {
                            transferModel.setProperty(idx, "sentBytes", sent);
                            transferModel.setProperty(idx, "totalSize", total);
                        }
                    }
                    function onFinished() {
                        var idx = transferModel.count - 1;
                        if (idx >= 0)
                            transferModel.setProperty(idx, "status", "Hoàn tất");
                    }
                    function onErrorOccurred(err) {
                        var idx = transferModel.count - 1;
                        if (idx >= 0)
                            transferModel.setProperty(idx, "status", "Lỗi: " + err);
                    }
                }

                // tương tự cho receiver:
                // Connections { target: networkManager (hoặc handler) ... }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1
                    color: "#292929"
                    radius: 4
                    border.width: 1
                    border.color: "#444444"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        Text {
                            text: "Thông tin file / trạng thái"
                            color: "#888888"
                            font.pixelSize: 14
                        }

                        ListView {
                            id: transferListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: transferModel
                            visible: transferModel.count > 0

                            delegate: Rectangle {
                                width: transferListView.width
                                height: 56
                                radius: 4
                                color: "#333333"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: (direction === "up" ? "⬆ " : "⬇ ") + fileName
                                            color: "white"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: status
                                            color: status.indexOf("Lỗi") === 0 ? "#e06c75" : "#888888"
                                            font.pixelSize: 12
                                        }
                                    }

                                    ProgressBar {
                                        Layout.fillWidth: true
                                        from: 0
                                        to: totalSize > 0 ? totalSize : 1
                                        value: sentBytes
                                    }
                                }
                            }
                        }

                        Text {
                            visible: transferModel.count === 0
                            text: "Chưa có transfer nào"
                            color: "#666666"
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
