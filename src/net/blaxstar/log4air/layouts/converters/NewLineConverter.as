package net.blaxstar.log4air.layouts.converters {
    import net.blaxstar.log4air.dataholder.Level;

    public class NewLineConverter extends Converter {

        override public function convert(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            return "\n";
        }
    }
}
