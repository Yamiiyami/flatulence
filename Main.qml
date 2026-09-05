import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

    NetworkManagerTest {
        id: networkManagerTest
        onPeerDiscovered: (name, ip) => {
            deviceModel.append({
                "name": name,
                "deviceType": "Phone",
                "ip": ip,
                "checked": false
            });
        }
    }

    FileHelper {
        id: fileHelper
    }

    FileDialog {
        id: fileDialog
        title: "Chọn file muốn gửi"
        fileMode: FileDialog.OpenFiles

        nameFilters: ["All file (*)"]
        onAccepted: {
            for (var i = 0; i < selectedFiles.length; i++) {
                var fileUrl = String(selectedFiles[i]);

                var result = fileHelper.getFileInfo(fileUrl);

                if (result) {
                    fileModel.append({
                        "fileName": String(result.name),
                        "size": String(result.size),
                        "byte": String(result.size)
                    });
                } else {
                    console.log("Không lấy được thông tin file:", fileUrl);
                }
            }
        }
    }

    ListModel {
        id: deviceReceive
    }

    ListModel {
        id: deviceModel
    }

    AppSplitView {

        leftView: Pane {
            anchors.fill: parent
            padding: 4

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Rectangle {
                    id: sidebar
                    Layout.fillWidth: true
                    Layout.preferredHeight: sidebarTitle.implicitHeight
                    Text {
                        id: sidebarTitle
                        text: "Thiết bị"
                    }
                }

                SearchField {
                    id: colorSearch
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    leftPadding: 24
                    rightPadding: 24

                    Accessible.name: qsTr("Demo searchfield")
                    background: Rectangle {
                        radius: 8
                        border.color: colorSearch.activeFocus ? "#3b82f6" : "#475569"
                        border.width: 1
                    }
                }

                ListView {
                    id: devices
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4
                    clip: true

                    model: deviceModel

                    delegate: ItemDelegate {
                        id: itemDevice
                        width: devices.width
                        height: 40

                        leftPadding: 10
                        rightPadding: 10

                        background: Rectangle {
                            color: itemDevice.hovered ? "#9de2ae" : "#96C98A"
                            radius: 8
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var newChecked = !model.checked;
                                deviceModel.setProperty(index, "checked", newChecked);

                                if (newChecked) {
                                    var isExisted = false;
                                    for (var i = 0; i < deviceReceive.count; i++) {
                                        if (deviceReceive.get(i).name === model.name) {
                                            isExisted = true;
                                            break;
                                        }
                                    }
                                    if (!isExisted) {
                                        deviceReceive.append({
                                            "name": model.name
                                        });
                                    }
                                } else {
                                    for (var j = 0; j < deviceReceive.count; j++) {
                                        if (deviceReceive.get(j).name === model.name) {
                                            deviceReceive.remove(j, 1);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        contentItem: RowLayout {
                            spacing: 10
                            anchors.fill: parent
                            Image {
                                id: deviceIcon
                                source: "assets/images/phone.png"
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                sourceSize.width: 24
                                sourceSize.height: 24
                            }

                            Text {
                                text: model.name
                                font.pointSize: 10
                                font.weight: 500
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                clip: true
                            }

                            CheckBox {
                                id: deviceCheck
                                Layout.preferredWidth: 24
                                Layout.fillHeight: true
                                enabled: false
                                checked: model.checked
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }

                Button {
                    id: checkDevice
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    font.weight: 500
                    font.pixelSize: 14
                    text: "Quét thiết bị"
                    palette.buttonText: "#f1f1f1"
                    background: Rectangle {
                        color: checkDevice.pressed ? "#61ad5a" : checkDevice.hovered ? "#166534" : "#15803d"
                        radius: 12
                        border.color: "#1f1f1f"
                    }
                }
            }
        }

        rightView: ScrollContainer {
            anchors.fill: parent

            Pane {
                id: mainPane
                rightPadding: 0
                leftPadding: 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: 8

                    // HỘP XANH SỐ 1
                    Rectangle {
                        id: greenBox
                        radius: 8
                        color: "#96C98A"
                        Layout.fillWidth: true

                        Layout.preferredHeight: contentContainer.implicitHeight + 20

                        ColumnLayout {
                            id: contentContainer
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.leftMargin: 6
                            anchors.rightMargin: 10
                            spacing: 15

                            Rectangle {
                                id: dropZoneBox
                                bottomLeftRadius: 8
                                topLeftRadius: 8
                                color: "#96C98A"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 200

                                Canvas {
                                    id: canvasBorder
                                    anchors.fill: parent
                                    anchors.margins: 2

                                    onWidthChanged: requestPaint()
                                    onHeightChanged: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = "#15803d";
                                        ctx.lineWidth = 2;
                                        ctx.setLineDash([6, 4]);

                                        var x = ctx.lineWidth / 2;
                                        var y = ctx.lineWidth / 2;
                                        var w = width - ctx.lineWidth;
                                        var h = height - ctx.lineWidth;
                                        var r = 8;
                                        ctx.beginPath();
                                        ctx.moveTo(x + r, y);
                                        ctx.lineTo(x + w - r, y);
                                        ctx.arcTo(x + w, y, x + w, y + r, r);
                                        ctx.lineTo(x + w, y + h - r);
                                        ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
                                        ctx.lineTo(x + r, y + h);
                                        ctx.arcTo(x, y + h, x, y + h - r, r);
                                        ctx.lineTo(x, y + r);
                                        ctx.arcTo(x, y, x + r, y, r);
                                        ctx.closePath();

                                        ctx.stroke();
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 10

                                    Item {
                                        Layout.fillHeight: true
                                    }
                                    Image {
                                        source: "assets/images/import.png"
                                        Layout.preferredWidth: 42
                                        Layout.preferredHeight: 42
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Label {
                                        text: "Kéo thả file vào đây hoặc"
                                        font.bold: true
                                        color: "#15803d"
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    Button {
                                        text: "thêm file từ máy này"
                                        Layout.alignment: Qt.AlignHCenter
                                        palette.buttonText: "#f1f1f1"
                                        background: Rectangle {
                                            color: parent.pressed ? "#96C98A" : parent.hovered ? "#166534" : "#15803d"
                                            border.color: "#1f1f1f"
                                            radius: 4
                                        }
                                        onClicked: {
                                            fileDialog.open();
                                        }
                                    }
                                    Item {
                                        Layout.fillHeight: true
                                    }
                                }
                                DropArea {
                                    anchors.fill: parent
                                    onDropped: drop => {
                                        if (drop.hasUrls) {
                                            for (var i = 0; i < drop.urls.length; i++) {
                                                var fileUrl = String(drop.urls[i]);

                                                var result = fileHelper.getFileInfo(fileUrl);

                                                if (result) {
                                                    fileModel.append({
                                                        "fileName": String(result.name),
                                                        "size": String(result.size),
                                                        "byte": result.byte
                                                    });
                                                } else {
                                                    console.log("Không lấy được thông tin file:", fileUrl);
                                                }
                                            }
                                            drop.acceptProposedAction();
                                        }
                                    }
                                }
                            }

                            ListView {
                                id: listFile
                                Layout.fillWidth: true
                                Layout.preferredHeight: listFile.contentHeight
                                interactive: false
                                spacing: 4
                                clip: true

                                model: ListModel {
                                    id: fileModel
                                }

                                delegate: ItemDelegate {
                                    width: listFile.width
                                    height: 40
                                    leftPadding: 10
                                    rightPadding: 10

                                    background: Rectangle {
                                        color: "#bf7fbf"
                                        border.color: "#1f1f1f"
                                        radius: 8
                                    }

                                    contentItem: RowLayout {
                                        ColumnLayout {
                                            spacing: 0
                                            Text {
                                                text: model.fileName
                                                color: "#fdfdfd"
                                            }
                                            Text {
                                                text: model.size
                                                color: "#fdfdfd"
                                                font.pointSize: 8
                                            }
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                        Image {
                                            source: "assets/images/Bin.png"
                                            Layout.preferredWidth: 12
                                            Layout.preferredHeight: 12
                                            sourceSize.width: 24
                                            sourceSize.height: 24
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    fileModel.remove(index, 1);
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                Layout.preferredHeight: implicitHeight
                                spacing: 6

                                Label {
                                    text: "Thiết bị nhận file (" + flowRepeater.count + " máy đã chọn):"
                                    font.bold: true
                                    font.pointSize: 10
                                    color: "#15803d"
                                    Layout.fillWidth: true
                                    leftPadding: 6
                                }
                                Label {
                                    text: "Chưa có thiết bị nào được chọn"
                                    font.italic: true
                                    font.pointSize: 9.5
                                    color: "#6b7280"
                                    Layout.fillWidth: true
                                    leftPadding: 12
                                    topPadding: 4
                                    bottomPadding: 4
                                    visible: flowRepeater.count === 0
                                }

                                Flow {
                                    id: flow
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: flow.implicitHeight
                                    spacing: 4

                                    Repeater {
                                        id: flowRepeater
                                        model: deviceReceive

                                        delegate: ItemDelegate {
                                            id: itemRoot
                                            height: 30
                                            leftPadding: 8
                                            rightPadding: 8

                                            background: Rectangle {
                                                color: "#bf7fbf"
                                                border.color: "#1f1f1f"
                                                radius: 15
                                            }

                                            contentItem: RowLayout {

                                                spacing: 6
                                                Text {
                                                    text: model.name
                                                    font.family: "Ubuntu Sans Mono"
                                                    color: "white"
                                                    font.pointSize: 9
                                                }
                                                Image {
                                                    source: "assets/images/remove.png"
                                                    Layout.preferredWidth: 14
                                                    Layout.preferredHeight: 14
                                                    sourceSize.width: 20
                                                    sourceSize.height: 20

                                                    MouseArea {
                                                        anchors.fill: parent

                                                        onClicked: {
                                                            var deviceName = model.name;

                                                            for (var i = 0; i < deviceModel.count; i++) {
                                                                if (deviceModel.get(i).name === deviceName) {
                                                                    deviceModel.setProperty(i, "checked", false);
                                                                    break;
                                                                }
                                                            }
                                                            deviceReceive.remove(index, 1);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Button {
                                text: "Gửi Files"
                                Layout.alignment: Qt.AlignRight
                                palette.buttonText: "#f1f1f1"
                                background: Rectangle {
                                    color: parent.pressed ? "#96C98A" : parent.hovered ? "#166534" : "#15803d"
                                    border.color: "#1f1f1f"
                                    radius: 4
                                }
                                onClicked: {
                                    if (deviceReceive.count === 0) {
                                        console.log("Vui lòng chọn người nhận");
                                        return;
                                    }
                                    var fileName = fileModel.get(0).fileName;
                                    var fileSize = fileModel.get(0).byte;
                                    networkManagerTest.announceFile(deviceReceive.get(0).ip, fileName, fileSize);
                                }
                            }
                        }
                    }

                    // HỘP XANH SỐ 2
                    Rectangle {
                        radius: 8
                        color: "#96C98A"
                        Layout.fillWidth: true

                        Layout.preferredHeight: containerRequest.implicitHeight
                        ColumnLayout {
                            id: containerRequest
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top

                            Text {
                                Layout.fillWidth: true
                                text: "Yêu cầu gần đây"
                                font.weight: 700
                                color: "#15803d"
                                leftPadding: 8
                                topPadding: 8
                            }
                            Text {
                                color: "#919191"
                                Layout.fillWidth: true
                                text: "Không có yêu cầu"
                                font.italic: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                styleColor: "#555555"
                                leftPadding: 8
                                topPadding: 8
                                enabled: itemRequest.cout === 0
                            }
                            ListView {
                                id: listRequest
                                Layout.fillWidth: true
                                spacing: 4
                                leftMargin: 10
                                rightMargin: 10
                                clip: true
                                Layout.preferredHeight: listRequest.contentHeight + 20
                                interactive: false
                                model: ListModel {
                                    id: itemRequest
                                    // ListElement {
                                    //     nameDevice: "Samsung pro max"
                                    //     typeDevice: "Phone"
                                    //     nameFile: "video360.mp4"
                                    //     sizeFile: "200mb"
                                    // }
                                    // ListElement {
                                    //     nameDevice: "Samsung pro max"
                                    //     typeDevice: "Phone"
                                    //     nameFile: "video360.mp4"
                                    //     sizeFile: "200mb"
                                    // }
                                }

                                delegate: ItemDelegate {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    leftPadding: 8
                                    rightPadding: 8

                                    background: Rectangle {

                                        color: "#bf7fbf"
                                        radius: 18
                                        border.color: "#1f1f1f"
                                    }
                                    contentItem: ColumnLayout {

                                        spacing: 2
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            Image {
                                                Layout.preferredHeight: 28
                                                Layout.preferredWidth: 28
                                                source: "assets/images/laptop.png"
                                            }
                                            ColumnLayout {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.margins: 5
                                                Text {
                                                    text: model.nameDevice
                                                    color: "#f1f1f1"
                                                }
                                                Text {
                                                    color: "#f1f1f1"
                                                    text: model.nameFile
                                                }
                                            }
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 40
                                            Text {
                                                text: model.sizeFile
                                                color: "#f1f1f1"
                                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                                verticalAlignment: Text.AlignBottom
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            RowLayout {
                                                Layout.fillHeight: true
                                                // color: "orange"
                                                Button {

                                                    text: "accept"
                                                    font.pixelSize: 14
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }
                                                    font.weight: 600
                                                }
                                                Button {
                                                    text: "Decline"
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }

                                                    font.pixelSize: 14
                                                    font.weight: 600
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // HỘP XANH SỐ 3
                    Rectangle {
                        radius: 8
                        color: "#96C98A"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200

                        Text {
                            anchors.centerIn: parent
                            text: "Hộp xanh số 3"
                        }
                    }
                }
            }
        }
    }
}
