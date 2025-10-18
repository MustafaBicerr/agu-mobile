import 'package:home_page/notifications.dart';

class Events {
  String? kulup;
  String? etkinlik_adi;
  String? etkinlik_turu;
  String? etkinlik_aciklamasi;
  String? etkinlik_tarihi;
  String? kulup_sayfasi;
  String? uygulama_ici_resim;
  String? etkinlik_afisi;
  String? sorumlu_uye;
  String? sorumlu_iletisim;

  Events.empty();

  Events(
      this.kulup,
      this.etkinlik_adi,
      this.etkinlik_turu,
      this.etkinlik_aciklamasi,
      this.etkinlik_tarihi,
      this.kulup_sayfasi,
      this.uygulama_ici_resim,
      this.etkinlik_afisi,
      this.sorumlu_uye,
      this.sorumlu_iletisim);

  Events.fromJson(Map<String, dynamic> json) {
    kulup = json["kulup"];
    etkinlik_adi = json["etkinlik_adi"];
    etkinlik_turu = json["etkinlik_turu"];
    etkinlik_aciklamasi = json["etkinlik_aciklamasi"];
    etkinlik_tarihi = json["etkinlik_tarihi"];
    kulup_sayfasi = json["kulup_sayfasi"];
    uygulama_ici_resim = json["uygulama_ici_resim"];
    etkinlik_afisi = json["etkinlik_afisi"];
    sorumlu_uye = json["sorumlu_uye"];
    sorumlu_iletisim = json["sorumlu_iletisim"];
  }

  Map toJson() {
    return {
      "kulup": kulup,
      "etkinlik_adi": etkinlik_adi,
      "etkinlik_turu": etkinlik_turu,
      "etkinlik_aciklamasi": etkinlik_aciklamasi,
      "etkinlik_tarihi": etkinlik_tarihi,
      "kulup_sayfasi": kulup_sayfasi,
      "uygulama_ici_resim": uygulama_ici_resim,
      "etkinlik_afisi": etkinlik_afisi,
      "sorumlu_uye": sorumlu_uye,
      "sorumlu_iletisim": sorumlu_iletisim,
    };
  }
}

class Speaker {
  String? etkinlik_adi;
  String? unvan1;
  String? ad1;
  String? url1;
  String? unvan2;
  String? ad2;
  String? url2;
  String? unvan3;
  String? ad3;
  String? url3;
  String? unvan4;
  String? ad4;
  String? url4;
  String? unvan5;
  String? ad5;
  String? url5;

  Speaker.empty();

  Speaker(
    this.etkinlik_adi,
    this.unvan1,
    this.ad1,
    this.url1,
    this.unvan2,
    this.ad2,
    this.url2,
    this.unvan3,
    this.ad3,
    this.url3,
    this.unvan4,
    this.ad4,
    this.url4,
    this.unvan5,
    this.ad5,
    this.url5,
  );

  Speaker.fromJson(Map<String, dynamic> json) {
    etkinlik_adi = json["etkinlik_adi"];
    unvan1 = json["unvan1"];
    ad1 = json["ad1"];
    url1 = json["url1"];
    unvan2 = json["unvan2"];
    ad2 = json["ad2"];
    url2 = json["url2"];
    unvan3 = json["unvan3"];
    ad3 = json["ad3"];
    url3 = json["url3"];
    unvan4 = json["unvan4"];
    ad4 = json["ad4"];
    url4 = json["url4"];
    unvan5 = json["unvan5"];
    ad5 = json["ad5"];
    url5 = json["url5"];

    // Verilerin başarılı şekilde alındığını logluyoruz.
    printColored("Etkinlik Kodu: ${json["etkinlik_adi"]}", "30");
    printColored("Konuşmacılar: ${json["unvan1"]} ${json["ad1"]}", "30");
    printColored("URL: ${json["url1"]}", "30");
    printColored("Konuşmacılar: ${json["unvan2"]} ${json["ad2"]}", "30");
    printColored("URL: ${json["url2"]}", "30");
    // Aynı şekilde diğer unvanlar ve adlar için de loglamaya devam edebilirsin.
  }

  Map toJson() {
    return {
      "etkinlik_adi": etkinlik_adi,
      "unvan1": unvan1,
      "ad1": ad1,
      "url1": url1,
      "unvan2": unvan2,
      "ad2": ad2,
      "url2": url2,
      "unvan3": unvan3,
      "ad3": ad3,
      "url3": url3,
      "unvan4": unvan4,
      "ad4": ad4,
      "url4": url4,
      "unvan5": unvan5,
      "ad5": ad5,
      "url5": url5,
    };
  }
}

class Trip {
  String? etkinlik_adi;
  String? saat1;
  String? konum1;
  String? aciklama1;
  String? saat2;
  String? konum2;
  String? aciklama2;
  String? saat3;
  String? konum3;
  String? aciklama3;
  String? saat4;
  String? konum4;
  String? aciklama4;
  String? saat5;
  String? konum5;
  String? aciklama5;

  Trip.empty();

  Trip(
    this.etkinlik_adi,
    this.saat1,
    this.konum1,
    this.aciklama1,
    this.saat2,
    this.konum2,
    this.aciklama2,
    this.saat3,
    this.konum3,
    this.aciklama3,
    this.saat4,
    this.konum4,
    this.aciklama4,
    this.saat5,
    this.konum5,
    this.aciklama5,
  );

  Trip.fromJson(Map<String, dynamic> json) {
    etkinlik_adi = json["etkinlik_adi"];
    saat1 = json["saat1"].toString();
    konum1 = json["konum1"];
    aciklama1 = json["aciklama1"];
    saat2 = json["saat2"].toString();
    konum2 = json["konum2"];
    aciklama2 = json["aciklama2"];
    saat3 = json["saat3"].toString();
    konum3 = json["konum3"];
    aciklama3 = json["aciklama3"];
    saat4 = json["saat4"].toString();
    konum4 = json["konum4"];
    aciklama4 = json["aciklama4"];
    saat5 = json["saat5"].toString();
    konum5 = json["konum5"];
    aciklama5 = json["aciklama5"];
  }

  Map toJson() {
    return {
      "etkinlik_adi": etkinlik_adi,
      "saat1": saat1,
      "konum1": konum1,
      "aciklama1": aciklama1,
      "saat2": saat2,
      "konum2": konum2,
      "aciklama2": aciklama2,
      "saat3": saat3,
      "konum3": konum3,
      "aciklama3": aciklama3,
      "saat4": saat4,
      "konum4": konum4,
      "aciklama4": aciklama4,
      "saat5": saat5,
      "konum5": konum5,
      "aciklama5": aciklama5,
    };
  }
}
