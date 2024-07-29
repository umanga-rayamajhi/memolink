import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15

Item {
    id: root
    property var dbManager
    anchors.fill: parent

    Material.theme: Material.Dark
    Material.accent: Material.Teal  // Adjust this to match your accentColor

    Component.onCompleted: {
        if (!root.dbManager) {
            console.error("dbManager is not available in LoginPage")
        } else {
            console.log("dbManager is available in LoginPage")
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

        // Right side with login form
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
                    text: "Login"
                    font.family: window.fontFamily
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    color: Material.accentColor
                    Layout.alignment: Qt.AlignHCenter
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

                Button {
                    text: "Login"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 50
                    font.family: window.fontFamily
                    font.pixelSize: 18
                    onClicked: login()
                    Material.background: Material.accentColor
                    Material.foreground: "white"
                }

                Button {
                    text: "Sign up"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 40
                    font.family: window.fontFamily
                    font.pixelSize: 16
                    Material.background: "transparent"
                    Material.foreground: Material.accentColor
                    onClicked: stackView.push("SignUpPage.qml")
                }

                Button {
                    text: "Back to Main Menu"
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.preferredHeight: 40
                    font.family: window.fontFamily
                    font.pixelSize: 14
                    onClicked: stackView.pop()
                    Material.background: "transparent"
                    Material.foreground: Material.foreground
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

    // Custom Components
    component CustomTextField: TextField {
        font.pixelSize: 14
        font.family: window.fontFamily
        Material.accent: Material.accentColor
        Material.foreground: Material.foreground
    }

    function login() {
        var email = emailInput.text;
        var password = passwordInput.text;

        if (email.trim() === "" || password.trim() === "") {
            errorDialog.contentItem.text = "Please fill in all required fields.";
            errorDialog.open();
            return;
        }

        if (!root.dbManager) {
            console.error("dbManager is not available");
            errorDialog.contentItem.text = "An error occurred. Please try again later.";
            errorDialog.open();
            return;
        }

        var success = root.dbManager.loginUser(email, password);
        if (success) {
            console.log("User login successful");
            stackView.push("MainWindow.qml");
        } else {
            console.log("User login failed");
            errorDialog.contentItem.text = "Invalid email or password. Please try again.";
            errorDialog.open();
        }
    }
}
