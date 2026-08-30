#include "Listener.h"

#include <QNetworkDatagram>
#include <QUdpSocket>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

Listener::Listener(quint16 port , QObject *parent)
    : QObject{parent}
{
    socket = new QUdpSocket(this);
    bool ok = socket->bind(
        QHostAddress::AnyIPv4,
        45678,
        QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint
        );

    qDebug() << "Bind result:" << ok;
    qDebug() << "Error:" << socket->errorString();
    qDebug() << "Local address:" << socket->localAddress();
    qDebug() << "Local port:" << socket->localPort();
    connect(socket, &QUdpSocket::readyRead, this, &Listener::onReadyRead);

}

void Listener::onReadyRead()
{
    while (socket->hasPendingDatagrams()) {
        QNetworkDatagram datagram = socket->receiveDatagram();
        QJsonObject obj = QJsonDocument::fromJson(datagram.data()).object();

        if (obj["type"].toString() == "file_offer") {
            emit fileOffered(
                datagram.senderAddress().toString(),
                obj["filename"].toString(),
                obj["size"].toVariant().toLongLong()
                );
        }
    }
}
