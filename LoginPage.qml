import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs


Item {
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
                        Layout.preferredWidth: Math.min(parent.width * 0.74, parent.height * 1.2)
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
                    spacing: 20
                    width: parent.width * 0.7

                    TextField {
                        id: emailInput
                        Layout.preferredWidth: 300
                        font.pixelSize: 16
                        background: Rectangle {
                            color: "#FFFFFF"
                            radius: 5
                            border.color: emailInput.activeFocus ? window.accentColor : "#CCCCCC"
                            border.width: emailInput.activeFocus ? 2 : 1
                        }
                        leftPadding: 10
                        rightPadding: 10

                        Text {
                            text: "Email"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            color: emailInput.displayText.length === 0 ? "#CCCCCC" : "transparent"
                            font: emailInput.font
                        }
                    }

                    TextField {
                        id: passwordInput
                        placeholderText: "Password"
                        echoMode: TextInput.Password
                        Layout.preferredWidth: 300
                        font.pixelSize: 16
                        background: Rectangle {
                            color: "#FFFFFF"
                            radius: 5
                            border.color: passwordInput.activeFocus ? window.accentColor : "#CCCCCC"
                            border.width: passwordInput.activeFocus ? 2 : 1
                        }
                        leftPadding: 10
                        rightPadding: 10

                        Text {

                            text: "Password"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            color: passwordInput.displayText.length === 0 ? "#CCCCCC" : "transparent"
                            font: passwordInput.font
                        }
                    }

                    Button {
                        text: "Login"
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 50
                        font.pixelSize: 18
                        onClicked: {
                            var email = emailInput.text;
                            var password = passwordInput.text;
                            var success = dbManager.userLogin(email, password);
                            if (success) {
                                console.log("User login successful");
                                stackView.push("UserDashboardPage.qml");
                            } else {
                                console.log("User login failed");
                                errorDialog.open();
                            }
                        }
                        background: Rectangle {
                            color: window.accentColor
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        text: "Sign up"
                        color: window.primaryColor
                        font.pixelSize: 20
                        font.underline: false
                        Layout.alignment: Qt.AlignHCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: stackView.push("SignUpPage.qml")
                        }
                    }

                    Button {
                        text: "Back to Main Menu"
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 40
                        font.pixelSize: 14
                        onClicked: stackView.pop()
                        background: Rectangle {
                            color: "transparent"
                            border.color: window.primaryColor
                            border.width: 1
                            radius: 20
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

    Dialog {
        id: errorDialog
        title: "Login Failed"
        standardButtons: Dialog.Ok

        contentItem: Text {
            text: "Invalid email or password. Please try again."
            color: "#FF0000"
            font.pixelSize: 14
        }

        onAccepted: errorDialog.close()
    }
}
