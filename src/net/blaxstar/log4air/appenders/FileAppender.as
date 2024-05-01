package net.blaxstar.log4air.appenders {
    import net.blaxstar.log4air.dataholder.Level;
    import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;

    public class FileAppender extends Appender {
        public function FileAppender(name:String) {
            super(name)
        }

        override public function print(time:Date, relative_time:int, level:Level, name:String, output:String):void {
            var filestream:FileStream = new FileStream();
            var filepath:String = properties.filepath; 
            
            try {
              filestream.openAsync(new File(filepath), FileMode.APPEND);
            } catch (error:*) {
              filepath = File.applicationStorageDirectory.resolvePath("log4air.log").nativePath;
              filestream.openAsync(new File(filepath), FileMode.APPEND);
            }
            filestream.writeUTFBytes(output + "\n");
            filestream.close();
        }

    }
}
