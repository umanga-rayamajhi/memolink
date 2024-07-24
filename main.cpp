#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include<QQmlContext>
#include<QQmlEngine>
// #include "DatabaseManager.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // DatabaseManager dbManager; // Instantiates and tries to open the database
    // engine.rootContext()->setContextProperty("dbManager", &dbManager);

    engine.load(QUrl(QStringLiteral("../../MainView.qml")));

    return app.exec();
}
