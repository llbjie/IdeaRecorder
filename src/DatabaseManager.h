#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QList>
#include <QVariantMap>
#include "IdeaModel.h"

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool initDatabase();
    Q_INVOKABLE bool saveIdea(const QString &content, const QString &tags = "");
    Q_INVOKABLE QVariantList loadAllIdeas();
    Q_INVOKABLE bool deleteIdea(int id);
    Q_INVOKABLE int getIdeaCount();
    Q_INVOKABLE QVariantList getAllIdeasForWordCloud();

signals:
    // 当数据发生变化时发射此信号
    void dataChanged();

private:
    QSqlDatabase m_database;
    bool createTable();
    QVariantList queryToIdeaList(QSqlQuery &query);
};

#endif // DATABASEMANAGER_H