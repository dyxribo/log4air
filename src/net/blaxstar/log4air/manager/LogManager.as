package net.blaxstar.log4air.manager {

    import flash.events.Event;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;

    import net.blaxstar.log4air.Logger;
    import net.blaxstar.log4air.core.LogFilter;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.utils.BufferedCaller;
    import net.blaxstar.log4air.utils.HashMap;
    import flash.filesystem.File;

    public class LogManager {
        private static var instance:LogManager;
        private static var log_file_path:String = File.applicationDirectory.resolvePath("log4air_config.json").nativePath;

        private var log_filter:LogFilter;
        private var log_filter_buffer:BufferedCaller;
        private var relative_time_map:HashMap;

        // ! CONSTRUCTOR ! //

        public function LogManager(notAllowed:Key) {
            if (notAllowed == null) {
                throw new ArgumentError("The LogManager parameter must not be null!");
            }

            log_filter = new LogFilter();
            relative_time_map = new HashMap();
            log_filter_buffer = new BufferedCaller(log_filter, log_filter.on_complete_signal);
            log_filter.load_config(log_file_path);
        }

        // ! PUBLIC FUNCTIONS ! //

        public function get_logger(log_target:Object):Logger {
            if (log_target == null) {
                throw new ArgumentError("log_target must not be null!");
            }
            var name:String

            if (log_target is String) {
                name = String(log_target);
            } else {
                name = getQualifiedClassName(log_target);
                name = name.replace(/::/g, ".");
            }

            var logger:Logger = new Logger(name, this);

            return logger;
        }

        public function add_log(level:Level, name:String, text:String, args:Array):void {
            var relative_time:int;
            if (relative_time_map.hasKey(name)) {
                var start_time:int = int(relative_time_map.get_value(name))
                relative_time = getTimer() - start_time;
            } else {
                relative_time_map.add(name, getTimer());
                relative_time = 0;
            }

            log_filter_buffer.add_log(new Date(), relative_time, level, name, text, args);
        }

        // ! PRIVATE FUNCTIONS ! //

        public static function get_instance():LogManager {
            if (instance) {
                return instance;
            } else {
                instance = new LogManager(new Key());
                return instance;
            }
        }
    }
}

internal class Key {
}
