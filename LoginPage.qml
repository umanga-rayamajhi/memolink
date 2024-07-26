import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Item {
    anchors.fill: parent

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left side with background image
        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width / 2
            source: "background.png"
            fillMode: Image.PreserveAspectCrop
        }

        // Right side with login form
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width / 2
            color: window.primaryColor

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.6

                Text {
                    text: "Login"
                    font.family: window.fontFamily
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: window.accentColor
                    Layout.alignment: Qt.AlignHCenter
                }

                TextField {
                    id: emailInput
                    placeholderText: "Email"
                    Layout.preferredWidth: parent.width * 0.6
                    font.family: window.fontFamily
                    font.pixelSize: 16
                    background: Rectangle {
                        color: "#FFFFFF"
                        radius: 5
                        border.color: emailInput.activeFocus ? window.accentColor : "#CCCCCC"
                        border.width: emailInput.activeFocus ? 2 : 1
                    }
                    leftPadding: 10
                    rightPadding: 10
                }

                TextField {
                    id: passwordInput
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    Layout.preferredWidth: parent.width * 0.6
                    font.family: window.fontFamily
                    font.pixelSize: 16
                    background: Rectangle {
                        color: "#FFFFFF"
                        radius: 5
                        border.color: passwordInput.activeFocus ? window.accentColor : "#CCCCCC"
                        border.width: passwordInput.activeFocus ? 2 : 1
                    }
                    leftPadding: 10
                    rightPadding: 10
                }

                Button {
                    text: "Login"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 50
                    font.family: window.fontFamily
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

                Button {
                    text: "Sign up"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 40
                    font.family: window.fontFamily
                    font.pixelSize: 16
                    background: Rectangle {
                        color: "transparent"
                        border.color: window.accentColor
                        border.width: 2
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.bold: true
                        color: window.accentColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: stackView.push("SignUpPage.qml")
                }

                Button {
                    text: "Back to Main Menu"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 40
                    font.family: window.fontFamily
                    font.pixelSize: 14
                    onClicked: stackView.pop()
                    background: Rectangle {
                        color: "transparent"
                        border.color: window.textColor
                        border.width: 1
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        font.bold: true
                        color: window.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
