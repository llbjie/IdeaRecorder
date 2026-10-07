import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: listPageRoot
    color: "#f5f5f5"

    property var allIdeas: []
    property var currentPageIdeas: []
    property int currentPage: 1
    property int pageSize: 10
    property int totalCount: 0
    property int totalPages: 0

    property int editingIdeaId: -1
    property var editAllTags: []
    property var editSelectedTags: []

    property int deletingIdeaId: -1

    property string messageText: ""
    property color messageColor: "#4CAF50"

    function refreshList() {
        allIdeas = dbManager.loadAllIdeas()
        totalCount = allIdeas.length
        totalPages = Math.max(1, Math.ceil(totalCount / pageSize))
        if (currentPage > totalPages) currentPage = 1
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

    function nextPage() { if (currentPage < totalPages) goToPage(currentPage + 1) }
    function prevPage() { if (currentPage > 1) goToPage(currentPage - 1) }

    function openEditDialog(idea) {
        editingIdeaId = idea.id
        editContent.text = idea.content
        editDate.text = "创建于 " + idea.createdAt
        editAllTags = dbManager.loadAllTags()
        var rawTags = idea.tags || ""
        editSelectedTags = rawTags.split(/[,，]\s*/).filter(function(t) { return t.length > 0 })
        editDialog.visible = true
    }

    function closeEditDialog() {
        editingIdeaId = -1
        editContent.text = ""
        editDate.text = ""
        editAllTags = []
        editSelectedTags = []
        editDialog.visible = false
    }

    function showMessage(text, color) {
        messageText = text
        messageColor = color || "#4CAF50"
        floatingMessage.visible = true
        floatingMessage.opacity = 1
        messageTimer.start()
    }

    Component.onCompleted: refreshList()
    onVisibleChanged: { if (visible) refreshList() }

    // ==================== 主内容 ====================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "我的想法"
                font.pointSize: 18
                color: "#333"
            }
            Item { Layout.fillWidth: true }
            Text {
                id: countText
                text: "共 0 条"
                font.pointSize: 12
                color: "#999"
            }
            Button {
                text: "刷新"
                font.pointSize: 12
                Layout.preferredWidth: 50
                Layout.preferredHeight: 32
                background: Rectangle { color: "#4CAF50"; radius: 6 }
                contentItem: Text { text: "刷新"; color: "white"; font.pointSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: refreshList()
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            model: currentPageIdeas

            delegate: Rectangle {
                id: delegateRoot
                width: listView.width
                height: 72
                color: "#fff"
                radius: 6
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Rectangle {
                        id: contentArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 2

                            Text {
                                text: modelData.content
                                font.pointSize: 13
                                color: "#333"
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                clip: true
                            }

                            RowLayout {
                                spacing: 6
                                Text {
                                    text: modelData.tags
                                    font.pointSize: 11
                                    color: "#2196F3"
                                    visible: modelData.tags && modelData.tags.length > 0
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                                Text {
                                    text: modelData.createdAt
                                    font.pointSize: 10
                                    color: "#999"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: openEditDialog(modelData)
                        }
                    }

                    Button {
                        id: deleteButton
                        text: "删除"
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 28
                        font.pointSize: 11
                        background: Rectangle { color: "#f44336"; radius: 4 }
                        contentItem: Text {
                            text: "删除"
                            color: "white"
                            font.pointSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            deletingIdeaId = modelData.id
                            deleteConfirmDialog.visible = true
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
                    Text { text: "还没有想法"; font.pointSize: 15; color: "#999"; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "去「记录」页面添加吧"; font.pointSize: 12; color: "#bbb"; Layout.alignment: Qt.AlignHCenter }
                }
            }
        }

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
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    enabled: currentPage > 1
                    onClicked: prevPage()
                    contentItem: Text { text: "上一页"; color: parent.enabled ? "#333" : "#999"; font.pointSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Text {
                    id: pageInfo
                    text: "1 / 1"
                    font.pointSize: 13
                    color: "#333"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Button {
                    text: "下一页"
                    font.pointSize: 12
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    enabled: currentPage < totalPages
                    onClicked: nextPage()
                    contentItem: Text { text: "下一页"; color: parent.enabled ? "#333" : "#999"; font.pointSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }
    }

    // ==================== 浮动消息提示 ====================
    Item {
        id: floatingMessage
        anchors.fill: parent
        visible: false
        z: 400
        MouseArea { anchors.fill: parent; enabled: false }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(300, parent.width - 40)
            height: 48
            radius: 8
            color: messageColor
            opacity: 0.9

            Text {
                anchors.centerIn: parent
                text: messageText
                color: "white"
                font.pointSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Timer {
        id: messageTimer
        interval: 1500
        onTriggered: {
            floatingMessage.visible = false
        }
    }

    // ==================== 编辑弹窗 ====================
    Item {
        id: editDialog
        anchors.fill: parent
        visible: false
        z: 200

        // 半透明遮罩
        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            MouseArea { anchors.fill: parent; onClicked: closeEditDialog() }
        }

        // 对话框主体
        Rectangle {
            id: dialogBox
            anchors.centerIn: parent
            width: Math.min(360, parent.width - 32)
            height: Math.min(520, parent.height - 40)
            color: "white"
            radius: 12
            clip: true

            // 阻止弹窗被拖动
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    mouse.accepted = true
                }
                drag.target: undefined
            }

            // ===== 外层 Flickable：拦截滚轮事件，防止穿透到列表 =====
            Flickable {
                id: outerFlickable
                anchors.fill: parent
                // 设置 contentHeight 与可视区域一样高，这样不会滚动，但会消耗滚轮事件
                contentHeight: height
                // 禁止弹性
                boundsBehavior: Flickable.StopAtBounds
                // 交互开启，以便捕获滚轮
                interactive: true
                // 隐藏滚动条
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff }

                // 内容容器（提供边距）
                Item {
                    anchors.fill: parent
                    anchors.margins: 20

                    Column {
                        id: dialogColumn
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "编辑想法"
                            font.pointSize: 18
                            color: "#333"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            id: editDate
                            text: ""
                            font.pointSize: 11
                            color: "#999"
                        }

                        // 内容输入框
                        Rectangle {
                            width: parent.width
                            height: 140
                            color: "#f5f5f5"
                            radius: 8
                            border.color: "#e0e0e0"
                            border.width: 1
                            clip: true

                            Flickable {
                                id: editContentFlickable
                                anchors.fill: parent
                                anchors.margins: 4
                                contentHeight: editContent.implicitHeight
                                clip: true
                                flickableDirection: Flickable.VerticalFlick
                                boundsBehavior: Flickable.StopAtBounds

                                TextEdit {
                                    id: editContent
                                    width: editContentFlickable.width - 8
                                    height: Math.max(editContentFlickable.height, implicitHeight)
                                    wrapMode: TextEdit.Wrap
                                    font.pointSize: 14
                                    color: "#333"
                                    selectByMouse: true
                                    padding: 8
                                }
                            }
                        }

                        // 标签区域
                        Rectangle {
                            width: parent.width
                            height: 180
                            color: "#fafafa"
                            radius: 8
                            border.color: "#e0e0e0"
                            border.width: 1
                            clip: true

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                RowLayout {
                                    width: parent.width
                                    spacing: 8

                                    TextField {
                                        id: editNewTagInput
                                        Layout.fillWidth: true
                                        height: 34
                                        placeholderText: "添加新标签"
                                        font.pointSize: 12
                                        background: Rectangle { color: "white"; radius: 6; border.color: "#ddd"; border.width: 1 }
                                        onAccepted: {
                                            var tag = editNewTagInput.text.trim()
                                            if (tag.length > 0) {
                                                dbManager.addTag(tag)
                                                editAllTags = dbManager.loadAllTags()
                                                editNewTagInput.text = ""
                                            }
                                        }
                                    }

                                    Button {
                                        text: "添加"
                                        font.pointSize: 12
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 34
                                        background: Rectangle { color: "#4CAF50"; radius: 6 }
                                        contentItem: Text { text: "添加"; color: "white"; font.pointSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                        onClicked: {
                                            var tag = editNewTagInput.text.trim()
                                            if (tag.length > 0) {
                                                dbManager.addTag(tag)
                                                editAllTags = dbManager.loadAllTags()
                                                editNewTagInput.text = ""
                                            }
                                        }
                                    }
                                }

                                Flickable {
                                    id: editTagFlickable
                                    width: parent.width
                                    height: 120
                                    contentHeight: editTagFlow.height
                                    clip: true
                                    flickableDirection: Flickable.VerticalFlick
                                    boundsBehavior: Flickable.StopAtBounds

                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                        width: 6
                                        contentItem: Rectangle { color: "#cccccc"; radius: 3 }
                                    }

                                    Flow {
                                        id: editTagFlow
                                        width: parent.width
                                        spacing: 6
                                        padding: 4

                                        Repeater {
                                            model: editAllTags

                                            Rectangle {
                                                id: editTagItem
                                                width: editTagRow.width + 20
                                                height: 30
                                                radius: 15
                                                color: editSelectedTags.indexOf(modelData.name) >= 0 ? "#4CAF50" : "#E8EAF6"
                                                border.color: editSelectedTags.indexOf(modelData.name) >= 0 ? "#4CAF50" : "#ddd"
                                                border.width: 1

                                                Row {
                                                    id: editTagRow
                                                    anchors.centerIn: parent
                                                    spacing: 4

                                                    Text {
                                                        text: modelData.name
                                                        font.pointSize: 12
                                                        color: editSelectedTags.indexOf(modelData.name) >= 0 ? "white" : "#333"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        var idx = editSelectedTags.indexOf(modelData.name)
                                                        if (idx >= 0) {
                                                            editSelectedTags.splice(idx, 1)
                                                        } else {
                                                            editSelectedTags.push(modelData.name)
                                                        }
                                                        editSelectedTags = editSelectedTags.slice()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 12

                            Rectangle {
                                width: (parent.width - 12) / 2
                                height: 40
                                color: "#999"
                                radius: 8
                                Text { text: "取消"; anchors.centerIn: parent; color: "white"; font.pointSize: 14 }
                                MouseArea { anchors.fill: parent; onClicked: closeEditDialog() }
                            }

                            Rectangle {
                                width: (parent.width - 12) / 2
                                height: 40
                                color: "#4CAF50"
                                radius: 8
                                Text { text: "保存"; anchors.centerIn: parent; color: "white"; font.pointSize: 14 }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        dbManager.updateIdea(editingIdeaId, editContent.text, editSelectedTags.join(", "))
                                        closeEditDialog()
                                        refreshList()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== 删除确认弹窗 ====================
    Item {
        id: deleteConfirmDialog
        anchors.fill: parent
        visible: false
        z: 300

        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            MouseArea { anchors.fill: parent; onClicked: deleteConfirmDialog.visible = false }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 280
            height: 140
            color: "white"
            radius: 12

            MouseArea { anchors.fill: parent }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Text {
                    text: "确认删除"
                    font.pointSize: 16
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "删除后不可恢复，确定要删除吗？"
                    font.pointSize: 13
                    color: "#666"
                    wrapMode: Text.Wrap
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    spacing: 12
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 100
                        height: 36
                        color: "#999"
                        radius: 6
                        Text { text: "取消"; anchors.centerIn: parent; color: "white"; font.pointSize: 13 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                deleteConfirmDialog.visible = false
                                deletingIdeaId = -1
                            }
                        }
                    }

                    Rectangle {
                        width: 100
                        height: 36
                        color: "#f44336"
                        radius: 6
                        Text { text: "删除"; anchors.centerIn: parent; color: "white"; font.pointSize: 13 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (deletingIdeaId > 0) {
                                    var success = dbManager.deleteIdea(deletingIdeaId)
                                    deleteConfirmDialog.visible = false
                                    deletingIdeaId = -1
                                    refreshList()
                                    if (success) {
                                        showMessage("已删除", "#4CAF50")
                                    } else {
                                        showMessage("删除失败", "#f44336")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}