#include "DatabaseManager.h"
#include <QStandardPaths>
#include <QDir>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_database.isOpen()) {
        m_database.close();
    }
}

bool DatabaseManager::initDatabase()
{
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dataPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    QString dbPath = dataPath + "/ideas.db";
    qDebug() << "Database path:" << dbPath;

    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(dbPath);

    if (!m_database.open()) {
        qDebug() << "Failed to open database:" << m_database.lastError().text();
        return false;
    }

    return createTable();
}

bool DatabaseManager::createTable()
{
    QSqlQuery query;
    
    QString createTableSQL = R"(
        CREATE TABLE IF NOT EXISTS ideas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            tags TEXT DEFAULT '',
            created_at TIMESTAMP DEFAULT (datetime('now', 'localtime'))
        )
    )";

    if (!query.exec(createTableSQL)) {
        qDebug() << "Failed to create table:" << query.lastError().text();
        return false;
    }

    qDebug() << "Database initialized successfully";
    return true;
}

bool DatabaseManager::saveIdea(const QString &content, const QString &tags)
{
    qDebug() << "=== saveIdea called ===";
    qDebug() << "Content:" << content;
    qDebug() << "Tags:" << tags;
    
    if (content.trimmed().isEmpty()) {
        qDebug() << "Cannot save empty idea";
        return false;
    }

    QDateTime localTime = QDateTime::currentDateTime();
    QString timeStr = localTime.toString("yyyy-MM-dd HH:mm:ss");

    QSqlQuery query;
    query.prepare(R"(
        INSERT INTO ideas (content, tags) 
        VALUES (:content, :tags)
    )");
    query.bindValue(":content", content);
    query.bindValue(":tags", tags);

    if (!query.exec()) {
        qDebug() << "Failed to save idea:" << query.lastError().text();
        return false;
    }

    qDebug() << "Idea saved successfully";
    
    // 发射信号通知数据变化
    emit dataChanged();
    
    return true;
}

QVariantList DatabaseManager::loadAllIdeas()
{
    QSqlQuery query(R"(
        SELECT id, content, tags, created_at 
        FROM ideas 
        ORDER BY created_at DESC
    )");
    return queryToIdeaList(query);
}

bool DatabaseManager::deleteIdea(int id)
{
    QSqlQuery query;
    query.prepare("DELETE FROM ideas WHERE id = :id");
    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to delete idea:" << query.lastError().text();
        return false;
    }

    qDebug() << "Idea deleted successfully";
    
    // 发射信号通知数据变化
    emit dataChanged();
    
    return true;
}

int DatabaseManager::getIdeaCount()
{
    QSqlQuery query("SELECT COUNT(*) FROM ideas");
    if (query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}

QVariantList DatabaseManager::queryToIdeaList(QSqlQuery &query)
{
    QVariantList ideas;
    
    while (query.next()) {
        QVariantMap idea;
        idea["id"] = query.value(0).toInt();
        idea["content"] = query.value(1).toString();
        idea["tags"] = query.value(2).toString();
        idea["createdAt"] = query.value(3).toString();
        ideas.append(idea);
    }
    
    qDebug() << "Loaded" << ideas.size() << "ideas";
    return ideas;
}

QVariantList DatabaseManager::getAllIdeasForWordCloud()
{
    QVariantList ideas;
    QSqlQuery query("SELECT content FROM ideas ORDER BY created_at DESC");
    
    while (query.next()) {
        QVariantMap idea;
        idea["content"] = query.value(0).toString();
        ideas.append(idea);
    }
    
    qDebug() << "Loaded" << ideas.size() << "ideas for word cloud";
    return ideas;
}
