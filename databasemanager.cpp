#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    if (!initDatabase()) {
        qDebug() << "Failed to initialize database";
    }
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initDatabase()
{
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dbPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    dbPath += "/memolinkmemo2.db";
    qDebug() << "Database path:" << dbPath;

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!openDatabase()) {
        return false;
    }

    QSqlQuery query(m_db);
    if (!query.exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT UNIQUE, password TEXT)")) {
        qDebug() << "Error creating table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::openDatabase()
{
    if (m_db.isOpen()) {
        return true;
    }

    if (!m_db.open()) {
        qDebug() << "Error opening database:" << m_db.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::registerUser(const QString &name, const QString &email, const QString &password)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO users (name, email, password) VALUES (:name, :email, :password)");
    query.bindValue(":name", name);
    query.bindValue(":email", email);
    query.bindValue(":password", password);  // Note: In a real app, you should hash the password

    if (!query.exec()) {
        qDebug() << "Error registering user:" << query.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::loginUser(const QString &email, const QString &password)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT * FROM users WHERE email = :email AND password = :password");
    query.bindValue(":email", email);
    query.bindValue(":password", password);  // Note: In a real app, you should hash the password and compare hashes

    if (!query.exec()) {
        qDebug() << "Error logging in user:" << query.lastError().text();
        return false;
    }

    return query.next();  // Returns true if a matching user was found
}
