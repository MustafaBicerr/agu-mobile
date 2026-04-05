class Lesson {
  final int id;
  final String? gun; // 'pazartesi' (lowercase)
  final String? saat; // '08:30-10:00'
  final String? dersKodu; // 'CSE101(06)' gibi
  final String? dersAdi;
  final String? derslik;
  final String? ogretimGorevlisi;
  final int? dow; // 1..7
  final int? startMin;
  final int? endMin;

  Lesson({
    required this.id,
    this.gun,
    this.saat,
    this.dersKodu,
    this.dersAdi,
    this.derslik,
    this.ogretimGorevlisi,
    this.dow,
    this.startMin,
    this.endMin,
  });

  factory Lesson.fromMap(Map<String, Object?> m) {
    int? _toInt(Object? v) => v == null ? null : (v as num).toInt();
    return Lesson(
      id: _toInt(m['id']) ?? 0,
      gun: m['gun'] as String?,
      saat: m['saat'] as String?,
      dersKodu: m['ders_kodu'] as String?,
      dersAdi: m['ders_adi'] as String?,
      derslik: m['derslik'] as String?,
      ogretimGorevlisi: m['ogretim_gorevlisi'] as String?,
      dow: _toInt(m['dow']),
      startMin: _toInt(m['start_min']),
      endMin: _toInt(m['end_min']),
    );
  }
}
