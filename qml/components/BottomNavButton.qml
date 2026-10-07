import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string buttonText: ""
    property bool isActive: false
    signal clicked()
    
    width: parent.width / 3
    height: parent.height
    color: isActive ? "#e0e0e0" : "transparent"
    
    Text {
        anchors.centerIn: parent
        text: root.buttonText
        font.pointSize: 14
        color: root.isActive ? "#333" : "#999"
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}