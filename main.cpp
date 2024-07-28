#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "databasemanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    DatabaseManager dbManager;
    if (!dbManager.initializeDatabase()) {
        qCritical() << "Failed to initialize database. Exiting.";
        return -1;
    }

    QQmlApplicationEngine engine;

    // Set the dbManager as a context property
    engine.rootContext()->setContextProperty("dbManager", &dbManager);

    const QUrl url("../../MainView.qml");
    qDebug() << "Loading QML file from:" << url.toString();

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                qCritical() << "Failed to create object for QML file:" << url.toString();
                QCoreApplication::exit(-1);
            }
        }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML file:" << url.toString();
        return -1;
    }

    return app.exec();
}
