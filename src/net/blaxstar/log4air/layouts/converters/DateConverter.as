package net.blaxstar.log4air.layouts.converters {
    import net.blaxstar.log4air.layouts.converters.Converter;
    import net.blaxstar.log4air.dataholder.Level;
    import net.blaxstar.log4air.printf;

    public class DateConverter extends Converter {

        override public function convert(time:Date, relative_time:int, level:Level, name:String, text:String):String {
            var result:String = printf("[%s/%s/%s @ %s:%s:%s.%s]", time.fullYear, pad_date_zeroes(time.month + 1), pad_date_zeroes(time.date), pad_date_zeroes(time.hours), pad_date_zeroes(time.minutes), pad_date_zeroes(time.seconds), time.milliseconds);

            return result;
        }


        private function pad_date_zeroes(num:Number):String {
            return String(num < 10 ? "0" + num : num);
        }
    }
}
