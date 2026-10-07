import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    // 使用点大小替代像素大小，在 Android 上更清晰
    property int fontSize: 14
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Label {
            text: "记录想法"
            font.pointSize: 20
            font.bold: true
            color: "#333"
            Layout.alignment: Qt.AlignHCenter
        }

        // 输入框区域
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            Layout.minimumHeight: 120
            color: "white"
            radius: 8
            border.color: "#ddd"
            
            TextArea {
                id: ideaInput
                anchors.fill: parent
                anchors.margins: 10
                placeholderText: "今天有什么想法？"
                font.pointSize: 14
                wrapMode: TextArea.Wrap
                padding: 4
                background: null  // 使用父容器的背景
            }
        }

        // 标签输入框
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.minimumHeight: 36
            color: "white"
            radius: 8
            border.color: "#ddd"
            
            TextField {
                id: tagInput
                anchors.fill: parent
                anchors.margins: 2
                placeholderText: "标签（逗号分隔）"
                font.pointSize: 13
                padding: 8
                background: null
            }
        }

        Button {
            text: "保存"
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.maximumWidth: 200
            Layout.alignment: Qt.AlignHCenter
            enabled: ideaInput.text.trim().length > 0
            font.pointSize: 15
            font.bold: true
            
            background: Rectangle {
                color: parent.enabled ? "#4CAF50" : "#cccccc"
                radius: 8
            }
            
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pointSize: 15
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                var success = dbManager.saveIdea(ideaInput.text, tagInput.text)
                
                if (success) {
                    savedLabel.text = "已保存！"
                    savedLabel.color = "#4CAF50"
                    ideaInput.text = ""
                    tagInput.text = ""
                    clearTimer.start()
                } else {
                    savedLabel.text = "保存失败，请重试"
                    savedLabel.color = "#f44336"
                }
            }
        }

        Label {
            id: savedLabel
            text: ""
            color: "#4CAF50"
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 13
            font.bold: true
            height: 24
        }
        
        Timer {
            id: clearTimer
            interval: 1500
            onTriggered: savedLabel.text = ""
        }
        
        // 底部留白，避免被键盘遮挡
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}