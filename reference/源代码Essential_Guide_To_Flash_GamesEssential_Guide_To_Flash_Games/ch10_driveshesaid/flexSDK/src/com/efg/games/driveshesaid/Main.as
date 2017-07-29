﻿package com.efg.games.driveshesaid
{
	
	import flash.text.TextFormat;
	import flash.text.TextField; //added
	import flash.text.TextFormatAlign;
	import flash.geom.Point;
	import flash.events.Event;
	
	import com.efg.framework.FrameWorkStates;
	import com.efg.framework.GameFrameWork;
	import com.efg.framework.BasicScreen;
	import com.efg.framework.ScoreBoard;
	import com.efg.framework.SideBySideScoreElement;
	import com.efg.framework.SoundManager;

	
	public class Main extends GameFrameWork {
		
		
		//custom sccore board elements
		public static const SCORE_BOARD_SCORE:String = "score";
		public static const SCORE_BOARD_TIME_LEFT:String = "timeleft";
		public static const SCORE_BOARD_HEARTS:String = "hearts";
	
		//custom sounds
		
		public static var SOUND_TITLE_MUSIC:String = "titlemusic";
		public static var SOUND_CAR:String = "car"
		public static var SOUND_CLOCK_PICKUP:String = "clockpickup";
		public static var SOUND_HEART_PICKUP:String = "heartpickup";
		public static var SOUND_GAME_LOST:String = "gamelost";
		public static var SOUND_LEVEL_COMPLETE:String = "levelcomplete";
		public static var SOUND_SKULL_HIT:String = "skullhit";
		public static var SOUND_PLAYER_START:String = "playerstart";
		public static var SOUND_HIT_WALL:String = "hitwall";
		
		//level in screen additions
		private var heartsToCollect:TextField = new TextField();
		
		// Our construction only calls init(). This way, we can re-init the entire system if necessary
		public function Main() {
			init();
		}
		
		// init() is used to set up all of the things that we should only need to do one time
		override public function init():void {
			game = new DriveSheSaid();
			game.y = 20; 
			game.x = 404; //added 
			setApplicationBackGround(384, 404, false, 0x000000);
			game.addEventListener(CustomEventHeartsNeeded.HEARTS_NEEDED, heartsNeededListener, false, 0, true);
			
			//add score board to the screen as the seconf layer
			scoreBoard = new ScoreBoard();
			addChild(scoreBoard);
			scoreBoardTextFormat = new TextFormat("_sans", "11", "0xffffff", "true");
			
			scoreBoard.createTextElement(SCORE_BOARD_SCORE, new SideBySideScoreElement(80, 5, 20, "Score", scoreBoardTextFormat, 25, "0", scoreBoardTextFormat));
			scoreBoard.createTextElement(SCORE_BOARD_TIME_LEFT, new SideBySideScoreElement(180, 5, 20, "Time Left", scoreBoardTextFormat, 45, "0", scoreBoardTextFormat));
			scoreBoard.createTextElement(SCORE_BOARD_HEARTS, new SideBySideScoreElement(280, 5, 20, "Hearts", scoreBoardTextFormat, 25, "0", scoreBoardTextFormat));
			
		
			//screen text initializations
			screenTextFormat = new TextFormat("_sans", "16", "0xffffff", "false");
			screenTextFormat.align = flash.text.TextFormatAlign.CENTER;
			screenButtonFormat = new TextFormat("_sans", "12", "0x000000", "false");
			
			titleScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_TITLE,384,404,false,0x000000 );
			titleScreen.createOkButton("Play", new Point(150, 250), 100, 20, screenButtonFormat, 0x000000, 0xff0000,2);
			titleScreen.createDisplayText("Drive She Said", 200, new Point(100, 150), screenTextFormat);
			
					
			instructionsScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_INSTRUCTIONS,384,404,false,0x000000);
			instructionsScreen.createOkButton("Start", new Point(150, 250), 100, 20,screenButtonFormat, 0x000000, 0xff0000,2);
			instructionsScreen.createDisplayText("Drive over all harts\nbefore timer\nruns out.",200,new Point(100,150),screenTextFormat);

			
			gameOverScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_GAME_OVER,640,500,false,0x0000dd);
			gameOverScreen.createOkButton("Restart", new Point(150, 250), 100, 20,screenButtonFormat, 0x000000, 0xff0000,2);
			gameOverScreen.createDisplayText("Time up\nGame Over",100,new Point(150,150),screenTextFormat);

			
			levelInScreen = new BasicScreen(FrameWorkStates.STATE_SYSTEM_LEVEL_IN, 384, 404, true, 0xbbff00ff);
			levelInText = "Level ";
			levelInScreen.createDisplayText(levelInText,100,new Point(150,150),screenTextFormat);
			heartsToCollect.defaultTextFormat = screenTextFormat;
			heartsToCollect.width = 300;
			heartsToCollect.x = 50;
			heartsToCollect.y = 200;
			levelInScreen.addChild(heartsToCollect);
			
			//set initial game state
			switchSystemState(FrameWorkStates.STATE_SYSTEM_TITLE);
			
			
			//sounds
			//*** Flex SDK
			soundManager.addSound(SOUND_TITLE_MUSIC,new Library.SoundTitleMusic);
			soundManager.addSound(SOUND_CAR, new Library.SoundCar);
			soundManager.addSound(SOUND_CLOCK_PICKUP,new Library.SoundClockPickup);
			soundManager.addSound(SOUND_HEART_PICKUP,new Library.SoundHeartPickup);
			soundManager.addSound(SOUND_GAME_LOST,new Library.SoundGameLost);
			soundManager.addSound(SOUND_LEVEL_COMPLETE,new Library.SoundLevelComplete);
			soundManager.addSound(SOUND_SKULL_HIT,new Library.SoundSkullHit);
			soundManager.addSound(SOUND_PLAYER_START,new Library.SoundPlayerStart);
			soundManager.addSound(SOUND_HIT_WALL,new Library.SoundHitWall);
			
			//create timer and run it one time
			frameRate = 40;
			startTimer();	
		}
		
		override public function systemTitle():void {
			soundManager.playSound(SOUND_TITLE_MUSIC, false,999, 20, 1);
			super.systemTitle();
		}
		
		override public function systemNewGame():void {
			
			soundManager.stopSound(SOUND_TITLE_MUSIC);
			super.systemNewGame();
		}
		
		override public function systemLevelIn():void {
			levelInScreen.alpha = 1
			super.systemLevelIn();
		}
		
		override public function systemWait():void {
			
			if (lastSystemState == FrameWorkStates.STATE_SYSTEM_LEVEL_IN) {
				game.x -= 2;
				if (game.x < 100) {
					levelInScreen.alpha -= .01;
					if (levelInScreen.alpha < 0 ) {
						levelInScreen.alpha = 0;
					}
				}
				if (game.x <= 0) {
					game.x = 0;
					soundManager.playSound(SOUND_PLAYER_START, false,1,20, 1);
					dispatchEvent(new Event(EVENT_WAIT_COMPLETE));
				}
			}
		}
		
		private function heartsNeededListener(e:CustomEventHeartsNeeded):void {
			heartsToCollect.text = "Collect " + e.heartsNeeded + " Hearts";
			
		}
	}
}	
		
		
		