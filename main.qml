import QtQuick 2.0
import QtQuick.Window 2.2

Window {
    visible: true
    visibility: Window.FullScreen

    Game {
        height: 480

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
