#include "ConnectionHandler.h"

ConnectionHandler::ConnectionHandler(QTcpSocket *socket, QObject *parent)
{
    this->socket = socket;
    socket->setParent(this);
    connect(socket, &QTcpSocket::readyRead, this, &ConnectionHandler::onReadyRead);
    connect(socket, &QTcpSocket::disconnected, this, &ConnectionHandler::onDisconnected);
}

void ConnectionHandler::onReadyRead()
{
    QByteArray socketData = socket->readAll();
    buffer.append(socketData);

    if(!headerParsed)
    {
        if(buffer.size() < 4) return;
        qint32 headerlen;
        QDataStream ds(buffer.left(4));
        ds >> headerlen;

        if(buffer.size() < 4 + (int)headerlen) return;

        QByteArray byteArr = buffer.mid(4, headerlen);
        QJsonObject header= QJsonDocument::fromJson(byteArr).object();
        QString name = header["file_name"].toString();
        expectSize = header["size"].toVariant().toLongLong();

        QString path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
         qDebug() << "file: " << path + "/" + name;
        outFile.setFileName(path + "/" + name);

        if(!outFile.open(QIODevice::WriteOnly)) {
            qDebug() << "khong tao dc file";
            return ;
        }

        buffer.remove(0, 4 + (int)headerlen);
        headerParsed = true;
    }

    if(headerParsed && !buffer.isEmpty())
    {
        outFile.write(buffer);
        receivedSize += buffer.size();
        buffer.clear();
        emit progressChanged(receivedSize, expectSize);

        if(receivedSize >= expectSize) {
            outFile.close();
            emit fileReceived(outFile.fileName());
            socket->disconnectFromHost();
        }

    }

}

void ConnectionHandler::onDisconnected()
{
    qDebug() << "Một Client đã ngắt kết nối.";
    this->deleteLater();
}
