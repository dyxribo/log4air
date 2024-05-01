package net.blaxstar.log4air.dataholder {

    public class LoggerInfo {
        private var _name:String;
        private var _level:Level;
        private var _appender_name:String;
        private var _is_root:Boolean;

        public function LoggerInfo(is_root:Boolean, name:String, level:Level, appender_name:String) {
            _is_root = is_root;
            _name = name == "" ? null : name;
            _level = level;
            _appender_name = appender_name == "" ? null : appender_name;
        }

        public function get name():String {
            return _name;
        }

        public function get level():Level {
            return _level;
        }

        public function get appender_name():String {
            return _appender_name;
        }

        public function get is_root():Boolean {
            return _is_root;
        }

    }
}
