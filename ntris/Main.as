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
		public function Main():void
		{
			// The rest of the initialization code is in finishMain(), called after the blockData.dat file is loaded
			var blockLoader:BlockLoader = new BlockLoader(this);
			blockLoader.openBlockData();
		}

		public function finishMain():void
		{
			var board:Board = new Board();
			addChild(board);
			board.redraw();
		}
	}
}