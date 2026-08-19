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
        
        // 收集所有标签
        var ideas = dbManager.loadAllIdeas()
        var tags = []
        for (var i = 0; i < ideas.length; i++) {
            if (ideas[i].tags) {
                var parts = ideas[i].tags.split(',')
                for (var j = 0; j < parts.length; j++) {
                    var tag = parts[j].trim()
                    if (tag && tags.indexOf(tag) === -1) {
                        tags.push(tag)
                    }
                }
            }
        }
        allTags = tags
        tagList.model = allTags
        
        // 更新气泡词云
        var allIdeas = dbManager.getAllIdeasForWordCloud()
        if (wordCloud) {
            wordCloud.updateBubbles(allIdeas)
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
                font.bold: true
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
                            font.bold: true
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
                            font.bold: true
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
                            font.bold: true
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
            
            // 标签列表
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "所有标签"
                        font.pointSize: 16
                        font.bold: true
                        color: "#333"
                    }
                    
                    ListView {
                        id: tagList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        orientation: ListView.Horizontal
                        
                        delegate: Rectangle {
                            height: 32
                            color: "#E8EAF6"
                            radius: 16
                            
                            Text {
                                anchors.centerIn: parent
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                text: "#" + modelData
                                font.pointSize: 13
                                color: "#3F51B5"
                            }
                        }
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
                    font.bold: true
                    font.pointSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: refreshStats()
            }
        }
    }
}