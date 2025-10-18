import 'package:home_page/models/sisLessons.dart';

extension SisLessonsDb on sisLessons {
  static sisLessons fromDb(Map<String, Object?> m) {
    String? _s(String k) => m[k] as String?;
    int? _i(String k) => (m[k] is num) ? (m[k] as num).toInt() : null;

    return sisLessons(
      gun: _s('gun'),
      saat: _s('saat'),
      ders_kodu: _s('ders_kodu'),
      ders_adi: _s('ders_adi'),
      derslik: _s('derslik'),
      ogretim_elemani: _s('ogretim_elemani'),
      dow: _i('dow'),
      // start_min: _i('start_min'),
      // end_min: _i('end_min'),
    );
  }
}
