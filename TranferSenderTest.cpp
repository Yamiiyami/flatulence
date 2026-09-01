#include "TranferSenderTest.h"
#include <QFile>
#include <QFileInfo>

TranferSenderTest::TranferSenderTest(QObject *parent)
    : QObject{parent}
{}

void TranferSenderTest::sendFile(QString receiverIp, quint16 port, const QString &path)
{
    QFile *file = new QFile(path, this);
    if (!file->open(QIODevice::ReadOnly)) {
        qDebug() << "khong mo dc file";
        emit errorOccurred("Không mở được file: " + path);
        file->deleteLater();
        return;
    }

    TransferJob *job = new TransferJob;
    job->file = file;
    job->totalSize = file->size();
    job->socket = new QTcpSocket(this);
    jobs.append(job);

    QTcpSocket *socket = job->socket;

    connect(socket, &QTcpSocket::connected, this, [this, job, path, socket] () {
        QFileInfo info(path);
        emit started(info.fileName(), job->totalSize);

        QJsonObject obj;
        obj["file_name"] = info.fileName();
        obj["size"] = job->totalSize;

        QJsonDocument doc(obj);
        QByteArray header = doc.toJson(QJsonDocument::Compact);
        QByteArray lenPrefix;
        quint32 sizeHeader = header.size();
        QDataStream ds(&lenPrefix, QIODevice::WriteOnly);
        ds << sizeHeader;

        socket->write(lenPrefix);
        socket->write(header);
        socket->write(job->file->read(CHUNK_SIZE));
    });

    connect(socket, &QTcpSocket::bytesWritten, this, [this, job, socket](qint64) {
        if (socket->bytesToWrite() > 0) return;

        emit progressChanged(job->file->pos(), job->totalSize);

        if (job->file->atEnd()) {
            job->file->close();
            socket->disconnectFromHost();
            emit finished();
            jobs.removeOne(job);
            job->file->deleteLater();
            socket->deleteLater();
            delete job;
            return;
        }
        socket->write(job->file->read(CHUNK_SIZE));
    });

    connect(socket, &QTcpSocket::errorOccurred, this, [this, socket]() {
        emit errorOccurred(socket->errorString());
    });

    socket->connectToHost(QHostAddress(receiverIp), port);
}


