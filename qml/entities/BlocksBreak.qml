import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: blocks
  entityType: "blocks"
  variationType: "break"

  // this property is true if the block is destroyed
  property bool destroyed: false

  // set the size to the sprite's size
  width: image.width
  height: image.height

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/blocks/brick_block.png"

  // hide the image when the block is destroyed
  image.visible: !destroyed

  BoxCollider {
    id: collider

    anchors.fill: parent
    bodyType: Body.Static

    // disable collider when block is destroyed
    active: !destroyed

    // Category5: solids
    categories: Box.Category5
    // Category1: player body, Category2: player feet sensor,
    // Category3: opponent body, Category4: opponent sensor
    collidesWith: Box.Category1 | Box.Category2 | Box.Category3 | Box.Category4
  }

  // if the block isn't destroyed, destroy it
  function smash() {
    if(destroyed)
      return

    destroyed = true
    audioManager.playSound("breakBlock")
  }

  // reset block
  function reset() {
    destroyed = false
  }
}
