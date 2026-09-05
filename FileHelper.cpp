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
        resultMap["size"] = formartFileSize(info.size());
        resultMap["path"] = info.absoluteFilePath();
        resultMap["byte"] = info.size();
        resultMap["exists"] = true;
    } else {
        resultMap["exists"] = false;
    }
    return resultMap;

}

QString FileHelper::formartFileSize(qint64 bytes)
{
    const qint64 kb = 1024;
    const qint64 mb =  kb * 1024;
    const qint64 gb = mb * 1024;

    if(bytes > gb) {
        return QString::number(bytes / double(gb), 'f', 2) + " GB";
    } else if(bytes > mb) {
        return QString::number(bytes/ double(mb) , 'f', 2) + " MB";
    } else if(bytes > kb){
        return QString::number(bytes/double(kb) , 'f', 2) + " MB";
    } else {
        return QString::number(bytes) + " B";
    }

}


