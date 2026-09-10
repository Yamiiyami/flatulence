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
            var isExistDevice = false;

            for (var i = 0; i < deviceModel.count; i++) {
                var currentDevice = deviceModel.get(i);
                if (currentDevice) {
                    console.log("Đang check IP của phần tử", i, ":", currentDevice.ip);
                    if (currentDevice.ip === ip) {
                        isExistDevice = true;
                        break;
                    }
                }
            }
            if (!isExistDevice) {
                deviceModel.append({
                    "name": name,
                    "deviceType": "Phone",
                    "ip": ip,
                    "checked": false
                });
            }
        }
        onFileOfferReceived: (ip, dName, files) => {
            let fileList = [];
            for (let i = 0; i < files.length; i++) {
                fileList.push({
                    "nameFile": files[i].fileName,
                    "sizeFile": files[i].size,
                    "byteFile": files[i].byte,
                    "pathFile": files[i].path
                });
            }
            itemRequest.append({
                "nameDevice": dName,
                "typeDevice": "phone",
                "senderIp": ip,
                "files": fileList
            });
        }
        onPortReceived: (ip, port) => {
            console.log("[DEBUG] onPortReceived - ip:", ip, "port:", port);
            tranferSenderTest.sendFiles(ip, port, fileModel);
        }
        onOffersSent: (successCount, failCount) => {
            if (successCount > 0) {
                notifyBanner.text = "Đã gửi lời mời tới " + successCount + " thiết bị" + (failCount > 0 ? " (" + failCount + " thất bại)" : "");
                notifyBanner.visible = true;
                notifyBannerTimer.restart();
            } else {
                notifyBanner.text = "Gửi lời mời thất bại";
                notifyBanner.visible = true;
                notifyBannerTimer.restart();
            }
        }
    }

    Component.onCompleted: {
        networkManagerTest.discoverPeers();
    }

    TranferSenderTest {
        id: tranferSenderTest

        onStarted: (receiverIp, fileName, size) => {
            var idx = -1;
            for (var i = 0; i < activeTransfers.count; i++) {
                if (activeTransfers.get(i).ip === receiverIp && activeTransfers.get(i).fileName === fileName) {
                    idx = i;
                    break;
                }
            }
            if (idx === -1) {
                activeTransfers.append({
                    "ip": receiverIp,
                    "fileName": fileName,
                    "percent": 0,
                    "status": "sending"
                });
            } else {
                activeTransfers.setProperty(idx, "percent", 0);
            }
        }

        onProgressChanged: (receiverIp, fileName, sent, total) => {
            var percent = total > 0 ? Math.round((sent / total) * 100) : 0;
            for (var i = 0; i < activeTransfers.count; i++) {
                if (activeTransfers.get(i).ip === receiverIp && activeTransfers.get(i).fileName === fileName) {
                    activeTransfers.setProperty(i, "percent", percent);
                    break;
                }
            }
        }

        onFinished: receiverIp => {
            // finished(ip) chỉ báo TẤT CẢ file cho ip này đã xong -> đánh dấu done cho mọi dòng có ip đó
            for (var i = activeTransfers.count - 1; i >= 0; i--) {
                if (activeTransfers.get(i).ip === receiverIp) {
                    activeTransfers.setProperty(i, "status", "done");
                    activeTransfers.setProperty(i, "percent", 100);
                }
            }

            for (var j = 0; j < deviceReceive.count; j++) {
                if (deviceReceive.get(j).ip === receiverIp) {
                    deviceReceive.remove(j, 1);
                    break;
                }
            }
            for (var k = 0; k < deviceModel.count; k++) {
                if (deviceModel.get(k).ip === receiverIp) {
                    deviceModel.setProperty(k, "checked", false);
                    break;
                }
            }

            removeTransferTimer.targetIp = receiverIp;
            removeTransferTimer.restart();
        }

        onErrorOccurred: (receiverIp, msg) => {
            for (var i = 0; i < activeTransfers.count; i++) {
                if (activeTransfers.get(i).ip === receiverIp) {
                    activeTransfers.setProperty(i, "status", "failed");
                }
            }
            console.log("Lỗi gửi tới", receiverIp, ":", msg);
        }
    }

    Timer {
        id: removeTransferTimer
        interval: 1500
        property string targetIp: ""
        onTriggered: {
            for (var i = 0; i < activeTransfers.count; i++) {
                if (activeTransfers.get(i).ip === targetIp) {
                    activeTransfers.remove(i, 1);
                    break;
                }
            }
        }
    }
    Rectangle {
        id: notifyBanner
        property alias text: notifyBannerText.text
        visible: false
        color: "#15803d"
        radius: 8
        z: 100
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 12
        width: notifyBannerText.implicitWidth + 24
        height: notifyBannerText.implicitHeight + 16

        Text {
            id: notifyBannerText
            anchors.centerIn: parent
            color: "#f1f1f1"
            font.pointSize: 10
        }
    }

    Timer {
        id: notifyBannerTimer
        interval: 2500
        onTriggered: notifyBanner.visible = false
    }
    ListModel {
        id: activeTransfers
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
                        "path": String(result.path),
                        "fileName": String(result.name),
                        "size": String(result.size),
                        "byte": String(result.byte)
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

    ListModel {
        id: fileModel
    }

    ListModel {
        id: itemRequest
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
                                        if (deviceReceive.get(i).ip === model.ip) {
                                            isExisted = true;
                                            break;
                                        }
                                    }
                                    if (!isExisted) {
                                        deviceReceive.append({
                                            "name": model.name,
                                            "ip": model.ip
                                        });
                                    }
                                } else {
                                    for (var j = 0; j < deviceReceive.count; j++) {
                                        if (deviceReceive.get(j).ip === model.ip) {
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
                    onClicked: {
                        networkManagerTest.discoverPeers();
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
                                                        "path": String(result.path),
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

                                model: fileModel

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
                                                            var deviceIp = model.ip;

                                                            for (var i = 0; i < deviceModel.count; i++) {
                                                                if (deviceModel.get(i).ip === deviceIp) {
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

                                    if (fileModel.count === 0) {
                                        console.log("Vui lòng chọn file cần gửi");
                                        return;
                                    }

                                    networkManagerTest.notifyRecipientsWithFiles(deviceReceive, fileModel);
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
                                font.family: "Ubuntu Sans Mono"
                                font.italic: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                styleColor: "#555555"
                                leftPadding: 8
                                topPadding: 8
                                visible: itemRequest.count === 0
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
                                model: itemRequest

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

                                        spacing: 0
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
                                                    font.pixelSize: 14
                                                    font.weight: 600
                                                    text: model.nameDevice
                                                    color: "#f1f1f1"
                                                }

                                                Flow {
                                                    Layout.fillWidth: true
                                                    spacing: 6
                                                    Repeater {
                                                        model: itemRequest.get(index).files
                                                        delegate: Rectangle {
                                                            width: contentRow.width + 16
                                                            height: 30
                                                            color: "#15803d"
                                                            border.color: "#1f1f1f"
                                                            radius: 4
                                                            Row {
                                                                id: contentRow
                                                                spacing: 2
                                                                anchors.centerIn: parent
                                                                Text {
                                                                    color: "#f1f1f1"
                                                                    text: model.nameFile
                                                                }
                                                                Text {
                                                                    color: "#f1f1f1"
                                                                    text: model.sizeFile
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 40

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            RowLayout {
                                                Layout.fillHeight: true
                                                Button {

                                                    text: "accept"
                                                    font.pixelSize: 14
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }
                                                    font.weight: 600
                                                    onClicked: {
                                                        var port = TransferReceiverTest.startListening();
                                                        networkManagerTest.sendPortReply(model.senderIp, port);
                                                        itemRequest.remove(index, 1); // xóa ngay sau khi accept
                                                    }
                                                }
                                                Button {
                                                    text: "Decline"
                                                    background: Rectangle {
                                                        color: "transparent"
                                                    }

                                                    font.pixelSize: 14
                                                    font.weight: 600
                                                    onClicked: {
                                                        itemRequest.remove(index, 1);
                                                    }
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
                        Layout.preferredHeight: progressContainer.implicitHeight + 20

                        ColumnLayout {
                            id: progressContainer
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                Layout.fillWidth: true
                                text: "Tiến trình gửi file"
                                font.weight: 700
                                color: "#15803d"
                            }

                            Text {
                                color: "#919191"
                                Layout.fillWidth: true
                                text: "Chưa có file nào đang gửi"
                                font.family: "Ubuntu Sans Mono"
                                font.italic: true
                                horizontalAlignment: Text.AlignHCenter
                                topPadding: 8
                                bottomPadding: 8
                                visible: activeTransfers.count === 0
                            }

                            Repeater {
                                model: activeTransfers
                                delegate: ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: model.ip + " — " + model.fileName
                                            font.pointSize: 9
                                            color: "#15803d"
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: model.status === "done" ? "Hoàn tất" : model.status === "failed" ? "Lỗi" : model.percent + "%"
                                            font.pointSize: 9
                                            color: model.status === "failed" ? "#dc2626" : "#15803d"
                                        }
                                    }

                                    ProgressBar {
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 100
                                        value: model.percent
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
