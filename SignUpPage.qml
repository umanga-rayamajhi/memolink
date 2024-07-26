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

        // Right side with signup form
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
                    text: "Sign Up"
                    font.family: window.fontFamily
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: window.accentColor
                    Layout.alignment: Qt.AlignHCenter
                }

                CustomTextField {
                    id: nameInput
                    placeholderText: "Full Name"
                    Layout.preferredWidth: parent.width * 0.6
                }

                CustomTextField {
                    id: emailInput
                    placeholderText: "Email"
                    Layout.preferredWidth: parent.width * 0.6
                }

                CustomTextField {
                    id: passwordInput
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    Layout.preferredWidth: parent.width * 0.6
                }

                CustomTextField {
                    id: confirmPasswordInput
                    placeholderText: "Confirm Password"
                    echoMode: TextInput.Password
                    Layout.preferredWidth: parent.width * 0.6
                }

                Button {
                    text: "Sign Up"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 50
                    font.family: window.fontFamily
                    font.pixelSize: 18
                    onClicked: signUp()
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
                    text: "Login"
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
                    onClicked: stackView.push("LoginPage.qml")
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
        title: "Signup Failed"
        standardButtons: Dialog.Ok

        contentItem: Text {
            id: errorText
            color: "#FF0000"
            font.pixelSize: 14
        }

        onAccepted: errorDialog.close()
    }

    // Custom Components
    component CustomTextField: TextField {
        font.pixelSize: 14
        background: Rectangle {
            color: "#FFFFFF"
            radius: 5
            border.color: parent.activeFocus ? window.accentColor : "#CCCCCC"
            border.width: parent.activeFocus ? 2 : 1
        }
        leftPadding: 10
        rightPadding: 10
        topPadding: 12
        bottomPadding: 12
    }

    function signUp() {
        var name = nameInput.text;
        var email = emailInput.text;
        var password = passwordInput.text;
        var confirmPassword = confirmPasswordInput.text;

        if (name.trim() === "" || email.trim() === "" || password.trim() === "" || confirmPassword.trim() === "") {
            errorText.text = "Please fill in all required fields.";
            errorDialog.open();
            return;
        }

        if (password !== confirmPassword) {
            errorText.text = "Passwords do not match.";
            errorDialog.open();
            return;
        }

        // Call the backend function to insert the user
        var success = dbManager.insertUser(name, email, password);
        if (success) {
            console.log("User signup successful");
            stackView.push("UserDashboardPage.qml");
        } else {
            console.log("User signup failed");
            errorText.text = "Signup failed. Please try again.";
            errorDialog.open();
        }
    }
}
