import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: rootPage
    focus: true // 防止进入时自动弹出键盘

    property int fontSize: 14
    
    // 标签相关
    property var allTags: []
    property var selectedTags: []
    property string selectedTagsText: ""
    
    function loadTags() {
        allTags = dbManager.loadAllTags()
    }
    
    function toggleTag(tagName) {
        var index = selectedTags.indexOf(tagName)
        if (index >= 0) {
            selectedTags.splice(index, 1)
        } else {
            selectedTags.push(tagName)
        }
        selectedTags = selectedTags.slice()
        updateSelectedTagsText()
    }
    
    function updateSelectedTagsText() {
        selectedTagsText = selectedTags.join(", ")
    }
    
    function addNewTag(tagName) {
        if (tagName.trim().length > 0) {
            dbManager.addTag(tagName.trim())
            loadTags()
        }
    }
    
    function hideAllDeleteButtons() {
        for (var i = 0; i < tagRepeater.count; i++) {
            var item = tagRepeater.itemAt(i)
            if (item) {
                item.showDelete = false
            }
        }
    }
    
    Component.onCompleted: {
        loadTags()
    }

    // 整个页面可滚动
    Flickable {
        id: pageScrollView
        anchors.fill: parent
        // 根据底部导航栏的高度（假设60），留出相应的底边距
        anchors.bottomMargin: 60 
        contentHeight: mainColumn.implicitHeight + 40 
        clip: true
        
        // 隐藏滚动条
        ScrollBar.vertical: ScrollBar {
            visible: false
            policy: ScrollBar.AlwaysOff
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                hideAllDeleteButtons()
            }
        }

        ColumnLayout {
            id: mainColumn
            width: parent.width
            // 给左右下留边距，顶部留足够空间避免太靠上
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: 12
            spacing: 12
            
            // 顶部留白
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }

            // ===== 标题栏 =====
            RowLayout {
                Layout.fillWidth: true
                height: 32
                
                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.35
                }
                
                Text {
                    text: "记录想法"
                    font.pointSize: 18
                    color: "#333"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0.35
                }
            }

            // ===== 输入框区域（Flickable结构，支持滚轮和高度自适应） =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200 // 初始高度
                Layout.minimumHeight: 120
                color: "white"
                radius: 6
                border.color: "#e0e0e0"
                border.width: 1
                clip: true
                
                // 外层 Flickable 控制滚动
                Flickable {
                    id: inputFlickable
                    anchors.fill: parent
                    anchors.margins: 2 // 稍微留一点边距防止边框遮挡
                    contentHeight: ideaInput.implicitHeight
                    clip: true
                    flickableDirection: Flickable.VerticalFlick
                    
                    // 统一滚动条样式 (类似下面的标签)
                    ScrollBar.vertical: ScrollBar {
                        id: inputVBar
                        policy: ScrollBar.AsNeeded
                        width: 6
                        contentItem: Rectangle { 
                            color: "#cccccc"; 
                            radius: 3 
                        }
                    }
                    
                    TextArea {
                        id: ideaInput // 【核心修正】：id 现在是唯一的
                        width: parent.width
                        height: Math.max(parent.height, implicitHeight) // 至少有父容器那么高
                        placeholderText: "今天有什么想法？"
                        font.pointSize: 14
                        wrapMode: TextArea.Wrap
                        padding: 10
                        background: null
                        color: "#333"
                        focus: false
                        
                        // 由于外层 Flickable 接管了滚动，内部去除滚动条
                        ScrollBar.vertical: null
                        
                        onPressed: {
                            hideAllDeleteButtons()
                        }
                    }
                    
                    // 鼠标滚轮支持
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton // 不阻挡点击，只拦截滚轮
                        onWheel: {
                            // 滚轮直接驱动 Flickable
                            inputFlickable.contentY -= wheel.angleDelta.y
                        }
                    }
                }
            }

            // ===== 标签选择区域 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                Layout.minimumHeight: 120
                color: "#fafafa"
                radius: 6
                border.color: "#e0e0e0"
                border.width: 1
                clip: true
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    // 标签输入和添加
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        TextField {
                            id: newTagInput
                            Layout.fillWidth: true
                            height: 34
                            placeholderText: "添加新标签"
                            font.pointSize: 12
                            background: Rectangle {
                                color: "white"
                                radius: 6
                                border.color: "#ddd"
                                border.width: 1
                            }
                            onAccepted: {
                                if (newTagInput.text.trim().length > 0) {
                                    addNewTag(newTagInput.text)
                                    newTagInput.text = ""
                                    hideAllDeleteButtons()
                                }
                            }
                            onPressed: {
                                hideAllDeleteButtons()
                            }
                        }
                        
                        Button {
                            text: "添加"
                            font.pointSize: 12
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 34
                            background: Rectangle {
                                color: "#4CAF50"
                                radius: 6
                            }
                            contentItem: Text {
                                text: "添加"
                                color: "white"
                                font.pointSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                if (newTagInput.text.trim().length > 0) {
                                    addNewTag(newTagInput.text)
                                    newTagInput.text = ""
                                    hideAllDeleteButtons()
                                }
                            }
                        }
                    }
                    
                    // 标签列表
                    Flickable {
                        id: tagFlickable
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: tagFlow.height
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        
                        // 标签列表也隐藏滚动条
                        ScrollBar.vertical: ScrollBar {
                            visible: false
                            policy: ScrollBar.AlwaysOff
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            z: 0
                            onClicked: {
                                hideAllDeleteButtons()
                            }
                        }
                        
                        Flow {
                            id: tagFlow
                            width: parent.width
                            spacing: 6
                            padding: 4
                            
                            Repeater {
                                id: tagRepeater
                                model: allTags
                                
                                Rectangle {
                                    id: tagItem
                                    width: tagRow.width + 20
                                    height: 30
                                    radius: 15
                                    color: selectedTags.indexOf(modelData.name) >= 0 ? "#4CAF50" : "#E8EAF6"
                                    border.color: selectedTags.indexOf(modelData.name) >= 0 ? "#4CAF50" : "#ddd"
                                    border.width: 1
                                    property bool showDelete: false
                                    
                                    Row {
                                        id: tagRow
                                        anchors.centerIn: parent
                                        spacing: 4
                                        
                                        Text {
                                            text: modelData.name
                                            font.pointSize: 12
                                            color: selectedTags.indexOf(modelData.name) >= 0 ? "white" : "#333"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    // 右上角删除按钮
                                    Rectangle {
                                        id: deleteBtn
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: "#f44336"
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.topMargin: -4
                                        anchors.rightMargin: -4
                                        z: 100
                                        opacity: tagItem.showDelete ? 1 : 0
                                        visible: tagItem.showDelete
                                        
                                        Behavior on opacity {
                                            NumberAnimation { duration: 150 }
                                        }
                                        
                                        Text {
                                            text: "×"
                                            font.pointSize: 10
                                            color: "white"
                                            anchors.centerIn: parent
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.margins: -6
                                            z: 101
                                            onClicked: {
                                                dbManager.deleteTag(modelData.id)
                                                loadTags()
                                                hideAllDeleteButtons()
                                            }
                                        }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        z: 1
                                        pressAndHoldInterval: 400
                                        onPressAndHold: {
                                            hideAllDeleteButtons()
                                            tagItem.showDelete = true
                                        }
                                        onClicked: {
                                            if (!tagItem.showDelete) {
                                                toggleTag(modelData.name)
                                            }
                                            tagItem.showDelete = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ===== 保存按钮 =====
            Button {
                text: "保存"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                Layout.maximumWidth: 200
                Layout.alignment: Qt.AlignHCenter
                enabled: ideaInput.text.trim().length > 0
                font.pointSize: 15
                
                background: Rectangle {
                    color: parent.enabled ? "#4CAF50" : "#cccccc"
                    radius: 8
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pointSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    var success = dbManager.saveIdea(ideaInput.text, selectedTagsText)
                    
                    if (success) {
                        savedLabel.text = "已保存！"
                        savedLabel.color = "#4CAF50"
                        ideaInput.text = ""
                        selectedTags = []
                        updateSelectedTagsText()
                        hideAllDeleteButtons()
                        clearTimer.start()
                    } else {
                        savedLabel.text = "保存失败，请重试"
                        savedLabel.color = "#f44336"
                    }
                }
            }

            // ===== 保存提示 =====
            Text {
                id: savedLabel
                text: ""
                color: "#4CAF50"
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: 13
                height: 24
            }
            
            Timer {
                id: clearTimer
                interval: 1500
                onTriggered: savedLabel.text = ""
            }
        }
    }
}