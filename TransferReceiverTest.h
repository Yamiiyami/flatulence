#ifndef TRANSFERRECEIVERTEST_H
#define TRANSFERRECEIVERTEST_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <qqml.h>
#include <ConnectionHandler.h>
#include <QList>

class TransferReceiverTest : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit TransferReceiverTest(QObject *parent = nullptr);
    Q_INVOKABLE quint16 startListening(quint16 port = 0);

signals:
    void fileReceived(const QString &path);
    void progressChanged(qint64 received, qint64 total);
private slots:
    void onNewConnection();

private:
    QTcpServer *server;
    QList<ConnectionHandler*> activeConnections;
};

#endif // TRANSFERRECEIVERTEST_H
