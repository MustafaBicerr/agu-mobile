class sisLessons {
  // late List<sisLessons> _sisLessonsList = [];

  String? gun;
  int? dow;
  String? saat;
  String? ders_kodu;
  late String? ders_adi;
  String? derslik;
  String? ogretim_elemani;

  sisLessons({
    // this._sisLessonsList,
    this.gun,
    this.dow,
    this.saat,
    this.ders_kodu,
    this.ders_adi,
    this.derslik,
    this.ogretim_elemani,
  });

  sisLessons.empty();

  sisLessons.fromJson(Map<String, dynamic> json) {
    gun = json["gun"];
    saat = json["saat"];
    ders_kodu = json["ders_kodu"];
    ders_adi = json["ders_adi"];
    derslik = json["derslik"];
    ogretim_elemani = json["ogretim_elemani"];
  }

  Map toJson() {
    return {
      gun: "gun",
      saat: "saat",
      ders_kodu: "ders_kodu",
      ders_adi: "ders_adi",
      derslik: "derslik",
      ogretim_elemani: "ogretim_elemani",
    };
  }
}
