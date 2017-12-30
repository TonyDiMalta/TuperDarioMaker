import QtQuick 2.0
import VPlay 2.0
import "../common"

PlatformerImageButton {
  id: itemGroupButton

  width: parent.buttonWidth
  height: parent.height

  // make the color grey when selected, white otherwise
  color: selected ? "#c0c0c0" : "#ffffff"

  property bool selected: false
}
