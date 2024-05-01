package net.blaxstar.log4air.layouts.converters {

    import flash.system.System;
    import net.blaxstar.log4air.layouts.converters.Converter;
    import net.blaxstar.log4air.dataholder.Level;

    public class MemoryConverter extends Converter {

        override public function convert(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            return String(System.totalMemory);
        }
    }
}
