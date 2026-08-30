
#ifndef TRANSFERRECEIVER_H
#define TRANSFERRECEIVER_H
#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QFile>
#include <qqml.h>

class TransferReceiver : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit TransferReceiver(QObject *parent = nullptr);
    Q_INVOKABLE quint16 startListening(quint16 port = 0); // 0 = OS tự chọn port trống

signals:
    void fileReceived(const QString &path);
    void progressChanged(qint64 received, qint64 total);

private slots:
    void onNewConnection();
    void onReadyRead();

private:
    QTcpServer *server;
    QTcpSocket *activeSocket = nullptr;
    QFile outFile;
    QByteArray buffer;
    qint64 expectedSize = 0;
    qint64 receivedSize = 0;
    bool headerParsed = false;
};
#endif