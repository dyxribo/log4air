package net.blaxstar.log4air.layouts {
    import net.blaxstar.log4air.interfaces.IPropertiesHolder;
    import net.blaxstar.log4air.dataholder.Level;
    import flash.utils.Dictionary;

    public class Layout implements IPropertiesHolder {

        private var _properties:Dictionary;

        public function Layout() {
            _properties = new Dictionary();
        }

        public function get properties():Dictionary {
            return _properties;
        }

        public function format(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            throw new Error("format is an abstract method; you must override it!");

            return "";
        }

    }
}
