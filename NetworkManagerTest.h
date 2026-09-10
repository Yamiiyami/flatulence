#ifndef NETWORKMANAGERTEST_H
#define NETWORKMANAGERTEST_H

#include <QUdpSocket>
#include <QObject>
#include <QHostAddress>
#include <qqml.h>
#include <QAbstractListModel>


class NetworkManagerTest : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit NetworkManagerTest(QObject *parent = nullptr);
    Q_INVOKABLE void discoverPeers();
    Q_INVOKABLE void announceFile(const QString &targetIp, const QString &fileName, const qint64 fileSize);
    Q_INVOKABLE void sendPortReply(const QString &ip, quint16 port);
    Q_INVOKABLE void notifyRecipientsWithFiles(QAbstractListModel *targetIps, QAbstractListModel *files);

public slots:
    void processPendingDatagrams();

signals:
    void peerDiscovered(const QString &name, const QString &ip);
    void fileOfferReceived(const QString &ip, const QString &deviceName, const QVariantList &files);
    void portReceived(const QString &ip, quint16 port);
    void offersSent(int successCount, int failCount);

private:
    QUdpSocket *socket;
    QHostAddress myLocalIp;
    QHostAddress getCurrentLocalIP();
};

#endif // NETWORKMANAGERTEST_H
