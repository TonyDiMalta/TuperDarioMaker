import VPlay 2.0
import QtQuick 2.0
import "../common"
import "../entities"
import "../editorElements"
import "../gameElements"
import "dialogs"

SceneBase {
  id: gameScene

  // set the scene alignment
  sceneAlignmentX: "left"
  sceneAlignmentY: "top"

  // the level's grid size
  gridSize: 32

  // current time
  property int time: 0

  // update displayed time
  onTimeChanged: {
    timeDisplay.text = timeLimit == 0 ? "∞" : time
    if(gameWindow.state === "game" && (state == "play" || state == "test")) {
      if(time == 30)
        audioManager.playSound("hurryUp")
      else if(time == timeLimit && state == "play" && previousState != "play")
        audioManager.playSound("start")
    }
  }

  // the time until player's death on current level
  // if zero, no time limit
  property int timeLimit: 0

  // the player's score
  property int score: 0

  // the previous state to differentiate how the level should be reloaded
  property string previousState: "play"

  // make components visible from the outside
  property alias editorOverlay: editorOverlay
  property alias container: container
  property alias player: player
  property alias physicsWorld: physicsWorld
  property alias bgImage: bgImage
  property alias camera: camera

  // Make itemEditor accessible from the outside.
  // This is necessary for dynamically created items, to be able to
  // set this editor as their target editor.
  property alias itemEditor: editorOverlay.itemEditor

  // this signal is emitted when the user presses the back button
  signal backPressed

  /**
   * States
   */
  state: "play"

  states: [
    State {
      name: "play"
      StateChangeScript {script: audioManager.handleMusic()}
    },
    State {
      name: "edit"
      PropertyChanges {target: physicsWorld; gravity: Qt.point(0,0)} // disable gravity
      PropertyChanges {target: editorUnderlay; enabled: true} // enable the editorUnderlay for placing entities and moving the camera
      PropertyChanges {target: editorOverlay; visible: true} // show the editorOverlay
      PropertyChanges {target: editorOverlay; inEditMode: true}
      StateChangeScript {script: stopTimer()}
      StateChangeScript {script: audioManager.handleMusic()}
      StateChangeScript {script: resetLevel()} // reset all entity positions
      StateChangeScript {script: editorOverlay.grid.requestPaint()}
    },
    State {
      name: "test"
      PropertyChanges {target: editorOverlay; visible: true} // show the editorOverlay
      PropertyChanges {target: camera; zoom: 1}
      StateChangeScript {script: stopTimer()}
      StateChangeScript {script: audioManager.handleMusic()}
      StateChangeScript {script: resetLevel()} // reset all entity positions
    },
    State {
      name: "dead"
      PropertyChanges {target: physicsWorld; running: false} // disable physics
      StateChangeScript {script: levelTimer.stop()}
      StateChangeScript {script: audioManager.handleMusic()}
    },
    State {
      name: "finish"
      PropertyChanges {target: physicsWorld; running: false} // disable physics
      StateChangeScript {script: levelTimer.stop()}
      StateChangeScript {script: audioManager.handleMusic()}
    }
  ]

  /**
   * BACKGROUND -----------------------------------------
   */
  // background image
  BackgroundImage {
    id: bgImage

    anchors.centerIn: parent.gameWindowAnchorItem

    // this property holds which background to show
    property int bg: 0

    // paths to all backgrounds
    property string bg0: "../../assets/backgroundImage/NSMBU_Overworld_Bg.png"
    property string bg1: "../../assets/backgroundImage/NSMBU_Sky_Bg.png"
    property string bg2: "../../assets/backgroundImage/NSMBU_Mountain_Bg.png"

    // if available, load background from levelData
    property int loadedBackground: {
      if(gameWindow.levelEditor && gameWindow.levelEditor.currentLevelData
          && gameWindow.levelEditor.currentLevelData["customData"]
          && gameWindow.levelEditor.currentLevelData["customData"]["background"])
        parseInt(gameWindow.levelEditor.currentLevelData["customData"]["background"])
      else
        -1 // set to -1 if background property is not available
    }

    // set image source depending on bg-property value
    source: bg == 0 ? bg0 : bg == 1 ? bg1 : bg2
  }

  /**
   * MOUSE AND GESTURE CONTROL --------------------------
   */
  EditorUnderlay {
    id: editorUnderlay
  }

  // make properties editable via itemEditor
  EditableComponent {
    editableType: "Balance"
    defaultGroup: "Timers"
    properties: {
      "timeLimit": {"min": 0, "max": 300, "stepSize": 30, "label": "Time limit (sec)"}
    }
  }

  /**
   * GAME ELEMENTS -----------------------------------------
   */
  // entity container
  // here all our entities are placed
  Item {
    id: container

    // When the container is scaled we want the transformation to
    // be applied from the top left corner, since this is also the
    // coordinates origin.
    transformOrigin: Item.TopLeft

    PhysicsWorld {
      id: physicsWorld

      property int gravityY: 40

      // set the gravity
      gravity: Qt.point(0, gravityY)

      debugDrawVisible: false // enable this for physics debugging
      z: 1000 // make sure the debugDraw is above all other game elements

      running: true

      //this is called before the Box2DWorld handles contact events
      onPreSolve: {
        var entityA = contact.fixtureA.getBody().target
        var entityB = contact.fixtureB.getBody().target

        // We want our platforms to be cloud platforms.
        // A cloud platform is a platform through which you can jump
        // from below.

        // If one of the colliding entities is a platform,
        // and the other a moving entity (player or opponent),
        // and the moving entity is below the platform...
        if(entityA.entityType === "platform" && (entityB.entityType === "player" || entityB.entityType === "opponent") && entityB.y + entityB.height > entityA.y + 1 // add +1 to avoid wrong border-line decisions
            || (entityA.entityType === "player" || entityA.entityType === "opponent") && entityB.entityType === "platform" && entityA.y + entityA.height > entityB.y + 1) {

          // ...disable the contact
          contact.enabled = false
        }

        // Disable physical collision handling between player
        // and opponents. This way, we can still handle them,
        // but their physics are not affected.
        if(entityA.entityType === "player" && entityB.entityType === "opponent"
            || entityB.entityType === "player" && entityA.entityType === "opponent") {
          contact.enabled = false
        }
      }

      // add gravity property to item editor
      EditableComponent {
        editableType: "Balance"
        defaultGroup: "Physics"
        properties: {
          "gravityY": {"min": 0, "max": 100, "label": "Gravity"}
        }
      }
    }

    Player {
      id: player

      z: 1 // let the player appear in front of the platforms

      // when colliding with the finish:
      // in play mode: display game over
      // in test mode: reset the level
      onFinish: {
        // set state to finish, to freeze the game
        gameScene.state = "finish"

        // update the score
        score += time * 50

        // if this level wasn't a test, display game over
        if(gameScene.previousState == "play") {
          // handle score
          handleScore()

          // show finish dialog
          finishDialog.score = score
          finishDialog.opacity = 1
        }
      }
    }

    ResetSensor {
      // This sensor is always at the bottom of the level, directly
      // below the player. So the player touches it just before he
      // would fall out of bounds at the bottom of the level.
      // When he touches it, he dies.

      player: player

      // if the player collides with the reset sensor, he dies
      onContact: {
        player.die(true)
      }
    }
  }

  // camera
  CameraVPlay {
    id: camera

    // set the gameWindowSize and entityContainer with which the camera works with
    gameWindowSize: Qt.point(gameScene.gameWindowAnchorItem.width, gameScene.gameWindowAnchorItem.height)
    entityContainer: container

    // disable the camera's mouseArea, since we handle the controls of the free
    // moving camera ourself, in EditorUnderlay
    mouseAreaEnabled: false

    // the camera follows the player when not in edit mode
    focusedObject: gameScene.state == "edit" ? null : player

    // set focused offset
    focusOffset: Qt.point(0.5, 0.3)

    // set limits
    limitLeft: 0
    limitBottom: 0

    // set free camera offset, if sidebar is visible
    freeOffset: gameScene.state == "edit" ? Qt.point(100, 0) : Qt.point(0, 0)
  }

  /**
   * CONTROLS ----------------------------------------------
   */

  // this button is for moving left and right on touch devices
  MoveTouchButton {
    id: moveTouchButton

    // pass TwoAxisController to moveTouchButton
    controller: controller
  }

  // this button is for jumping on touch devices
  JumpTouchButton {
    id: jumpTouchButton

    onPressed: player.startJump(true)
    onReleased: player.endJump()
  }

  // On desktops, we can move the player with the arrow keys,
  // on mobile devices we are using our custom inputs above,
  // to modify the controller axis values.
  // With this approach, we only need one actual logic for the
  // movement, always referring to the axis values of the controller.

  // forward the keyboard keys to the controller
  Keys.forwardTo: controller

  // this is the controller, which handles the user's input
  TwoAxisController {
    id: controller

    // controls should be only enabled when playing a level
    enabled: gameScene.state == "play" || gameScene.state == "test"

    // use it to customize input keys
    /*inputActionsToKeyCode: {
      "up": Qt.Key_Z,
      "down": Qt.Key_S,
      "left": Qt.Key_Q,
      "right": Qt.Key_D,
      "fire": Qt.Key_Space
      //"changeToWeapon1": Qt.Key_1
      //"changeToWeapon2": Qt.Key_2
      //"reload": Qt.Key_R
    }*/

    // reset inputs
    onEnabledChanged: {
        if(enabled) {
          // reset the controller's xAxis to ensure, that it's zero
          // at the beginning of the level
          xAxis = 0
          if(isPressed("up"))
            setInputActionPressedStatus("up", false)
          if(isPressed("down"))
            setInputActionPressedStatus("down", false)
          if(isPressed("left"))
            setInputActionPressedStatus("left", false)
          if(isPressed("right"))
            setInputActionPressedStatus("right", false)
        }
    }

    // handle keyboard input
    onInputActionPressed: {
      //console.debug("key pressed actionName " + actionName)

      // movement via left and right buttons is handled automatically

      // start jump when pressing the up button
      if(actionName == "up") {
        player.startJump(true)
      }
    }

    onInputActionReleased: {
      // end jump when releasing the up button
      if(actionName == "up") {
        player.endJump()
      }
    }

    // if the xAxis changes, we change the direction the player looks,
    // depending on the direction he moves
    onXAxisChanged: player.changeSpriteOrientation()
  }

  /**
   * HUD
   */

  HUDIconAndText {
    id: timeDisplay

    // When the time is a whole number, the text would be e.g. "1" - but we
    // want it to be "1.0". So we check if it is a whole number, and if so,
    // add a ".0" to the end of it.
    text: time
    icon.source: "../../assets/ui/time.png"
  }

  // this timer keeps track of the time the user plays a level,
  // also handle time limit
  Timer {
    id: levelTimer

    interval: 1000

    repeat: true

    onTriggered: {
      // decrease time until it reaches zero, then trigger player's death
      if(time == 0)
        player.die(true)
      else
        --time
    }
  }

  // this displays the player's coins
  HUDIconAndText {
    id: coinsDisplay

    text: "x "+player.coins
    icon.source: "../../assets/coin/coin.png"

    anchors.left: timeDisplay.right
  }

  // this displays the player's score
  HUDIconAndText {
    id: scoreDisplay

    text: "Score: "+score
    icon.width: 0

    anchors.left: coinsDisplay.right
  }

  /**
   * TOP BAR
   */

  // back to menu button
  PlatformerImageButton {
    id: menuButton

    width: 40
    height: 30

    anchors.right: editorOverlay.right
    anchors.top: editorOverlay.top

    image.source: "../../assets/ui/home.png"

    // this button should only be visible in play or edit mode
    visible: gameScene.state == "play" || gameScene.state == "edit"

    // go back to menu
    onClicked: backPressed()
  }

  /**
   * EDITOR OVERLAY
   */

  EditorOverlay {
    id: editorOverlay

    visible: false

    scene: gameScene
  }

  /**
   * DIALOGS
   */

  FinishDialog {
    id: finishDialog
  }

  /**
   * JAVASCRIPT FUNCTIONS --------------------------------------
   */

  function handleScore() {
    // id only exists in published levels
    var leaderboard = levelEditor.currentLevelData.levelMetaData ? levelEditor.currentLevelData.levelMetaData.id : undefined

    // if current levelMetaData doesn't have an id, check if it has publishedLevelId
    if(!leaderboard)
      leaderboard = levelEditor.currentLevelData.levelMetaData ? levelEditor.currentLevelData.levelMetaData.publishedLevelId : undefined
    // if level is published...
    else {
      // ...report the score; the higher the score, the better
      gameNetwork.reportScore(score, leaderboard, null, "highest_is_best")
    }
  }

  // initializes the level
  // this function is called after a level was loaded
  function initLevel() {
    // initialize the editor
    editorOverlay.initEditor()

    // set background image
    // when there is a background saved, load it
    // otherwise take the default background
    bgImage.bg = bgImage.loadedBackground && bgImage.loadedBackground != -1 ? bgImage.loadedBackground : 0

    // reset the camera
    camera.zoom = 1
    camera.freePosition = Qt.point(0, 0)

    // initialize the player
    player.initialize()

    // reset score
    score = 0

    // reset time and timer
    if(levelEditor.currentLevelData["editableComponentData"] !== undefined && levelEditor.currentLevelData["editableComponentData"]["Balance"] !== undefined && levelEditor.currentLevelData["editableComponentData"]["Balance"]["timeLimit"] !== undefined)
      time = timeLimit = levelEditor.currentLevelData["editableComponentData"]["Balance"]["timeLimit"]
    else
      time = timeLimit
    if(state != "edit" && time != 0)
      levelTimer.start()
  }

  // resets the level
  // this function is i.a. called everytime the player dies, or the user
  // switches from test to edit mode
  function resetLevel() {
    // reset the editor
    editorOverlay.resetEditor()

    // reset player
    player.reset()

    // reset opponents
    var opponents = entityManager.getEntityArrayByType("opponent")
    for(var opp in opponents) {
      opponents[opp].reset()
    }

    // reset coins
    var coins = entityManager.getEntityArrayByType("coin")
    for(var coin in coins) {
      coins[coin].reset()
    }

    // reset mushrooms
    var mushrooms = entityManager.getEntityArrayByType("mushroom")
    for(var mushroom in mushrooms) {
      if(!mushrooms[mushroom].poolingEnabled)
        entityManager.removeEntityById(mushrooms[mushroom].entityId);
      else
        mushrooms[mushroom].reset()
    }

    // reset stars
    var stars = entityManager.getEntityArrayByType("star")
    for(var star in stars) {
      stars[star].reset()
    }

    // reset blocks
    var blocks = entityManager.getEntityArrayByType("blocks")
    for(var block in blocks) {
      blocks[block].reset()
    }

    // reset score
    score = 0

    // reset time and timer
    time = timeLimit
    if(state != "edit" && time != 0)
      levelTimer.start()
  }

  // stop timer and reset time
  function stopTimer() {
    levelTimer.stop()
    time = -1
  }
}
