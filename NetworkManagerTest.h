#ifndef NETWORKMANAGERTEST_H
#define NETWORKMANAGERTEST_H

#include <QUdpSocket>
#include <QObject>
#include <QHostAddress>
#include <qqml.h>

class NetworkManagerTest : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit NetworkManagerTest(QObject *parent = nullptr);
    Q_INVOKABLE void discoverPeers();
    Q_INVOKABLE void announceFile(const QString &targetIp, const QString &fileName, const qint64 fileSize);
    Q_INVOKABLE void sendPortReply(const QString &ip, quint16 port);

public slots:
    void processPendingDatagrams();

signals:
    void peerDiscovered(const QString &name, const QString &ip);
    void fileOfferReceived(const QString &senderIp, QString DeviceName, QString fileName, qint64 fileSize);
    void portReceived(QString senderIp, quint16 port);

private:
    QUdpSocket *socket;
    QHostAddress myLocalIp;
    QHostAddress getCurrentLocalIP();
};

#endif // NETWORKMANAGERTEST_H
