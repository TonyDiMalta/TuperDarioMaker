import QtQuick 2.0
import VPlay 2.0

Opponent {
  id: opponentWalker
  variationType: "walker"

  // this property determines in which the opponent moves
  // (-1 = left, 1 = right)
  property int direction: -1

  // the moving speed of the opponent
  property int speed: 70

  // set image in edit mode
  // if opponent is alive, use walk sprite sheet,
  // else, use dead sprite
  image.source: alive ? "../../assets/opponent/goomba.png" :
                        "../../assets/opponent/goomba_dead.png"

  // mirror sprite, when the opponent is moving right
  image.mirror: collider.linearVelocity.x < 0 ? false : true

  // hide the image if we need to display the animation
  image.visible: inLevelEditingMode || !(hidden || alive)

  SpriteSequenceVPlay {
    id: walkerAnim

    defaultSource: "../../assets/opponent/goomba_walk.png"
    width: image.width
    height: image.height

    running: !inLevelEditingMode && alive && gameScene.state !== "dead"
    visible: !inLevelEditingMode && alive

    // mirror anim, when the opponent is moving right
    mirrorX: collider.linearVelocity.x < 0 ? false : true

    // animation when the goomba move on xAxis
    SpriteVPlay {
      name: "walk"
      frameCount: 16
      startFrameColumn: 1
      frameRate: 20
      to: {"walk": 1}
    }
  }

  // define colliderComponent for collision detection while dragging
  colliderComponent: collider

  // When this opponent dies, we reset it's abyssChecker's
  // contacts to zero. Otherwise, after a level reset,
  // the abyssCheckers might not start with 0 contacts.
  onAliveChanged: {
    if(!alive) {
      leftAbyssChecker.contacts = 0
      rightAbyssChecker.contacts = 0
      gameScene.score += 100
    }
  }

  // When being moved to the entity pool, reset the abyss checker's contacts.
  // For more information on entity pooling have a look at:
  // https://v-play.net/doc/vplay-entitybase/#poolingEnabled-prop
  onMovedToPool: {
    leftAbyssChecker.contacts = 0
    rightAbyssChecker.contacts = 0
  }

  // the opponents main collider
  PolygonCollider {
    id: collider

    // the vertices, forming the shape of the collider
    vertices: [
      Qt.point(4, 4),
      Qt.point(28, 4),
      Qt.point(28, 30),
      Qt.point(26, 31),
      Qt.point(6, 31),
      Qt.point(4, 30)
    ]

    // the collider can move and test for collisions
    bodyType: Body.Dynamic

    // the collider should not be active in edit mode or
    // when dead
    active: inLevelEditingMode || !alive ? false : true

    // Category3: opponent body
    categories: Box.Category3
    // Category2: player body, Category2: player feet sensor,
    // Category5: solids
    collidesWith: Box.Category1 | Box.Category2 | Box.Category5

    // set the opponent's velocity
    linearVelocity: Qt.point(direction * speed, 0)

    onLinearVelocityChanged: {
      // if the opponent stops moving, reverse direction
      if(linearVelocity.x === 0)
        direction *= -1

      // make sure the speed is constant
      linearVelocity.x = direction * speed
    }
  }

  // The abyss checkers check for abysses left and right of the
  // opponent. With this, we can let the opponent change direction,
  // before it would fall of an edge.
  BoxCollider {
    id: leftAbyssChecker

    // only active, when the main collider is active
    active: collider.active

    // we make it rather small
    width: 5
    height: 5

    // place it left, below the opponent
    anchors.top: parent.bottom
    anchors.left: parent.left

    // Category4: opponent sensor
    categories: Box.Category4
    // Category5: solids
    collidesWith: Box.Category5

    // this collider should only check for collisions
    collisionTestingOnlyMode: true

    // This property keeps track of the contacts. If contacts
    // is 0, there is an abyss and the opponent should reverse
    // it's direction.
    property int contacts: 0

    // handle number of contacts
    fixture.onBeginContact: ++contacts
    fixture.onEndContact: if(contacts > 0) --contacts

    // change direction when there are no contacts
    onContactsChanged: if(contacts == 0) direction *= -1
  }
  BoxCollider {
    id: rightAbyssChecker

    active: collider.active

    // size and position
    width: 5
    height: 5
    anchors.top: parent.bottom
    anchors.right: parent.right

    // Category4: opponent sensor
    categories: Box.Category4
    // Category5: solids
    collidesWith: Box.Category5

    collisionTestingOnlyMode: true

    // handle contacts
    property int contacts: 0

    fixture.onBeginContact: ++contacts
    fixture.onEndContact: if(contacts > 0) --contacts

    onContactsChanged: if(contacts == 0) direction *= -1
  }

  // make property editable via item editor
  EditableComponent {
    editableType: "Balance"
    defaultGroup: "OpponentWalker"

    targetEditor: gameScene.itemEditor

    properties: {
      "speed": {"min": 0, "max": 300, "stepSize": 5, "label": "Speed"}
    }
  }

  // when the speed is changed, via the itemEditor, we also want to update
  // the opponents velocity
  onSpeedChanged: {
    collider.linearVelocity.x = direction * speed
  }

  // reset the opponent
  function reset() {
    // We set alive to false here, and reset it to true later,
    // to deactivate the collider while the opponent is reset.
    alive = false

    // this is the reset function of the base entity Opponent.qml
    reset_super()

    // reset force
    collider.linearVelocity.x = Qt.point(direction * speed, 0)

    alive = true
  }
}

