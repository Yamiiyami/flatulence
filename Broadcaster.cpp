#include "Broadcaster.h"
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QJsonDocument>
#include <QJsonObject>

Broadcaster::Broadcaster(QObject *parent)
    : QObject{parent}
{
    socket = new QUdpSocket(this);
    bool ok = socket->bind(
        QHostAddress::AnyIPv4,
        45678
        );

    if (!ok) {
        qDebug() << "Broadcaster bind failed:"
                 << socket->errorString();
    } else {
        qDebug() << "Broadcaster:"
                 << socket->localAddress()
                 << socket->localPort();
    }

    connect(socket, &QUdpSocket::readyRead, this, [this]() {
        while (socket->hasPendingDatagrams()) {
            QNetworkDatagram dg = socket->receiveDatagram();
            if (dg.data() == "ACK_RECEIVED") {
                qDebug() << "Xác nhận: máy" << dg.senderAddress().toString() << "đã nhận tín hiệu!";
            }
        }
    });
}

void Broadcaster::sendSignal(const QString &messages, quint16 port)
{
    QByteArray data = messages.toUtf8();
    qint64 sent = socket->writeDatagram(data, QHostAddress::Broadcast, port );
    if (sent == -1) {
        qDebug() << "Gửi thất bại:" << socket->errorString() ;
    } else if (sent != data.size()) {
        qDebug() << "Chỉ gửi được" << sent << "/" << data.size() << "bytes";
    } else {
        qDebug() << "Đã gửi" << sent << "bytes ra khỏi máy (chưa chắc bên kia nhận)"  ;
    }
}

void Broadcaster::announceFile(const QString &fileName, qint64 fileSize)
{
    QJsonObject obj;
    obj["type"] = "file_offer";
    obj["filename"] = fileName;
    obj["size"] = fileSize;

    QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    socket->writeDatagram(data, QHostAddress::Broadcast, 45678);
}

void Broadcaster::sendPortReply(const QString &ip, quint16 port)
{
    QJsonObject obj;
    obj["type"] = "port_reply";
    obj["port"] = port;
    QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    socket->writeDatagram(data, QHostAddress(ip), 45678);
}