package ntris
{
	import flash.geom.Point;
	import ntris.Constants;
	
	public class Block
	{
		var x:int = 0;
		var y:int = 0;
		var angle:int = 0;
		var numSquares:int = 0;
		var squares:Array = new Array(Constants.MAXBLOCKSIZE);
		var color:uint = 0xFF0000;
		var shoveaways:int = 0;
		var localStickFrames:int = Constants.MAXLOCALSTICKFRAMES;
		var globalStickFrames:int = Constants.MAXGLOBALSTICKFRAMES;
		var rotates:Boolean = true;
		var height:int = 0;
		var rowsDropped:int = 0;
		
		public function Block()
		{
			for (var i:int = 0; i < Constants.MAXBLOCKSIZE; i++)
			{
				squares[i] = new Point();
			}
		}
	}
}