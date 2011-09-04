package ntris
{
	import flash.display.Sprite;
	import ntris.Color;
	import ntris.Constants;
	
	public class Board extends Sprite
	{
		
		public function Board()
		{
		
		}
		
		private function drawLineOffset(x1:int, y1:int, x2:int, y2:int):void
		{
			graphics.moveTo(x1 + Constants.BORDER, y1 + Constants.BORDER);
			graphics.lineTo(x2 + Constants.BORDER, y2 + Constants.BORDER);
		}
		
		private function drawRectOffset(x:int, y:int, w:int, h:int):void
		{
			graphics.drawRect(x + Constants.BORDER, y + Constants.BORDER, w, h);
		}
		
		public function redraw():void
		{
			graphics.beginFill(Color.BLACK);
			graphics.drawRect(0, 0, Constants.BOARDWIDTH + 2 * Constants.BORDER, Constants.BOARDHEIGHT + 2 * Constants.BORDER);
			
			graphics.lineStyle(2, Color.colorCode(28));
			graphics.endFill();
			graphics.drawRect(Constants.BORDER/2, Constants.BORDER/2, Constants.BOARDWIDTH + Constants.BORDER, Constants.BOARDHEIGHT + Constants.BORDER);
			
			graphics.lineStyle(1, Color.mixedColor(Color.BLACK, Color.WHITE, Color.LAMBDA));
			var height:uint = Constants.SQUAREWIDTH * (Constants.NUMROWS - Constants.MAXBLOCKSIZE + 1);
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				drawLineOffset(Constants.SQUAREWIDTH * i, 0, Constants.SQUAREWIDTH * i, height);
				drawLineOffset(Constants.SQUAREWIDTH * (i + 1) - 1, 0, Constants.SQUAREWIDTH * (i + 1) - 1, height);
			}
			var width:uint = Constants.SQUAREWIDTH * Constants.NUMCOLS;
			for (var j:int = 0; j < Constants.NUMROWS - Constants.MAXBLOCKSIZE + 1; j++)
			{
				drawLineOffset(0, Constants.SQUAREWIDTH * j, width, Constants.SQUAREWIDTH * j);
				drawLineOffset(0, Constants.SQUAREWIDTH * (j + 1) - 1, width, Constants.SQUAREWIDTH * (j + 1) - 1);
			}
		}
	}
}