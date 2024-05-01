package {
    import flash.display.Sprite;

    import net.blaxstar.log4air.Logger;
    import net.blaxstar.log4air.LoggerFactory;
    import net.blaxstar.log4air.appenders.ConsoleAppender;
    ConsoleAppender;
    import net.blaxstar.log4air.appenders.FileAppender;
    FileAppender;
    import net.blaxstar.log4air.layouts.PatternLayout;
    PatternLayout;

    public class Main extends Sprite {
        private var log:Logger = LoggerFactory.getLogger(Main);
        // EXAMPLE 
        public function Main() {
            log.info("initializing app...");
            var fairy:Sprite = new Sprite();
            log.debug("Created class: {}", fairy);
            addChild(fairy);
            log.debug("added man to {}", this);
            log.info("main finished");
        }
    }
}
