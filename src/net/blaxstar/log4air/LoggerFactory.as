package net.blaxstar.log4air {
    import net.blaxstar.log4air.manager.LogManager;

    public class LoggerFactory {

        public static var log_manager:LogManager = LogManager.get_instance()

        public static function getLogger(log_target:Object):Logger {
            return log_manager.get_logger(log_target);
        }

    }
}
