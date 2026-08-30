#include "NetworkManagerTest.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkInterface>

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
    obj["appName"] = "appNe";
    QJsonDocument jsDoc(obj);
    QByteArray data = jsDoc.toJson(QJsonDocument::Compact);

    // QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    quint16 port = 45454;
    qint64 result = socket->writeDatagram(data.data(), QHostAddress::Broadcast, port);

    if(result == -1) {
        qDebug() << "Khong gui dc du lieu";
    } else {
        qDebug() << "Dang quet cac may trong mang Lan";
    }
    // socket->deleteLater();

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
        qDebug() << "size: " << socket->pendingDatagramSize();

        QHostAddress senderIp;
        quint16 senderPort;

        socket->readDatagram(datagram.data(), datagram.size(), &senderIp, &senderPort);

        QJsonObject message = QJsonDocument::fromJson(datagram.data()).object();
        qDebug() << "Nhận được từ IP:" << senderIp.toString() << "Port:" << senderPort;
        qDebug() << "Nội dung:" << message["type"].toString();
        QString type =  message["type"].toString();
        if(type == "DISCOVER_REQUEST")
        {
            // if(senderIp == myLocalIp) continue;
            QJsonObject replyObj;
            replyObj["type"] = "DISCOVER_RESPONSE";
            replyObj["deviceName"] = "May cua t ne";

            QByteArray replyData = QJsonDocument(replyObj).toJson(QJsonDocument::Compact);
            socket->writeDatagram(replyData, senderIp, senderPort);
        }else if(type == "DISCOVER_RESPONSE") {
            QString name = message["deviceName"].toString();
             qDebug() << "Tìm thấy 1 người dùng online! IP:" << senderIp.toString() << " - Tên:" << name;

        }
    }

}



