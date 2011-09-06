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
		public var isKeyExecuted:Array = new Array();
		
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
		
		public const START = 0;
		public const HOLD = 1;
		public const HARD_DROP = 2;
		public const SOFT_DROP = 3;
		public const MOVE_LEFT = 4;
		public const MOVE_RIGHT = 5;
		public const ROTATE_LEFT = 6;
		public const ROTATE_RIGHT = 7;
		public const NUM_KEYS = 8;
		
		public function Input($boardRef:Board)
		{
			setDefaultKeyMap();
			$gameBoard = $boardRef;
			$gameBoard.addEventListener(MouseEvent.CLICK, function(event:MouseEvent)
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
				isKeyExecuted[key] = false;
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
			for (var i:int = 0; i < NUM_KEYS; i++)
			{
				if (isKeyDown[i])
				{
					if (nextFireTime[i] <= curTime)
					{
						firedKeys.push(i);
						if (nextFireTime[i] == NOW)
						{
							nextFireTime[i] = curTime + pauseTime;
						}
						else
						{
							nextFireTime[i] += repeatTime;
						}
					}
				}
			}
			return firedKeys;
		}
	}
}