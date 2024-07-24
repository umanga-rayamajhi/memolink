import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: loginSignupChoicePage
    property string mode: "login" // or "signup"

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.4
                color: primaryColor

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    width: parent.width

                    Image {
                        source: "../../Pictures/Logo.png"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.width * 0.76, parent.height * 1.2)
                        Layout.preferredHeight: Layout.preferredWidth
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "BloodBound"
                        font.pixelSize: Math.min(parent.width * 0.15, 48)
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Connecting donors and hospitals"
                        font.pixelSize: Math.min(parent.width * 0.05, 18)
                        color: "white"
                        opacity: 0.8
                        Layout.alignment: Qt.AlignHCenter
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.preferredWidth: parent.width * 0.8
                    }
                }
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 34
                    width: parent.width * 0.5

                    Text {
                        text: mode === "login" ? "Choose Login Type" : "Choose Signup Type"
                        font.pixelSize: 32
                        font.bold: true
                        color: window.primaryColor
                        Layout.alignment: Qt.AlignCenter
                    }

                    Button {
                        text: mode === "login" ? "User Login" : "User Signup"
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 60
                        font.pixelSize: 20
                        onClicked: stackView.push(mode === "login" ? "UserLoginPage.qml" : "UserSignupPage.qml")
                        background: Rectangle {
                            color: window.accentColor
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
                        text: mode === "login" ? "Hospital Login" : "Hospital Signup"
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 60
                        font.pixelSize: 20
                        onClicked: stackView.push(mode === "login" ? "HospitalLoginPage.qml" : "HospitalSignupPage.qml")
                        background: Rectangle {
                            color: "white"
                            border.color: window.accentColor
                            border.width: 2
                            radius: 30
                        }
                        contentItem: Text {
                            text: parent.text
                            font.bold: true
                            color: window.accentColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Back to Main Menu"
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 50
                        font.pixelSize: 18
                        onClicked: stackView.pop()
                        background: Rectangle {
                            color: "transparent"
                            border.color: window.primaryColor
                            border.width: 2
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.bold: true
                            color: window.primaryColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
