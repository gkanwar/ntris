package ntris
{
	import flash.geom.Point;
	import ntris.Constants;
	
	public class Block
	{
		public var x:int = 0;
		public var y:int = 0;
		public var angle:int = 0;
		public var numSquares:int = 0;
		public var squares:Array = new Array(Constants.MAXBLOCKSIZE);
		public var color:uint = 0xFF0000;
		public var shoveaways:int = 0;
		public var localStickFrames:int = Constants.MAXLOCALSTICKFRAMES;
		public var globalStickFrames:int = Constants.MAXGLOBALSTICKFRAMES;
		public var rotates:Boolean = true;
		public var height:int = 0;
		public var rowsDropped:int = 0;
		
		public function Block()
		{
			for (var i:int = 0; i < Constants.MAXBLOCKSIZE; i++)
			{
				squares[i] = new Point();
			}
		}
	}
}