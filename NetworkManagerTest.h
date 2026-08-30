#ifndef NETWORKMANAGERTEST_H
#define NETWORKMANAGERTEST_H

#include <QUdpSocket>
#include <QObject>
#include <QHostAddress>

class NetworkManagerTest : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManagerTest(QObject *parent = nullptr);
    void discoverPeers();
    QHostAddress getCurrentLocalIP();

public slots:
    void processPendingDatagrams();

signals:

private:
    QUdpSocket *socket;
    QHostAddress myLocalIp;
    QList<QString> devices;
};

#endif // NETWORKMANAGERTEST_H
