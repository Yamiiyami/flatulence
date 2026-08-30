 // TransferSender.cpp
#include "TransferSender.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QFileInfo>
#include <QDataStream>

TransferSender::TransferSender(QObject *parent) : QObject(parent) {}

void TransferSender::sendFile(const QString &ip, quint16 port, const QString &filePath)
{
    file.setFileName(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        emit errorOccurred("Không mở được file: " + filePath);
        return;
    }
    totalSize = file.size();

    socket = new QTcpSocket(this);

    connect(socket, &QTcpSocket::connected, this, [this, filePath]() {
        QFileInfo info(filePath);
        QJsonObject header;
        header["filename"] = info.fileName();
        header["size"] = totalSize;

        QByteArray headerData = QJsonDocument(header).toJson(QJsonDocument::Compact);
        QByteArray lenPrefix;
        QDataStream ds(&lenPrefix, QIODevice::WriteOnly);
        ds << (quint32)headerData.size();

        socket->write(lenPrefix);
        socket->write(headerData);

        // Gửi chunk đầu tiên, các chunk tiếp theo gửi khi bytesWritten báo rảnh
        QByteArray chunk = file.read(CHUNK_SIZE);
        socket->write(chunk);
    });

    connect(socket, &QTcpSocket::bytesWritten, this, [this]() {
        if (socket->bytesToWrite() > 0) return; // vẫn còn dữ liệu cũ chưa gửi hết

        emit progressChanged(file.pos(), totalSize);

        if (file.atEnd()) {
            file.close();
            socket->disconnectFromHost();
            emit finished();
            return;
        }

        QByteArray chunk = file.read(CHUNK_SIZE);
        socket->write(chunk);
    });

    connect(socket, &QTcpSocket::errorOccurred, this, [this]() {
        emit errorOccurred(socket->errorString());
    });

    socket->connectToHost(QHostAddress(ip), port);
}