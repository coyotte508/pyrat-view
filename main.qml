import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Layouts 1.1
import QtQuick.Particles 2.0

Window {
    visible: true
    width: 1050
    height: 650

    property var maze: ({})
    property var coins: ({})
    property var p1Pos: ({x: 0, y: 24})
    property var p2Pos: ({x: 24, y: 0})

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
//                font.pointSize: 8
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
        return loadDataStr(io.getFile(fileName));
    }

    function loadDataStr(data) {
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

        io.p1Moved.connect(function(x, y) {p1Pos = {"x": x, "y": y};});
        io.p2Moved.connect(function(x, y) {p2Pos = {"x": x, "y": y};});
        io.coinsUpdated.connect(function(coinsStr) {
            var coins = loadDataStr(coinsStr);
            this.coins = ({});

            for (var x in coins) {
                this.coins[coordsToInt(coins[x])] = true;
            }
        });
    }

    Rectangle {
        anchors.fill: parent
        Text {
            id: score1
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: 28
            text: "Score p1"
            width: 200
        }

        GridView {
            id: grid
            delegate: gridDelegate
            cellHeight: 25
            cellWidth: 25
            width: 650
            model:0
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: score1.right

            Rectangle {
                id: p1
                x: p1Pos.x * grid.cellWidth + 5
                y: p1Pos.y * grid.cellHeight + 5
                width : grid.cellWidth - 10
                height: grid.cellHeight - 10
                color: "black"
            }

            Rectangle {
                id: p2
                property real prop: 1
                x: p2Pos.x * grid.cellWidth * prop + 5
                y: p2Pos.y * grid.cellHeight + 5
                width : grid.cellWidth - 10
                height: grid.cellHeight - 10
                color: "blue"
                z: 100

                SequentialAnimation {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { target: p2; property: "prop"; duration: 5000; easing.type: Easing.Linear; to: 0 }
                    NumberAnimation { target: p2; property: "prop"; duration: 5000; easing.type: Easing.Linear; to: 1 }
                }
            }

            ParticleSystem {
                z: 99

                Emitter {
                    x: p2.x
                    y: p2.y
                    width: p2.width
                    height: p2.height
                    group: "A"
                    emitRate: 50
                    lifeSpan: 1500
                    //velocityFromMovement: -100
                }


                ImageParticle {
                    source: "qrc:/lightparticle2.png"
                    groups: "A"
                }
            }
        }

        Text {
            anchors.left: grid.right
            font.pointSize: 28
            width: 200
            text: "Score p2"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
