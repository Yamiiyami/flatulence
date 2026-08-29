#ifndef BROADCASTER_H
#define BROADCASTER_H

#include <QObject>
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <qqml.h>

class Broadcaster : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit Broadcaster(QObject *parent = nullptr);

    Q_INVOKABLE void sendSignal(const QString &messages, quint16 port =45678);

signals:
private:
    QUdpSocket *socket;
};

#endif // BROADCASTER_H
