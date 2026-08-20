#include "TagModel.h"

Tag::Tag()
    : m_id(-1)
{
}

Tag::Tag(int id, const QString &name)
    : m_id(id)
    , m_name(name)
{
}

void Tag::setName(const QString &name)
{
    m_name = name;
}

QVariantMap Tag::toVariantMap() const
{
    QVariantMap map;
    map["id"] = m_id;
    map["name"] = m_name;
    return map;
}
