import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: mainwindow
    background: Rectangle {
        color: "#0A192F"  // Dark blue background
    }

    property color accentColor: "#64FFDA"
    property color textColor: "#CCD6F6"
    property color lightBackgroundColor: "#F8F8F8"
    property string fontFamily: "Roboto"

    Drawer {
        id: sidebar
        width: 250
        height: parent.height
        visible: false
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

                // Font controls
                Row {
                    spacing: 5
                    CustomButton { text: "-"; onClicked: decreaseFontSize() }
                    TextField {
                        id: fontSizeField
                        width: 40
                        text: "18"
                        validator: IntValidator { bottom: 1; top: 100 }
                        inputMethodHints: Qt.ImhDigitsOnly
                        onTextChanged: setFontSizeFromField()
                        horizontalAlignment: Text.AlignHCenter
                        background: Rectangle {
                            color: lightBackgroundColor
                            radius: 4
                        }
                    }
                    CustomButton { text: "+"; onClicked: increaseFontSize() }
                }

                CustomButton { text: "B"; font.bold: true; onClicked: toggleBold() }
                CustomButton { text: "I"; font.italic: true; onClicked: toggleItalic() }
                CustomButton { text: "U"; font.underline: true; onClicked: toggleUnderline() }
                CustomButton { text: "Create List"; onClicked: createList() }
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

                        Label {
                            text: "Previous Files"
                            font.family: fontFamily
                            font.pixelSize: 20
                            color: accentColor
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: ListModel { }
                            delegate: ItemDelegate {
                                width: parent.width
                                height: 40
                                contentItem: Text {
                                    text: ""
                                    font.family: fontFamily
                                    font.pixelSize: 16
                                    color: textColor
                                    verticalAlignment: Text.AlignVCenter
                                }
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

                            Keys.onPressed: {
                                if (event.key === Qt.Key_B && event.modifiers & Qt.ControlModifier) {
                                    toggleBold();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_I && event.modifiers & Qt.ControlModifier) {
                                    toggleItalic();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_U && event.modifiers & Qt.ControlModifier) {
                                    toggleUnderline();
                                    event.accepted = true;
                                }
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
                }
            }
        }
    }

    // Custom button component
    component CustomButton: Button {
        contentItem: Text {
            text: parent.text
            font: parent.font
            color: parent.pressed ? "#172A45" : accentColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            color: parent.pressed ? accentColor : "transparent"
            border.color: accentColor
            border.width: 1
            radius: 4
        }
    }

    function increaseFontSize() {
        var newSize = parseInt(fontSizeField.text) + 1;
        fontSizeField.text = newSize.toString();
        notesTextArea.font.pointSize = newSize;
    }

    function decreaseFontSize() {
        var newSize = parseInt(fontSizeField.text) - 1;
        if (newSize > 0) {
            fontSizeField.text = newSize.toString();
            notesTextArea.font.pointSize = newSize;
        }
    }

    function setFontSizeFromField() {
        var newSize = parseInt(fontSizeField.text);
        if (newSize > 0) {
            notesTextArea.font.pointSize = newSize;
        }
    }

    function toggleBold() {
        notesTextArea.font.bold = !notesTextArea.font.bold;
    }

    function toggleItalic() {
        notesTextArea.font.italic = !notesTextArea.font.italic;
    }

    function toggleUnderline() {
        notesTextArea.font.underline = !notesTextArea.font.underline;
    }

    function createList() {
        var text = notesTextArea.text;
        var cursorPos = notesTextArea.cursorPosition;
        text = text.substring(0, cursorPos) + '• ' + text.substring(cursorPos);
        notesTextArea.text = text;
        notesTextArea.cursorPosition += 2;
    }
}
