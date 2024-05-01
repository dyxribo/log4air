package net.blaxstar.log4air.utils {
    import flash.utils.Dictionary;
    
    public class HashMap {
        private var _map:Dictionary;
        private var _reverse_map:Dictionary;
        private var _size:uint;

        public function HashMap() {
            _map = new Dictionary(true);
            _reverse_map = new Dictionary(true);
            _size = 0;
        }

        public function get size():int {
            return _size;
        }

        public function add(key:Object, obj:Object):void {
            _map[key] = obj;
            _reverse_map[obj] = key;
            _size += 1;
        }

        public function get_value(key:Object):Object {
            return _map[key];
        }

        public function getKey(obj:Object):Object {
            return _reverse_map[obj];
        }

        public function hasKey(key:Object):Boolean {
            if (get_value(key) != null) {
                return true;
            } else {
                return false;
            }
        }

        public function get_dictionary():Dictionary {
            return _map;
        }

        public function remove(key:Object):void {
            delete _reverse_map[_map[key]];
            delete _map[key];
            _size = _size - 1;
        }
    }
}
