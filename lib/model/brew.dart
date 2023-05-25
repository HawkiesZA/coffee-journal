import '../extensions.dart';

class Brew {
  String? id;
  String? creator;
  String? roaster;
  String? blend;
  String? roastProfile;
  String? method;
  String? grindSize;
  int? dose;
  String? doseMeasurement;
  int? water;
  String? waterMeasurement;
  int? duration;
  int? time;
  int? rating;
  String? notes;

  Brew({ this.id, this.creator, this.roaster, this.blend, this.roastProfile, this.method,
    this.grindSize, this.dose, this.doseMeasurement, this.water,
    this.waterMeasurement, this.duration, this.time, this.rating, this.notes });
  factory Brew.fromDatabaseJson(Map<String, dynamic> data) => Brew(
    id: data['id'].toString(),
    creator: data['creator'],
    roaster: data['roaster'],
    blend: data['blend'],
    roastProfile: data['roast_profile'],
    method: data['method'],
    grindSize: data["grind_size"],
    dose: data['dose'],
    doseMeasurement: data['dose_measurement'],
    water: data['water'],
    waterMeasurement: data['water_measurement'],
    duration: data['duration'],
    time: data['time'],
    rating: data['rating'],
    notes: data['notes'],
  );

  String toString() {
    return "I just brewed $blend roasted $roastProfile by $roaster $dose $doseMeasurement $grindSize ground brewed with $water $waterMeasurement water for ${Duration(seconds: duration ?? 0).strFormat()} $method at ${DateTime.fromMillisecondsSinceEpoch(time ?? 0, isUtc: true).format()}. $rating / 5";
  }

  Map<String, dynamic> toDatabaseJson() => {
    "id": this.id,
    "creator": this.creator,
    "roaster": this.roaster,
    "blend": this.blend,
    "roast_profile": this.roastProfile,
    "method": this.method,
    "grind_size": this.grindSize,
    "dose": this.dose,
    "dose_measurement": this.doseMeasurement,
    "water": this.water,
    "water_measurement": this.waterMeasurement,
    "duration": this.duration,
    "time": this.time,
    "rating": this.rating,
    "notes": this.notes,
  };
}