import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: coin
  entityType: "coin"

  // this property is true when the player collected the coin
  property bool collected: false

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/coin/coin.png"

  // hide the image if we need to display the animation
  image.visible: inLevelEditingMode

  SpriteSequenceVPlay {
    id: coinAnim

    defaultSource: "../../assets/coin/coin_anim.png"
    width: image.width
    height: image.height

    running: !inLevelEditingMode && !collected && gameScene.state !== "dead"
    visible: !inLevelEditingMode && !collected

    // animate the coin rotation
    SpriteVPlay {
      name: "rotate"
      frameCount: 8
      startFrameColumn: 1
      frameRate: 10
      to: {"rotate": 1}
    }
  }

  CircleCollider {
    id: collider

    // make the collider a little smaller than the sprite
    radius: parent.width / 2 - 3

    // center collider
    x: 3
    y: 3

    // disable collider when coin is collected
    active: !collected

    // the collider is static (shouldn't move) and should only test
    // for collisions
    bodyType: Body.Static
    collisionTestingOnlyMode: true

    // Category6: powerup
    categories: Box.Category6
    // Category1: player body
    collidesWith: Box.Category1
  }

  // collect coin
  function collect() {
    console.debug("collect coin")
    coin.collected = true
    ++gameScene.player.coins
    gameScene.score += 200

    audioManager.playSound("collectCoin")
  }

  // reset coin
  function reset() {
    coin.collected = false
  }
}
