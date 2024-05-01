package net.blaxstar.log4air.core {
    import net.blaxstar.log4air.appenders.Appender;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.dataholder.LoggerInfo;
    import net.blaxstar.log4air.utils.HashMap;
    import net.blaxstar.log4air.utils.MessageFormatter;

    import org.osflash.signals.Signal;

    public class LogFilter {
        private var _configuration_loader:ConfigurationLoader;
        private var _appenders:HashMap;
        private var _loggers:Array;
        private var _on_complete_signal:Signal;


        // ! CONSTRUCTOR ! //

        public function LogFilter() {
            _on_complete_signal = new Signal();
            _configuration_loader = new ConfigurationLoader();
            _configuration_loader.on_complete_signal.add(on_config_loaded);
        }

        // ! PUBLIC FUNCTIONS ! //

        public function load_config(file_path:String):void {
            _configuration_loader.load_config_file(file_path);
        }

        public function add_log(time:Date, relative_time:int, level:Level, name:String, text:String, args:Array):void {

            var logger_info_array:Array = get_logger_info_array(level, name);
            if (logger_info_array) {
                var num_logger_infos:uint = logger_info_array.length;
                for (var i:int = 0; i < num_logger_infos; i++) {
                    add_to_appender(time, relative_time, logger_info_array[i], level, name, text, args);
                }
            }
        }

        // ! PRIVATE FUNCTIONS ! //

        private function get_logger_info_array(level:Level, name:String):Array {

            var infos:Array = [];
            for (var i:int = 0; i < _loggers.length; i++) {
                var current_logger_info:LoggerInfo = _loggers[i]

                if (current_logger_info.is_root) {
                    infos.push(current_logger_info);
                } else if (current_logger_info.name.length <= name.length) {
                    if (package_equals(name, current_logger_info.name)) {
                        infos.push(current_logger_info);
                    }
                }
            }

            return filter_logger_infos(infos, level);
        }


        private function package_equals(full_name:String, short_name:String):Boolean {
            var full_parts:Array = full_name.toUpperCase().split(".");
            var short_parts:Array = short_name.toUpperCase().split(".");

            for (var i:int = 0; i < short_parts.length; i++) {
                if (full_parts[i] != short_parts[i]) {
                    return false
                }
            }

            return true
        }

        private function filter_logger_infos(logger_info_array:Array, level:Level):Array {
            var filtered_logger_infos:Array = [];

            if (logger_info_array.length == 0) {
                return filtered_logger_infos;
            }

            logger_info_array.sort(logger_info_sorter);

            var first_logger_info:LoggerInfo = logger_info_array[0]
            filtered_logger_infos[0] = first_logger_info;

            for (var i:int = 1; i < logger_info_array.length; i++) {
                var current_logger_info:LoggerInfo = logger_info_array[i];
                
                if (current_logger_info.level.priority > first_logger_info.level.priority || current_logger_info.level.priority < first_logger_info.level.priority) {

                    filtered_logger_infos.splice(0);
                    filtered_logger_infos.push(current_logger_info);
                    first_logger_info = current_logger_info;
                } else {
                    filtered_logger_infos.push(current_logger_info);
                }
            }

            if (level.priority >= first_logger_info.level.priority) {
                return filtered_logger_infos;
            }

            return null;
        }

        private function logger_info_sorter(a:LoggerInfo, b:LoggerInfo):Number {
            if (a.is_root) {
                return -1;
            } else if (b.is_root) {
                return 1;
            } else if (a.name.length > b.name.length) {
                return 1;
            } else if (a.name.length < b.name.length) {
                return -1;
            }

            return 0;
        }

        private function add_to_appender(time:Date, relative_time:int, logger_info:LoggerInfo, level:Level, name:String, text:String, args:Array):void {
            var appender:Appender = _appenders.get_value(logger_info.appender_name) as Appender;

            if (appender) {
                var formatted_text:String = MessageFormatter.format_string(text, args);
                appender.add_log(time, relative_time, level, name, formatted_text);
            }
        }

        // ! GETTERS & SETTERS ! //

        public function get on_complete_signal():Signal {
          return _on_complete_signal;
        }

        // ! DELEGATE FUNCTIONS ! //

        public function on_config_loaded(config_data:Object):void {
            _appenders = config_data.appenders;
            _loggers = config_data.loggers;

            _on_complete_signal.dispatch();
        }
    }
}
