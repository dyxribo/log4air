package net.blaxstar.log4air.core {
    // Import necessary dependencies from the project
    import net.blaxstar.log4air.appenders.Appender;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.dataholder.LoggerInfo;
    import net.blaxstar.log4air.utils.HashMap;
    import net.blaxstar.log4air.utils.MessageFormatter;

    // Import Signal library for event handling
    import org.osflash.signals.Signal;

    public class LogFilter {
        // Handles loading of log configuration
        private var _configuration_loader:ConfigurationLoader;

        // Stores registered appenders (output destinations for logs)
        private var _appenders:HashMap;

        // Stores logger configurations
        private var _loggers:Array;

        // Signal dispatched when configuration loading is complete
        private var _on_complete_signal:Signal;

        // ! CONSTRUCTOR ! //

        /**
         * Constructor initializes necessary components and sets up event listeners.
         */
        public function LogFilter() {
            // Initialize the signal to notify when configuration loading is complete
            _on_complete_signal = new Signal();

            // Create an instance of the configuration loader
            _configuration_loader = new ConfigurationLoader();

            // Add an event listener for when configuration loading completes
            _configuration_loader.on_complete_signal.add(on_config_loaded);
        }

        // ! PUBLIC FUNCTIONS ! //

        /**
         * Loads logging configuration from the given file path.
         */
        public function load_config(file_path:String):void {
            _configuration_loader.load_config_file(file_path);
        }

        /**
         * Adds a log entry to all applicable loggers.
         * 
         * @param time         The timestamp of the log event.
         * @param relative_time The elapsed time since the first log for this source.
         * @param level        The severity level of the log.
         * @param name         The name of the log source.
         * @param text         The log message content.
         * @param args         Additional arguments for message formatting.
         */
        public function add_log(time:Date, relative_time:int, level:Level, name:String, text:String, args:Array):void {
            // Retrieve an array of applicable logger configurations for this log event
            var logger_info_array:Array = get_logger_info_array(level, name);

            // If logger configurations exist, process each one
            if (logger_info_array) {
                var num_logger_infos:uint = logger_info_array.length;

                // Loop through each logger configuration and send the log to the appropriate appenders
                for (var i:int = 0; i < num_logger_infos; i++) {
                    add_to_appender(time, relative_time, logger_info_array[i], level, name, text, args);
                }
            }
        }

        // ! PRIVATE FUNCTIONS ! //

        /**
         * Retrieves an array of logger configurations applicable to the given log level and name.
         */
        private function get_logger_info_array(level:Level, name:String):Array {
            var infos:Array = [];

            // Iterate through all configured loggers
            for (var i:int = 0; i < _loggers.length; i++) {
                var current_logger_info:LoggerInfo = _loggers[i];

                // If it's a root logger, always include it
                if (current_logger_info.is_root) {
                    infos.push(current_logger_info);
                }
                // Otherwise, check if the logger's name matches the log source's package hierarchy
                else if (current_logger_info.name.length <= name.length) {
                    if (package_equals(name, current_logger_info.name)) {
                        infos.push(current_logger_info);
                    }
                }
            }

            // Apply filtering logic to select only relevant loggers based on severity level
            return filter_logger_infos(infos, level);
        }

        /**
         * Checks if a given log source name belongs to a specific package.
         * 
         * @param full_name  The full log source name.
         * @param short_name The package name to compare against.
         * @return           Boolean indicating if the log source is part of the package.
         */
        private function package_equals(full_name:String, short_name:String):Boolean {
            var full_parts:Array = full_name.toUpperCase().split(".");
            var short_parts:Array = short_name.toUpperCase().split(".");

            // Compare each segment of the package name
            for (var i:int = 0; i < short_parts.length; i++) {
                if (full_parts[i] != short_parts[i]) {
                    return false;
                }
            }

            return true;
        }

        /**
         * Filters the list of logger configurations to determine the most appropriate ones for logging.
         */
        private function filter_logger_infos(logger_info_array:Array, level:Level):Array {
            var filtered_logger_infos:Array = [];

            // If there are no logger configurations, return an empty array
            if (logger_info_array.length == 0) {
                return filtered_logger_infos;
            }

            // Sort the loggers based on specificity and priority
            logger_info_array.sort(logger_info_sorter);

            // Select the first logger as the reference point for filtering
            var first_logger_info:LoggerInfo = logger_info_array[0];
            filtered_logger_infos[0] = first_logger_info;

            // Iterate through remaining loggers and apply filtering based on log level priority
            for (var i:int = 1; i < logger_info_array.length; i++) {
                var current_logger_info:LoggerInfo = logger_info_array[i];

                // If the priority is different, replace the current selection
                if (current_logger_info.level.priority > first_logger_info.level.priority ||
                    current_logger_info.level.priority < first_logger_info.level.priority) {
                    
                    filtered_logger_infos.splice(0);
                    filtered_logger_infos.push(current_logger_info);
                    first_logger_info = current_logger_info;
                } 
                // If priority is the same, add the logger to the selection
                else {
                    filtered_logger_infos.push(current_logger_info);
                }
            }

            // Return the filtered list only if the log level meets the minimum priority
            if (level.priority >= first_logger_info.level.priority) {
                return filtered_logger_infos;
            }

            return null;
        }

        /**
         * Sort function for logger configurations.
         * Ensures root loggers appear first, followed by loggers sorted by name length.
         */
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

        /**
         * Sends a log entry to the appropriate appender based on the logger configuration.
         */
        private function add_to_appender(time:Date, relative_time:int, logger_info:LoggerInfo, level:Level, name:String, text:String, args:Array):void {
            // Retrieve the appropriate appender based on the logger configuration
            var appender:Appender = _appenders.get_value(logger_info.appender_name) as Appender;

            // If an appender exists, format the message and log it
            if (appender) {
                var formatted_text:String = MessageFormatter.format_string(text, args);
                appender.add_log(time, relative_time, level, name, formatted_text);
            }
        }

        // ! GETTERS & SETTERS ! //

        /**
         * Returns the signal that is dispatched when configuration loading is complete.
         */
        public function get on_complete_signal():Signal {
            return _on_complete_signal;
        }

        // ! DELEGATE FUNCTIONS ! //

        /**
         * Callback function triggered when the configuration file has been loaded.
         * Stores the appenders and loggers from the configuration data.
         */
        public function on_config_loaded(config_data:Object):void {
            _appenders = config_data.appenders;
            _loggers = config_data.loggers;

            // Dispatch the signal to notify that configuration loading is complete
            _on_complete_signal.dispatch();
        }
    }
}