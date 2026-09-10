#include "NetworkManagerTest.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkInterface>
#include <QSysInfo>
#include <QDir>
#include <QJsonArray>

NetworkManagerTest::NetworkManagerTest(QObject *parent)
    : QObject{parent}
{

    socket = new QUdpSocket(parent);
    socket->bind(QHostAddress::AnyIPv4, 45454, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);
    myLocalIp = getCurrentLocalIP();
    connect(socket, &QUdpSocket::readyRead, this, &NetworkManagerTest::processPendingDatagrams);


}

void NetworkManagerTest::discoverPeers()
{

    QJsonObject obj;
    obj["type"] = "DISCOVER_REQUEST";
    obj["appName"] = "App ne";
    QJsonDocument jsDoc(obj);
    QByteArray data = jsDoc.toJson(QJsonDocument::Compact);

    quint16 port = 45454;
    qint64 result = socket->writeDatagram(data.data(), QHostAddress::Broadcast, port);

    if(result == -1) {
        qDebug() << "Khong gui dc du lieu";
    } else {
        qDebug() << "Dang quet cac may trong mang Lan";
    }

}

void NetworkManagerTest::announceFile(const QString &targetIp, const QString &fileName, const qint64 fileSize)
{
    QJsonObject obj;
    obj["type"] = "FILE_OFFER";
    obj["device_name"] = QSysInfo::machineHostName();
    obj["file_name"] = fileName;
    obj["file_size"]= fileSize;
    QJsonDocument doc(obj);
    QByteArray byteArr = doc.toJson(QJsonDocument::Compact);
    quint16 targetPort = 45454;

    qint64 result = socket->writeDatagram(byteArr,QHostAddress(targetIp), targetPort);
    if(result == -1)  {
        qDebug() << "gui khong thanh cong";
    }else {
         qDebug() << "gui thanh cong";
    }
}

void NetworkManagerTest::sendPortReply(const QString &ip, quint16 port)
{
    QJsonObject obj;
    obj["type"] = "PORT_REPLY";
    obj["port"] = port;
    QJsonDocument doc(obj);
    QByteArray byteArr = doc.toJson(QJsonDocument::Compact);
    quint16 portRecive = 45454;
    socket->writeDatagram(byteArr, QHostAddress(ip), portRecive);

}

void NetworkManagerTest::notifyRecipientsWithFiles(QAbstractListModel *targetIps, QAbstractListModel *files)
{
    if (!targetIps) {
        qDebug() << "Danh sach IP trong!";
        return;
    }

    if(!files) {
        qDebug() << "vui long chon files truoc khi gui";
        return;
    }

    int fileRowCount = files->rowCount();
    QHash<int, QByteArray> roleFile = files->roleNames();
    QJsonArray fileArr;

    for(int i = 0; i < fileRowCount; i++)
    {
        QJsonObject objFile;
        QModelIndex index = files->index(i, 0);
        for(auto it = roleFile.constBegin(); it != roleFile.constEnd(); ++it)
        {
            int key = it.key();
            QString name = QString::fromUtf8(it.value());
            QVariant value = files->data(index, key);
            objFile[name] = QJsonValue::fromVariant(value);
        }
        fileArr.append(objFile);
    }


    int ipRowCount = targetIps->rowCount();
    QHash<int, QByteArray> role =  targetIps->roleNames();

    for(int i= 0; i < ipRowCount; i++)
    {
        QJsonObject obj;
        QModelIndex index = targetIps->index(i, 0);
        for(auto it = role.constBegin(); it != role.constEnd(); ++it)
        {
            int key = it.key();
            QString name = QString::fromUtf8(it.value());
            QVariant value = targetIps->data(index, key);
            obj[name] = QJsonValue::fromVariant(value);
        }

        obj["files"] = fileArr;
        obj["device_name"] = QSysInfo::machineHostName();
        obj["type"] = "FILE_OFFER";
        QJsonDocument doc(obj);
        QByteArray byteData = doc.toJson(QJsonDocument::Compact);
        QString ipstr = obj["ip"].toString();

        if (ipstr.isEmpty()) {
            qDebug() << "Dong" << i << "khong co truong 'ip' hop le!";
            continue;
        }

        quint16 targetPort = 45454;
        qint64 result = socket->writeDatagram(byteData, QHostAddress(ipstr), targetPort);

        if(result == -1) {
            qDebug() << "ko gửi được tới ip: " + ipstr;
        } else {
            qDebug() << "gửi thành công tới ip: " + ipstr;
        }


    }

}



QHostAddress NetworkManagerTest::getCurrentLocalIP() {
    const QList<QHostAddress> list = QNetworkInterface::allAddresses();
    for (const QHostAddress &address : list) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol &&
            address != QHostAddress::LocalHost) {
            return address;
        }
    }
    return QHostAddress::Null;
}

void NetworkManagerTest::processPendingDatagrams()
{

    while(socket->hasPendingDatagrams())
    {
        QByteArray datagram;
        datagram.resize(socket->pendingDatagramSize());

        QHostAddress senderIp;
        quint16 senderPort;

        socket->readDatagram(datagram.data(), datagram.size(), &senderIp, &senderPort);

        QJsonObject message = QJsonDocument::fromJson(datagram.data()).object();
        qDebug() << "Nhận được từ IP:" << senderIp.toString() << "Port:" << senderPort;
        QString type =  message["type"].toString();

        if(type == "DISCOVER_REQUEST")
        {
            // if(senderIp == myLocalIp) continue;
            QJsonObject replyObj;
            replyObj["type"] = "DISCOVER_RESPONSE";
            replyObj["device_name"] = QSysInfo::machineHostName();

            QByteArray replyData = QJsonDocument(replyObj).toJson(QJsonDocument::Compact);
            socket->writeDatagram(replyData, senderIp, senderPort);

        }else if(type == "DISCOVER_RESPONSE") {
            QString name = message["device_name"].toString();
            qDebug() << "Tìm thấy 1 người dùng online! IP:" << senderIp.toString() << " - Tên:" << name;
            emit peerDiscovered(name, senderIp.toString());

        } else if(type == "FILE_OFFER") {
            QString dName = message["device_name"].toString();
            // QString fName = message["file_name"].toString();
            // qint64 fSize = message["file_size"].toVariant().toLongLong();
            QJsonArray filesArray = message["files"].toArray();
            QVariantList variantFiles;
            for (const QJsonValue &v : filesArray) {
                if (v.isObject())
                    variantFiles.append(v.toObject().toVariantMap());
                else
                    variantFiles.append(v.toVariant());
            }


            emit fileOfferReceived(senderIp.toString(), dName, variantFiles);

        } else if(type == "PORT_REPLY") {
            quint16 port = message["port"].toInt();
            qDebug() << QDir::currentPath();
            emit portReceived(senderIp.toString(), port);

        }
    }
}



