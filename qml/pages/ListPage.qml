import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: listPageRoot
    color: "#f5f5f5"
    
    // 分页相关属性
    property var allIdeas: []
    property var currentPageIdeas: []
    property int currentPage: 1
    property int pageSize: 10
    property int totalCount: 0
    property int totalPages: 0
    
    function refreshList() {
        console.log("Loading all ideas...")
        allIdeas = dbManager.loadAllIdeas()
        totalCount = allIdeas.length
        totalPages = Math.max(1, Math.ceil(totalCount / pageSize))
        
        // 如果当前页超出总页数，回到第一页
        if (currentPage > totalPages) {
            currentPage = 1
        }
        
        updateCurrentPage()
        countText.text = "共 " + totalCount + " 条"
        pageInfo.text = currentPage + " / " + totalPages
    }
    
    function updateCurrentPage() {
        var start = (currentPage - 1) * pageSize
        var end = Math.min(start + pageSize, totalCount)
        currentPageIdeas = allIdeas.slice(start, end)
        listView.model = currentPageIdeas
    }
    
    function goToPage(page) {
        if (page < 1 || page > totalPages) return
        currentPage = page
        updateCurrentPage()
        pageInfo.text = currentPage + " / " + totalPages
    }
    
    function nextPage() {
        if (currentPage < totalPages) {
            goToPage(currentPage + 1)
        }
    }
    
    function prevPage() {
        if (currentPage > 1) {
            goToPage(currentPage - 1)
        }
    }
    
    Component.onCompleted: {
        refreshList()
    }
    
    onVisibleChanged: {
        if (visible) {
            refreshList()
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10
        
        // 标题栏
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "我的想法"
                font.pointSize: 18
                font.bold: true
                color: "#333"
            }
            
            Text {
                id: countText
                text: "共 0 条"
                font.pointSize: 12
                color: "#999"
                Layout.alignment: Qt.AlignRight
            }
            
            Button {
                text: "刷新"
                font.pointSize: 12
                Layout.preferredWidth: 48
                Layout.preferredHeight: 32
                onClicked: refreshList()
            }
        }
        
        // 列表
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            
            model: currentPageIdeas
            delegate: Rectangle {
                width: listView.width
                height: 72
                color: "#fff"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 2
                        
                        Text {
                            text: modelData.content
                            font.pointSize: 13
                            color: "#333"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        
                        RowLayout {
                            spacing: 6
                            
                            Text {
                                text: modelData.tags
                                font.pointSize: 11
                                color: "#2196F3"
                                visible: modelData.tags && modelData.tags.length > 0
                            }
                            
                            Text {
                                text: modelData.createdAt
                                font.pointSize: 10
                                color: "#999"
                            }
                        }
                    }
                    
                    Button {
                        text: "删除"
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 28
                        font.pointSize: 11
                        background: Rectangle {
                            color: "#f44336"
                            radius: 4
                        }
                        contentItem: Text {
                            text: "删除"
                            color: "white"
                            font.pointSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            dbManager.deleteIdea(modelData.id)
                            refreshList()
                        }
                    }
                }
            }
            
            Rectangle {
                anchors.centerIn: parent
                visible: listView.count === 0
                color: "transparent"
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Text {
                        text: "还没有想法"
                        font.pointSize: 15
                        color: "#999"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "去「记录」页面添加吧"
                        font.pointSize: 12
                        color: "#bbb"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
        
        // 分页控件
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                spacing: 8
                
                Button {
                    text: "上一页"
                    font.pointSize: 12
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 32
                    enabled: currentPage > 1
                    onClicked: prevPage()
                }
                
                Text {
                    id: pageInfo
                    text: "1 / 1"
                    font.pointSize: 13
                    color: "#333"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Button {
                    text: "下一页"
                    font.pointSize: 12
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 32
                    enabled: currentPage < totalPages
                    onClicked: nextPage()
                }
            }
        }
    }
}