import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "pages"

ApplicationWindow {
    visible: true
    width: 400
    height: 700
    title: "想法记录"

    SwipeView {
        id: swipeView
        anchors.fill: parent
        anchors.bottomMargin: 56
        currentIndex: 1
        ListPage {}
        RecordPage {}
        StatisticsPage {}
    }

    // 底部导航栏
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 56
        color: "#f5f5f5"
        
        Row {
            anchors.fill: parent
            spacing: 0
            
            // 列表按钮
            Rectangle {
                width: parent.width / 3
                height: parent.height
                color: swipeView.currentIndex === 0 ? "#e0e0e0" : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "列表"
                    font.pointSize: 14
                    color: swipeView.currentIndex === 0 ? "#333" : "#999"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: swipeView.currentIndex = 0
                }
            }
            
            // 记录按钮
            Rectangle {
                width: parent.width / 3
                height: parent.height
                color: swipeView.currentIndex === 1 ? "#e0e0e0" : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "记录"
                    font.pointSize: 14
                    color: swipeView.currentIndex === 1 ? "#333" : "#999"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: swipeView.currentIndex = 1
                }
            }
            
            // 统计按钮
            Rectangle {
                width: parent.width / 3
                height: parent.height
                color: swipeView.currentIndex === 2 ? "#e0e0e0" : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "统计"
                    font.pointSize: 14
                    color: swipeView.currentIndex === 2 ? "#333" : "#999"
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: swipeView.currentIndex = 2
                }
            }
        }
        
        // 底部指示线
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width / 3
            height: 3
            color: "#4CAF50"
            x: swipeView.currentIndex * (parent.width / 3)
            
            Behavior on x {
                NumberAnimation { duration: 200 }
            }
        }
    }
    
    Connections {
        target: dbManager
        onDataChanged: {
            console.log("Data changed signal received!")
            // 刷新列表
            var listPage = swipeView.itemAt(0)
            if (listPage && typeof listPage.refreshList === "function") {
                listPage.refreshList()
            }
            // 刷新统计
            var statsPage = swipeView.itemAt(2)
            if (statsPage && typeof statsPage.refreshStats === "function") {
                statsPage.refreshStats()
            }
        }
    }
}