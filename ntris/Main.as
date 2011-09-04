package ntris
{
	import flash.display.Sprite;
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
		
		public function Main():void
		{
			// The rest of the initialization code is in finishMain(), called after BlockLoader is finished loading data
			var blockLoader:BlockLoader = new BlockLoader(this, numBlockTypes, blockData);
			blockLoader.openBlockData();
		}

		public function finishMain():void
		{
			difficultyLevels = numBlockTypes.length;
			var board:Board = new Board();
			addChild(board);
			board.redraw();
		}
	}
}