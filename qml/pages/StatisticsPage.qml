import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: root
    color: "#f5f5f5"
    
    property var allTags: []
    
    function refreshStats() {
        // 更新总想法数
        ideaCountText.text = dbManager.getIdeaCount()
        
        // 收集所有标签及其出现次数
        var ideas = dbManager.loadAllIdeas()
        var tagCount = {}
        for (var i = 0; i < ideas.length; i++) {
            if (ideas[i].tags) {
                var parts = ideas[i].tags.split(',')
                for (var j = 0; j < parts.length; j++) {
                    var tag = parts[j].trim()
                    if (tag) {
                        if (tagCount[tag]) {
                            tagCount[tag]++
                        } else {
                            tagCount[tag] = 1
                        }
                    }
                }
            }
        }
        
        // 转换为词云需要的格式
        var tagData = []
        for (var name in tagCount) {
            tagData.push({word: name, count: tagCount[name]})
        }
        allTags = Object.keys(tagCount)
        
        // 更新关键词云
        var allIdeas = dbManager.getAllIdeasForWordCloud()
        if (wordCloud) {
            wordCloud.updateBubbles(allIdeas)
        }
        
        // 更新标签词云
        if (tagCloud) {
            tagCloud.updateBubblesWithData(tagData)
        }
    }
    
    Component.onCompleted: refreshStats()
    
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        
        ColumnLayout {
            width: parent.width
            anchors.margins: 16
            spacing: 16
            
            // 标题
            Text {
                text: "统计信息"
                font.pointSize: 24
                font.bold: false
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 统计卡片网格
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                
                // 总想法数卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "#E3F2FD"
                    radius: 8
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        Text {
                            text: "总想法"
                            font.pointSize: 14
                            color: "#1565C0"
                        }
                        Text {
                            id: ideaCountText
                            text: "0"
                            font.pointSize: 28
                            font.bold: false
                            color: "#1565C0"
                        }
                    }
                }
                
                // 标签数卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "#F3E5F5"
                    radius: 8
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        Text {
                            text: "标签"
                            font.pointSize: 14
                            color: "#6A1B9A"
                        }
                        Text {
                            text: allTags.length + " 个"
                            font.pointSize: 28
                            font.bold: false
                            color: "#6A1B9A"
                        }
                    }
                }
            }
            
            // 气泡词云区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "关键词云"
                            font.pointSize: 16
                            font.bold: false
                            color: "#333"
                        }
                        
                        Text {
                            text: "（点击词查看频率）"
                            font.pointSize: 12
                            color: "#999"
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                    
                    // 气泡词云组件
                    BubbleWordCloud {
                        id: wordCloud
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
            
            // 标签词云区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "标签云"
                        font.pointSize: 16
                        font.bold: false
                        color: "#333"
                    }
                    
                    // 标签词云组件
                    BubbleWordCloud {
                        id: tagCloud
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
            
            // 刷新按钮
            Button {
                text: "刷新统计"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                font.pointSize: 15
                
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: false
                    font.pointSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: refreshStats()
            }
        }
    }
}