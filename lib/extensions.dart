import 'package:intl/intl.dart';

extension Formatting on Duration {
  String format() => '$this'.split('.')[0].substring(2);
  String strFormat() {
        final mins = this.inMinutes;
        final seconds = this.inSeconds - (mins * Duration.secondsPerMinute);
        return '$mins minutes and $seconds seconds with';
      }
}

extension Things on DateTime {
  String format() {
    final now = DateTime.now().toUtc();
    if (this.day == now.day) {
      return DateFormat("HH:mm").format(this.toLocal());
    }
    return DateFormat("yyyy-MM-dd HH:mm").format(this.toLocal());
  }
}