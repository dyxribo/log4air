package net.blaxstar.log4air.core {
    import net.blaxstar.log4air.utils.HashMap;
    import net.blaxstar.log4air.utils.LogUtils;
    import net.blaxstar.log4air.appenders.Appender;
    import net.blaxstar.log4air.printf;
    import net.blaxstar.log4air.interfaces.IPropertiesHolder;
    import net.blaxstar.log4air.dataholder.LoggerInfo;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.dataholder.LevelHolder;

    public class ConfigurationParser {

        static public function parse_appenders(json:Object):HashMap {
            var appenders:Array = json.appenders;
            var instances:HashMap = new HashMap();
            var num_appenders:uint = appenders.length;

            for (var i:int = 0; i < num_appenders; i++) {
                var current_appender:Object = appenders[i];
                var class_name:String = current_appender["class"];
                var appender_name:String = String(current_appender.name).toUpperCase();
                var appender_class:Class = LogUtils.get_definition(class_name);

                if (appender_class) {
                    try {
                        var appender:Appender = new appender_class(appender_name) as Appender;
                        if (appender) {
                            parse_appender_properties(current_appender, appender);
                            instances.add(appender_name, appender);
                        }
                    } catch (error:Error) {
                    }
                } else {
                    printf("[ERROR][CONFIG_PARSER] appender class %s not found; make sure that it was compiled with your application!", class_name);
                }
            }
            return instances;
        }

        static public function parse_loggers(json:Object):Array {
            var loggers:Array = json.loggers;
            var root:Object = json.root;
            var instances:Array = [];
            var num_loggers:uint = loggers.length;

            for (var i:int = 0; i < num_loggers; i++) {
                var logger_info:LoggerInfo = parse_logger(loggers[i]);

                if (logger_info) {
                    instances.push(logger_info);
                }
            }
            if (root) {
                logger_info = parse_logger(root, true);

                if (logger_info) {
                    instances.push(parse_logger(root, true));
                }
            }
            return instances;
        }

        static public function parse_appender_properties(json:Object, property_holder:IPropertiesHolder):void {
            for (var property:Object in json) {
                var current_property:Object = json[property];

                if (current_property.hasOwnProperty("class") && (String(current_property["class"]).length)) {
                    var class_name:String = String(current_property["class"]);
                    var main_class:Class = LogUtils.get_definition(class_name);

                    if (main_class) {
                        try {
                            var instance:* = new main_class();
                        } catch (e:Error) {
                            trace(e);
                        }
                        property_holder.properties[property] = instance;
                        if (has_content(json[property]) && instance is IPropertiesHolder) {
                            parse_appender_properties(json[property], IPropertiesHolder(instance));
                        }
                    } else {
                        printf("[ERROR][CONFIG_PARSER] class %s not found; make sure that it was compiled with your application!", class_name);
                    }
                } else {
                    property_holder.properties[property] = current_property;
                }
            }
        }

        static private function parse_logger(json:Object, root:Boolean = false):LoggerInfo {
            if (!has_content(json)) {
                return null;
            }
            var logger_name:String = String(json.name).toUpperCase();
            var level_name:String = String(json.level).toUpperCase();
            // TODO: allow multiple appender references as array. will need to refactor how the logger parses them.
            var appender_name:String = json.appender_ref;
            var level:Level = LevelHolder.get_level(level_name);

            if (!level) {
                return null;
            }

            var logger_info:LoggerInfo = new LoggerInfo(root, logger_name, level, appender_name);

            return logger_info;
        }

        static private function has_content(json:Object):Boolean {

            for each (var item:Object in json) {
                return true;
            }
            return false;
        }
    }
}
