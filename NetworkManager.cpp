// NetworkManager.cpp
#include "NetworkManager.h"
#include <QNetworkDatagram>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent)
{
    socket = new QUdpSocket(this);
    bool ok = socket->bind(QHostAddress::AnyIPv4, 45678,
                           QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);
    qDebug() << "NetworkManager bind:" << ok << socket->errorString();
    connect(socket, &QUdpSocket::readyRead, this, &NetworkManager::onReadyRead);
}

void NetworkManager::announceFile(const QString &fileName, qint64 fileSize)
{
    QJsonObject obj;
    obj["type"] = "file_offer";
    obj["filename"] = fileName;
    obj["size"] = fileSize;
    socket->writeDatagram(QJsonDocument(obj).toJson(QJsonDocument::Compact),
                          QHostAddress::Broadcast, 45678);
}

void NetworkManager::sendPortReply(const QString &ip, quint16 port)
{
    QJsonObject obj;
    obj["type"] = "port_reply";
    obj["port"] = port;
    socket->writeDatagram(QJsonDocument(obj).toJson(QJsonDocument::Compact),
                          QHostAddress(ip), 45678);
}

void NetworkManager::onReadyRead()
{
    while (socket->hasPendingDatagrams()) {
        QNetworkDatagram dg = socket->receiveDatagram();
        QJsonObject obj = QJsonDocument::fromJson(dg.data()).object();
        QString type = obj["type"].toString();

        if (type == "file_offer") {
            emit fileOffered(dg.senderAddress().toString(),
                             obj["filename"].toString(),
                             obj["size"].toVariant().toLongLong());
        } else if (type == "port_reply") {
            emit portReceived(dg.senderAddress().toString(),
                              (quint16)obj["port"].toInt());
        }
    }
}