import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: qsTr("MemoLink")

    property string fontFamily: "Roboto"
    Material.theme: Material.Dark
    Material.accent: "#64FFDA"
    Material.primary: "#0A192F"
    Material.background: "#0A192F"
    Material.foreground: "#CCD6F6"

    Component.onCompleted: {
        if (dbManager) {
            console.log("dbManager is available in MainView")
        } else {
            console.error("dbManager is not available in MainView")
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainMenu
    }

    Component {
        id: mainMenu
        Item {
            anchors.fill: parent

            // Navbar
            Rectangle {
                id: navbar
                width: parent.width
                height: 70
                color: Material.primary

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30

                    Text {
                        text: "MemoLink"
                        font.family: window.fontFamily
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: Material.accent
                    }

                    Item { Layout.fillWidth: true }

                    CustomButton {
                        text: "Login"
                        onClicked: stackView.push("LoginPage.qml", { dbManager: dbManager })
                        outlined: true
                    }

                    CustomButton {
                        text: "Sign Up"
                        onClicked: stackView.push("SignUpPage.qml", { dbManager: dbManager })
                        outlined: false
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

                // Right side with MemoLink text and description
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    color: Material.background

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 30
                        width: parent.width * 0.8

                        Text {
                            text: "Welcome to MemoLink"
                            font.family: window.fontFamily
                            font.pixelSize: 48
                            font.weight: Font.Bold
                            color: Material.accent
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Capture ideas instantly, organize thoughts effortlessly, and access your notes from anywhere."
                            font.family: window.fontFamily
                            font.pixelSize: 18
                            color: Material.foreground
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "With intuitive features and seamless synchronization, stay productive and never miss a brilliant idea again."
                            font.family: window.fontFamily
                            font.pixelSize: 16
                            color: Qt.rgba(Material.foreground.r, Material.foreground.g, Material.foreground.b, 0.7)
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    // Custom button component
    component CustomButton: Button {
        property bool outlined: false

        contentItem: Text {
            text: parent.text
            font.family: window.fontFamily
            font.pixelSize: 16
            color: outlined ? Material.accent : Material.primary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 40
            color: outlined ? "transparent" : Material.accent
            border.color: Material.accent
            border.width: outlined ? 2 : 0
            radius: 4
        }
    }
}
