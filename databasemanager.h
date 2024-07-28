#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QtSql/QSqlDatabase>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    virtual ~DatabaseManager();

    Q_INVOKABLE bool initializeDatabase();
    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password);
    Q_INVOKABLE bool loginUser(const QString &email, const QString &password);

private:
    QSqlDatabase m_db;
    QString m_dbPath;  // Add this line
};

#endif // DATABASEMANAGER_H
