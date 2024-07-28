#include "databasemanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QCryptographicHash>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataPath);
    m_dbPath = dataPath + "/users.db";
    qDebug() << "Database path:" << m_dbPath;
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen())
        m_db.close();
}

bool DatabaseManager::initializeDatabase()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_dbPath);

    if (!m_db.open()) {
        qCritical() << "Error: connection with database failed";
        return false;
    }

    QSqlQuery query;
    query.prepare("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT UNIQUE, password TEXT)");

    if (!query.exec()) {
        qCritical() << "Error creating table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::registerUser(const QString &name, const QString &email, const QString &password)
{
    if (!m_db.isOpen() && !m_db.open()) {
        qCritical() << "Database is not open";
        return false;
    }

    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT * FROM users WHERE email = (:email)");
    checkQuery.bindValue(":email", email);

    if (checkQuery.exec()) {
        if (checkQuery.next()) {
            qDebug() << "Email already exists";
            return false;
        }
    } else {
        qCritical() << "Error checking existing user:" << checkQuery.lastError().text();
        return false;
    }

    QSqlQuery insertQuery;
    insertQuery.prepare("INSERT INTO users (name, email, password) VALUES (:name, :email, :password)");
    insertQuery.bindValue(":name", name);
    insertQuery.bindValue(":email", email);

    QByteArray hashedPassword = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
    insertQuery.bindValue(":password", hashedPassword.toHex());

    if (insertQuery.exec()) {
        qDebug() << "User registered successfully";
        return true;
    } else {
        qCritical() << "Error registering user:" << insertQuery.lastError().text();
        return false;
    }
}

bool DatabaseManager::loginUser(const QString &email, const QString &password)
{
    if (!m_db.isOpen() && !m_db.open()) {
        qCritical() << "Database is not open";
        return false;
    }

    QSqlQuery query;
    query.prepare("SELECT password FROM users WHERE email = (:email)");
    query.bindValue(":email", email);

    if (query.exec()) {
        if (query.next()) {
            QByteArray storedPassword = query.value(0).toByteArray();
            QByteArray hashedPassword = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);

            return (storedPassword == hashedPassword.toHex());
        } else {
            qDebug() << "User not found";
            return false;
        }
    } else {
        qCritical() << "Error during login:" << query.lastError().text();
        return false;
    }
}
