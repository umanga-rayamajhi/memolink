import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15

Item {
    id: root
    property var dbManager
    anchors.fill: parent

    signal registrationSuccessful(int userId)

    Material.theme: Material.Dark
    Material.accent: Material.Teal  // Adjust this to match your accentColor

    Component.onCompleted: {
        if (!root.dbManager) {
            console.error("dbManager is not available in SignUpPage")
        } else {
            console.log("dbManager is available in SignUpPage")
        }
    }

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
            color: Material.backgroundColor

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.6

                Text {
                    text: "Sign Up"
                    font.family: window.fontFamily
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: Material.accentColor
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
                    Material.background: Material.accentColor
                    Material.foreground: "white"
                }

                Button {
                    text: "Login"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 40
                    font.family: window.fontFamily
                    font.pixelSize: 16
                    Material.background: "transparent"
                    Material.foreground: Material.accentColor
                    onClicked: stackView.push("LoginPage.qml", { dbManager: root.dbManager })
                }

                Button {
                    text: "Back to Main Menu"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 40
                    font.family: window.fontFamily
                    font.pixelSize: 14
                    onClicked: stackView.pop("../../MainView.qml")
                    Material.background: "transparent"
                    Material.foreground: Material.foreground
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

    Dialog {
        id: successDialog
        title: "Signup Successful"
        standardButtons: Dialog.Ok

        contentItem: Text {
            text: "Your account has been created successfully. You can now log in."
            color: "#008000"
            font.pixelSize: 14
        }

        onAccepted: {
            successDialog.close();
            stackView.push("LoginPage.qml", { dbManager: root.dbManager });
        }
    }

    // Custom Components
    component CustomTextField: TextField {
        font.pixelSize: 14
        font.family: window.fontFamily
        Material.accent: Material.accentColor
        Material.foreground: Material.foreground
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

        if (!root.dbManager) {
            console.error("dbManager is not available");
            errorText.text = "An error occurred. Please try again later.";
            errorDialog.open();
            return;
        }

        var userId = root.dbManager.registerUser(name, email, password);
        if (userId > 0) {
            console.log("User signup successful");
            registrationSuccessful(userId);  // Emit the signal with the userId
            successDialog.open();
        } else {
            console.log("User signup failed");
            errorText.text = "Signup failed. Email may already be in use.";
            errorDialog.open();
        }
    }
}
