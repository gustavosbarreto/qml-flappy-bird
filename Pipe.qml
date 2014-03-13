import QtQuick 1.1

Item {
    id: pipe
    width: 52
    height: 399

    property bool ignore: false

    BorderImage {
      id: up
      source: "sprites/pipe.png"
      width: parent.width
      horizontalTileMode: BorderImage.Stretch
      verticalTileMode: BorderImage.Stretch
      border { left: 0; top: 52; right: 0; bottom: 0 }
    }

    BorderImage {
      id: down
      source: "sprites/pipe.png"
      height: 100
      width: parent.width
      y: 299
      horizontalTileMode: BorderImage.Stretch
      verticalTileMode: BorderImage.Stretch
      border { left: 0; top: 52; right: 0; bottom: 0 }
    }

    PropertyAnimation {
        id: animation
        running: true
        target: pipe
        properties: "x"
        from: parent.width
        to: pipe.width*-1
        duration: 4000
    }

    function init() {
        var w = Math.floor((Math.random()*200)+40);
        //up.y -= w;
        up.height = w;
        up.rotation = 180;

        down.y = up.height + 120;
        down.height = 399 - (down.y);
    }

    Connections {
        target: game

        onGameOver: {
            pipe.ignore = true
            animation.stop();
        }

        onDestroyPipes: {
            pipe.destroy();
        }

        onBirdPositionChanged: {
            if (!game.initialized) return;
            if (!pipe.ignore && game.bird.y > up.height - 10 && game.bird.y + game.bird.height < down.y + 10) {
                if (game.bird.x > pipe.x + pipe.width) {
                    pipe.ignore = true;
                    game.increaseScore();
                }
            } else {
                if (!pipe.ignore && game.bird.x + game.bird.width >= pipe.x + 10) {
                    pipe.ignore = true;
                    animation.stop();
                    game.terminateGame();
                }
            }
    }
}
}
