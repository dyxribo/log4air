package net.blaxstar.log4air.layouts.converters {

    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.printf;

    public class ClassConverter extends Converter {

        override public function convert(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            return printf("[%s]", name);
        }
    }
}
