import QtQuick 2.0
import QtQuick.Window 2.2

Window {
    id: game
    visible: true
    visibility: Window.FullScreen

    property bool initialized: false
    property alias bird: bird

    width: 288
    height: 511

    signal birdPositionChanged
    signal gameOver
    signal destroyPipes

    function terminateGame() {
        initialized = false

        game.gameOver()

        backgroundAnim.stop()
        groundAnim.stop()
        pipeCreator.stop()
        birdRotation.complete()

        gravity.interval = 6

        //        gameOverAnim.start();

        score.opacity = 0;
    }

    function increaseScore() {
        var component = Qt.createComponent("Font.qml")

        score.count++

        for (var i = 0; i < score.children.length; i++)
            score.children[i].destroy()

        if (parseInt(score.count / 10) == 0) {
            score.width = 24

            var font = component.createObject(score)
            font.setIndex(score.count)
        } else {
            var n1 = parseInt(score.count / 10)
            var n2 = parseInt(score.count % 10)

            score.width = 48

            var f1 = component.createObject(score)
            f1.setIndex(n1)
            var f2 = component.createObject(score)
            f2.setIndex(n2)
            f2.x = 24
        }
    }

    function setFinalScore(value) {
        var component = Qt.createComponent("Font.qml")

        for (var i = 0; i < finalScore.children.length; i++)
            finalScore.children[i].destroy()

        if (parseInt(value / 10) == 0) {
            finalScore.width = 12

            var font = component.createObject(finalScore)
            font.setSize(12, 14);
            font.setFileName("sprites/fontmini.png");
            font.setIndex(value)
        } else {
            var n1 = parseInt(value / 10)
            var n2 = parseInt(value % 10)

            score.width = 24

            var f1 = component.createObject(finalScore)
            f1.setSize(12, 14);
            f1.setFileName("sprites/fontmini.png");
            f1.setIndex(n1)
            var f2 = component.createObject(finalScore)
            f2.setSize(12, 14);
            f2.setFileName("sprites/fontmini.png");
            f2.setIndex(n2)
            f2.x = 12
        }
    }

    function flappy() {
        if (!initialized) {
            initialized = true

            tap.opacity = 0;
            ready.opacity = 0;
            score.opacity = 1;
            score.count = 0;

            for (var i = 0; i < score.children.length; i++)
                score.children[i].destroy()

            gravity.start()
            backgroundAnim.start()
            groundAnim.start()
            pipeCreator.start()

            return
        }

        jumpAnim.from = bird.y
        jumpAnim.to = bird.y - 75
        jumpAnim.start()

        birdRotation.from = bird.rotation
        birdRotation.start()
    }

    Item {
        width: 288
        height: 511
        focus: true
        clip: true

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Keys.onPressed: {
            if (playAgain.opacity == 1) {
                playAgain.restart();
            } else {
                game.flappy()
            }
        }

        Image {
            id: background
            source: "sprites/bg.png"
            width: parent.width
            height: parent.height
            fillMode: Image.TileHorizontally


            //anchors.verticalCenter: parent.verticalCenter

            Timer {
                id: backgroundAnim
                interval: 75
                repeat: true
                running: true

                onTriggered: {
                    background.x -= 2
                    background.width += 2
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: flappy()
            }
        }

        Image {
            id: ground
            source: "sprites/ground.png"

            height: 112
            y: parent.height - height
            fillMode: Image.TileHorizontally

            width: parent.width

            Connections {
                target: game

                onBirdPositionChanged: {
                    if (game.bird.y + game.bird.height >= ground.y) {
                        if (game.initialized) game.terminateGame()
                        gravity.stop()
                        gameOverAnim.start();
                    }
                }
            }

            Timer {
                id: groundAnim
                interval: 12
                repeat: true
                running: true

                onTriggered: {
                    ground.x -= 6
                    ground.width += 6
                }
            }
        }

        Image {
            id: ready
            anchors.horizontalCenter: parent.horizontalCenter
            source: "sprites/getready.png"
            y: 60
        }

        Image {
            id: tap
            anchors.horizontalCenter: parent.horizontalCenter
            source: "sprites/tap.png"
            y: 150
        }

        Image {
            id: gameOverSplash
            anchors.horizontalCenter: parent.horizontalCenter
            source: "sprites/gameover.png"
            height: 44
            y: -height
            z: 2

            PropertyAnimation {
                id: gameOverAnim
                target: gameOverSplash
                properties: "y"
                from: -gameOverSplash.height
                to: 60
                duration: 600

                onRunningChanged: {
                    if (!running) {
                        medalsTable.opacity = 1;
                        playAgain.opacity = 1;
                        console.log(score.count);
                        setFinalScore(score.count);
                    }
                    //
                }
            }
        }

        Image {
            id: medalsTable
            source: "sprites/medalstable.png"
            anchors.top: gameOverSplash.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            z: 2
            opacity: 0

            Image {
                //            source: "bronzemedal.png"
                x: 24
                y: 42
            }

            Item {
                id: finalScore
                width: 12
                height: 24
                x: 170
                y: 35
            }
        }

        Image {
            id: playAgain
            source: "sprites/playagain.png"
            anchors.top: medalsTable.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0
            z: 2

            function restart() {
                playAgain.opacity = 0;
                medalsTable.opacity = 0;

                gameOverSplash.y = -gameOverSplash.height;
                ready.opacity = 1;
                tap.opacity = 1;
                game.destroyPipes();

                backgroundAnim.start();
                groundAnim.start();

                bird.y = 180;
                bird.rotation = 0;

                gravity.interval = 9;
            }

        }

        Timer {
            id: pipeCreator
            interval: 2500
            repeat: true

            onTriggered: {
                var component = Qt.createComponent("Pipe.qml")
                var pipe = component.createObject(parent)
                pipe.init()
            }
        }

        Image {
            id: bird
            rotation: 0
            source: "sprites/bird.png"
            width: 34
            height: 24
            x: (parent.width / 2 - width / 2) - 60
            y: 180
            z: 1

            onYChanged: {
                game.birdPositionChanged()
            }
        }

        Item {
            id: score
            width: 24
            height: 36
            anchors.horizontalCenter: parent.horizontalCenter
            y: 10
            z: 1
            property int count: 0
        }
    }

    SequentialAnimation {
        id: birdRotation

        property alias from : firstMoviment.from

        PropertyAnimation {
            id: firstMoviment
            target: bird
            properties: "rotation"
            duration: 50
            to: -50
        }

        PropertyAnimation {
            target: bird
            properties: "rotation"
            duration: 300
            to: 40
        }
    }

    Timer {
        id: gravity

        repeat: true
        interval: 9

        onTriggered: {
            bird.y += 2
        }
    }

    PropertyAnimation {
        id: jumpAnim
        easing.type: Easing.OutQuad
        target: bird
        properties: "y"
        duration: 300
    }
}
