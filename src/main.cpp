#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include "DatabaseManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    app.setApplicationName("IdeaRecorder");
    app.setOrganizationName("MyCompany");

    DatabaseManager dbManager;
    if (!dbManager.initDatabase()) {
        qDebug() << "Failed to initialize database";
        return -1;
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.load(QUrl("qrc:/main.qml"));
    
    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Failed to load main.qml";
        return -1;
    }
    
    return app.exec();
}