package ntris
{
	import flash.display.Sprite;
	import ntris.Board;
	
	
	// Width is BOARDWIDTH + 2*BORDER, height is BOARDHEIGHT + 2*BORDER
	[SWF(width='367',height='546')]
	
	public class Main extends Sprite
	{
		public function Main():void
		{
			//openBlockData();
			var board:Board = new Board();
			addChild(board);
			board.redraw();
		}
		
		private function openBlockData():void {
			
		}
	}
}