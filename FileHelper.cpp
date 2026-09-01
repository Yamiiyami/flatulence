#include "FileHelper.h"
#include <QFileInfo>

FileHelper::FileHelper(QObject *parent)
    : QObject{parent}
{}

QVariantMap FileHelper::getFileInfo(const QString &path)
{

    QFileInfo info(QUrl(path).toLocalFile());
    QVariantMap resultMap;

    if(info.exists())
    {
        resultMap["name"] = info.fileName();
        resultMap["size"] = info.size();
        resultMap["path"] = info.absoluteFilePath();
        resultMap["exists"] = true;
    } else {
        resultMap["exists"] = false;
    }
    return resultMap;

}
