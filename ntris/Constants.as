package ntris
{
	
	public class Constants
	{
		public static const MAXBLOCKSIZE:int = 10;
		public static const NUMROWS:int = (24 + MAXBLOCKSIZE - 1);
		public static const NUMCOLS:int = 12;
		public static const FPS:int = 60;
		
		public static const GRAVITY:int = 60;
		
		public static const SQUAREWIDTH:int = 21;
		public static const SIDEBOARD:int = 7 * SQUAREWIDTH / 2;
		public static const BOARDWIDTH:int = SQUAREWIDTH * NUMCOLS + SIDEBOARD;
		public static const BOARDHEIGHT:int = SQUAREWIDTH * (NUMROWS - MAXBLOCKSIZE + 1);
		public static const BORDER:int = SQUAREWIDTH;
		
		public static const MAXLOCALSTICKFRAMES:int = 60;
		public static const MAXGLOBALSTICKFRAMES:int = 120;
		
		public function Constants()
		{
		}
	}
}