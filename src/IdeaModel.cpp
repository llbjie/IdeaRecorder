#include "IdeaModel.h"

Idea::Idea()
    : m_id(-1)
{
}

Idea::Idea(int id, const QString &content, const QString &tags,
           const QDateTime &createdAt)
    : m_id(id)
    , m_content(content)
    , m_tags(tags)
    , m_createdAt(createdAt)
{
}

void Idea::setContent(const QString &content)
{
    m_content = content;
}

void Idea::setTags(const QString &tags)
{
    m_tags = tags;
}

QVariantMap Idea::toVariantMap() const
{
    QVariantMap map;
    map["id"] = m_id;
    map["content"] = m_content;
    map["tags"] = m_tags;
    map["createdAt"] = m_createdAt.toString("yyyy-MM-dd HH:mm:ss");
    return map;
}

