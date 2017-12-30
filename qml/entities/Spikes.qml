import QtQuick 2.0
import VPlay 2.0
import "../editorElements"

PlatformerEntityBaseDraggable {
  id: spikes
  entityType: "spikes"
  variationType: "up"

  // set the size to the sprite's size
  width: image.width
  height: image.height

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // set image
  image.source: "../../assets/spikes/thwomp.png"

  PolygonCollider {
    id: collider

    // the vertices, forming the shape of the collider
    vertices: [
      Qt.point(1, 5),
      Qt.point(5, 1),
      Qt.point(26, 1),
      Qt.point(31, 5),
      Qt.point(31, 26),
      Qt.point(26, 31),
      Qt.point(5, 31),
      Qt.point(1, 26)
    ]

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

