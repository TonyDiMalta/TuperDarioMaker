import VPlay 2.0
import QtQuick 2.0
import "scenes"
import "common"

GameWindow {
  id: gameWindow

  activeScene: menuScene

  // the size of the Window can be changed at runtime by pressing Ctrl (or Cmd on Mac) + the number keys 1-8
  // the content of the logical scene size (480x320 for landscape mode by default) gets scaled to the window size based on the scaleMode
  screenWidth: 960
  screenHeight: 640

  // aliases to make levelEditor and itemEditor accessible from the outside
  property alias levelEditor: levelEditor
  property alias itemEditor: gameScene.itemEditor

  // stop timer and update background music when scene changes
  onActiveSceneChanged: {
    gameScene.stopTimer()
    audioManager.handleMusic()
  }

  // level editor
  LevelEditor {
    id: levelEditor

    Component.onCompleted: levelEditor.loadAllLevelsFromStorageLocation(authorGeneratedLevelsLocation)

    // These are the entity types, that the can be stored and removed by the entityManager.
    // Note, that the player is not here. This is because we only
    // want ONE player instance - we don't want to be able to place
    // another player or delete the existing player.
    toRemoveEntityTypes: [ "ground", "blocks", "platform", "spikes", "opponent", "coin", "mushroom", "star", "finish" ]
    toStoreEntityTypes: [ "ground", "blocks", "platform", "spikes", "opponent", "coin", "mushroom", "star", "finish" ]

    // set the gameNetwork
    gameNetworkItem: gameNetwork

    // directory where the predefined json levels are
    applicationJSONLevelsDirectory: "levels/"

    onLevelPublished: {
      // save level
      gameScene.editorOverlay.saveLevel()

      //report a dummy score, to initialize the leaderboard
      /*var leaderboard = levelId
      if(leaderboard)
        gameNetwork.reportScore(-1, leaderboard, null, "highest_is_best")*/

      gameWindow.state = "level"
    }
  }

  AudioManager {
    id: audioManager
  }

  // the entity manager handles all our entities
  EntityManager {
    id: entityManager

    // here we define the container the entityManager manages
    // so all entities, the entityManager creates are in this container
    entityContainer: gameScene.container

    // the entity does not get destroyed from memory when we call removeEntity(),
    // but is set to invisible until the entity type can be reused again
    poolingEnabled: true

    // we want to be able to build this entity in-game
    dynamicCreationEntityList: [
      Qt.resolvedUrl("entities/Mushroom.qml")
    ]
  }

  VPlayGameNetwork {
    id: gameNetwork

    // set id and secret
    gameId: 123
    secret: "dummyPassword"

    // set gameNetworkView
    gameNetworkView: myGameNetworkView
  }

  // custom mario style font
  FontLoader {
    id: marioFont
    source: "../assets/fonts/SuperMario256.ttf"
  }

  // Scenes -----------------------------------------
  MenuScene {
    id: menuScene

    onLevelScenePressed: {
      gameWindow.state = "level"
    }
  }

  LevelScene {
    id: levelScene

    VPlayGameNetworkView {
      id: myGameNetworkView

      z: 1000

      anchors.fill: parent.gameWindowAnchorItem

      // invisible by default
      visible: false

      onShowCalled: myGameNetworkView.visible = true

      onBackClicked: myGameNetworkView.visible = false
    }

    onNewLevelPressed: {
      // create a new level
      var creationProperties = {
        levelMetaData: {
          levelName: "newLevel"
        }
      }
      levelEditor.createNewLevel(creationProperties)

      // switch to gameScene, edit mode
      gameWindow.state = "game"
      gameScene.state = "edit"

      // initialize level
      gameScene.initLevel()
    }

    onPlayLevelPressed: {
      // load level
      levelEditor.loadSingleLevel(levelData)

      // switch to gameScene, play mode
      gameWindow.state = "game"
      gameScene.state = "play"

      // initialize level
      gameScene.initLevel()
    }

    onEditLevelPressed: {
      // load level
      levelEditor.loadSingleLevel(levelData)

      // switch to gameScene, play mode
      gameWindow.state = "game"
      gameScene.state = "edit"

      // initialize level
      gameScene.initLevel()
    }

    onRemoveLevelPressed: {
      // load level
      levelEditor.loadSingleLevel(levelData)

      // remove loaded level
      levelEditor.removeCurrentLevel()
    }

    onBackPressed: gameWindow.state = "menu"
  }

  GameScene {
    id: gameScene

    onBackPressed: {
      // reset timer
      gameScene.stopTimer()
      // reset level
      gameScene.resetLevel()

      // switch to levelScene
      gameWindow.state = "level"
    }
  }

  // states
  state: "menu"

  // this state machine handles the transition between scenes
  states: [
    State {
      name: "menu"
      PropertyChanges {target: menuScene; opacity: 1}
      PropertyChanges {target: gameWindow; activeScene: menuScene}
    },
    State {
      name: "level"
      PropertyChanges {target: levelScene; opacity: 1}
      PropertyChanges {target: gameWindow; activeScene: levelScene}
    },
    State {
      name: "game"
      PropertyChanges {target: gameScene; opacity: 1}
      PropertyChanges {target: gameWindow; activeScene: gameScene}
    }
  ]

}
