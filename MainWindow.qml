import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "MemoLink"
    color: "#f8f8f8"  // Light background color

    // Sidebar
    Drawer {
        id: sidebar
        width: 250
        height: parent.height
        visible: false
        edge: Qt.LeftEdge
        modal: true

        Column {
            spacing: 10
            padding: 10

            Label {
                text: "Modes"
                font.pointSize: 24
                color: "#2c3e50"  // Dark text
            }

            Label {
                text: "Smart Mode"
                font.pointSize: 18
                color: "#2c3e50"  // Dark text
                MouseArea {
                    anchors.fill: parent
                    onClicked: openSmartMode()
                }
            }

            // Add more sidebar content here as needed
        }
    }

    // Edit bar with font controls and list creation
    RowLayout {
        id: editBar
        width: parent.width
        height: 40
        Layout.alignment: Qt.AlignTop
        spacing: 10

        // Menu icon
        Button {
            text: "☰"
            onClicked: sidebar.open()
            font.pointSize: 18
            background: Rectangle {
                color: "transparent"
                border.color: "transparent"
            }
        }

        // Font size controls and text formatting controls
        RowLayout {
            spacing: 5

            Button {
                text: "-"
                onClicked: decreaseFontSize()
            }

            TextField {
                id: fontSizeField
                width: 40
                text: "18"
                validator: IntValidator { bottom: 1; top: 100 }
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: setFontSizeFromField()
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "+"
                onClicked: increaseFontSize()
            }
        }

        Button {
            text: "B"
            font.bold: true
            onClicked: toggleBold()
        }
        Button {
            text: "I"
            font.italic: true
            onClicked: toggleItalic()
        }
        Button {
            text: "U"
            font.underline: true
            onClicked: toggleUnderline()
        }
        Button {
            text: "Create List"
            onClicked: createList()
        }

        // Spacer to push all icons to the left
        Rectangle {
            Layout.fillWidth: true
            color: "transparent"
        }
    }

    Rectangle {
        anchors.top: editBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#f8f8f8"  // Light background color

        Column {
            anchors.fill: parent
            spacing: 10
            padding: 10

            // Title
            Rectangle {
                width: parent.width
                height: 50
                color: "#3498db"  // Primary color
                border.color: "#2980b9"  // Darker primary color
                radius: 5

                Label {
                    text: "MEMOLINK"
                    font.pointSize: 24
                    color: "#ffffff"  // White text
                    anchors.centerIn: parent
                    font.bold: true
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.fill: parent
                spacing: 10

                // Side panel
                Rectangle {
                    width: parent.width * 0.25
                    height: parent.height
                    color: "#ecf0f1"  // Light gray background
                    radius: 5

                    Column {
                        anchors.fill: parent
                        spacing: 10
                        padding: 10

                        Label {
                            text: "Previous Files"
                            font.pointSize: 18
                            color: "#2c3e50"  // Dark text
                        }

                        ListView {
                            width: parent.width
                            height: parent.height - 50
                            model: ListModel { }

                            delegate: Item {
                                width: parent.width
                                height: 40

                                Text {
                                    text: ""
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pointSize: 16
                                    color: "#2c3e50"  // Dark text
                                }
                            }
                        }
                    }
                }

                // Main content area
                Rectangle {
                    width: parent.width * 0.75
                    height: parent.height
                    color: "#ffffff"  // White background
                    radius: 5

                    Column {
                        anchors.fill: parent
                        spacing: 10
                        padding: 10

                        TextField {
                            id: titleField
                            placeholderText: "Title"
                            font.pointSize: 18
                            width: parent.width
                            color: "#2c3e50"  // Dark text
                            background: Rectangle {
                                color: "#ecf0f1"  // Light gray background
                                radius: 5
                            }
                        }

                        TextArea {
                            id: notesTextArea
                            placeholderText: "Notes..."
                            width: parent.width
                            height: parent.height - titleField.height - editBar.height - 40 // Adjusted height calculation
                            color: "#2c3e50"  // Dark text
                            background: Rectangle {
                                color: "#ecf0f1"  // Light gray background
                                radius: 5
                            }

                            // Handling key presses
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
                                } else {
                                    event.accepted = false; // Allow the default behavior for other keys
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Smart Mode window
    Window {
        id: smartModeWindow
        width: 400
        height: 300
        visible: false
        title: "Smart Mode"
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "#ffffff"  // White background

        Column {
            anchors.fill: parent
            spacing: 10
            padding: 10

            TextField {
                id: smartModeTitleField
                placeholderText: "Title"
                font.pointSize: 18
                width: parent.width
                color: "#2c3e50"  // Dark text
                background: Rectangle {
                    color: "#ecf0f1"  // Light gray background
                    radius: 5
                }
            }

            TextArea {
                id: smartModeNotesTextArea
                placeholderText: "Notes..."
                width: parent.width
                height: parent.height - smartModeTitleField.height - 20
                color: "#2c3e50"  // Dark text
                background: Rectangle {
                    color: "#ecf0f1"  // Light gray background
                    radius: 5
                }
                focus: true // Make sure the TextArea is focused
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent

            onPressed: {
                dragArea.drag.start()
            }
        }

        Drag.active: dragArea.drag.active
        Drag.hotSpot.x: dragArea.width / 2
        Drag.hotSpot.y: dragArea.height / 2
        Drag.source: dragArea
    }

    function openSmartMode() {
        smartModeWindow.visible = true;
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
