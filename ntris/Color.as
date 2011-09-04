package ntris
{
	import Math;
	
	public class Color
	{
		public static const LAMBDA:Number = 0.32;
		public static const RAINBOWCODE:Array = [0xFFFFFF, 0xDDDDDD, 0xCCCCCC, 0xFFFF00, 0xBBBBBB, 0x87CEEB, 0xFA8072, 0xDDA0DD, 0xFFD700, 0xDA70D6, 0x98FB98, 0xAAAAAA, 0x4169E1, 0xFF0000, 0x0000FF, 0xB21111, 0x8B0011, 0x00008B, 0xFF00FF, 0x800080, 0xD284BC, 0xFF8C00, 0x20B2AA, 0xB8860B, 0xFF4500, 0x48D1CC, 0x9966CC, 0xFFA500, 0x00FF00];
		public static const BLACK:uint = 0x000000;
		public static const WHITE:uint = 0xFFFFFF;
		
		public static function colorCode(index:int):uint
		{
			return mixedColor(BLACK, mixedColor(WHITE, RAINBOWCODE[index], 1.6 * LAMBDA), 0.4 * LAMBDA);
		}
		
		public static function mixedColor(color1:uint, color2:uint, lambda:Number):uint
		{
			var red1:uint = color1 >>> 16;
			var red2:uint = color2 >>> 16;
			var red:uint = Math.max(Math.min(lambda * red1 + (1 - lambda) * red2, 0xFF), 0);
			
			var blue1:uint = (color1 >>> 8) & 0xFF;
			var blue2:uint = (color2 >>> 8) & 0xFF;
			var blue:uint = Math.max(Math.min(lambda * blue1 + (1 - lambda) * blue2, 0xFF), 0);
			
			var green1:uint = color1 & 0xFF;
			var green2:uint = color2 & 0xFF;
			var green:uint = Math.max(Math.min(lambda * green1 + (1 - lambda) * green2, 0xFF), 0);
			
			return uint(red << 16) + uint(blue << 8) + green;
		}
		
		public function Color()
		{
		}
	}
}