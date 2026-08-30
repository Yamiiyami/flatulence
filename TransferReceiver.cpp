
#include "TransferReceiver.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDataStream>
#include <QStandardPaths>
#include <QDir>

TransferReceiver::TransferReceiver(QObject *parent) : QObject(parent)
{
    server = new QTcpServer(this);
    connect(server, &QTcpServer::newConnection, this, &TransferReceiver::onNewConnection);
}

quint16 TransferReceiver::startListening(quint16 port)
{
    if (!server->listen(QHostAddress::AnyIPv4, port)) {
        qDebug() << "Lỗi mở TCP server:" << server->errorString();
        return 0;
    }
    qDebug() << "TransferReceiver đang lắng nghe port" << server->serverPort();
    return server->serverPort();
}

void TransferReceiver::onNewConnection()
{
    activeSocket = server->nextPendingConnection();
    headerParsed = false;
    receivedSize = 0;
    buffer.clear();
    connect(activeSocket, &QTcpSocket::readyRead, this, &TransferReceiver::onReadyRead);
}

void TransferReceiver::onReadyRead()
{
    buffer.append(activeSocket->readAll());

    if (!headerParsed) {
        if (buffer.size() < 4) return;

        quint32 headerLen;
        QDataStream ds(buffer.left(4));
        ds >> headerLen;

        if (buffer.size() < 4 + (int)headerLen) return;

        QByteArray headerData = buffer.mid(4, headerLen);
        QJsonObject header = QJsonDocument::fromJson(headerData).object();
        QString fileName = header["filename"].toString();
        expectedSize = header["size"].toVariant().toLongLong();

        QString downloadDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        outFile.setFileName(downloadDir + "/" + fileName);
        if (!outFile.open(QIODevice::WriteOnly)) {
            qDebug() << "Không tạo được file đích";
            return;
        }

        buffer.remove(0, 4 + headerLen);
        headerParsed = true;
    }

    if (headerParsed && !buffer.isEmpty()) {
        outFile.write(buffer);
        receivedSize += buffer.size();
        buffer.clear();
        emit progressChanged(receivedSize, expectedSize);

        if (receivedSize >= expectedSize) {
            outFile.close();
            emit fileReceived(outFile.fileName());
        }
    }
}