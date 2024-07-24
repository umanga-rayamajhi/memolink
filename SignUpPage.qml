import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: userSignupPage

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.4
                color: window.primaryColor

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    Image {
                        source: "../../Pictures/Logo.png"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.width * 0.74, parent.height * 1.2)
                        Layout.preferredHeight: Layout.preferredWidth
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Join BloodBound"
                        font.pixelSize: Math.min(parent.width * 0.15, 36)
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Create your account and start saving lives"
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
                color: "white"

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20
                        width: Math.min(parent.width * 0.7, 400)

                        Text {
                            text: "Sign Up"
                            font.pixelSize: 32
                            font.bold: true
                            color: window.primaryColor
                            Layout.alignment: Qt.AlignHCenter
                        }

                        CustomTextField {
                            id: nameInput
                            placeholderText: "Full Name"
                            Layout.fillWidth: true
                        }

                        CustomTextField {
                            id: emailInput
                            placeholderText: "Email"
                            Layout.fillWidth: true
                        }

                        CustomTextField {
                            id: passwordInput
                            placeholderText: "Password"
                            echoMode: TextInput.Password
                            Layout.fillWidth: true
                        }

                        CustomTextField {
                            id: confirmPasswordInput
                            placeholderText: "Confirm Password"
                            echoMode: TextInput.Password
                            Layout.fillWidth: true
                        }

                        Button {
                            text: "Sign Up"
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            font.pixelSize: 16
                            font.bold: true
                            onClicked: signUp()
                            background: Rectangle {
                                color: window.accentColor
                                radius: 25
                            }
                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Text {
                            text: "Already have an account? Log in"
                            color: window.primaryColor
                            font.pixelSize: 14
                            font.underline: true
                            Layout.alignment: Qt.AlignHCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: stackView.pop()
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: errorDialog
        title: "Error"
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
            color: "#F0F0F0"
            radius: 5
            border.color: parent.activeFocus ? window.accentColor : "#CCCCCC"
            border.width: parent.activeFocus ? 2 : 1
        }
        leftPadding: 10
        rightPadding: 10
        topPadding: 12
        bottomPadding: 12
    }

    component CustomComboBox: ComboBox {
        id: comboBox
        font.pixelSize: 14
        background: Rectangle {
            color: "#F0F0F0"
            radius: 5
            border.color: comboBox.activeFocus ? window.accentColor : "#CCCCCC"
            border.width: comboBox.activeFocus ? 2 : 1
        }
        delegate: ItemDelegate {
            width: comboBox.width
            contentItem: Text {
                text: modelData
                color: "#333333"
                font: comboBox.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: comboBox.highlightedIndex === index
        }
        contentItem: Text {
            leftPadding: 10
            rightPadding: 30
            text: comboBox.displayText
            font: comboBox.font
            color: comboBox.pressed ? "#666666" : "#333333"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    function signUp() {
        var name = nameInput.text;
        var email = emailInput.text;
        var password = passwordInput.text;
        var confirmPassword = confirmPasswordInput.text;

        if (name.trim() === "" || email.trim() === "" || password.trim() === "" || confirmPassword.trim() === "" || bloodGroup === "") {
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
        var success = dbManager.insertUser(name, email, password, bloodGroup, healthInfo);
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
