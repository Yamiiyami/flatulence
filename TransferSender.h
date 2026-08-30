
#ifndef TRANSFERSENDER_H
#define TRANSFERSENDER_H
#include <QObject>
#include <QTcpSocket>
#include <QFile>
#include <qqml.h>

class TransferSender : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit TransferSender(QObject *parent = nullptr);
    Q_INVOKABLE void sendFile(const QString &ip, quint16 port, const QString &filePath);

signals:
    void progressChanged(qint64 sent, qint64 total);
    void finished();
    void errorOccurred(const QString &msg);

private:
    QTcpSocket *socket = nullptr;
    QFile file;
    qint64 totalSize = 0;
    static const qint64 CHUNK_SIZE = 65536; // 64KB
};
#endif