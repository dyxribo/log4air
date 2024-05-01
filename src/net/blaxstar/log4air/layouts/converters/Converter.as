package net.blaxstar.log4air.layouts.converters {
    import net.blaxstar.log4air.dataholder.Level;

    public class Converter {
        public function convert(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            throw new Error("convert is an abstract method; you must override it!");

            return "";
        }
    }
}
