package net.blaxstar.log4air {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.display.NativeWindow;
    import flash.events.Event;
    import flash.display.Stage;
    import flash.desktop.NativeApplication;

    public class Logger {
        public static const OK:uint = 0;
        public static const DEBUG:uint = 1;
        public static const WARN:uint = 2;
        public static const ERROR:uint = 3;
        public static const FATAL:uint = 4;

        private static var _log_file:File;
        private static var _instance:Logger;
        private static var _log:Vector.<String>;
        private static var _filestream:FileStream;
        private static var _native_window:NativeWindow;
        private static var _silence_errors:Boolean;
        private static var _instantiating_internally:Boolean;

        //TODO: add notification system
        //private static var _enable_notifications:Boolean;

        /**
         * TODO: class documentation
         */
        public function Logger() {
            if (!_instantiating_internally) {
                throw new Error("class is a singleton instance. use Logger.get_instance().");
            }
            _log = new Vector.<String>();
            _filestream = new FileStream();
            _instantiating_internally = false;
        }

        public function init(stage:Stage, silence_errors:Boolean=true, logfile_name:String = "app_log"):Logger {
            _log_file = new File(File.applicationStorageDirectory.nativePath + File.separator + logfile_name + ".log");
            _silence_errors = silence_errors;

            if (stage) {
                _native_window = stage.nativeWindow;
                _native_window.addEventListener(Event.CLOSE, on_app_close);
            } else {
              throw new Error("stage is null, logger could not be initialized!");
            }
            return this;
        }

        static public function get_instance():Logger {
            if (!_instance) {
                _instantiating_internally = true;
                _instance = new Logger();
            }

            return _instance;
        }

        public function write_success(message:String, ... format):void {
            write_log.apply(null, [message, Logger.OK].concat(format));
        }

        public function write_debug(message:String, ... format):void {
            write_log.apply(null, [message, Logger.DEBUG].concat(format));
        }

        public function write_warning(message:String, ... format):void {
            write_log.apply(null, [message, Logger.WARN].concat(format));
        }

        public function write_error(message:String, ... format):void {
            write_log.apply(null, [message, Logger.ERROR].concat(format));
        }

        public function write_fatal(message:String, ... format):void {
            write_log.apply(null, [message, Logger.FATAL].concat(format));
        }

        public function write_log(message:String, severity:uint = Logger.DEBUG, ... format):void {
            if (!_instance) {
                return;
            }

            var prefix:String = "[".concat(new Date().toUTCString()).concat("]");
            var full_message:String = "";

            if (!_log) {
                _log = new Vector.<String>();
            }

            switch (severity) {
                case OK:
                    prefix = prefix.concat("[OK]");
                    break;
                case DEBUG:
                    prefix = prefix.concat("[DEBUG]");
                    break;
                case WARN:
                    prefix = prefix.concat("[WARN]");
                    break;
                case ERROR:
                    prefix = prefix.concat("[ERROR]");
                    break;
                case FATAL:
                    prefix = prefix.concat("[FATAL]");
                    break;
            }

            full_message = printf(prefix.concat(" ").concat(message), format);
            _log.push(full_message);

            if (severity == ERROR || severity == FATAL) {
                if (!_filestream) {
                    _filestream = new FileStream();
                }

                flush_log();

                if (!_silence_errors) {
                    throw new Error(full_message, severity);
                }

                if (severity == FATAL) {
                  NativeApplication.nativeApplication.exit(severity);
                }
            }
        }

        public function flush_log():Boolean {
            _filestream.open(_log_file, FileMode.APPEND);
            for (var i:uint = 0; i < _log.length; i++) {
                try {
                    _filestream.writeUTFBytes(_log[i].concat("\n"));
                } catch (e:Error) {
                    write_log("error writing log file: %s", Logger.ERROR, e.message);
                }

            }

            _filestream.close();
            return true;
        }

        public function get silence_errors():Boolean {
            return _silence_errors;
        }

        public function set silence_errors(value:Boolean):void {
            _silence_errors = value;
        }

        private function on_app_close(e:Event):void {
            write_log("application terminated.", DEBUG);
            flush_log();
        }
    }
}
