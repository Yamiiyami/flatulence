#ifndef CONNECTIONHANDLER_H
#define CONNECTIONHANDLER_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>
#include <QFile>
#include <QDataStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

class ConnectionHandler : public QObject
{
    Q_OBJECT
public:
    explicit ConnectionHandler(QTcpSocket* socket, QObject *parent = nullptr);

public slots:
    void onReadyRead();
    void onDisconnected();

signals:
    void progressChanged(qint64 received, qint64 total);
    void fileReceived(QString filePath);

private:
    QTcpSocket *socket = nullptr;
    quint64 size = 0;
    QFile outFile ;
    QByteArray buffer;
    qint64 expectSize =0;
    qint64 receivedSize = 0;
    bool headerParsed = false;

};

#endif // CONNECTIONHANDLER_H
