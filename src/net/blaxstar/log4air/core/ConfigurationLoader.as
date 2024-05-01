package net.blaxstar.log4air.core {
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;

    import net.blaxstar.log4air.printf;
    import net.blaxstar.log4air.utils.HashMap;

    import org.osflash.signals.Signal;



    public class ConfigurationLoader {
        private var _io_stream:FileStream;
        private var _on_file_read_signal:Signal;
        private var _on_complete_signal:Signal;
        private var _on_error_signal:Signal;
        // ! CONSTRUCTOR ! //
        public function ConfigurationLoader() {
            _on_file_read_signal = new Signal(String);
            _on_complete_signal = new Signal(Object);
            _on_error_signal = new Signal(Error);
            _io_stream = new FileStream();
            _on_file_read_signal.add(on_complete);
        }

        // ! PUBLIC FUNCTIONS ! //

        public function load_config_file(file_path:String):void {
            try {
              var config_file_data:String;
              _io_stream.open(new File(file_path), FileMode.READ);
              config_file_data = _io_stream.readUTFBytes(_io_stream.bytesAvailable);
              _io_stream.close()
            } catch (error:Error) {
              _on_error_signal.dispatch(error);
              return;
            }
            _on_file_read_signal.dispatch(config_file_data);
        }

        // ! DELEGATE FUNCTIONS ! //

        private function on_complete(file_data:String):void {
            var config_json:Object = JSON.parse(file_data);
            var appenders:HashMap;
            var loggers:Array;

            try {
                appenders = ConfigurationParser.parse_appenders(config_json);
                loggers = ConfigurationParser.parse_loggers(config_json);
            } catch (error:Error) {
                printf("[ERROR][JSON CONFIG]: %s", error.message);

                _on_error_signal.dispatch(error);
                return;
            }
            var final:Object = {appenders: appenders, loggers: loggers};
            _on_complete_signal.dispatch(final);
        }

        public function get on_error_signal():Signal {
          return _on_error_signal;
        }

        public function get on_complete_signal():Signal {
          return _on_complete_signal;
        }
    }
}
