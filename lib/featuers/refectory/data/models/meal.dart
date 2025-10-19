class Meal {
  String? date;
  String? day;
  String? soup;
  String? mainMeal;
  String? mainMealVegetarian;
  String? helperMeal;
  String? dessert;
  String? soupImageUrl;
  String? mealImageUrl;
  String? vegetarianImageUrl;
  String? helperMealImageUrl;
  String? dessertImageUrl;

  Meal.empty();

  Meal(
      this.date,
      this.day,
      this.soup,
      this.mainMeal,
      this.mainMealVegetarian,
      this.helperMeal,
      this.dessert,
      this.soupImageUrl,
      this.mealImageUrl,
      this.vegetarianImageUrl,
      this.helperMealImageUrl,
      this.dessertImageUrl);

  Meal.fromJson(Map<String, dynamic> json) {
    date = json["date"];
    day = json["day"];
    soup = json["soup"];

    // 1) Cache’ten gelirse ayrı ayrı olabilir
    final main1 = json["mainMeal"]?.toString();
    final veg1 = json["mainMealVegetarian"]?.toString();

    // 2) Sunucudan gelirse tek string olabilir
    final combined = json["meal"]?.toString();
    if (combined != null && combined.trim().isNotEmpty) {
      final parts = combined.split('-');
      final ana = parts.isNotEmpty ? parts[0].trim() : null;
      final veg = parts.length > 1 ? parts[1].trim() : null;

      // Öncelik: ayrı alan verilmişse onu kullan, yoksa combined’den geleni
      mainMeal = main1 ?? ana;
      mainMealVegetarian = veg1 ?? veg;
    } else {
      mainMeal = main1;
      mainMealVegetarian = veg1;
    }

    // if (json["meal"] != null) {
    //   // 'meal' stringini '-' karakterine göre ayır
    //   final meal = json["meal"].split("-");
    //   mainMeal = meal.isNotEmpty ? meal[0].trim() : null; // İlk kısım
    //   mainMealVegetarian =
    //       meal.length > 1 ? meal[1].trim() : null; // İkinci kısım
    // }

    helperMeal = json["helperMeal"];
    dessert = json["dessert"];

    // 📌 soupImageUrl kontrolü
    if (json.containsKey("soupImageUrl")) {
      print("soupImageUrl Found: ${json["soupImageUrl"]}");
    } else {
      print("soupImageUrl NOT FOUND in JSON!");
    }

    soupImageUrl = json["soupImageUrl"];
    mealImageUrl = json["mealImageUrl"];
    vegetarianImageUrl = json["vegetarianImageUrl"];
    helperMealImageUrl = json["helperMealImageUrl"];
    dessertImageUrl = json["dessertImageUrl"];
  }

  Map toJson() {
    return {
      "date": date,
      "day": day,
      "soup": soup,
      "mainMeal": mainMeal,
      "mainMealVegetarian": mainMealVegetarian,
      "helperMeal": helperMeal,
      "dessert": dessert,
      "soupImageUrl": soupImageUrl,
      "mealImageUrl": mealImageUrl,
      "vegetarianImageUrl": vegetarianImageUrl,
      "helperMealImageUrl": helperMealImageUrl,
      "dessertImageUrl": dessertImageUrl,
    };
  }
}
