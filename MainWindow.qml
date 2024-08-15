import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: mainwindow
    title: "MemoLink"

    property color accentColor: "#64FFDA"
    property color textColor: "#CCD6F6"
    property color lightBackgroundColor: "#F8F8F8"
    property string fontFamily: "Roboto"
    property bool isLoggedIn: false
    property var dbManager
    property int currentUserId: -1
    property bool showingDeletedFiles: false
    property bool editingExistingNote: false
    property string originalTitle: ""

    background: Rectangle {
        color: "#0A192F"  // Dark blue background
    }

    ListModel { id: savedFilesModel }
    ListModel { id: deletedFilesModel }

    Drawer {
        id: sidebar
        width: 200
        height: parent.height
        edge: Qt.LeftEdge
        modal: true

        background: Rectangle {
            color: "#172A45"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 10

            Label {
                text: "Menu"
                font.family: fontFamily
                font.pixelSize: 20
                color: accentColor
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
            }

            Repeater {
                model: ["Notes", "To-Do List", "About Me"]
                delegate: Button {
                    text: modelData
                    font.family: fontFamily
                    font.pixelSize: 16
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    onClicked: {
                        stackLayout.currentIndex = index
                        sidebar.close()
                    }
                    background: Rectangle {
                        color: stackLayout.currentIndex === index ? accentColor : "transparent"
                        radius: 5
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: stackLayout.currentIndex === index ? "#172A45" : textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Button {
                text: "Log Out"
                font.family: fontFamily
                font.pixelSize: 16
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.bottomMargin: 10
                onClicked: {
                    logOut()
                    sidebar.close()
                }
                background: Rectangle {
                    color: "transparent"
                    border.color: accentColor
                    border.width: 1
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Navbar
        Rectangle {
            Layout.fillWidth: true
            height: 70
            color: "#172A45"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10

                Button {
                    text: "☰"
                    onClicked: sidebar.open()
                    font.pixelSize: 24
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: accentColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    text: "MEMOLINK"
                    font.family: fontFamily
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: accentColor
                }

                Item { Layout.fillWidth: true }
            }
        }

        // Main content area
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Notes Page
            RowLayout {
                spacing: 0

                // Side panel
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.25
                    Layout.fillHeight: true
                    color: "#172A45"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Label {
                                text: showingDeletedFiles ? "Deleted Files" : "Saved Files"
                                font.family: fontFamily
                                font.pixelSize: 20
                                color: accentColor
                            }

                            Button {
                                text: "▼"
                                onClicked: showingDeletedFiles = !showingDeletedFiles
                                background: Rectangle {
                                    color: "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.family: fontFamily
                                    font.pixelSize: 16
                                    color: accentColor
                                }
                            }
                        }

                        ListView {
                            id: filesList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: showingDeletedFiles ? deletedFilesModel : savedFilesModel
                            delegate: ItemDelegate {
                                width: parent.width
                                height: 40

                                background: Rectangle {
                                    color: "transparent"
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: 1
                                        color: Qt.rgba(textColor.r, textColor.g, textColor.b, 0.1)
                                    }
                                }

                                contentItem: Text {
                                    text: title
                                    font.family: fontFamily
                                    font.pixelSize: 16
                                    color: textColor
                                    verticalAlignment: Text.AlignVCenter
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.background.color = Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2)
                                    onExited: parent.background.color = "transparent"
                                    onClicked: {
                                        titleField.text = title
                                        notesTextArea.text = content
                                        editingExistingNote = true
                                        originalTitle = title
                                    }
                                }
                            }
                        }

                        Button {
                            visible: showingDeletedFiles
                            text: "Empty Trash"
                            onClicked: emptyTrash()
                            Layout.fillWidth: true
                            background: Rectangle {
                                color: "transparent"
                                border.color: accentColor
                                border.width: 1
                                radius: 5
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: fontFamily
                                font.pixelSize: 16
                                color: accentColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Notes area
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    anchors.margins: 20

                    TextField {
                        id: titleField
                        Layout.fillWidth: true
                        placeholderText: "Title"
                        font.family: fontFamily
                        font.pixelSize: 24
                        color: "#2c3e50"
                        background: Rectangle {
                            color: lightBackgroundColor
                            radius: 5
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        TextArea {
                            id: notesTextArea
                            width: parent.width
                            placeholderText: "Notes..."
                            font.family: fontFamily
                            font.pixelSize: 18
                            color: "#2c3e50"
                            background: Rectangle {
                                color: lightBackgroundColor
                                radius: 5
                            }
                            wrapMode: TextEdit.Wrap
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        spacing: 10

                        Button {
                            text: showingDeletedFiles ? "Delete Permanently" : "New Note"
                            onClicked: showingDeletedFiles ? permanentlyDeleteNote() : newNote()
                            background: Rectangle {
                                color: "transparent"
                                border.color: accentColor
                                border.width: 1
                                radius: 5
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: fontFamily
                                font.pixelSize: 16
                                color: accentColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: showingDeletedFiles ? "Recover Note" : "Delete Note"
                            onClicked: showingDeletedFiles ? recoverNote() : deleteNote()
                            background: Rectangle {
                                color: "transparent"
                                border.color: accentColor
                                border.width: 1
                                radius: 5
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: fontFamily
                                font.pixelSize: 16
                                color: accentColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            visible: !showingDeletedFiles
                            text: "Save Note"
                            onClicked: saveNote()
                            background: Rectangle {
                                color: accentColor
                                radius: 5
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: fontFamily
                                font.pixelSize: 16
                                color: "#172A45"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            // To-Do List Page
            Rectangle {
                color: "#172A45"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    Label {
                        text: "To-Do List"
                        font.family: fontFamily
                        font.pixelSize: 24
                        color: accentColor
                    }

                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true

                        TextField {
                            id: todoInput
                            Layout.fillWidth: true
                            placeholderText: "Add a new task"
                            font.family: fontFamily
                            font.pixelSize: 16
                            color: "#2c3e50"
                            background: Rectangle {
                                color: lightBackgroundColor
                                radius: 5
                            }
                        }

                        ComboBox {
                            id: priorityCombo
                            model: ["Select Priority", "Low", "Medium", "High"]
                            currentIndex: 0
                            font.family: fontFamily
                            font.pixelSize: 16
                            Layout.preferredWidth: 150
                            onCurrentIndexChanged: {
                                if (currentIndex === 0) {
                                    currentIndex = -1  // This will show the placeholder text
                                }
                            }
                        }

                        TextField {
                            id: deadlineInput
                            placeholderText: "YYYY-MM-DD"
                            font.family: fontFamily
                            font.pixelSize: 16
                            color: "#2c3e50"
                            Layout.preferredWidth: 120
                            background: Rectangle {
                                color: lightBackgroundColor
                                radius: 5
                            }
                        }

                        Button {
                            text: "Add"
                            onClicked: {
                                if (todoInput.text.trim() !== "" && priorityCombo.currentIndex > 0) {
                                    todoListModel.append({
                                        task: todoInput.text,
                                        completed: false,
                                        priority: priorityCombo.currentText,
                                        deadline: deadlineInput.text
                                    })
                                    todoInput.text = ""
                                    priorityCombo.currentIndex = 0
                                    deadlineInput.text = ""
                                }
                            }
                            background: Rectangle {
                                color: accentColor
                                radius: 5
                            }
                            contentItem: Text {
                                text: parent.text
                                font.family: fontFamily
                                font.pixelSize: 16
                                color: "#172A45"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            anchors.fill: parent
                            model: ListModel { id: todoListModel }
                            delegate: Rectangle {
                                width: parent.width
                                height: 50
                                color: index % 2 === 0 ? "#1F2A3C" : "#172A45"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    CheckBox {
                                        checked: completed
                                        onCheckedChanged: {
                                            todoListModel.setProperty(index, "completed", checked)
                                        }
                                    }

                                    Text {
                                        text: task
                                        font.family: fontFamily
                                        font.pixelSize: 16
                                        color: completed ? Qt.rgba(textColor.r, textColor.g, textColor.b, 0.5) : textColor
                                        font.strikeout: completed
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: priority
                                        font.family: fontFamily
                                        font.pixelSize: 14
                                        color: {
                                            switch(priority) {
                                                case "Low": return "green"
                                                case "Medium": return "orange"
                                                case "High": return "red"
                                                default: return textColor
                                            }
                                        }
                                        Layout.preferredWidth: 60
                                    }

                                    Text {
                                        text: deadline
                                        font.family: fontFamily
                                        font.pixelSize: 14
                                        color: textColor
                                        Layout.preferredWidth: 100
                                    }

                                    Button {
                                        text: "Delete"
                                        onClicked: todoListModel.remove(index)
                                                                                background: Rectangle {
                                                                                    color: "transparent"
                                                                                    border.color: accentColor
                                                                                    border.width: 1
                                                                                    radius: 5
                                                                                }
                                                                                contentItem: Text {
                                                                                    text: parent.text
                                                                                    font.family: fontFamily
                                                                                    font.pixelSize: 14
                                                                                    color: accentColor
                                                                                    horizontalAlignment: Text.AlignHCenter
                                                                                    verticalAlignment: Text.AlignVCenter
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }

                                                            Button {
                                                                text: "Save To-Do List"
                                                                Layout.alignment: Qt.AlignRight
                                                                onClicked: saveTodoList()
                                                                background: Rectangle {
                                                                    color: accentColor
                                                                    radius: 5
                                                                }
                                                                contentItem: Text {
                                                                    text: parent.text
                                                                    font.family: fontFamily
                                                                    font.pixelSize: 16
                                                                    color: "#172A45"
                                                                    horizontalAlignment: Text.AlignHCenter
                                                                    verticalAlignment: Text.AlignVCenter
                                                                }
                                                            }
                                                        }
                                                    }

                                                    // About Me Page
                                                    Rectangle {
                                                        color: "#172A45"

                                                        RowLayout {
                                                            anchors.fill: parent
                                                            spacing: 20

                                                            // Left side: User Info and Account Statistics
                                                            ColumnLayout {
                                                                Layout.fillHeight: true
                                                                Layout.preferredWidth: parent.width / 2
                                                                Layout.margins: 20
                                                                spacing: 20

                                                                Label {
                                                                    text: "About Me"
                                                                    font.family: fontFamily
                                                                    font.pixelSize: 24
                                                                    color: accentColor
                                                                }

                                                                // User Info Section
                                                                ColumnLayout {
                                                                    Layout.fillWidth: true
                                                                    spacing: 10

                                                                    Label {
                                                                        text: "User Information"
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 18
                                                                        color: textColor
                                                                    }

                                                                    Text {
                                                                        text: "Username: " + dbManager.getUsername(currentUserId)
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: textColor
                                                                    }

                                                                    Text {
                                                                        text: "Email: " + dbManager.getUserEmail(currentUserId)
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: textColor
                                                                    }
                                                                }

                                                                // Account Statistics Section
                                                                ColumnLayout {
                                                                    Layout.fillWidth: true
                                                                    spacing: 10

                                                                    Label {
                                                                        text: "Account Statistics"
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 18
                                                                        color: textColor
                                                                    }

                                                                    Text {
                                                                        text: "Total Notes: " + dbManager.getTotalNotes(currentUserId)
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: textColor
                                                                    }

                                                                    Text {
                                                                        text: "Completed Tasks: " + dbManager.getCompletedTasks(currentUserId)
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: textColor
                                                                    }
                                                                }
                                                            }

                                                            // Right side: Change Password and Delete Account
                                                            ColumnLayout {
                                                                Layout.fillHeight: true
                                                                Layout.preferredWidth: parent.width / 2
                                                                Layout.margins: 20
                                                                spacing: 20

                                                                // Change Password Section
                                                                ColumnLayout {
                                                                    Layout.fillWidth: true
                                                                    spacing: 10

                                                                    Label {
                                                                        text: "Change Password"
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 18
                                                                        color: textColor
                                                                    }

                                                                    TextField {
                                                                        id: currentPasswordField
                                                                        Layout.fillWidth: true
                                                                        placeholderText: "Current Password"
                                                                        echoMode: TextInput.Password
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: "#2c3e50"
                                                                        background: Rectangle {
                                                                            color: lightBackgroundColor
                                                                            radius: 5
                                                                        }
                                                                    }

                                                                    TextField {
                                                                        id: newPasswordField
                                                                        Layout.fillWidth: true
                                                                        placeholderText: "New Password"
                                                                        echoMode: TextInput.Password
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: "#2c3e50"
                                                                        background: Rectangle {
                                                                            color: lightBackgroundColor
                                                                            radius: 5
                                                                        }
                                                                    }

                                                                    TextField {
                                                                        id: confirmNewPasswordField
                                                                        Layout.fillWidth: true
                                                                        placeholderText: "Confirm New Password"
                                                                        echoMode: TextInput.Password
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: "#2c3e50"
                                                                        background: Rectangle {
                                                                            color: lightBackgroundColor
                                                                            radius: 5
                                                                        }
                                                                    }

                                                                    Button {
                                                                        text: "Change Password"
                                                                        Layout.fillWidth: true
                                                                        onClicked: changePassword()
                                                                        background: Rectangle {
                                                                            color: accentColor
                                                                            radius: 5
                                                                        }
                                                                        contentItem: Text {
                                                                            text: parent.text
                                                                            font.family: fontFamily
                                                                            font.pixelSize: 16
                                                                            color: "#172A45"
                                                                            horizontalAlignment: Text.AlignHCenter
                                                                            verticalAlignment: Text.AlignVCenter
                                                                        }
                                                                    }
                                                                }

                                                                // Delete Account Section
                                                                ColumnLayout {
                                                                    Layout.fillWidth: true
                                                                    spacing: 10

                                                                    Label {
                                                                        text: "Delete Account"
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 18
                                                                        color: textColor
                                                                    }

                                                                    Text {
                                                                        text: "Warning: This action cannot be undone. All your data will be permanently deleted."
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 14
                                                                        color: "red"
                                                                        wrapMode: Text.Wrap
                                                                        Layout.fillWidth: true
                                                                    }

                                                                    TextField {
                                                                        id: deleteAccountPasswordField
                                                                        Layout.fillWidth: true
                                                                        placeholderText: "Enter your password to confirm"
                                                                        echoMode: TextInput.Password
                                                                        font.family: fontFamily
                                                                        font.pixelSize: 16
                                                                        color: "#2c3e50"
                                                                        background: Rectangle {
                                                                            color: lightBackgroundColor
                                                                            radius: 5
                                                                        }
                                                                    }

                                                                    Button {
                                                                        text: "Delete Account"
                                                                        Layout.fillWidth: true
                                                                        onClicked: deleteAccount()
                                                                        background: Rectangle {
                                                                            color: "red"
                                                                            radius: 5
                                                                        }
                                                                        contentItem: Text {
                                                                            text: parent.text
                                                                            font.family: fontFamily
                                                                            font.pixelSize: 16
                                                                            color: "white"
                                                                            horizontalAlignment: Text.AlignHCenter
                                                                            verticalAlignment: Text.AlignVCenter
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            function newNote() {
                                                titleField.text = ""
                                                notesTextArea.text = ""
                                                editingExistingNote = false
                                                originalTitle = ""
                                            }

                                            function saveNote() {
                                                if (titleField.text.trim() !== "") {
                                                    var success;
                                                    if (editingExistingNote) {
                                                        success = dbManager.updateNote(currentUserId, originalTitle, titleField.text, notesTextArea.text);
                                                        console.log("Note update attempt. Success:", success, "Title:", titleField.text);
                                                    } else {
                                                        success = dbManager.saveNote(currentUserId, titleField.text, notesTextArea.text);
                                                        console.log("New note save attempt. Success:", success, "Title:", titleField.text);
                                                    }
                                                    loadNotes();
                                                    titleField.text = "";
                                                    notesTextArea.text = "";
                                                    editingExistingNote = false;
                                                    originalTitle = "";
                                                }
                                            }

                                            function deleteNote() {
                                                if (titleField.text.trim() !== "") {
                                                    dbManager.deleteNote(currentUserId, titleField.text)
                                                    loadNotes()
                                                    titleField.text = ""
                                                    notesTextArea.text = ""
                                                    editingExistingNote = false
                                                    originalTitle = ""
                                                }
                                            }

                                            function recoverNote() {
                                                if (titleField.text.trim() !== "") {
                                                    dbManager.recoverNote(currentUserId, titleField.text)
                                                    loadNotes()
                                                    titleField.text = ""
                                                    notesTextArea.text = ""
                                                    editingExistingNote = false
                                                    originalTitle = ""
                                                }
                                            }

                                            function permanentlyDeleteNote() {
                                                if (titleField.text.trim() !== "") {
                                                    dbManager.permanentlyDeleteNote(currentUserId, titleField.text)
                                                    loadNotes()
                                                    titleField.text = ""
                                                    notesTextArea.text = ""
                                                    editingExistingNote = false
                                                    originalTitle = ""
                                                }
                                            }

                                            function emptyTrash() {
                                                dbManager.emptyTrash(currentUserId)
                                                loadNotes()
                                            }

                                            function loadNotes() {
                                                console.log("Loading notes for user:", currentUserId);
                                                savedFilesModel.clear();
                                                deletedFilesModel.clear();
                                                var notes = dbManager.getAllNotes(currentUserId);
                                                var deletedNotes = dbManager.getDeletedNotes(currentUserId);
                                                console.log("Received notes:", JSON.stringify(notes));
                                                console.log("Received deleted notes:", JSON.stringify(deletedNotes));
                                                for (var i = 0; i < notes.length; i++) {
                                                    savedFilesModel.append(notes[i]);
                                                    console.log("Appended saved note:", JSON.stringify(notes[i]));
                                                }
                                                for (var i = 0; i < deletedNotes.length; i++) {
                                                    deletedFilesModel.append(deletedNotes[i]);
                                                    console.log("Appended deleted note:", JSON.stringify(deletedNotes[i]));
                                                }
                                                console.log("Loaded", savedFilesModel.count, "saved notes and", deletedFilesModel.count, "deleted notes");
                                            }

                                            function saveTodoList() {
                                                var todoItems = []
                                                for (var i = 0; i < todoListModel.count; i++) {
                                                    todoItems.push({
                                                        task: todoListModel.get(i).task,
                                                        completed: todoListModel.get(i).completed,
                                                        priority: todoListModel.get(i).priority,
                                                        deadline: todoListModel.get(i).deadline
                                                    })
                                                }
                                                var todoListJson = JSON.stringify(todoItems)
                                                console.log("Saving todo list:", todoListJson)
                                                var success = dbManager.saveTodoList(currentUserId, todoListJson)
                                                console.log("Todo list save " + (success ? "successful" : "failed"))
                                            }

                                            function loadTodoList() {
                                                var todoListJson = dbManager.getTodoList(currentUserId)
                                                console.log("Loaded todo list JSON:", todoListJson)
                                                if (todoListJson) {
                                                    try {
                                                        var todoItems = JSON.parse(todoListJson)
                                                        todoListModel.clear()
                                                        for (var i = 0; i < todoItems.length; i++) {
                                                            console.log("Adding item to model:", JSON.stringify(todoItems[i]))
                                                            todoListModel.append(todoItems[i])
                                                        }
                                                        console.log("Todo list loaded successfully:", todoListModel.count, "items")
                                                    } catch (e) {
                                                        console.error("Error parsing todo list JSON:", e)
                                                    }
                                                } else {
                                                    console.log("No todo list found for user")
                                                }
                                            }

                                            function changePassword() {
                                                if (newPasswordField.text !== confirmNewPasswordField.text) {
                                                    showMessage("New passwords do not match.")
                                                    return
                                                }

                                                if (dbManager.changePassword(currentUserId, currentPasswordField.text, newPasswordField.text)) {
                                                    showMessage("Password changed successfully.")
                                                    currentPasswordField.text = ""
                                                    newPasswordField.text = ""
                                                    confirmNewPasswordField.text = ""
                                                } else {
                                                    showMessage("Failed to change password. Please check your current password.")
                                                }
                                            }

                                            function deleteAccount() {
                                                if (dbManager.verifyPassword(currentUserId, deleteAccountPasswordField.text)) {
                                                    if (dbManager.deleteAccount(currentUserId)) {
                                                        showMessage("Account deleted successfully.")
                                                        logOut()
                                                    } else {
                                                        showMessage("Failed to delete account. Please try again.")
                                                    }
                                                } else {
                                                    showMessage("Incorrect password. Account deletion canceled.")
                                                }
                                                deleteAccountPasswordField.text = ""
                                            }

                                            function showMessage(message) {
                                                // Implement a message dialog or toast notification here
                                                console.log(message)
                                            }

                                            function logOut() {
                                                saveTodoList() // Save todo list before logging out
                                                savedFilesModel.clear()
                                                deletedFilesModel.clear()
                                                todoListModel.clear()
                                                titleField.text = ""
                                                notesTextArea.text = ""
                                                editingExistingNote = false
                                                originalTitle = ""

                                                isLoggedIn = false
                                                currentUserId = -1

                                                stackView.push("LoginPage.qml", { dbManager: dbManager })
                                            }

                                            function onLoginSuccessful(userId) {
                                                currentUserId = userId
                                                isLoggedIn = true
                                                loadNotes()
                                                loadTodoList()
                                            }

                                            Component.onCompleted: {
                                                console.log("MainWindow completed. isLoggedIn:", isLoggedIn, "currentUserId:", currentUserId);
                                                if (isLoggedIn && currentUserId !== -1) {
                                                    loadNotes();
                                                    loadTodoList();
                                                } else {
                                                    stackView.replace("LoginPage.qml", { dbManager: dbManager });
                                                }
                                            }
                                        }
