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
    color: "#f5f5f5"
    property color primaryColor: "#ADD8E6"  // Light Blue
    property color accentColor: "#1E90FF"   // Dodger Blue

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenuComponent
    }

    Component {
        id: mainMenuComponent
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Navbar
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: primaryColor

                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 20

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Login"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        font.pixelSize: 20
                        onClicked: stackView.push("LoginPage.qml")
                        background: Rectangle {
                            color: accentColor
                            radius: 30
                        }
                        contentItem: Text {
                            text: parent.text
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Sign Up"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        font.pixelSize: 20
                        onClicked: stackView.push("SignUpPage.qml")
                        background: Rectangle {
                            color: "white"
                            border.color: accentColor
                            radius: 30
                        }
                        contentItem: Text {
                            text: parent.text
                            font.bold: true
                            color: accentColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Main content area
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Left side with background image
                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    source: "background.png"
                    fillMode: Image.PreserveAspectCrop
                }

                // Right side with Memolink text
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    color: "white"

                    Text {
                        anchors.centerIn: parent
                        text: "Memolink"
                        font.pixelSize: 48
                        font.bold: true
                        color: accentColor
                    }
                }
            }
        }
    }
}
