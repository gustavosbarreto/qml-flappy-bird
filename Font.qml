import QtQuick 1.1

 Item {
    id: fonts

     width: 24
     height: 36
     clip: true
     z: 1

     Image {
        id: font
        source: "sprites/font.png"
        x: -parent.width * 0
    }

    function setFileName(file) {
        font.source = file;
    }

    function setSize(w, h) {
        fonts.width = w;
        fonts.height = h;
    }

    function setIndex(i) {
        font.x = -fonts.width * i;
    }
}
