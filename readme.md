# LOG4AIR

Log4AIR is a versatile, industrial-grade ActionScript 3 logging framework based on Apache's [Log4j](https://github.com/apache/logging-log4j2).

It uses a JSON formatted configuration file (instead of the typical XML) to manipulate and customize logging for richer, clearer log files.

The JSON format is easier to read, write, and is less resource-hungry on the AVM than XML. With JSON's conciseness, you can modify your config with ease.

## USAGE
The below shows the example config file (located in the bin folder as log4air_config.json):

```
{
  "appenders": [
    {
      "name": "STDOUT",
      "class": "net.blaxstar.log4air.appenders.ConsoleAppender",
      "layout": {
        "class": "net.blaxstar.log4air.layouts.PatternLayout",
        "pattern": "%date%level%class %msg"
      }
    },
    {
      "name": "FILE",
      "class": "net.blaxstar.log4air.appenders.FileAppender",
      "layout": {
        "class": "net.blaxstar.log4air.layouts.PatternLayout",
        "pattern": "%date%level%class %msg"
      },
      "filepath": "fakefile.log"
    }
  ],
  "loggers": [
    {
      "name": "Main",
      "level": "INFO",
      "appender_ref": "STDOUT"
    }
  ],
  "root": {
    "level": "OFF",
    "appender_ref": "STDOUT"
  }
}

```
appenders and layouts are extendable, so you can create your own custom configs. currently, there are the base `Appender` class, `ConsoleAppender` for writing to standard output, and `FileAppender` for writing to files. multiple output appenders per logger is not yet supported but is coming soon. 

once your config is how you want it, simply reference your appender classes and layouts somewhere in your application so that they are compiled, then get an instance of your logger to start using right away:

```
import net.blaxstar.log4air.appenders.ConsoleAppender;
import net.blaxstar.log4air.appenders.FileAppender;
import net.blaxstar.log4air.layouts.PatternLayout;
ConsoleAppender;
FileAppender;
PatternLayout;

public class Main extends Sprite {
    private var log:Logger = LoggerFactory.getLogger(Main);
    public function Main() {
        log.info("initializing app...");
        var fairy:Sprite = new Sprite();
        log.debug("Created class: {}", fairy);
        addChild(fairy);
        log.debug("added man to {}", this);
        log.info("main finished");
    }
}
// using the example config, this outputs:
// [2024/04/30 @ 23:09:17.544][INFO][Main] initializing app...
// [2024/04/30 @ 23:10:34.787][INFO][Main] main finished
```