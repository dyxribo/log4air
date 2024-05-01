package net.blaxstar.log4air.utils {
    import flash.events.Event;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    import org.osflash.signals.ISignal;

    public dynamic class BufferedCaller extends Proxy {

        private var _signal_dispatched:Boolean;
        private var _signal_dispatcher:ISignal;
        private var _signal_type:String;
        private var _target_object:*;
        private var _buffer:Array;

        public function BufferedCaller(target:*, dispatcher:ISignal) {
            _signal_dispatched = false;
            _buffer = [];

            this._target_object = target;
            this._signal_dispatcher = dispatcher;
            dispatcher.add(on_signal_dispatched);
        }

        private function call_buffer():void {
            for (var i:int = 0; i < _buffer.length; i++) {
                call_function(_buffer[i].name, _buffer[i].args);
            }
            _buffer.splice(0);
        }

        private function add_to_buffer(funcName:String, args:*):void {
            _buffer.push({name: funcName, args: args});
        }

        private function call_function(name:String, args:*):void {
            _target_object[name].apply(null, args);
        }

        private function on_signal_dispatched(...dispatch_data):void {
            _signal_dispatched = true;
            _signal_dispatcher.remove(on_signal_dispatched);
            _signal_dispatcher = null;
            call_buffer();
        }

        override flash_proxy function callProperty(method_name:*, ... args):* {
            if (!_signal_dispatched) {
                add_to_buffer(method_name, args);
            } else {
                call_function(method_name, args);
            }
        }

        override flash_proxy function getProperty(name:*):* {
            return "";
        }

        override flash_proxy function setProperty(name:*, value:*):void {

        }
    }
}
