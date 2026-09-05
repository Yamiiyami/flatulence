#include "TransferReceiverTest.h"
#include <QDebug>


TransferReceiverTest::TransferReceiverTest(QObject *parent)
    : QObject{parent}
{
    server = new QTcpServer(parent);
    connect(server, &QTcpServer::newConnection, this, &TransferReceiverTest::onNewConnection);

}

quint16 TransferReceiverTest::startListening(quint16 port)
{
    bool result = server->listen(QHostAddress::AnyIPv4, port);
    if(!result) {
        qDebug() << "mo port that bai";
        return 0;
    }
    qDebug() << "mo port Thang cong";
    return server->serverPort();
}

void TransferReceiverTest::onNewConnection()
{
    QTcpSocket *clientSocket = server->nextPendingConnection();

    ConnectionHandler* handler = new ConnectionHandler(clientSocket, this);
    activeConnections.append(handler);
    qDebug() << "Số lượng người đang kết nối:" << activeConnections.size();

    connect(handler, &ConnectionHandler::destroyed, this, [=]() {
        activeConnections.removeOne(handler);
        qDebug() << "Một người đã rời đi. Còn lại:" << activeConnections.size();
    });

    connect(handler, &ConnectionHandler::fileReceiveStarted, this, &TransferReceiverTest::fileReceiveStarted);
    connect(handler, &ConnectionHandler::progressChanged, this, &TransferReceiverTest::progressChanged);
    connect(handler, &ConnectionHandler::fileReceived, this, &TransferReceiverTest::fileReceived);

}



