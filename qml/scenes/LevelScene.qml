import QtQuick 2.0
import VPlay 2.0
import "../common"
import "dialogs"
import "sceneElements"

SceneBase {
  id: levelScene

  // time limit between high scores
  property int timeLimit: 0

  // can be: "created_at", "average_quality", "times_downloaded"
  property string order: "created_at"

  // this alias enables access to the dialog from the outside
  property alias removeLevelDialog: removeLevelDialog

  // holds the currently active level grid
  property var activeLevelGrid

  // visibility settings
  property bool demoLevelsVisible: state == "demoLevels"
  property bool myLevelsVisible: state == "myLevels"
  property bool myCreatedLevelsVisible: myLevelsVisible && subState == "createdLevels"
  property bool myDownloadedLevelsVisible: myLevelsVisible && subState == "downloadedLevels"
  property bool communityLevelsVisible: state == "communityLevels"

  // signals
  signal newLevelPressed
  signal playLevelPressed(var levelData)
  signal editLevelPressed(var levelData)
  signal removeLevelPressed(var levelData)
  signal backPressed

  // can be: "demoLevels", "myLevels", "communityLevels"
  state: "myLevels"
  // can be: "createdLevels", "downloadedLevels"
  property string subState: "createdLevels"

  // handle state changes
  onStateChanged: reloadLevels()
  onSubStateChanged: reloadLevels()

  // reload levels, when time limit or order is changed
  onTimeLimitChanged: reloadLevels()
  onOrderChanged: reloadLevels()

  onActiveLevelGridChanged: {
    // if the communityLevelGrid is active, show the loading screen
    if(activeLevelGrid === communityLevelGrid) {
      activeLevelGrid.startLoading()
    }
    // all other level grids don't need any loading time, so we can immediately
    // call finishLoading(), which displays all levels
    else {
      activeLevelGrid.finishLoading()
    }
  }

  // background
  Rectangle {
    id: background

    anchors.fill: parent.gameWindowAnchorItem

    gradient: Gradient {
      GradientStop { position: 0.0; color: "#4595e6" }
      GradientStop { position: 1.0; color: "#80bfff" }
    }
  }

  Rectangle {
    id: mainBar

    width: parent.gameWindowAnchorItem.width
    height: 40

    anchors.top: parent.gameWindowAnchorItem.top
    anchors.left: parent.gameWindowAnchorItem.left

    color: "transparent"

    Row {
      height: 30

      anchors.centerIn: parent

      spacing: 5

      PlatformerSelectableTextButton {
        id: demoLevels

        screenText: "Demos"

        width: 80

        // this button is selected if the state is demoLevels
        isSelected: levelScene.state == "demoLevels"

        // set state to demoLevels
        onClicked: levelScene.state = "demoLevels"
      }

      PlatformerSelectableTextButton {
        id: myLevels

        screenText: "My Levels"

        width: 80

        // this button is selected if the state is myLevels
        isSelected: levelScene.state == "myLevels"

        // set state to myLevels
        onClicked: levelScene.state = "myLevels"
      }

      PlatformerSelectableTextButton {
        id: communityLevels

        screenText: "Community"

        width: 80

        // TO DEBUG - CRASH
        visible: false

        // this button is selected if the state is communityLevels
        isSelected: levelScene.state == "communityLevels"

        // set state to communityLevels
        onClicked: levelScene.state = "communityLevels"
      }
    }

    // back to menu button
    PlatformerImageButton {
      id: menuButton

      image.source: "../../assets/ui/home.png"

      width: 40
      height: 30

      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: 5

      // go back to MenuScene
      onClicked: backPressed()
    }
  }

  Rectangle {
    id: subBar

    width: parent.gameWindowAnchorItem.width
    height: 40

    anchors.top: mainBar.bottom
    anchors.left: parent.gameWindowAnchorItem.left

    // make mainBar and subBar overlap a little bit
    anchors.topMargin: -1

    color: "transparent"

    // show subBar when myLevels or communityLevels are visible
    visible: myLevelsVisible || communityLevelsVisible

    /**
     * MyLevels
     */
    Row {
      height: 30

      anchors.centerIn: parent

      spacing: 5

      // only visible if myLevels are selected
      visible: myLevelsVisible

      // add new level button
      PlatformerImageButton {
        id: newLevelButton

        width: 50
        height: 30

        // image
        image.source: "../../assets/ui/add.png"

        // background color
        color: "#00d900"

        // emit newLevelPressed signal
        onClicked: newLevelPressed()
      }

      PlatformerSelectableTextButton {
        id: createdLevelsButton

        screenText: "Created"

        width: 80

        // this button is selected, if the subState is createdLevels
        isSelected: subState == "createdLevels"

        // set subState to createdLevels
        onClicked: subState = "createdLevels"
      }

      PlatformerSelectableTextButton {
        id: downloadedLevelsButton

        screenText: "Downloaded"

        width: 80

        // this button is selected, if the subState is downloadedLevels
        isSelected: subState == "downloadedLevels"

        // set subState to downloadedLevels
        onClicked: subState = "downloadedLevels"
      }
    }

    /**
     * CommunityLevels
     */
    Row {
      height: 30

      anchors.centerIn: parent

      spacing: 5

      // only visible if communityLevels are selected
      visible: communityLevelsVisible

      PlatformerTextButton {
        id: orderButton

        // set text depending on order
        screenText: order == "created_at" ? "Newest" : order == "average_quality" ? "Highest Rated" : order == "times_downloaded" ? "Most Downloaded" : ""

        // open dialog to set another order
        onClicked: levelOrderDialog.opacity = 1
      }

      PlatformerTextButton {
        id: timeLimitButton

        // set text depending on time limit
        screenText: timeLimit == 0 ? "All Time" : timeLimit == 24 * 7 ? "This Week" : timeLimit == 24 ? "Today" : ""

        // set width to orderButton width, to make sure that these two buttons
        // always have the same width
        width: orderButton.width

        // open dialog to set another time limit
        onClicked: levelTimeLimitDialog.opacity = 1
      }
    }
  }

  // this displays all demo levels
  LevelGrid {
    id: demoLevelGrid

    visible: demoLevelsVisible

    levelMetaDataArray: gameWindow.levelEditor.applicationJSONLevels
  }

  // this displays all created levels
  LevelGrid {
    id: createdLevelGrid

    visible: myCreatedLevelsVisible

    // we only show authorGeneratedLevels
    levelMetaDataArray: gameWindow.levelEditor.authorGeneratedLevels
  }

  // this displays all downloaded levels
  LevelGrid {
    id: downloadedLevelGrid

    visible: myDownloadedLevelsVisible

    // we only show authorGeneratedLevels
    levelMetaDataArray: gameWindow.levelEditor.downloadedLevels
  }

  // this displays all community levels
  LevelGrid {
    id: communityLevelGrid

    visible: communityLevelsVisible

    // we only show authorGeneratedLevels
    levelMetaDataArray: gameWindow.levelEditor.communityLevels
  }

  /**
   * DIALOGS --------------------------------------------------
   */
  LevelOrderDialog {
    id: levelOrderDialog
  }

  LevelTimeLimitDialog {
    id: levelTimeLimitDialog
  }

  // this dialog pops up, when the user clicks the remove button of
  // one of the levels
  RemoveLevelDialog {
    id: removeLevelDialog
  }

  UnpublishDialog {
    id: unpublishDialog
  }

  RatingDialog {
    id: ratingDialog

    onLevelRated: reloadLevels()
  }

  /**
   * JAVASCRIPT FUNCTIONS
   */

  // reload levels
  function reloadLevels() {
    var params = {}
    if(timeLimit > 0) {
      params.timeLimit = timeLimit
    }
    params.order = order

    if(state == "demoLevels") {
      levelEditor.loadAllLevelsFromStorageLocation(levelEditor.applicationJSONLevelsLocation)
      activeLevelGrid = demoLevelGrid
    }
    else if(state == "myLevels") {
      if(subState == "createdLevels") {
        levelEditor.loadAllLevelsFromStorageLocation(levelEditor.authorGeneratedLevelsLocation)
        activeLevelGrid = createdLevelGrid
      }
      else if(subState == "downloadedLevels") {
        levelEditor.loadAllLevelsFromStorageLocation(levelEditor.downloadedLevelsLocation)
        activeLevelGrid = downloadedLevelGrid
      }
      else {
        console.debug("invalid subState", subState)
      }
    }
    else if (state == "communityLevels") {
      levelEditor.loadCommunityLevels(params)
      activeLevelGrid = communityLevelGrid
    }
    else {
      console.debug("invalid state", state)
    }
  }
}
