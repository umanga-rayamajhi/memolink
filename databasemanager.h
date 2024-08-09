#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QVariantList>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool registerUser(const QString &name, const QString &email, const QString &password);
    Q_INVOKABLE int loginUser(const QString &email, const QString &password);
    Q_INVOKABLE bool saveNote(int userId, const QString &title, const QString &content);
    Q_INVOKABLE bool updateNote(int userId, const QString &oldTitle, const QString &newTitle, const QString &content);
    Q_INVOKABLE QVariantList getAllNotes(int userId);
    Q_INVOKABLE QVariantList getDeletedNotes(int userId);
    Q_INVOKABLE bool deleteNote(int userId, const QString &title);
    Q_INVOKABLE bool recoverNote(int userId, const QString &title);
    Q_INVOKABLE bool emptyTrash(int userId);
    Q_INVOKABLE bool saveTodoList(int userId, const QString &todoListJson);
    Q_INVOKABLE QString getTodoList(int userId);
    Q_INVOKABLE bool permanentlyDeleteNote(int userId, const QString &title);

private:
    QSqlDatabase m_db;
    bool initDatabase();
    bool openDatabase();
    bool ensureNotesTableStructure();
};
