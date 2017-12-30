import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: blocks
  entityType: "blocks"
  variationType: "?"

  // this property is true when the player collected the powerup
  property bool collected: false

  // set the size to the sprite's size
  width: image.width
  height: image.height

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: collected ? "../../assets/blocks/empty_block.png" :
                            "../../assets/blocks/question_block.png"

  // hide the image if we need to display the animation
  image.visible: inLevelEditingMode || collected

  SpriteSequenceVPlay {
    id: blockAnim

    defaultSource: "../../assets/blocks/question_block_anim.png"
    width: image.width
    height: image.height

    running: !inLevelEditingMode && !collected && gameScene.state !== "dead"
    visible: !inLevelEditingMode && !collected

    // animate the question mark rotation
    SpriteVPlay {
      name: "rotate"
      frameCount: 16
      startFrameColumn: 1
      frameRate: 20
      to: {"rotate": 1}
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

  // if the block powerup isn't collected, collect it
  function smash() {
    if(collected)
      return

    collected = true
    console.debug("item appeared: mushroom")
    var entityId = entityManager.createEntityFromEntityTypeAndVariationType( {entityType: "mushroom"} )
    var entity = entityManager.getEntityById(entityId)
    entity.poolingEnabled = false
    entity.x = x + 8
    entity.y = y - 16
    entity.rescale()

    audioManager.playSound("itemAppear")
  }

  // reset block
  function reset() {
    collected = false
  }
}
