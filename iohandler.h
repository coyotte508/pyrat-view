#ifndef IOHANDLER_H
#define IOHANDLER_H

#include <QObject>
#include <QString>

class IOHandler : public QObject
{
    Q_OBJECT
public:
    explicit IOHandler(QObject *parent = 0);

signals:
    void p1Moved(int x, int y);
    void p2Moved(int x, int y);
    void coinsUpdated(const QString& coins);
public slots:
    QString getFile(const QString &path);
};

#endif // IOHANDLER_H
