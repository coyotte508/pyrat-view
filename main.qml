import QtQuick 2.2
import QtQuick.Window 2.1

Window {
    visible: true
    width: 800
    height: 650

    property var maze: ({})
    property var coins: ({})

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Qt.quit();
        }
    }

    Text {
        text: qsTr("Hello World")
        anchors.centerIn: parent
    }


    function wallTop(index) {
        return wallCheck(index, 0, -1);
    }

    function wallBottom(index) {
        return wallCheck(index, 0, 1);
    }

    function wallLeft(index) {
        return wallCheck(index, -1, 0);
    }

    function wallRight(index) {
        return wallCheck(index, 1, 0);
    }

    function wallCheck(index, xd, yd) {
        var coords = intToCoords(index);
        var around = maze[coordsToStr(coords)];
        for (var x in around) {
            if (coordsToStr(around[x][0]) === coordsToStr([coords[0]+xd, coords[1]+yd])) {
                return around[x][1];
            }
        }

        return 0;
    }

    Component {
        id: gridDelegate

        Rectangle{
            color: coins[index] ? "yellow" : "white"
            width: grid.cellWidth
            height: grid.cellHeight

//            Text {
//                text: index
//                anchors.centerIn: parent
//            }

            Rectangle {
                id: borderLeft
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                property int strength: wallLeft(index)
                height: strength == 1 ? 0 : (strength == 0 ? parent.height : strength)
                width: 1
                color: "black"
            }

            Rectangle {
                id: borderRight
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                property int strength: wallRight(index)
                height: strength == 1 ? 0 : (strength == 0 ? parent.height : strength)
                width: 1
                color:"black"
            }

            Rectangle {
                id: borderTop
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                property int strength: wallTop(index)
                width: strength == 1 ? 0 : (strength == 0 ? parent.width : strength)
                height: 1
                color: "black"
            }

            Rectangle {
                id: borderBottom
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                property int strength: wallBottom(index)
                width: strength == 1 ? 0 : (strength == 0 ? parent.width : strength)
                height: 1
                color: "black"
            }
        }
    }

    GridView {
        id: grid
        delegate: gridDelegate
        cellHeight: 25
        cellWidth: 25
        model:0
    }

    function getSize(maze) {
        var w = 0;
        var h = 0;
        for (var x in maze) {
            x = strToCoords(x);
            if (x[0] > w) {
                w = x[0];
            }
            if (x[1] > h) {
                h = x[1];
            }
        }

        return {"w":w+1, "h":h+1};
    }

    function coordsToInt(c) {
        return c[0] + c[1]*maze.w;
    }

    function intToCoords(x) {
        return [(x % maze.w), Math.floor(x/maze.w)];
    }

    function strToCoords(key) {
        var coords = key.split("x");
        return [parseInt(coords[0]), parseInt(coords[1])];
    }

    function coordsToStr(c) {
        return c[0] + "x" + c[1];
    }

    function loadData(fileName) {
        var data = io.getFile(fileName);
        data = data.replace(/\(([^)]*),[ ]*([^)]*)\):/g, '"$1x$2":');
        data = data.replace(/\(/g, "[");
        data = data.replace(/\)/g, "]");
        return JSON.parse(data);
    }

    Component.onCompleted: {
        var coins = loadData(":coins.txt");
        maze = loadData(":maze.txt");

        var size = getSize(maze);

        maze.w = size.w;
        maze.h = size.h;

        for (var x in coins) {
            this.coins[coordsToInt(coins[x])] = true;
        }

        //console.debug(JSON.stringify(this.coins));

        grid.width = size.w * grid.cellWidth;
        grid.height = size.h * grid.cellHeight;
        grid.model = size.w * size.h;

        console.log(JSON.stringify(size));
    }
}
