import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 360
    height: 640
    title: "想法记录"

    SwipeView {
        id: view
        anchors.fill: parent
        anchors.bottomMargin: tabBar.height
        currentIndex: tabBar.currentIndex

        RecordPage {}
        ListPage {}
        StatisticsPage {}
    }

    TabBar {
        id: tabBar
        anchors.bottom: parent.bottom
        width: parent.width
        TabButton { text: "记录" }
        TabButton { text: "列表" }
        TabButton { text: "统计" }
    }
}
