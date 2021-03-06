import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: spikeball
  entityType: "spikes"
  variationType: "ball"

  // set the size to the sprite's size
  width: image.width
  height: image.height

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/spikeball/spikeball.png"

  CircleCollider {
    id: collider

    // fit the collider with the sprite
    radius: parent.width / 2 + 0.5

    // center collider
    x: 1
    y: 1

    // the collider is static (shouldn't move) and only test
    // for collisions
    bodyType: Body.Static

    // the collider should not be active in edit mode
    active: !inLevelEditingMode

    // Category5: solids
    categories: Box.Category5
    // Category1: player body, Category2: player feet sensor,
    // Category3: opponent body, Category4: opponent sensor
    collidesWith: Box.Category1 | Box.Category2 | Box.Category3 | Box.Category4
  }
}

