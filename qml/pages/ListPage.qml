import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Label {
            text: "想法列表"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: "暂无记录"
            color: "gray"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
