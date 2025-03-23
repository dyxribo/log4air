package net.blaxstar.log4air.manager {

    // Import necessary Flash classes and project dependencies
    import flash.events.Event;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getTimer;
    import flash.filesystem.File;
    
    import net.blaxstar.log4air.Logger;
    import net.blaxstar.log4air.core.LogFilter;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.utils.BufferedCaller;
    import net.blaxstar.log4air.utils.HashMap;

    public class LogManager {
        // Holds the singleton instance of LogManager
        private static var instance:LogManager;

        // Stores the file path to the logging configuration JSON file
        private static var log_file_path:String = File.applicationDirectory.resolvePath("log4air_config.json").nativePath;

        // Manages log filtering rules and processing
        private var log_filter:LogFilter;

        // Buffers log messages before sending them for processing
        private var log_filter_buffer:BufferedCaller;

        // Maps log source names to timestamps for relative timing
        private var relative_time_map:HashMap;

        // ! CONSTRUCTOR ! //

        /**
         * Private constructor to enforce the singleton pattern.
         * The 'notAllowed' parameter ensures that only LogManager itself can instantiate this class.
         */
        public function LogManager(notAllowed:Key) {
            // Prevent direct instantiation by requiring a 'Key' parameter
            if (notAllowed == null) {
                throw new ArgumentError("Unauthorized instantiation of LogManager. Use get_instance() instead.");
            }

            // Initialize the log filter, which manages log configuration and filtering rules
            log_filter = new LogFilter();

            // Initialize the hash map to store timestamps for log sources
            relative_time_map = new HashMap();

            // Initialize the buffered caller to queue log messages before processing
            log_filter_buffer = new BufferedCaller(log_filter, log_filter.on_complete_signal);

            // Load the log configuration from the specified file path
            log_filter.load_config(log_file_path);
        }

        // ! PUBLIC FUNCTIONS ! //

        /**
         * Returns a Logger instance associated with the given log target.
         * The log target can be either a string or an object.
         */
        public function get_logger(log_target:Object):Logger {
            // Ensure that the log target is not null
            if (log_target == null) {
                throw new ArgumentError("log_target must not be null!");
            }

            var name:String;

            // If the target is a string, use it directly as the logger name
            if (log_target is String) {
                name = String(log_target);
            } 
            // Otherwise, retrieve the class name of the object and format it
            else {
                name = getQualifiedClassName(log_target);
                name = name.replace(/::/g, ".");
            }

            // Create and return a new Logger instance linked to this LogManager
            var logger:Logger = new Logger(name, this);
            return logger;
        }

        /**
         * adds a log entry to the buffered queue for processing.
         * this method calculates the relative time since the first log entry for the given source.
         * @param level the severity level of the log (e.g., DEBUG, INFO, WARN, ERROR).
         * @param name the name of the log source (e.g., class name or module).
         * @param text the log message content.
         * @param args additional arguments for message formatting (optional).
         * @throws ArgumentError if the log source name is null or empty.
         * @throws Error if the log level is not recognized.
         * @throws Error if the log message is null or empty.
         * @throws Error if the arguments array is not valid.
         */
        public function add_log(level:Level, name:String, text:String, args:Array):void {
            var relative_time:int;

            // Check if a timestamp already exists for this log source
            if (relative_time_map.hasKey(name)) {
                // Retrieve the original timestamp and calculate the elapsed time
                var start_time:int = int(relative_time_map.get_value(name));
                relative_time = getTimer() - start_time;
            } 
            // If this is the first log entry for the given source, store the current timestamp
            else {
                relative_time_map.add(name, getTimer());
                relative_time = 0;
            }

            // Add the log entry to the buffered queue, using the calculated relative time
            log_filter_buffer.add_log(new Date(), relative_time, level, name, text, args);
        }

        /**
         * returns the singleton instance of LogManager.
         * if the instance does not exist, it creates one using a private Key class to enforce singleton restrictions.
         * @return the singleton instance of LogManager.
         * @throws ArgumentError if an attempt is made to instantiate LogManager directly.
         */
        public static function get_instance():LogManager {
            // return the existing instance if it has already been created
            if (instance) {
                return instance;
            } 
            // otherwise, create a new instance and enforce singleton restrictions
            else {
                instance = new LogManager(new Key());
                return instance;
            }
        }
    }
}

// internal Key class prevents external instantiation of LogManager
internal class Key {
}