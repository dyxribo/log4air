package net.blaxstar.log4air.utils {
    import flash.utils.getDefinitionByName;

    public class LogUtils {
        public static function get_definition(name:String):Class {
            var definition:*;

            try {
                definition = getDefinitionByName(name);
            } catch (e:*) {
                return null;
            }

            return Class(definition);
        }
    }
}
