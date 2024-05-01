package net.blaxstar.log4air.layouts {


    import net.blaxstar.log4air.utils.HashMap;
    import net.blaxstar.log4air.layouts.converters.LevelConverter;
    import net.blaxstar.log4air.layouts.converters.DateConverter;
    import net.blaxstar.log4air.layouts.converters.MessageConverter;
    import net.blaxstar.log4air.layouts.converters.ClassConverter;
    import net.blaxstar.log4air.layouts.converters.NewLineConverter;
    import net.blaxstar.log4air.layouts.converters.MemoryConverter;
    import net.blaxstar.log4air.layouts.converters.RelativeTimeConverter;
    import net.blaxstar.log4air.layouts.converters.RelativeTimeConverter;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.layouts.converters.Converter;
    import net.blaxstar.log4air.utils.MessageFormatter;

    public class PatternLayout extends Layout {
        private static const PATTERN:RegExp = /%(\w+)/gmi;
        private static var converters:HashMap = new HashMap();

        // ! CONSTRUCTOR ! //

        public function PatternLayout() {
            add_converter(["level", "le", "l"], LevelConverter);
            add_converter(["date", "d"], DateConverter);
            add_converter(["message", "msg", "m"], MessageConverter);
            add_converter(["class", "logger", "l", "c"], ClassConverter);
            add_converter(["newline", "n"], NewLineConverter);
            add_converter(["memory", "mem"], MemoryConverter);
            add_converter(["relative", "r"], RelativeTimeConverter);
        }

        // ! CONSTRUCTOR ! //

        override public function format(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            if (properties.pattern != null && String(properties.pattern).length) {
                var pattern_string:String = properties.pattern;
                var pattern_list:Array = get_patterns(pattern_string)

                return apply_pattern(pattern_string, pattern_list, time, relative_time, level, name, text)
            } else {
                return text;
            }
        }

        // ! STATIC METHODS ! //

        public static function add_converter(patterns:Array, converterClass:Class):void {
            var converter:* = new converterClass()
            if (!(converter is Converter)) {
                throw new ArgumentError("converterClass must extend net.blaxstar.log4air.layouts.converters.Converter!")
            }

            for (var i:int = 0; i < patterns.length; i++) {
                if (!converters.hasKey(patterns[i])) {
                    converters.add(patterns[i], converter)
                }
            }

        }

        // ! PRIVATE METHODS ! //

        private function apply_pattern(pattern_string:String, patterns:Array, time:Date, relative_time:int, level:Level, name:String, text:String):String {
            var result_string:String = pattern_string;

            for (var i:int = 0; i < patterns.length; i++) {
                var curPattern:String = String(patterns[i]).toLowerCase()
                var converter:Converter = converters.get_value(curPattern) as Converter
                if (converter) {
                    result_string = MessageFormatter.replace(result_string, "%" + curPattern, converter.convert(time, relative_time, level, name, text))
                }
            }

            return result_string;
        }


        private function get_patterns(patternStr:String):Array {
            var patterns:Array = [];

            var result:Object;
            while ((result = PATTERN.exec(patternStr)) != null) {
                patterns.push(result[1]);
            }

            return patterns
        }
    }
}
