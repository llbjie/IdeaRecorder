import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Label {
            text: "记录想法"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        TextArea {
            id: ideaInput
            placeholderText: "在这里输入你的想法..."
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            Layout.leftMargin: 16
            Layout.rightMargin: 16
        }

        Button {
            text: "保存"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 120
            onClicked: {
                if (ideaInput.text.trim().length > 0) {
                    savedLabel.text = "已保存!"
                    ideaInput.clear()
                }
            }
        }

        Label {
            id: savedLabel
            text: ""
            color: "green"
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
