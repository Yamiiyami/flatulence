#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <qqml.h>
class FileHelper : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit FileHelper(QObject *parent = nullptr);
    Q_INVOKABLE QVariantMap getFileInfo(const QString &path);
signals:


};

#endif // FILEHELPER_H
