#ifndef TRANFERSENDERTEST_H
#define TRANFERSENDERTEST_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDataStream>
#include <qqml.h>
#include <QList>
#include <QAbstractListModel>

struct TransferJob {
    QFile *file;
    QTcpSocket *socket;
    qint64 totalSize;
};

class TranferSenderTest : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit TranferSenderTest(QObject *parent = nullptr);
    Q_INVOKABLE void sendFile(QString receiverIp, quint16 port, const QString &path);
    Q_INVOKABLE void sendFiles(QString receiverIp, quint16 port, QAbstractListModel *paths);
    Q_INVOKABLE void sendFilesToUsers(QAbstractListModel *receiversIp, quint16 port, QAbstractListModel *paths);

signals:
    void finished();
    void errorOccurred(const QString &msg);
    void progressChanged(qint64 sent, qint64 total);
    void started(const QString &fileName, qint64 size);

private:
    QList<TransferJob*> jobs;
    static const quint64 CHUNK_SIZE = 65536; // 64kb
};

#endif // TRANFERSENDERTEST_H
