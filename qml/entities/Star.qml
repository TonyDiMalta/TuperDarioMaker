import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: star
  entityType: "star"

  // this property is true when the player collected the star
  property bool collected: false

  // when the star is collected, it shouldn't be visible anymore
  image.visible: !collected

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/powerups/star.png"

  CircleCollider {
    id: collider

    // fit the collider with the sprite
    radius: parent.width / 2 + 0.5

    // center collider
    x: 0
    y: 1

    // disable collider when star is collected
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

  // set collected to true
  function collect() {
    console.debug("collect star")
    star.collected = true
    gameScene.score += 1000
  }

  // reset star
  function reset() {
    star.collected = false
  }
}
