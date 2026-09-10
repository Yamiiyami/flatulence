#include "TranferSenderTest.h"
#include <QFile>
#include <QFileInfo>
#include <QAbstractListModel>

TranferSenderTest::TranferSenderTest(QObject *parent)
    : QObject{parent}
{


}

void TranferSenderTest::sendFile(QString receiverIp, quint16 port, const QString &path)
{
    // QFile *file = new QFile(path, this);
    // if (!file->open(QIODevice::ReadOnly)) {
    //     qDebug() << "khong mo dc file";
    //     emit errorOccurred("Không mở được file: " + path);
    //     file->deleteLater();
    //     return;
    // }

    // TransferJob *job = new TransferJob;
    // job->file = file;
    // job->totalSize = file->size();
    // job->socket = new QTcpSocket(this);
    // jobs.append(job);

    // QTcpSocket *socket = job->socket;

    // connect(socket, &QTcpSocket::connected, this, [this, job, path, socket] () {
    //     QFileInfo info(path);
    //     emit started(info.fileName(), job->totalSize);

    //     QJsonObject obj;
    //     obj["file_name"] = info.fileName();
    //     obj["size"] = job->totalSize;

    //     QJsonDocument doc(obj);
    //     QByteArray header = doc.toJson(QJsonDocument::Compact);
    //     QByteArray lenPrefix;
    //     quint32 sizeHeader = header.size();
    //     QDataStream ds(&lenPrefix, QIODevice::WriteOnly);
    //     ds << sizeHeader;

    //     socket->write(lenPrefix);
    //     socket->write(header);
    //     socket->write(job->file->read(CHUNK_SIZE));
    // });

    // connect(socket, &QTcpSocket::bytesWritten, this, [this, job, socket](qint64) {
    //     if (socket->bytesToWrite() > 0) return;

    //     emit progressChanged(job->file->pos(), job->totalSize);

    //     if (job->file->atEnd()) {
    //         job->file->close();
    //         socket->disconnectFromHost();
    //         emit finished();
    //         jobs.removeOne(job);
    //         job->file->deleteLater();
    //         socket->deleteLater();
    //         delete job;
    //         return;
    //     }
    //     socket->write(job->file->read(CHUNK_SIZE));
    // });

    // connect(socket, &QTcpSocket::errorOccurred, this, [this, socket]() {
    //     emit errorOccurred(socket->errorString());
    // });

    // socket->connectToHost(QHostAddress(receiverIp), port);
}
void TranferSenderTest::sendFiles(QString receiverIp, quint16 port, QAbstractListModel *paths)
{
    if(!paths) return;

    int row = paths->rowCount();
    if (row == 0) return;

    QHash<int, QByteArray> roles = paths->roleNames();
    pendingCountByIp[receiverIp] += row;

    for(int i = 0; i < row; i++)
    {
        QModelIndex index = paths->index(i, 0);
        QString path = paths->data(index, roles.key("path")).toString();

        QFile *file = new QFile();
        file->setFileName(path);
        if(!file->open(QIODevice::ReadOnly))
        {
            qDebug() << "Không mở được file";
            emit errorOccurred(receiverIp, "Không mở được file" + path);
            pendingCountByIp[receiverIp] -= 1;
            continue;
        }

        TransferJob *tranJob = new TransferJob();
        tranJob->file = file;
        tranJob->socket = new QTcpSocket(this);
        tranJob->totalSize = file->size();
        tranJob->receiverIp = receiverIp;

        jobs.append(tranJob);

        connect(tranJob->socket, &QTcpSocket::connected, this, [this, tranJob] () {
            QJsonObject js;
            QFileInfo fileInfo(tranJob->file->fileName());
            js["file_name"] = fileInfo.fileName();
            js["size"] = tranJob->file->size();
            QJsonDocument dc(js);
            QByteArray header = dc.toJson(QJsonDocument::Compact);
            quint32 sizeHear = header.size();

            QByteArray lenPrefix;
            QDataStream stream(&lenPrefix, QIODevice::WriteOnly);
            stream << sizeHear;

            emit started(tranJob->receiverIp, fileInfo.fileName(), tranJob->totalSize);

            tranJob->socket->write(lenPrefix);
            tranJob->socket->write(header);
            tranJob->socket->write(tranJob->file->read(CHUNK_SIZE));
        });

        connect(tranJob->socket, &QTcpSocket::bytesWritten, this, [this, tranJob]() {
            if(tranJob->socket->bytesToWrite() > 0) return;

            QFileInfo fileInfo(tranJob->file->fileName());
            emit progressChanged(tranJob->receiverIp, fileInfo.fileName(), tranJob->file->pos(), tranJob->totalSize);

            if(tranJob->file->atEnd())
            {
                QString ip = tranJob->receiverIp;
                QString fName = fileInfo.fileName();

                tranJob->file->close();
                tranJob->socket->disconnectFromHost();
                jobs.removeOne(tranJob);
                tranJob->file->deleteLater();
                tranJob->socket->deleteLater();
                delete tranJob;

                emit fileFinished(ip, fName);

                int &remain = pendingCountByIp[ip];
                remain -= 1;
                if (remain <= 0) {
                    pendingCountByIp.remove(ip);
                    emit finished(ip);
                }
                return;
            }

            tranJob->socket->write(tranJob->file->read(CHUNK_SIZE));
        });

        connect(tranJob->socket, &QTcpSocket::errorOccurred, this, [this, tranJob]() {
            emit errorOccurred(tranJob->receiverIp, tranJob->socket->errorString());
        });

        tranJob->socket->connectToHost(QHostAddress(receiverIp), port);
    }
    if (pendingCountByIp.value(receiverIp, 0) <= 0) {
        pendingCountByIp.remove(receiverIp);
        emit finished(receiverIp);
    }
}

void TranferSenderTest::sendFilesToUsers(QAbstractListModel *receiversIp, quint16 port, QAbstractListModel *paths)
{

}






