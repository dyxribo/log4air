package net.blaxstar.log4air.dataholder {
    import net.blaxstar.log4air.utils.HashMap;

    public class LevelHolder {
        public static const ALL:Level = new Level(int.MIN_VALUE, "ALL");
        public static const SUCCESS:Level = new Level(0, "SUCCESS");
        public static const DEBUG:Level = new Level(10, "DEBUG");
        public static const INFO:Level = new Level(20, "INFO");
        public static const WARN:Level = new Level(30, "WARN");
        public static const ERROR:Level = new Level(40, "ERROR");
        public static const FATAL:Level = new Level(50, "FATAL");
        public static const OFF:Level = new Level(int.MAX_VALUE, "OFF");

        public static var initialized:Boolean = init();
        private static var levels:HashMap;

        public static function addLevel(level:Level):void {
            if (!(level is Level)) {
                throw new ArgumentError("level type must be of type `net.blaxstar.log4air.dataholder.Level`!");
            }
            levels.add(level.name.toUpperCase(), level);
        }

        public static function get_level(name:String):Level {
            return Level(levels.get_value(name.toUpperCase()));
        }


        private static function init():Boolean {
            levels = new HashMap();

            addLevel(ALL);
            addLevel(SUCCESS);
            addLevel(DEBUG);
            addLevel(INFO);
            addLevel(WARN);
            addLevel(ERROR);
            addLevel(FATAL);
            addLevel(OFF);

            return true;
        }
    }
}
