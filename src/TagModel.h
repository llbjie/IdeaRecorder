#ifndef TAGMODEL_H
#define TAGMODEL_H

#include <QString>
#include <QVariantMap>

class Tag
{
public:
    Tag();
    Tag(int id, const QString &name);

    int id() const { return m_id; }
    QString name() const { return m_name; }

    void setName(const QString &name);

    QVariantMap toVariantMap() const;

private:
    int m_id;
    QString m_name;
};

#endif // TAGMODEL_H
