import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "MemoLink"
    color: "#0A192F"  // Dark blue background

    property var dbManager: null
    property color primaryColor: "#0A192F"  // Dark blue
    property color secondaryColor: "#172A45"  // Slightly lighter blue
    property color accentColor: "#64FFDA"  // Teal accent
    property color textColor: "#E6F1FF"  // Light blue-white for text
    property string fontFamily: "Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif"

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuComponent
    }

    Component {
        id: mainMenuComponent
        Item {
            anchors.fill: parent

            // Navbar
            Rectangle {
                id: navbar
                width: parent.width
                height: 70
                color: secondaryColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30

                    Text {
                        text: "MemoLink"
                        font.family: fontFamily
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: accentColor
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Login"
                        font.family: fontFamily
                        font.pixelSize: 16
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        onClicked: stackView.push("LoginPage.qml", {dbManager: window.dbManager})
                        background: Rectangle {
                            color: "transparent"
                            border.color: accentColor
                            border.width: 2
                            radius: 5
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: accentColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Sign Up"
                        font.family: fontFamily
                        font.pixelSize: 16
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        onClicked: stackView.push("SignUpPage.qml", {dbManager: window.dbManager})
                        background: Rectangle {
                            color: accentColor
                            radius: 5
                        }
                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: primaryColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Main content area
            RowLayout {
                anchors.top: navbar.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                // Left side with background image
                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    source: "background.png"
                    fillMode: Image.PreserveAspectCrop
                }

                // Right side with Memolink text and description
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    color: primaryColor

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 30
                        width: parent.width * 0.8

                        Text {
                            text: "MemoLink"
                            font.family: fontFamily
                            font.pixelSize: 48
                            font.weight: Font.Bold
                            color: accentColor
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Your ultimate digital note-taking companion"
                            font.family: fontFamily
                            font.pixelSize: 24
                            color: textColor
                            opacity: 0.8
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            text: "Capture ideas instantly, organize thoughts effortlessly, and access your notes from anywhere. With intuitive features and seamless synchronization, stay productive and never miss a brilliant idea again."
                            font.family: fontFamily
                            font.pixelSize: 16
                            color: textColor
                            opacity: 0.6
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }
                    }
                }
            }
        }
    }
}
