package ntris
{
	import adobe.utils.ProductManager;
	import flash.events.KeyboardEvent;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	public class Input
	{
		private var isKeyDown:Array = new Array();
		private var nextFireTime:Array = new Array();
		
		public var pauseTime:int = 120;
		public var repeatTime:int = 30;
		
		private var $gameBoard:Board;
		private static const NOW:int = -1;
		
		private const KEY_ENTER:int = 13;
		private const KEY_SHIFT:int = 16;
		private const KEY_SPACE:int = 32;
		private const KEY_LEFT_ARROW:int = 37;
		private const KEY_UP_ARROW:int = 38;
		private const KEY_RIGHT_ARROW:int = 39;
		private const KEY_DOWN_ARROW:int = 40;
		private const KEY_A:int = 65;
		private const KEY_C:int = 67;
		private const KEY_D:int = 68;
		private const KEY_P:int = 80;
		private const KEY_S:int = 83;
		private const KEY_W:int = 87;
		private const KEY_X:int = 88;
		private const KEY_Z:int = 90;
		
		public var keyMap:Array = new Array();
		
		public static const START:int = 0;
		
		public static const MOVE_LEFT:int = 1;
		public static const MOVE_RIGHT:int = 2;
		public static const ROTATE_LEFT:int = 3;
		public static const ROTATE_RIGHT:int = 4;
		public static const HARD_DROP:int = 5;
		public static const SOFT_DROP:int = 6;
		public static const HOLD:int = 7;
		public static const NUM_KEYS:int = 8;
		
		public function Input($boardRef:Board)
		{
			setDefaultKeyMap();
			$gameBoard = $boardRef;
			$gameBoard.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
				{
					$gameBoard.stage.focus = $gameBoard;
				});
			$gameBoard.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			$gameBoard.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function setDefaultKeyMap():void
		{
			keyMap[KEY_ENTER] = START;
			keyMap[KEY_P] = START;
			keyMap[KEY_SHIFT] = HOLD;
			keyMap[KEY_C] = HOLD;
			keyMap[KEY_SPACE] = HARD_DROP;
			keyMap[KEY_DOWN_ARROW] = SOFT_DROP;
			keyMap[KEY_LEFT_ARROW] = MOVE_LEFT;
			keyMap[KEY_RIGHT_ARROW] = MOVE_RIGHT;
			keyMap[KEY_UP_ARROW] = ROTATE_RIGHT;
			keyMap[KEY_X] = ROTATE_RIGHT;
			keyMap[KEY_Z] = ROTATE_LEFT;
		}
		
		private function keyDown(event:KeyboardEvent):void
		{
			if (keyMap[event.keyCode] != undefined)
			{
				var key:int = keyMap[event.keyCode];
				isKeyDown[key] = true;
				nextFireTime[key] = NOW;
			}
		}
		
		private function keyUp(event:KeyboardEvent):void
		{
			if (event.keyCode in keyMap)
			{
				isKeyDown[keyMap[event.keyCode]] = false;
			}
		}
		
		public function query(curTime:int):Array
		{
			var firedKeys:Array = new Array();
			var releasedKeys:Array = new Array();
			for (var i:int = 0; i < NUM_KEYS; i++)
			{
				if (isKeyDown[i])
				{
					if (nextFireTime[i] == NOW)
					{
						firedKeys.push(i);
						nextFireTime[i] = curTime + pauseTime;
					}
					else if (curTime >= nextFireTime[i])
					{
						firedKeys.push(i);
						nextFireTime[i] += repeatTime;
					}
				}
				else if (nextFireTime[i] != NOW)
				{
					nextFireTime[i] = NOW;
					releasedKeys.push(i);
				}
			}
			return [firedKeys, releasedKeys];
		}
	}
}