package net.blaxstar.log4air.appenders {
    import net.blaxstar.log4air.dataholder.Level;

    public class ConsoleAppender extends Appender {

        public function ConsoleAppender(name:String) {
            super(name)
        }

        override public function print(time:Date, relative_time:int, level:Level, name:String, output:String):void {
            trace(output);
        }

    }
}
