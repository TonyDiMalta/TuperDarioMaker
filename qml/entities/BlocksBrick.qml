import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: blocks
  entityType: "blocks"
  variationType: "brick"

  // this property is true when the player collected the coin
  property bool collected: false

  // set the size to the sprite's size
  width: image.width
  height: image.height

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image according to the scene and block state
  image.source: inLevelEditingMode ? "../../assets/blocks/coin_block.png" :
                         collected ? "../../assets/blocks/empty_block.png" :
                                     "../../assets/blocks/brick_block.png"

  // animate block position changes
  Behavior on y { NumberAnimation { duration: 100 } }

  // used to reset the block to its initial position
  Timer {
    id: animTimer

    interval: 100

    running: false

    onTriggered: {
      y += height / 2
      collected = true
    }
  }

  BoxCollider {
    id: collider

    anchors.fill: parent
    bodyType: Body.Static

    // Category5: solids
    categories: Box.Category5
    // Category1: player body, Category2: player feet sensor,
    // Category3: opponent body, Category4: opponent sensor
    collidesWith: Box.Category1 | Box.Category2 | Box.Category3 | Box.Category4
  }

  // if the block coin isn't collected, collect it
  function smash() {
    if(collected)
      return

    y -= height / 2
    animTimer.start()
    console.debug("collect coin")
    ++gameScene.player.coins
    gameScene.score += 200

    audioManager.playSound("collectCoin")
  }

  // reset block
  function reset() {
    collected = false
  }
}
