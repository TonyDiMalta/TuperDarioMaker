import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: finish
  entityType: "finish"

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/finish/goal_pole.png"

  // start the goal pole from the ground
  image.y: 32 - height

  // handle pole collision
  BoxCollider {
    id: collider

    // fit the collider with the sprite
    width: 6
    height: parent.height - 39
    x: 17
    y: 16 + image.y

    // the collider is static (shouldn't move) and only test
    // for collisions
    bodyType: Body.Static

    // Category5: solids
    categories: Box.Category5
    // Category1: player body, Category2: player feet sensor,
    // Category3: opponent body, Category4: opponent sensor
    collidesWith: Box.Category1 | Box.Category2 | Box.Category3 | Box.Category4

    // the collider should not be active in edit mode
    active: !inLevelEditingMode

    // this is called whenever the contact with another entity begins
    fixture.onBeginContact: {
      var otherEntity = other.getBody().target

      // if the collided entity is the player...
      if(otherEntity.entityType === "player") {
        console.debug("Player touches finish")

        // keep track of previous state to reload it
        gameScene.previousState = gameScene.state
        // ...we emit the player's finish() signal
        gameScene.player.finish()
      }
    }
  }

  // avoid to win by colliding with the platform below the pole
  BoxCollider {
    id: bottomCollider

    // fit the collider with the sprite
    width: 40
    height: 23
    y: 9

    // this entity shouldn't move
    bodyType: Body.Static

    // Category5: solids
    categories: Box.Category5
    // Category1: player body, Category2: player feet sensor,
    // Category3: opponent body, Category4: opponent sensor
    collidesWith: Box.Category1 | Box.Category2 | Box.Category3 | Box.Category4
  }

  // this sensor makes sure, that the user can't draw/create any
  // entities close to the goal pole
  BoxCollider {
    id: editorCollider

    width: parent.width
    height: parent.height
    y: 32 - height

    collisionTestingOnlyMode: true
    active: inLevelEditingMode
    visible: active

    // Category16: misc
    categories: Box.Category16
  }
}
