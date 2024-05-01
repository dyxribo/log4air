package net.blaxstar.log4air.appenders {
    import flash.utils.getQualifiedClassName;

    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.interfaces.IPropertiesHolder;
    import net.blaxstar.log4air.layouts.Layout;
    import flash.utils.Dictionary;

    public class Appender implements IPropertiesHolder {

        private var _name:String
        private var _properties:Dictionary

        public function get properties():Dictionary {
            return _properties;
        }

        public function get name():String {
            return _name;
        }

        public function Appender(name:String) {
            _name = name;
            _properties = new Dictionary();
        }

        public function add_log(time:Date, relative_time:int, level:Level, name:String, text:String):void {
            if (properties.layout) {
                if (properties.layout is Layout) {
                    var layout:Layout = Layout(properties.layout)

                    var formated:String = layout.format(time, relative_time, level, name, text)
                    print(time, relative_time, level, name, formated)
                } else {
                    throw new Error(getQualifiedClassName(properties.layout) + " must extend `net.blaxstar.log4air.layouts.Layout`!")
                }
            } else {
                print(time, relative_time, level, name, text)
            }

        }

        public function print(time:Date, relative_time:int, level:Level, name:String, output:String):void {
            throw new Error("print is an abstract method; you must override it!")
        }

    }
}
