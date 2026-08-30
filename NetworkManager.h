// NetworkManager.h
#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H
#include <QObject>
#include <QUdpSocket>
#include <qqml.h>

class NetworkManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit NetworkManager(QObject *parent = nullptr);

    Q_INVOKABLE void announceFile(const QString &fileName, qint64 fileSize);
    Q_INVOKABLE void sendPortReply(const QString &ip, quint16 port);

signals:
    void fileOffered(const QString &senderIp, const QString &fileName, qint64 fileSize);
    void portReceived(const QString &senderIp, quint16 port);

private slots:
    void onReadyRead();

private:
    QUdpSocket *socket;
};
#endif