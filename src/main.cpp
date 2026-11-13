#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QDirIterator>   // 关键：补上这个

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

    // 列出所有嵌入资源
    QDirIterator it(":/", QDirIterator::Subdirectories);
    while (it.hasNext())
        qDebug() << it.next();

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/IdeaRecorderModule/qml/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Failed to load main.qml";
        return -1;
    }

    return app.exec();
}