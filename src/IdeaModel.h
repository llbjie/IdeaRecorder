#ifndef IDEAModel_H
#define IDEAModel_H

#include <QString>
#include <QDateTime>
#include <QVariantMap>

class Idea
{
public:
    Idea();
    Idea(int id, const QString &content, const QString &tags, 
         const QDateTime &createdAt);

    // Getter 方法
    int id() const { return m_id; }
    QString content() const { return m_content; }
    QString tags() const { return m_tags; }
    QDateTime createdAt() const { return m_createdAt; }

    // Setter 方法
    void setContent(const QString &content);
    void setTags(const QString &tags);

    // 转换为 QVariantMap（用于 QML）
    QVariantMap toVariantMap() const;

private:
    int m_id;
    QString m_content;
    QString m_tags;
    QDateTime m_createdAt;
};

#endif // IDEAModel_H