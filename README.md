Memolink
Memolink is a note-taking and to-do list application built using Qt and QML. It allows users to register, log in, create, update, delete, and recover notes, as well as manage to-do lists.

Features
User registration and login
Create, update, delete, and recover notes
Manage to-do lists with tasks, priorities, and deadlines
View account statistics and change password
Delete account
Installation
Clone the repository:
git clone <repository-url>
Open the project in Qt Creator.
Build and run the project.
Usage
User Registration
Open the application.
Click on the "Sign Up" button.
Fill in the required fields (Full Name, Email, Password, Confirm Password).
Click on the "Sign Up" button to create an account.
User Login
Open the application.
Click on the "Login" button.
Enter your email and password.
Click on the "Login" button to log in.
Notes Management
To create a new note, enter the title and content in the respective fields and click on the "Save Note" button.
To update an existing note, select the note from the list, make the necessary changes, and click on the "Save Note" button.
To delete a note, select the note from the list and click on the "Delete Note" button.
To recover a deleted note, switch to the "Deleted Files" view, select the note, and click on the "Recover Note" button.
To permanently delete a note, switch to the "Deleted Files" view, select the note, and click on the "Delete Permanently" button.
To empty the trash, switch to the "Deleted Files" view and click on the "Empty Trash" button.
To-Do List Management
To add a new task, enter the task description, select the priority, and enter the deadline. Click on the "Add" button.
To mark a task as completed, check the checkbox next to the task.
To delete a task, click on the "Delete" button next to the task.
To save the to-do list, click on the "Save To-Do List" button.
Account Management
To view account statistics, navigate to the "About Me" page.
To change your password, enter the current password, new password, and confirm the new password. Click on the "Change Password" button.
To delete your account, enter your password and click on the "Delete Account" button.
File Structure

databasemanager.cpp
 (
databasemanager.cpp
): Contains the implementation of the DatabaseManager class, which handles database operations.

databasemanager.h
 (
databasemanager.h
): Contains the declaration of the DatabaseManager class.

LoginPage.qml
 (
LoginPage.qml
): QML file for the login page.

main.cpp
 (
main.cpp
): Entry point of the application.

MainView.qml
 (
MainView.qml
): QML file for the main view of the application.

MainWindow.qml
 (
MainWindow.qml
): QML file for the main window of the application.

memolink.pro
 (
memolink.pro
): Project file for the application.

SignUpPage.qml
 (
SignUpPage.qml
): QML file for the sign-up page.
