package net.blaxstar.log4air.utils {

    public class MessageFormatter {

        public static const json_pattern:String = "{}";

        public static function format_string(format:String, args:Array):String {
            var patterns:Array = format.split(json_pattern);

            if (patterns.length - 1 != args.length) {
                throw new ArgumentError("incorrect number of arguments!");
            }

            var result:String = patterns[0];

            for (var i:int = 0; i < args.length; i++) {
                result += args[i] + patterns[i + 1];
            }

            return result;
        }

        public static function replace(str:String, pattern:String, rep:String):String {
            var regex:RegExp = new RegExp(pattern, "gim");

            return str.replace(regex, rep);
        }
    }
}
