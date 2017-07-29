﻿package com.efg.games.tunnelpanic{		import com.efg.framework.FrameCounter;	import com.efg.framework.FrameRateProfiler;	import flash.text.TextFormat;	import flash.text.TextField; 	import flash.text.TextFormatAlign;	import flash.geom.Point;	import flash.events.Event;		import com.efg.framework.FrameWorkStates;	import com.efg.framework.GameFrameWork;	import com.efg.framework.BasicScreen;	import com.efg.framework.ScoreBoard;	import com.efg.framework.SideBySideScoreElement;	import com.efg.framework.SoundManager;	import mochi.as3.*;		dynamic public class Main extends GameFrameWork {						//custom sccore board elements		public static const SCORE_BOARD_SCORE:String = "score";						public static var SOUND_TITLE_MUSIC:String = "titlemusic";		public static var SOUND_IN_GAME_MUSIC:String = "ingamemusic";		public static var SOUND_EXPLODE:String = "explode";												public function Main() {			//added in chapter 11			if (stage) addedToStage();			else addEventListener(Event.ADDED_TO_STAGE, addedToStage,false,0,true);		}				override public function addedToStage(e:Event = null):void {			if (e != null) {				removeEventListener(Event.ADDED_TO_STAGE, addedToStage);			}			super.addedToStage();			trace("in tunnel panic added to stage");			init();		}				// init() is used to set up all of the things that we should only need to do one time		override public function init():void {			trace("init");			game= new TunnelPanic();			setApplicationBackGround(600, 400, false, 0x000000);						//add score board to the screen as the seconf layer			scoreBoard = new ScoreBoard();			addChild(scoreBoard);			scoreBoardTextFormat = new TextFormat("_sans", "11", "0xffffff", "true");						scoreBoard.createTextElement(SCORE_BOARD_SCORE, new SideBySideScoreElement(200, 0, 20, "Score", scoreBoardTextFormat, 25, "0", scoreBoardTextFormat));										//screen text initializations			screenTextFormat = new TextFormat("_sans", "16", "0xffffff", "false");			screenTextFormat.align = flash.text.TextFormatAlign.CENTER;			screenButtonFormat = new TextFormat("_sans", "12", "0x000000", "false");									titleScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_TITLE,600,400,false,0x000000 );			titleScreen.createOkButton("Play", new Point(250, 250), 100, 20, screenButtonFormat, 0x000000, 0xff0000,2);			titleScreen.createDisplayText("Tunnel Panic", 200, new Point(200, 150), screenTextFormat);								instructionsScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_INSTRUCTIONS,600,400,false,0x000000);			instructionsScreen.createOkButton("Start", new Point(250, 250), 100, 20,screenButtonFormat, 0x000000, 0xff0000,2);			instructionsScreen.createDisplayText("Dodge everything\nCan you go far?.",300,new Point(150,150),screenTextFormat);						gameOverScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_GAME_OVER,600,400,false,0x0000dd);			gameOverScreen.createOkButton("Submit", new Point(250, 250), 100, 20,screenButtonFormat, 0x000000, 0xff0000,2);			gameOverScreen.createDisplayText("Game Over",100,new Point(250,150),screenTextFormat);						levelInScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_LEVEL_IN, 600, 400, true, 0xbbff0000);			levelInText = "GO!";			levelInScreen.createDisplayText(levelInText,100,new Point(250,150),screenTextFormat);						pausedScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_PAUSE,400,400,false,0xff000000 );			pausedScreen.createOkButton("UNPAUSE", new Point(250, 250), 100, 20, screenButtonFormat, 0x000000, 0xff0000,2);			pausedScreen.createDisplayText("Paused", 100, new Point(250, 150), screenTextFormat);						//new chapter 12			preloadScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_PRELOAD, 600, 400, true, 0xff0000ff);			preloadScreen.createDisplayText("Loading...",150,new Point(250,150),screenTextFormat);									//set initial game state			switchSystemState(FrameWorkStates.STATE_SYSTEM_MOCHI_AD);			//switchSystemState(FrameWorkStates.STATE_SYSTEM_PRELOAD);									//sounds added after pre-load in the addSounds() function												//mochi			mochiGameId = "81e8cd4f0999371e";			mochiBoardId = "ffe2de0ae221a7f4";			MochiServices.connect(mochiGameId, this);						//framerate profiler						frameRate = 40;						frameRateProfiler = new FrameRateProfiler();			frameRateProfiler.profilerRenderObjects = 4000;			frameRateProfiler.profilerRenderLoops = 7;			frameRateProfiler.profilerDisplayOnScreen= true;			frameRateProfiler.profilerXLocation = 0;			frameRateProfiler.profilerYLocation = 0;			addChild(frameRateProfiler);			frameRateProfiler.startProfile(frameRate);						frameRateProfiler.addEventListener(FrameRateProfiler.EVENT_COMPLETE, frameRateProfileComplete, false, 0, true);		}				override public function addSounds():void {			trace("add sounds");			//flash IDE			soundManager.addSound(SOUND_IN_GAME_MUSIC, new SoundMusicInGame);			soundManager.addSound(SOUND_TITLE_MUSIC,new SoundMusicTitle);			soundManager.addSound(SOUND_EXPLODE,new SoundExplode);		}				override public function frameRateProfileComplete(e:Event):void {			//advanced timer			trace("profiledFrameRate=" + frameRateProfiler.profilerFrameRateAverage);						game.setRendering(frameRateProfiler.profilerFrameRateAverage, frameRate);			game.timeBasedUpdateModifier = frameRate;						removeEventListener(FrameRateProfiler.EVENT_COMPLETE, frameRateProfileComplete) ;			removeChild(frameRateProfiler);						//frame counter			frameCounter.x = 400;			frameCounter.y = 0;			frameCounter.profiledRate = frameRateProfiler.profilerFrameRateAverage;			frameCounter.showProfiledRate = true;			addChild(frameCounter);			startTimer(true);			}				override public function systemMochiAd():void {			trace("mochi ad");			super.systemMochiAd();			nextSystemState = FrameWorkStates.STATE_SYSTEM_PRELOAD;		}				override public function systemGameOver():void {			super.systemGameOver();			lastScore = game.lastScore;			nextSystemState = FrameWorkStates.STATE_SYSTEM_MOCHI_HIGHSCORES; 		}								override public function systemGamePlay():void {			game.runGameTimeBased(paused,timeDifference);								}				override public function systemTitle():void {			soundManager.playSound(SOUND_TITLE_MUSIC, true,999, 20, 1);			super.systemTitle();		}				override public function systemNewGame():void {			trace("new game");			soundManager.stopSound(SOUND_TITLE_MUSIC,true);			super.systemNewGame();		}				override public function systemLevelIn():void {			levelInScreen.alpha = 1;			super.systemLevelIn();		}				override public function systemWait():void {			//trace("system Level In");			if (lastSystemState == FrameWorkStates.STATE_SYSTEM_LEVEL_IN) {				levelInScreen.alpha -= .01;				if (levelInScreen.alpha < 0 ) {					dispatchEvent(new Event(EVENT_WAIT_COMPLETE));					levelInScreen.alpha = 0;				}			}		}					}}							