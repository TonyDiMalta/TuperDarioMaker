import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: mushroom
  entityType: "mushroom"

  // this property is true when the player collected the mushroom
  property bool collected: false

  // when the mushroom is collected, it shouldn't be visible anymore
  image.visible: !collected

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/powerups/mushroom.png"

  property int x0: x - 8
  property int y0: y - 16

  // animate scale changes
  ParallelAnimation {
    id: animScale
    running: false
    NumberAnimation { target: mushroom; property: "scale"; to: 1; duration: 500 }
    NumberAnimation { target: mushroom; property: "x"; to: x0; duration: 500 }
    NumberAnimation { target: mushroom; property: "y"; to: y0; duration: 500 }
  }

  BoxCollider {
    id: collider

    // make the collider a little smaller than the sprite
    width: parent.width - 1
    height: parent.height - 1
    anchors.centerIn: parent

    // disable collider when mushroom is collected
    active: !collected

    // the collider is static (shouldn't move) and only test
    // for collisions
    bodyType: Body.Static
    collisionTestingOnlyMode: true

    // Category6: powerup
    categories: Box.Category6
    // Category1: player body
    collidesWith: Box.Category1
  }

  // collect mushroom
  function collect() {
    console.debug("collect mushroom")
    collected = true
    gameScene.score += 1000

    audioManager.playSound("collectMushroom")
  }

  // reset mushroom
  function reset() {
    collected = false
  }

  // rescale mushroom
  function rescale() {
    scale = 0.5
    animScale.running = true
  }
}
