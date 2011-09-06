package ntris
{
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import ntris.Board;
	import ntris.BlockLoader;
	import ntris.Color;
	
	// Width is BOARDWIDTH + 2*BORDER, height is BOARDHEIGHT + 2*BORDER
	[SWF(width='367',height='546')]
	
	public class Main extends Sprite
	{
		private var difficultyLevels:uint;
		private var numBlockTypes:Array = new Array();
		private var blockData:Array = new Array();
		private var nextFrame:int = 0;
		private var board:Board;
		private var input:Input;
		
		public function Main():void
		{
			// The rest of the initialization code is in finishMain(), called after BlockLoader is finished loading data
			var blockLoader:BlockLoader = new BlockLoader(this, numBlockTypes, blockData);
			blockLoader.openBlockData();
		}
		
		public function finishMain():void
		{
			difficultyLevels = numBlockTypes.length;
			board = new Board();
			addChild(board);
			stage.focus = board;
			input = new Input( board );
			gameLoop();
		}
		
		private function gameLoop():void
		{
			while (true)
			{
				var curTime:int = getTimer();
				if (curTime >= nextFrame)
				{
					nextFrame = curTime + 1000 / Constants.FPS;
					update(curTime);
					var timeDiff:int = nextFrame - getTimer() - 2;
					if (timeDiff < 0)
					{
						timeDiff = 0;
					}
					setTimeout(gameLoop, timeDiff);
					break;
				}
			}
		}
		private function update(curTime:int) : void
		{
			board.timeStep(input.query(curTime));
			board.draw();
		}
	}
}