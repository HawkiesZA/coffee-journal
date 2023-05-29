const roastProfiles = <String>["Light", "Medium", "Dark", "Charcoal"];
const brewMethods = <String>["Aeropress", "Moka Pot", "V60", "Chemex", "Siphon Pot", "French Press", "Espresso", "Delter Press", "Bripe"];
const grindSizes = <String>["Coarse", "Medium-Coarse", "Medium", "Fine", "Superfine"];
const doseMeasurements = <String>["g", "ml", "scoops", "beans"];
const waterMeasurements = <String>["g", "ml", "cups", "drops"];

enum PrefKeys {
  default_roast_profile,
  default_brew_method,
  default_grind_size,
  default_dose_measurement,
  default_water_measurement
}