#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{
    initDatabase();
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
    QDir().mkpath(dbPath);
    dbPath += "/memolinkmemo2.db";
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);
    if (!openDatabase()) {
        return false;
    }

    QSqlQuery query(m_db);
    query.exec("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT UNIQUE, password TEXT)");
    query.exec("CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, content TEXT, is_deleted BOOLEAN DEFAULT 0, FOREIGN KEY(user_id) REFERENCES users(id))");
    query.exec("CREATE TABLE IF NOT EXISTS todolist (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, task TEXT, completed BOOLEAN, priority TEXT, deadline TEXT, FOREIGN KEY(user_id) REFERENCES users(id))");
    ensureNotesTableStructure();
    return true;
}

bool DatabaseManager::openDatabase()
{
    if (m_db.isOpen()) {
        return true;
    }
    return m_db.open();
}

bool DatabaseManager::registerUser(const QString &name, const QString &email, const QString &password)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO users (name, email, password) VALUES (:name, :email, :password)");
    query.bindValue(":name", name);
    query.bindValue(":email", email);
    query.bindValue(":password", password);
    return query.exec();
}

int DatabaseManager::loginUser(const QString &email, const QString &password)
{
    if (!openDatabase()) {
        return -1;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT id FROM users WHERE email = :email AND password = :password");
    query.bindValue(":email", email);
    query.bindValue(":password", password);
    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    return -1;
}

bool DatabaseManager::saveNote(int userId, const QString &title, const QString &content)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO notes (user_id, title, content, is_deleted) VALUES (:userId, :title, :content, 0)");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    query.bindValue(":content", content);
    return query.exec();
}

bool DatabaseManager::updateNote(int userId, const QString &oldTitle, const QString &newTitle, const QString &content)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("UPDATE notes SET title = :newTitle, content = :content WHERE user_id = :userId AND title = :oldTitle AND is_deleted = 0");
    query.bindValue(":userId", userId);
    query.bindValue(":oldTitle", oldTitle);
    query.bindValue(":newTitle", newTitle);
    query.bindValue(":content", content);
    return query.exec();
}

QVariantList DatabaseManager::getAllNotes(int userId)
{
    QVariantList notes;
    if (!openDatabase()) {
        return notes;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT title, content FROM notes WHERE user_id = :userId AND is_deleted = 0");
    query.bindValue(":userId", userId);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap note;
            note["title"] = query.value(0).toString();
            note["content"] = query.value(1).toString();
            notes.append(note);
        }
    }
    return notes;
}

QVariantList DatabaseManager::getDeletedNotes(int userId)
{
    QVariantList notes;
    if (!openDatabase()) {
        return notes;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT title, content FROM notes WHERE user_id = :userId AND is_deleted = 1");
    query.bindValue(":userId", userId);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap note;
            note["title"] = query.value(0).toString();
            note["content"] = query.value(1).toString();
            notes.append(note);
        }
    }
    return notes;
}

bool DatabaseManager::deleteNote(int userId, const QString &title)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("UPDATE notes SET is_deleted = 1 WHERE user_id = :userId AND title = :title");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    return query.exec();
}

bool DatabaseManager::recoverNote(int userId, const QString &title)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("UPDATE notes SET is_deleted = 0 WHERE user_id = :userId AND title = :title");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    return query.exec();
}

bool DatabaseManager::emptyTrash(int userId)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM notes WHERE user_id = :userId AND is_deleted = 1");
    query.bindValue(":userId", userId);
    return query.exec();
}

bool DatabaseManager::saveTodoList(int userId, const QString &todoListJson)
{
    if (!openDatabase()) {
        return false;
    }

    QJsonDocument jsonDoc = QJsonDocument::fromJson(todoListJson.toUtf8());
    QJsonArray todoArray = jsonDoc.array();

    m_db.transaction();

    QSqlQuery insertQuery(m_db);
    insertQuery.prepare("INSERT INTO todolist (user_id, task, completed, priority, deadline) VALUES (?, ?, ?, ?, ?)");

    for (const QJsonValue &value : todoArray) {
        QJsonObject item = value.toObject();
        insertQuery.addBindValue(userId);
        insertQuery.addBindValue(item["task"].toString());
        insertQuery.addBindValue(item["completed"].toBool());
        insertQuery.addBindValue(item["priority"].toString());
        insertQuery.addBindValue(item["deadline"].toString());

        if (!insertQuery.exec()) {
            m_db.rollback();
            return false;
        }
    }

    return m_db.commit();
}

QString DatabaseManager::getTodoList(int userId)
{
    if (!openDatabase()) {
        return QString();
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT task, completed, priority, deadline FROM todolist WHERE user_id = :userId");
    query.bindValue(":userId", userId);

    if (!query.exec()) {
        return QString();
    }

    QJsonArray todoArray;
    while (query.next()) {
        QJsonObject item;
        item["task"] = query.value("task").toString();
        item["completed"] = query.value("completed").toBool();
        item["priority"] = query.value("priority").toString();
        item["deadline"] = query.value("deadline").toString();
        todoArray.append(item);
    }

    QJsonDocument jsonDoc(todoArray);
    return QString(jsonDoc.toJson());
}

bool DatabaseManager::ensureNotesTableStructure()
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.exec("PRAGMA table_info(notes)");
    QStringList columns;
    while (query.next()) {
        columns << query.value(1).toString();
    }
    if (!columns.contains("is_deleted")) {
        return query.exec("ALTER TABLE notes ADD COLUMN is_deleted BOOLEAN DEFAULT 0");
    }
    return true;
}

bool DatabaseManager::permanentlyDeleteNote(int userId, const QString &title)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM notes WHERE user_id = :userId AND title = :title AND is_deleted = 1");
    query.bindValue(":userId", userId);
    query.bindValue(":title", title);
    return query.exec();
}

QString DatabaseManager::getUsername(int userId)
{
    if (!openDatabase()) {
        return QString();
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT name FROM users WHERE id = :userId");
    query.bindValue(":userId", userId);
    if (query.exec() && query.next()) {
        return query.value(0).toString();
    }
    return QString();
}

QString DatabaseManager::getUserEmail(int userId)
{
    if (!openDatabase()) {
        return QString();
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT email FROM users WHERE id = :userId");
    query.bindValue(":userId", userId);
    if (query.exec() && query.next()) {
        return query.value(0).toString();
    }
    return QString();
}

bool DatabaseManager::changePassword(int userId, const QString &currentPassword, const QString &newPassword)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("UPDATE users SET password = :newPassword WHERE id = :userId AND password = :currentPassword");
    query.bindValue(":userId", userId);
    query.bindValue(":currentPassword", currentPassword);
    query.bindValue(":newPassword", newPassword);
    return query.exec() && query.numRowsAffected() > 0;
}

bool DatabaseManager::deleteAccount(int userId)
{
    if (!openDatabase()) {
        return false;
    }
    m_db.transaction();
    QSqlQuery query(m_db);

    query.prepare("DELETE FROM notes WHERE user_id = :userId");
    query.bindValue(":userId", userId);
    if (!query.exec()) {
        m_db.rollback();
        return false;
    }

    query.prepare("DELETE FROM todolist WHERE user_id = :userId");
    query.bindValue(":userId", userId);
    if (!query.exec()) {
        m_db.rollback();
        return false;
    }

    query.prepare("DELETE FROM users WHERE id = :userId");
    query.bindValue(":userId", userId);
    if (!query.exec()) {
        m_db.rollback();
        return false;
    }

    return m_db.commit();
}

int DatabaseManager::getTotalNotes(int userId)
{
    if (!openDatabase()) {
        return 0;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT COUNT(*) FROM notes WHERE user_id = :userId AND is_deleted = 0");
    query.bindValue(":userId", userId);
    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}

int DatabaseManager::getCompletedTasks(int userId)
{
    if (!openDatabase()) {
        return 0;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT COUNT(*) FROM todolist WHERE user_id = :userId AND completed = 1");
    query.bindValue(":userId", userId);
    if (query.exec() && query.next()) {
        return query.value(0).toInt();
    }
    return 0;
}

bool DatabaseManager::verifyPassword(int userId, const QString &password)
{
    if (!openDatabase()) {
        return false;
    }
    QSqlQuery query(m_db);
    query.prepare("SELECT COUNT(*) FROM users WHERE id = :userId AND password = :password");
    query.bindValue(":userId", userId);
    query.bindValue(":password", password);
    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
    }
    return false;
}
