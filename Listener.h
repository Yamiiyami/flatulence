#ifndef LISTENER_H
#define LISTENER_H

#include <QObject>
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QDebug>
#include <qqml.h>

class Listener : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit Listener(quint16 port =45678, QObject *parent = nullptr);



signals:
    void fileOffered(const QString &senderIp, const QString &fileName, qint64 fileSize);
private slots:
    void onReadyRead();

private:
    QUdpSocket *socket;
};

#endif // LISTENER_H
