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

    background: Rectangle {
        color: "#0A192F"  // Dark blue background
    }

    ListModel { id: savedFilesModel }
    ListModel { id: deletedFilesModel }

    Drawer {
        id: sidebar
        width: 250
        height: parent.height
        edge: Qt.LeftEdge
        modal: true

        background: Rectangle {
            color: "#172A45"  // Slightly lighter blue for sidebar
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 20

            Label {
                text: "Menu"
                font.family: fontFamily
                font.pixelSize: 24
                color: accentColor
            }

            Button {
                text: "Notes"
                font.family: fontFamily
                font.pixelSize: 18
                Layout.fillWidth: true
                onClicked: {
                    stackLayout.currentIndex = 0
                    sidebar.close()
                }
                background: Rectangle {
                    color: stackLayout.currentIndex === 0 ? accentColor : "transparent"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: stackLayout.currentIndex === 0 ? "#172A45" : textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "To-Do List"
                font.family: fontFamily
                font.pixelSize: 18
                Layout.fillWidth: true
                onClicked: {
                    stackLayout.currentIndex = 1
                    sidebar.close()
                }
                background: Rectangle {
                    color: stackLayout.currentIndex === 1 ? accentColor : "transparent"
                    radius: 5
                }
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: stackLayout.currentIndex === 1 ? "#172A45" : textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "Log Out"
                font.family: fontFamily
                font.pixelSize: 18
                Layout.fillWidth: true
                onClicked: {
                    logOut()
                    sidebar.close()
                }
                background: Rectangle {
                    color: "transparent"
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
            color: "#172A45"  // Slightly lighter blue for navbar

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
                    color: "#172A45"  // Slightly lighter blue for side panel

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
                                        if (!showingDeletedFiles) {
                                            titleField.text = title
                                            notesTextArea.text = content
                                        }
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
                            text: "Delete Note"
                            onClicked: deleteNote()
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

                    Row {
                        spacing: 10
                        TextField {
                            id: todoInput
                            width: 300
                            placeholderText: "Add a new task"
                            font.family: fontFamily
                            font.pixelSize: 16
                            color: "#2c3e50"
                            background: Rectangle {
                                color: lightBackgroundColor
                                radius: 5
                            }
                        }
                        Button {
                            text: "Add"
                            onClicked: {
                                if (todoInput.text.trim() !== "") {
                                    todoListModel.append({task: todoInput.text, completed: false})
                                    todoInput.text = ""
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

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: ListModel { id: todoListModel }
                        delegate: RowLayout {
                            width: parent.width
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
        }
    }

    function saveNote() {
        if (titleField.text.trim() !== "") {
            var success = dbManager.saveNote(currentUserId, titleField.text, notesTextArea.text);
            console.log("Note save attempt. Success:", success, "Title:", titleField.text);
            loadNotes();
            titleField.text = "";
            notesTextArea.text = "";
        }
    }

    function deleteNote() {
        if (titleField.text.trim() !== "") {
            dbManager.deleteNote(currentUserId, titleField.text)
            loadNotes()
            titleField.text = ""
            notesTextArea.text = ""
        }
    }

    function recoverNote(index) {
        var noteTitle = deletedFilesModel.get(index).title
        dbManager.recoverNote(currentUserId, noteTitle)
        loadNotes()
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
                completed: todoListModel.get(i).completed
            })
        }
        dbManager.saveTodoList(currentUserId, JSON.stringify(todoItems))
            }

            function loadTodoList() {
                var todoListJson = dbManager.getTodoList(currentUserId)
                if (todoListJson) {
                    var todoItems = JSON.parse(todoListJson)
                    todoListModel.clear()
                    for (var i = 0; i < todoItems.length; i++) {
                        todoListModel.append(todoItems[i])
                    }
                }
            }

            function logOut() {
                savedFilesModel.clear()
                deletedFilesModel.clear()
                todoListModel.clear()
                titleField.text = ""
                notesTextArea.text = ""

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
