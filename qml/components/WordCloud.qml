import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: "transparent"
    
    property var wordData: []  // [{word: "学习", count: 5}, ...]
    property int maxCount: 1
    
    // 颜色数组
    property var colors: [
        "#E53935", "#8E24AA", "#1E88E5", "#43A047",
        "#FB8C00", "#00ACC1", "#6D4C41", "#D81B60",
        "#3949AB", "#00897B"
    ]
    
    function updateWordCloud(ideas) {
        // 1. 提取所有文本
        var allText = ""
        for (var i = 0; i < ideas.length; i++) {
            allText += ideas[i].content + " "
        }
        
        // 2. 分词（简单按标点和空格分割）
        var words = allText.split(/[\s,，。.!！?？;；、\n\r\t]+/)
        
        // 3. 过滤停用词（常见无意义词）
        var stopWords = [
            "的", "了", "是", "在", "我", "有", "和", "就", "不", "人", "都",
            "一", "一个", "上", "也", "很", "到", "说", "要", "去", "你", "会",
            "着", "没有", "看", "好", "自己", "来", "这", "那", "什么", "怎么",
            "吧", "啊", "呢", "哦", "嗯", "哈", "嘿", "哎", "哇"
        ]
        
        var wordCount = {}
        for (var j = 0; j < words.length; j++) {
            var word = words[j].trim()
            // 过滤：空字符串、单字符、停用词、纯数字
            if (word.length < 2 || stopWords.indexOf(word) !== -1 || !isNaN(word)) {
                continue
            }
            if (wordCount[word]) {
                wordCount[word]++
            } else {
                wordCount[word] = 1
            }
        }
        
        // 4. 转换为数组并排序
        var wordArray = []
        for (var key in wordCount) {
            wordArray.push({word: key, count: wordCount[key]})
        }
        wordArray.sort(function(a, b) { return b.count - a.count })
        
        // 5. 取前 30 个高频词
        if (wordArray.length > 30) {
            wordArray = wordArray.slice(0, 30)
        }
        
        // 6. 更新属性
        root.wordData = wordArray
        if (wordArray.length > 0) {
            root.maxCount = wordArray[0].count
        }
        
        // 7. 重新生成布局
        wordCloudContainer.children = []
        for (var k = 0; k < wordArray.length; k++) {
            var item = wordArray[k]
            var fontSize = 12 + (item.count / root.maxCount) * 28  // 12-40px
            
            var colorIndex = k % root.colors.length
            var textColor = root.colors[colorIndex]
            
            var textComponent = Qt.createQmlObject(
                'import QtQuick; Text {' +
                '   text: "' + item.word + '";' +
                '   font.pointSize: ' + fontSize + ';' +
                '   font.bold: ' + (fontSize > 28) + ';' +
                '   color: "' + textColor + '";' +
                '   opacity: 0.7 + 0.3 * (' + item.count + ' / ' + root.maxCount + ');' +
                '   x: Math.random() * (parent.width - 60);' +
                '   y: Math.random() * (parent.height - 40);' +
                '   MouseArea {' +
                '       anchors.fill: parent;' +
                '       hoverEnabled: true;' +
                '       onEntered: parent.font.bold = true;' +
                '       onExited: parent.font.bold = ' + (fontSize > 28) + ';' +
                '       onClicked: parent.opacity = 0.3;' +
                '   }' +
                '}',
                wordCloudContainer
            )
        }
    }
    
    // 容器
    Item {
        id: wordCloudContainer
        anchors.fill: parent
    }
    
    // 空状态
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: root.wordData.length === 0
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: ""
                font.pointSize: 48
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "还没有足够的数据"
                font.pointSize: 16
                color: "#999"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "添加一些想法后，词云会自动生成"
                font.pointSize: 14
                color: "#bbb"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}