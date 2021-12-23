import 'package:intl/intl.dart';

import 'model/brew.dart';

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

extension BrewListHelpers on List<Brew>? {
  List<Brew> filterUniqueRoaster() {
    var roasterSet = Set<String>();
    var brewList = List.generate(0, (index) => Brew());
    this?.forEach((element) {
      if (!roasterSet.contains(element.roaster)) {
        roasterSet.add(element.roaster!);
        brewList.add(element);
      }
    });
    return brewList;
  }

  List<Brew> filterUniqueBlend() {
    var blendSet = Set<String>();
    var brewList = List.generate(0, (index) => Brew());
    this?.forEach((element) {
      if (!blendSet.contains(element.blend)) {
        blendSet.add(element.blend!);
        brewList.add(element);
      }
    });
    return brewList;
  }
}