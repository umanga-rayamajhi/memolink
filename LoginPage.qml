import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtQuick.Controls.Material 2.15

Page {
    id: root
    property var dbManager
    width: parent.width
    height: parent.height

    signal loginSuccessful(int userId)

    Material.theme: Material.Dark
    Material.accent: Material.Teal

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width / 2
            source: "background.png"
            fillMode: Image.PreserveAspectCrop
        }

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
                    onClicked: stackView.push("SignUpPage.qml", { dbManager: root.dbManager })
                }
            }
        }
    }

    Dialog {
        id: errorDialog
        title: "Login Failed"
        standardButtons: Dialog.Ok
        width: 300

        Text {
            width: parent.width
            text: "Invalid email or password. Please try again."
            color: "#FF0000"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        onAccepted: errorDialog.close()
    }

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

        var userId = root.dbManager.loginUser(email, password);
        if (userId > 0) {
            console.log("User login successful");
            loginSuccessful(userId);  // Emit the signal with the userId
            stackView.push("MainWindow.qml", {
                dbManager: root.dbManager,
                currentUserId: userId,
                isLoggedIn: true
            });
        } else {
            console.log("User login failed");
            errorDialog.contentItem.text = "Invalid email or password. Please try again.";
            errorDialog.open();
        }
    }
}
