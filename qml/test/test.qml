import QtQuick

Rectangle {
    id: page
    width:320; height: 480
    color: "lightgrey"

    Text {
        id: helloQML
        text: "HELLO QML"
        y: 30
        anchors.horizontalCenter: page.horizontalCenter
        font.pointSize: 20; font.bold:true
    }
}