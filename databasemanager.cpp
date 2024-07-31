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
        qDebug() << "Error creating users table:" << query.lastError().text();
        return false;
    }
    if (!query.exec("CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, content TEXT, is_deleted BOOLEAN DEFAULT 0, FOREIGN KEY(user_id) REFERENCES users(id))")) {
        qDebug() << "Error creating notes table:" << query.lastError().text();
        return false;
    }
    if (!query.exec("CREATE TABLE IF NOT EXISTS todolist (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, content TEXT, FOREIGN KEY(user_id) REFERENCES users(id))")) {
        qDebug() << "Error creating todolist table:" << query.lastError().text();
        return false;
    }
    if (!ensureNotesTableStructure()) {
        qDebug() << "Failed to ensure notes table structure";
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

int DatabaseManager::loginUser(const QString &email, const QString &password)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return -1;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT id FROM users WHERE email = :email AND password = :password");
    query.bindValue(":email", email);
    query.bindValue(":password", password);  // Note: In a real app, you should hash the password and compare hashes
    if (!query.exec()) {
        qDebug() << "Error logging in user:" << query.lastError().text();
        return -1;
    }
    if (query.next()) {
        return query.value(0).toInt();  // Return user ID
    }
    return -1;  // User not found or invalid credentials
}

bool DatabaseManager::saveNote(int userId, const QString &title, const QString &content)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO notes (user_id, title, content, is_deleted) VALUES (:userId, :title, :content, 0)");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    query.bindValue(":content", content);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error saving note:" << query.lastError().text();
        return false;
    }
    qDebug() << "Note saved successfully for user" << userId << "with title:" << title;
    return true;
}

QVariantList DatabaseManager::getAllNotes(int userId)
{
    QVariantList notes;
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return notes;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT title, content FROM notes WHERE user_id = :userId AND is_deleted = 0");
    query.bindValue(":userId", userId);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error fetching notes:" << query.lastError().text();
        return notes;
    }
    while (query.next()) {
        QVariantMap note;
        note["title"] = query.value(0).toString();
        note["content"] = query.value(1).toString();
        notes.append(note);
        qDebug() << "Fetched note:" << note["title"].toString() << note["content"].toString();
    }
    qDebug() << "Fetched" << notes.size() << "notes for user" << userId;
    return notes;
}

QVariantList DatabaseManager::getDeletedNotes(int userId)
{
    QVariantList notes;
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return notes;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT title, content FROM notes WHERE user_id = :userId AND is_deleted = 1");
    query.bindValue(":userId", userId);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error fetching deleted notes:" << query.lastError().text();
        return notes;
    }
    while (query.next()) {
        QVariantMap note;
        note["title"] = query.value(0).toString();
        note["content"] = query.value(1).toString();
        notes.append(note);
        qDebug() << "Fetched deleted note:" << note["title"].toString() << note["content"].toString();
    }
    qDebug() << "Fetched" << notes.size() << "deleted notes for user" << userId;
    return notes;
}

bool DatabaseManager::deleteNote(int userId, const QString &title)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("UPDATE notes SET is_deleted = 1 WHERE user_id = :userId AND title = :title");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error deleting note:" << query.lastError().text();
        return false;
    }
    qDebug() << "Note deleted (marked as deleted) for user" << userId << "with title:" << title;
    return true;
}

bool DatabaseManager::recoverNote(int userId, const QString &title)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("UPDATE notes SET is_deleted = 0 WHERE user_id = :userId AND title = :title");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error recovering note:" << query.lastError().text();
        return false;
    }
    qDebug() << "Note recovered for user" << userId << "with title:" << title;
    return true;
}

bool DatabaseManager::emptyTrash(int userId)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM notes WHERE user_id = :userId AND is_deleted = 1");
    query.bindValue(":userId", userId);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error emptying trash:" << query.lastError().text();
        return false;
    }
    qDebug() << "Trash emptied for user" << userId;
    return true;
}

bool DatabaseManager::saveTodoList(int userId, const QString &todoListJson)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("INSERT OR REPLACE INTO todolist (user_id, content) VALUES (:userId, :content)");
    query.bindValue(":userId", userId);
    query.bindValue(":content", todoListJson);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error saving todo list:" << query.lastError().text();
        return false;
    }
    qDebug() << "Todo list saved for user" << userId;
    return true;
}

QString DatabaseManager::getTodoList(int userId)
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return QString();
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT content FROM todolist WHERE user_id = :userId");
    query.bindValue(":userId", userId);
    qDebug() << "Query prepared:" << query.lastQuery();
    qDebug() << "Bound values:" << query.boundValues();
    if (!query.exec()) {
        qDebug() << "Error fetching todo list:" << query.lastError().text();
        return QString();
    }
    if (query.next()) {
        return query.value(0).toString();
    }
    return QString();
}

bool DatabaseManager::ensureNotesTableStructure()
{
    if (!openDatabase()) {
        qDebug() << "Database is not open";
        return false;
    }
    QSqlQuery query(m_db);
    if (!query.exec("PRAGMA table_info(notes)")) {
        qDebug() << "Error getting table info:" << query.lastError().text();
        return false;
    }
    QStringList columns;
    while (query.next()) {
        columns << query.value(1).toString();
    }
    if (!columns.contains("is_deleted")) {
        if (!query.exec("ALTER TABLE notes ADD COLUMN is_deleted BOOLEAN DEFAULT 0")) {
            qDebug() << "Error adding is_deleted column:" << query.lastError().text();
            return false;
        }
        qDebug() << "Added is_deleted column to notes table";
    }
    return true;
}
