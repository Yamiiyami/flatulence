#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "Listener.h"
#include "NetworkManagerTest.h"
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);


    // NetworkManagerTest *net = new NetworkManagerTest();
    // net->discoverPeers();

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("flatulence", "Main");

    return QGuiApplication::exec();
}
