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
    
    // 创建版本表
    QString createVersionTableSQL = R"(
        CREATE TABLE IF NOT EXISTS db_version (
            version INTEGER PRIMARY KEY
        )
    )";
    query.exec(createVersionTableSQL);
    
    // 获取当前版本
    int currentVersion = 0;
    QSqlQuery versionQuery("SELECT version FROM db_version");
    if (versionQuery.next()) {
        currentVersion = versionQuery.value(0).toInt();
    }
    
    qDebug() << "Database version:" << currentVersion;
    
    // 版本1：创建ideas表
    if (currentVersion < 1) {
        QString createIdeasSQL = R"(
            CREATE TABLE IF NOT EXISTS ideas (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT NOT NULL,
                tags TEXT DEFAULT '',
                created_at TIMESTAMP DEFAULT (datetime('now', 'localtime'))
            )
        )";
        if (!query.exec(createIdeasSQL)) {
            qDebug() << "Failed to create ideas table:" << query.lastError().text();
            return false;
        }
        qDebug() << "Version 1: ideas table created";
    }
    
    // 版本2：创建tags表和默认标签
    if (currentVersion < 2) {
        QString createTagsSQL = R"(
            CREATE TABLE IF NOT EXISTS tags (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE
            )
        )";
        if (!query.exec(createTagsSQL)) {
            qDebug() << "Failed to create tags table:" << query.lastError().text();
            return false;
        }
        
        // 插入默认标签（如果表为空）
        query.exec("SELECT COUNT(*) FROM tags");
        if (query.next() && query.value(0).toInt() == 0) {
            QStringList defaultTags = {"正面", "负面", "中性"};
            for (const QString &tag : defaultTags) {
                QSqlQuery insertQuery;
                insertQuery.prepare("INSERT INTO tags (name) VALUES (:name)");
                insertQuery.bindValue(":name", tag);
                insertQuery.exec();
            }
            qDebug() << "Default tags inserted";
        }
        qDebug() << "Version 2: tags table created";
    }
    
    // 更新版本号
    query.exec("DELETE FROM db_version");
    query.prepare("INSERT INTO db_version (version) VALUES (:version)");
    query.bindValue(":version", 2);
    query.exec();

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

bool DatabaseManager::updateIdea(int id, const QString &content, const QString &tags)
{
    if (content.trimmed().isEmpty()) {
        qDebug() << "Cannot save empty idea";
        return false;
    }

    QSqlQuery query;
    query.prepare(R"(
        UPDATE ideas 
        SET content = :content, tags = :tags 
        WHERE id = :id
    )");
    query.bindValue(":content", content);
    query.bindValue(":tags", tags);
    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to update idea:" << query.lastError().text();
        return false;
    }

    qDebug() << "Idea updated successfully";
    emit dataChanged();
    return true;
}

QVariantList DatabaseManager::loadAllTags()
{
    QVariantList tags;
    QSqlQuery query("SELECT id, name FROM tags ORDER BY name");
    
    while (query.next()) {
        QVariantMap tag;
        tag["id"] = query.value(0).toInt();
        tag["name"] = query.value(1).toString();
        tags.append(tag);
    }
    
    qDebug() << "Loaded" << tags.size() << "tags";
    return tags;
}

bool DatabaseManager::addTag(const QString &name)
{
    if (name.trimmed().isEmpty()) {
        qDebug() << "Cannot add empty tag";
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT INTO tags (name) VALUES (:name)");
    query.bindValue(":name", name.trimmed());

    if (!query.exec()) {
        qDebug() << "Failed to add tag:" << query.lastError().text();
        return false;
    }

    qDebug() << "Tag added successfully";
    emit dataChanged();
    return true;
}

bool DatabaseManager::deleteTag(int id)
{
    QSqlQuery query;
    query.prepare("DELETE FROM tags WHERE id = :id");
    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to delete tag:" << query.lastError().text();
        return false;
    }

    qDebug() << "Tag deleted successfully";
    emit dataChanged();
    return true;
}

bool DatabaseManager::renameTag(int id, const QString &newName)
{
    if (newName.trimmed().isEmpty()) {
        qDebug() << "Cannot rename to empty tag";
        return false;
    }

    QSqlQuery query;
    query.prepare("UPDATE tags SET name = :name WHERE id = :id");
    query.bindValue(":name", newName.trimmed());
    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "Failed to rename tag:" << query.lastError().text();
        return false;
    }

    qDebug() << "Tag renamed successfully";
    emit dataChanged();
    return true;
}
