#include "Listener.h"

#include <QNetworkDatagram>
#include <QUdpSocket>


Listener::Listener(quint16 port , QObject *parent)
    : QObject{parent}
{
    socket = new QUdpSocket(this);
    socket->bind(QHostAddress::AnyIPv4, port, QUdpSocket::ShareAddress);
    connect(socket, &QUdpSocket::readyRead, this, &Listener::onReadyRead);

}

void Listener::onReadyRead()
{
    while(socket->hasPendingDatagrams()) {
        QNetworkDatagram datagram = socket->receiveDatagram();
        qDebug() << "Nhận từ" << datagram.senderAddress().toString()
                 << ":" << datagram.data();

        // Gửi ACK ngược lại cho A
        QByteArray ack = "ACK_RECEIVED";
        socket->writeDatagram(ack, datagram.senderAddress(), datagram.senderPort());
    }
}
