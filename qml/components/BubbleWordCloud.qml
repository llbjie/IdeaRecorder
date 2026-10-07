import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: "transparent"
    
    property var wordData: []
    property int maxCount: 1
    
    property var colors: [
        "#E53935", "#8E24AA", "#1E88E5", "#43A047",
        "#FB8C00", "#00ACC1", "#6D4C41", "#D81B60",
        "#3949AB", "#00897B", "#F4511E", "#7B1FA2",
        "#0288D1", "#388E3C", "#F57C00", "#00838F"
    ]
    
    property var bubbles: []
    property string selectedWord: ""
    property int selectedCount: 0
    
    function updateBubbles(ideas) {
        var allText = ""
        for (var i = 0; i < ideas.length; i++) {
            allText += ideas[i].content + " "
        }
        
        var words = allText.split(/[\s,，。.!！?？;；、\n\r\t]+/)
        
        var stopWords = [
            "的", "了", "是", "在", "我", "有", "和", "就", "不", "人", "都",
            "一", "一个", "上", "也", "很", "到", "说", "要", "去", "你", "会",
            "着", "没有", "看", "好", "自己", "来", "这", "那", "什么", "怎么",
            "吧", "啊", "呢", "哦", "嗯", "哈", "嘿", "哎", "哇"
        ]
        
        var wordCount = {}
        for (var j = 0; j < words.length; j++) {
            var word = words[j].trim()
            if (word.length < 2 || stopWords.indexOf(word) !== -1 || !isNaN(word)) {
                continue
            }
            if (wordCount[word]) {
                wordCount[word]++
            } else {
                wordCount[word] = 1
            }
        }
        
        var wordArray = []
        for (var key in wordCount) {
            wordArray.push({word: key, count: wordCount[key]})
        }
        wordArray.sort(function(a, b) { return b.count - a.count })
        
        if (wordArray.length > 20) {
            wordArray = wordArray.slice(0, 20)
        }
        
        root.wordData = wordArray
        if (wordArray.length > 0) {
            root.maxCount = wordArray[0].count
        }
        
        generateBubbleLayout()
    }
    
    function updateBubblesWithData(data) {
        var wordArray = []
        for (var i = 0; i < data.length; i++) {
            wordArray.push({word: data[i].word, count: data[i].count})
        }
        wordArray.sort(function(a, b) { return b.count - a.count })
        
        if (wordArray.length > 20) {
            wordArray = wordArray.slice(0, 20)
        }
        
        root.wordData = wordArray
        if (wordArray.length > 0) {
            root.maxCount = wordArray[0].count
        }
        
        generateBubbleLayout()
    }
    
    function generateBubbleLayout() {
        var containerWidth = root.width - 20
        var containerHeight = root.height - 20
        
        if (containerWidth < 10) containerWidth = 300
        if (containerHeight < 10) containerHeight = 200
        
        var bubbles = []
        var padding = 6
        var minRadius = 20
        var maxRadius = Math.min(containerWidth, containerHeight) / 2 * 0.45
        
        for (var i = 0; i < root.wordData.length; i++) {
            var item = root.wordData[i]
            var ratio = item.count / root.maxCount
            var radius = minRadius + ratio * (maxRadius - minRadius)
            var textWidth = item.word.length * 6 + 16
            var minTextRadius = textWidth / 1.8
            if (radius < minTextRadius) radius = minTextRadius
            
            bubbles.push({
                word: item.word,
                count: item.count,
                radius: radius,
                x: 0,
                y: 0,
                placed: false
            })
        }
        
        bubbles.sort(function(a, b) { return b.radius - a.radius })
        
        var placedBubbles = []
        var maxAttempts = 2000
        
        for (var k = 0; k < bubbles.length; k++) {
            var bubble = bubbles[k]
            var placed = false
            var tryCount = 0
            
            while (!placed && tryCount < maxAttempts) {
                tryCount++
                
                var x = padding + Math.random() * (containerWidth - 2 * bubble.radius - padding * 2)
                var y = padding + Math.random() * (containerHeight - 2 * bubble.radius - padding * 2)
                
                var overlap = false
                for (var l = 0; l < placedBubbles.length; l++) {
                    var other = placedBubbles[l]
                    var dx = x - other.x
                    var dy = y - other.y
                    var dist = Math.sqrt(dx * dx + dy * dy)
                    var minDist = bubble.radius + other.radius + padding
                    
                    if (dist < minDist) {
                        overlap = true
                        break
                    }
                }
                
                if (!overlap) {
                    bubble.x = x
                    bubble.y = y
                    bubble.placed = true
                    placed = true
                    placedBubbles.push(bubble)
                }
            }
            
            if (!placed) {
                var corners = [
                    {x: padding, y: padding},
                    {x: containerWidth - 2 * bubble.radius - padding, y: padding},
                    {x: padding, y: containerHeight - 2 * bubble.radius - padding},
                    {x: containerWidth - 2 * bubble.radius - padding, y: containerHeight - 2 * bubble.radius - padding}
                ]
                
                for (var c = 0; c < corners.length; c++) {
                    var cx = corners[c].x
                    var cy = corners[c].y
                    var overlap2 = false
                    
                    for (var m = 0; m < placedBubbles.length; m++) {
                        var other2 = placedBubbles[m]
                        var dx2 = cx - other2.x
                        var dy2 = cy - other2.y
                        var dist2 = Math.sqrt(dx2 * dx2 + dy2 * dy2)
                        var minDist2 = bubble.radius + other2.radius + padding
                        
                        if (dist2 < minDist2) {
                            overlap2 = true
                            break
                        }
                    }
                    
                    if (!overlap2) {
                        bubble.x = cx
                        bubble.y = cy
                        bubble.placed = true
                        placedBubbles.push(bubble)
                        placed = true
                        break
                    }
                }
            }
        }
        
        root.bubbles = placedBubbles
        updateDisplay()
    }
    
    function updateDisplay() {
        var children = bubbleContainer.children
        for (var i = children.length - 1; i >= 0; i--) {
            children[i].destroy()
        }
        
        for (var j = 0; j < root.bubbles.length; j++) {
            var data = root.bubbles[j]
            var colorIndex = j % root.colors.length
            var fontSize = Math.max(10, data.radius * 0.55)
            var textColor = root.colors[colorIndex]
            
            var brightness = getColorBrightness(textColor)
            var textColor2 = brightness > 180 ? "#333" : "white"
            
            //使用整数半径，避免"预期是整数"错误
            var radiusInt = Math.round(data.radius)
            var fontSizeInt = Math.round(fontSize)
            
            // 使用字符串模板构建，确保所有值都是整数
            var qmlString = [
                'import QtQuick;',
                'Rectangle {',
                '   x: ' + Math.round(data.x) + ';',
                '   y: ' + Math.round(data.y) + ';',
                '   width: ' + (radiusInt * 2) + ';',
                '   height: ' + (radiusInt * 2) + ';',
                '   radius: ' + radiusInt + ';',
                '   color: "' + textColor + '";',
                '   opacity: 0.9;',
                '   border.color: "' + textColor + '";',
                '   border.width: 2;',
                '   Text {',
                '       anchors.centerIn: parent;',
                '       text: "' + data.word + '";',
                '       font.pointSize: ' + fontSizeInt + ';',
                '       font.bold: false;',
                '       color: "' + textColor2 + '";',
                '       horizontalAlignment: Text.AlignHCenter;',
                '       verticalAlignment: Text.AlignVCenter;',
                '       wrapMode: Text.Wrap;',
                '       width: parent.width - 8;',
                '   }',
                '   MouseArea {',
                '       anchors.fill: parent;',
                '       hoverEnabled: true;',
                '       cursorShape: Qt.PointingHandCursor;',
                '       onEntered: parent.scale = 1.05;',
                '       onExited: parent.scale = 1.0;',
                '       onClicked: {',
                '           root.selectedWord = "' + data.word + '";',
                '           root.selectedCount = ' + data.count + ';',
                '           toast.show("' + data.word + '", ' + data.count + ');',
                '       }',
                '   }',
                '   Behavior on scale { NumberAnimation { duration: 150 } }',
                '}'
            ].join(' ')
            
            Qt.createQmlObject(qmlString, bubbleContainer)
        }
    }
    
    function getColorBrightness(hexColor) {
        var r = parseInt(hexColor.substring(1,3), 16)
        var g = parseInt(hexColor.substring(3,5), 16)
        var b = parseInt(hexColor.substring(5,7), 16)
        return (r * 299 + g * 587 + b * 114) / 1000
    }
    
    Item {
        id: bubbleContainer
        anchors.fill: parent
        anchors.margins: 10
    }
    
    // 点击词频率提示 - 居中弹出，1秒后消失
    Rectangle {
        id: toast
        anchors.centerIn: bubbleContainer
        width: toastLabel.width + 32
        height: 36
        color: "#333333"
        radius: 18
        opacity: 0
        visible: false
        
        Text {
            id: toastLabel
            anchors.centerIn: parent
            text: ""
            font.pointSize: 12
            color: "white"
        }
        
        SequentialAnimation {
            id: toastAnimation
            PropertyAction { target: toast; property: "visible"; value: true }
            NumberAnimation { target: toast; property: "opacity"; to: 0.95; duration: 150 }
            PauseAnimation { duration: 1000 }
            NumberAnimation { target: toast; property: "opacity"; to: 0; duration: 300 }
            PropertyAction { target: toast; property: "visible"; value: false }
        }
        
        function show(word, count) {
            toastLabel.text = word + "  " + count + " 次"
            toastAnimation.start()
        }
    }
    
    onWidthChanged: {
        if (root.wordData.length > 0) {
            generateBubbleLayout()
        }
    }
    onHeightChanged: {
        if (root.wordData.length > 0) {
            generateBubbleLayout()
        }
    }
    
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