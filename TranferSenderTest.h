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
#include <QHash>
#include <QAbstractListModel>

struct TransferJob {
    QFile *file;
    QTcpSocket *socket;
    qint64 totalSize;
    QString receiverIp;
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
    void started(const QString &receiverIp, const QString &fileName, qint64 size);
    void progressChanged(const QString &receiverIp, const QString &fileName, qint64 sent, qint64 total);
    void fileFinished(const QString &receiverIp, const QString &fileName);
    void finished(const QString &receiverIp);
    void errorOccurred(const QString &receiverIp, const QString &msg);

private:
    QList<TransferJob*> jobs;
    QHash<QString, int> pendingCountByIp;
    static const quint64 CHUNK_SIZE = 65536; // 64kb
};

#endif // TRANFERSENDERTEST_H