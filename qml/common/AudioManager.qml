import VPlay 2.0
import QtQuick 2.0
import QtMultimedia 5.0

Item {
  id: audioManager

  Component.onCompleted: handleMusic()

  /**
   * Background Music ----------------------------------
   */
  BackgroundMusic {
    id: menuMusic
    autoPlay: false
    source: "../../assets/audio/music/SuperMarioMaker_TitleScreen.mp3"
  }

  BackgroundMusic {
    id: playMusic
    autoPlay: false
    source: "../../assets/audio/music/NewSuperMarioBrosU_Overworld.mp3"
    onPlaybackStateChanged: {
      if(playbackState === Audio.StoppedState)
        playbackRate = 1
    }
  }

  BackgroundMusic {
    id: editMusic
    autoPlay: false
    source: "../../assets/audio/music/SuperMarioRun_KingdomBuilder.mp3"
  }

  /**
   * Sounds ----------------------------------
   */
  SoundEffectVPlay {
    id: playerJump
    source: "../../assets/audio/sounds/phase_jump1.wav"
  }

  SoundEffectVPlay {
    id: playerJump2
    source: "../../assets/audio/sounds/phase_jump2.wav"
  }

  SoundEffectVPlay {
    id: playerHit
    source: "../../assets/audio/sounds/change_small.wav"
  }

  SoundEffectVPlay {
    id: playerDie
    source: "../../assets/audio/sounds/death.wav"
    onPlayingChanged: {
      if(playing)
        audioManager.stopSounds()
      else {
        gameScene.resetLevel()
        gameScene.state = gameScene.previousState
      }
    }
  }

  SoundEffectVPlay {
    id: playerInvincible
    source: "../../assets/audio/sounds/star_theme.wav"
    loops: SoundEffect.Infinite
    onPlayingChanged: {
      if(playing)
        playMusic.pause()
      else if(activeScene === gameScene && (gameScene.state == "play" || gameScene.state == "test") && !hurryUp.playing)
        playMusic.play()
    }
  }

  SoundEffectVPlay {
    id: collectCoin
    source: "../../assets/audio/sounds/coin1.wav"
  }

  SoundEffectVPlay {
    id: collectMushroom
    source: "../../assets/audio/sounds/change_big.wav"
  }

  SoundEffectVPlay {
    id: finish
    source: "../../assets/audio/sounds/level_clear.wav"
    onPlayingChanged: {
      if(playing)
        audioManager.stopSounds()
      else if(gameScene.previousState == "test") {
        gameScene.resetLevel()
        gameScene.state = gameScene.previousState
      }
    }
  }

  SoundEffectVPlay {
    id: opponentWalkerDie
    source: "../../assets/audio/sounds/stomp.wav"
  }

  SoundEffectVPlay {
    id: opponentJumperDie
    source: "../../assets/audio/sounds/twitch.wav"
  }

  SoundEffectVPlay {
    id: start
    source: "../../assets/audio/sounds/here_we_go.wav"
  }

  SoundEffectVPlay {
    id: click
    source: "../../assets/audio/sounds/click1.wav"
  }

  SoundEffectVPlay {
    id: dragEntity
    source: "../../assets/audio/sounds/slide_network.wav"
  }

  SoundEffectVPlay {
    id: createOrDropEntity
    source: "../../assets/audio/sounds/tap_professional.wav"
  }

  SoundEffectVPlay {
    id: removeEntity
    source: "../../assets/audio/sounds/tap_mellow.wav"
  }

  SoundEffectVPlay {
    id: hurryUp
    source: "../../assets/audio/sounds/hurry_up.wav"
    onPlayingChanged: {
      if(playing)
        playMusic.pause()
      else if(gameWindow.state === "game" && (gameScene.state == "play" || gameScene.state == "test")) {
        playMusic.playbackRate = 1.3
        if(!playerInvincible.playing)
          playMusic.play()
      }
    }
  }

  SoundEffectVPlay {
    id: marioTime
    source: "../../assets/audio/sounds/mario_clear_stage.wav"
  }

  SoundEffectVPlay {
    id: marioNumber1
    source: "../../assets/audio/sounds/mario_clear_boss.wav"
  }

  SoundEffectVPlay {
    id: yahoo
    source: "../../assets/audio/sounds/yahoo.wav"
  }

  SoundEffectVPlay {
    id: itemAppear
    source: "../../assets/audio/sounds/item_appear.wav"
  }

  SoundEffectVPlay {
    id: pickupLife
    source: "../../assets/audio/sounds/pickup_life.wav"
  }

  SoundEffectVPlay {
    id: breakBlock
    source: "../../assets/audio/sounds/break_block.wav"
  }

  // this function sets the music, depending on the current scene and the gameScene's state
  function handleMusic() {
    if(activeScene === gameScene) {
      switch(gameScene.state) {
        case "play" :
          audioManager.startMusic(playMusic)
          break
        case "test" :
          audioManager.startMusic(playMusic)
          break
        case "edit" :
          audioManager.startMusic(editMusic)
          break
        case "dead" :
          playSound("playerDie")
          break
        case "finish" :
          playSound("finish")
          playSound("marioTime")
          break
        default :
          console.debug("unknown case name:", gameScene.state)
      }
    } else {
      // reset sounds
      hurryUp.stop()
      playerInvincible.stop()

      audioManager.startMusic(menuMusic)
    }
  }

  // starts the given music
  function startMusic(music) {
    // if music is already playing, we don't have to do anything
    if(music.playing)
      return

    // otherwise stop all music tracks
    menuMusic.stop()
    playMusic.stop()
    editMusic.stop()

    // then play the music
    music.play()
  }

  // stop all sounds
  function stopSounds() {
    // sound effects
    hurryUp.stop()
    playerInvincible.stop()

    // music tracks
    menuMusic.stop()
    playMusic.stop()
    editMusic.stop()
  }

  // play the sound effect with the given name
  function playSound(sound) {
    switch(sound) {
      case "playerJump" :
        playerJump.play()
        break
      case "playerJump2" :
        playerJump2.play()
        break
      case "playerHit" :
        playerHit.play()
        break
      case "playerDie" :
        playerDie.play()
        break
      case "playerInvincible" :
        playerInvincible.play()
        break
      case "collectCoin" :
        collectCoin.play()
        break
      case "collectMushroom" :
        collectMushroom.play()
        break
      case "finish" :
        finish.play()
        break
      case "opponentWalkerDie" :
        opponentWalkerDie.play()
        break
      case "opponentJumperDie" :
        opponentJumperDie.play()
        break
      case "start" :
        start.play()
        break
      case "click" :
        click.play()
        break
      case "dragEntity" :
        dragEntity.play()
        break
      case "createOrDropEntity" :
        createOrDropEntity.play()
        break
      case "removeEntity" :
        removeEntity.play()
        break
      case "hurryUp" :
        hurryUp.play()
        break
      case "marioTime" :
        marioTime.play()
        break
      case "marioNumber1" :
        marioNumber1.play()
        break
      case "yahoo" :
        yahoo.play()
        break
      case "itemAppear" :
        itemAppear.play()
        break
      case "pickupLife" :
        pickupLife.play()
        break
      case "breakBlock" :
        breakBlock.play()
        break
      default :
        console.debug("unknown sound name:", sound)
    }
  }

  // stop the sound effect with the given name
  function stopSound(sound) {
    if(sound === "playerInvincible")
      playerInvincible.stop()
    else
      console.debug("unknown sound name:", sound)
  }
}
