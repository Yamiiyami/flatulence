#ifndef LISTENER_H
#define LISTENER_H

#include <QObject>
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QDebug>

class Listener : public QObject
{
    Q_OBJECT
public:
    explicit Listener(quint16 port =45678, QObject *parent = nullptr);



signals:

private slots:
    void onReadyRead();

private:
    QUdpSocket *socket;
};

#endif // LISTENER_H
