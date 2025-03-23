package net.blaxstar.log4air.core {
    import net.blaxstar.log4air.utils.HashMap;
    import net.blaxstar.log4air.utils.LogUtils;
    import net.blaxstar.log4air.appenders.Appender;
    import net.blaxstar.log4air.printf;
    import net.blaxstar.log4air.interfaces.IPropertiesHolder;
    import net.blaxstar.log4air.dataholder.LoggerInfo;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.dataholder.LevelHolder;

    /**
     * ConfigurationParser is responsible for parsing the logging configuration from a JSON object.
     * It extracts the appenders and loggers defined in the configuration and creates instances of them.
     * The appenders are stored in a HashMap keyed by their names, while the loggers are returned as an array of LoggerInfo objects.
     * It also handles the parsing of appender properties, allowing for nested properties to be set correctly.
     * This class is essential for setting up the logging framework based on a provided configuration file.
     * @author Deron Decamp
     * @version 1.0
     * @date 2025.03.23
     */
    public class ConfigurationParser {

        /**
         * parses the appenders defined in the provided JSON object and returns a HashMap of appender instances.
         * each appender is created based on its class name and properties defined in the JSON object.
         * the appender name is used as the key in the HashMap.
         * @param json the JSON object containing the appender configuration.
         * @return  a HashMap containing appender instances, keyed by their names.
         * @throws error if the class specified in the JSON object cannot be found or instantiated.
         */
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

        /**
         * parses the loggers defined in the provided json object and returns an array of LoggerInfo objects.
         * @param configuration_json the JSON object containing the logger configuration.
         * @return an array of LoggerInfo objects representing the loggers defined in the configuration.
         */
        static public function parse_loggers(configuration_json:Object):Array {
            var loggers:Array = configuration_json.loggers;
            var root:Object = configuration_json.root;
            var config_objects:Array = [];
            var num_loggers:uint = loggers.length;

            if (!has_content(configuration_json)) {
                return null;
            }

            for (var i:int = 0; i < num_loggers; i++) {
                var logger_config:Object = loggers[i];

                if (!logger_config || typeof logger_config != "object") {
                    throw new Error("[ERROR][CONFIG_PARSER] possible bad configuration: logger config was parsed as an null object!");
                    return null;
                }

                if (!logger_config.hasOwnProperty("type") || !logger_config.hasOwnProperty("name") || !logger_config.hasOwnProperty("level")) {
                    throw new Error("[ERROR][CONFIG_PARSER] possible bad configuration: logger type, name or level was not found!");
                    return null;
                }

                var level:Level = LevelHolder.get_level(logger_config.level);

                if (!level) {
                    return null;
                }

                var logger_info:LoggerInfo = new LoggerInfo(root, logger_config.name, level, logger_config.type);
                config_objects.push(logger_info);
            }

            if (root) {
                logger_info = new LoggerInfo(true, logger_config.name, level, logger_config.type);

                if (logger_info && root.level !== "OFF") {
                    config_objects.push(logger_info);
                }
            }
            return config_objects;
        }

        /**
         * parses the properties of an appender from the provided JSON object and assigns them to the given property holder.
         * this function recursively processes nested properties if the appender has its own properties defined.
         * @param json the JSON object containing the appender properties.
         * @param property_holder the object that holds the properties to be set.
         * @throws error if the class specified in the JSON object cannot be found or instantiated.
         */
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

        /**
         * checks if the provided JSON object has any content (i.e., properties).
         * @param json The JSON object to check for content.
         * @return true if the JSON object has at least one property, false otherwise.
         */
        static private function has_content(json:Object):Boolean {
            for each (var item:Object in json) {
                return true;
            }
            return false;
        }

    }
}
