#include <QFile>
#include "iohandler.h"

IOHandler::IOHandler(QObject *parent) :
    QObject(parent)
{
}

QString IOHandler::getFile(const QString &path)
{
    QFile in(path);
    in.open(QFile::ReadOnly | QFile::Text);

    return QString::fromUtf8(in.readAll());
}
