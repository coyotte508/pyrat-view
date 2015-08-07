#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "iohandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("io", new IOHandler());
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}
