import 'package:flutter/material.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/models/events.dart';

class GeziPage extends StatelessWidget {
  final Trip trip;
  const GeziPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final steps = _extractSteps(trip);

    return Scaffold(
      appBar: AppBar(
        // title: const Text("Gezi Planı"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: .5,
      ),
      bottomNavigationBar: bottomBar2(context, 2),
      body: LayoutBuilder(
        builder: (context, cts) {
          // —— düzen parametreleri ——
          const padding = EdgeInsets.fromLTRB(16, 16, 16, 24);
          const headerHeight = 100.0;
          const vGap = 22.0; // kartlar arası boşluk
          const cardH = 230.0; // kart yüksekliği (içerik sığıyor)
          final w = cts.maxWidth;
          final cardW = (w * 0.78)
              .clamp(280.0, w - padding.horizontal); // daraltılmış genişlik

          // hizaya göre sol konum
          double _leftForIndex(int i) {
            final leftAlign = i.isOdd == false; // 0,2,4 -> sol; 1,3 -> sağ
            if (leftAlign) return padding.left;
            return w - padding.right - cardW; // sağa yasla
          }

          Offset _centerOf(int i) {
            final top = padding.top + headerHeight + i * (cardH + vGap);
            final left = _leftForIndex(i);
            return Offset(left + cardW / 2, top + cardH / 2);
          }

          final arrows = <Widget>[];
          final cards = <Widget>[];

          for (int i = 0; i < steps.length; i++) {
            final top = padding.top + headerHeight + i * (cardH + vGap);
            final left = _leftForIndex(i);

            // kart
            cards.add(Positioned(
              left: left,
              top: top,
              width: cardW,
              height: cardH,
              child: _StepCardZigzag(step: steps[i], index: i),
            ));

            // ok: i -> i+1
            if (i < steps.length - 1) {
              final p1 = _centerOf(i);
              final p2 = _centerOf(i + 1);

              final leftBox = p1.dx < p2.dx ? p1.dx : p2.dx;
              final topBox = p1.dy < p2.dy ? p1.dy : p2.dy;
              final widthBox = (p1.dx - p2.dx).abs();
              final heightBox = (p1.dy - p2.dy).abs();

              arrows.add(Positioned(
                left: leftBox,
                top: topBox,
                width: widthBox,
                height: heightBox,
                child: CustomPaint(
                  painter: _DiagonalArrowPainter(
                    start: Offset(p1.dx - leftBox, p1.dy - topBox),
                    end: Offset(p2.dx - leftBox, p2.dy - topBox),
                    color1: const Color(0xFF7C89FF),
                    color2: const Color(0xFF4CD2E0),
                  ),
                ),
              ));
            }
          }

          final totalH = padding.vertical +
              headerHeight +
              steps.length * cardH +
              (steps.length - 1) * vGap;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 39, 113, 148),
                  Color.fromARGB(255, 255, 255, 255),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                height: totalH,
                width: w,
                child: Stack(
                  children: [
                    // başlık
                    Positioned(
                      left: padding.left,
                      right: padding.right,
                      top: padding.top,
                      height: headerHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            trip.etkinlik_adi ?? "Etkinlik",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .2),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Teknik gezi adımları",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontSize: 22,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    ...arrows, // oklar altta
                    ...cards, // kartlar üstte
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // API -> step list
  List<_TripStep> _extractSteps(Trip t) {
    String? nz(String? s) {
      final x = (s ?? '').trim();
      return x.isEmpty ? null : x;
    }

    final list = <_TripStep>[];
    void add(String? s, String? k, String? a) {
      final saat = nz(s), konum = nz(k), aciklama = nz(a);
      if (saat != null || konum != null || aciklama != null) {
        list.add(_TripStep(saat: saat, konum: konum, aciklama: aciklama));
      }
    }

    add(t.saat1, t.konum1, t.aciklama1);
    add(t.saat2, t.konum2, t.aciklama2);
    add(t.saat3, t.konum3, t.aciklama3);
    add(t.saat4, t.konum4, t.aciklama4);
    add(t.saat5, t.konum5, t.aciklama5);
    return list;
  }
}

// —————————————— Kart & yardımcılar ——————————————

class _StepCardZigzag extends StatelessWidget {
  const _StepCardZigzag({required this.step, required this.index});
  final _TripStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(.96);

    return SingleChildScrollView(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + (index % 4) * 90),
        curve: Curves.easeOut,
        builder: (context, v, child) => Transform.translate(
          offset: Offset((index.isOdd ? 1 : -1) * (1 - v) * 12, (1 - v) * 10),
          child: Opacity(opacity: v, child: child),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge("Adım ${index + 1}"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (step.saat != null)
                    _MiniInfo(
                      color: const Color(0xFF4E5BF6),
                      title: "Saat",
                      value: step.saat!,
                      icon: Icons.schedule_rounded,
                    ),
                  if (step.konum != null)
                    _MiniInfo(
                      color: const Color(0xFF22B07D),
                      title: "Konum",
                      value: step.konum!,
                      icon: Icons.place_rounded,
                    ),
                  if (step.aciklama != null)
                    _MiniInfo.wide(
                      color: const Color(0xFF7C89FF),
                      title: "Açıklama",
                      value: step.aciklama!,
                      icon: Icons.notes_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
    this.wide = false,
  });

  factory _MiniInfo.wide({
    required Color color,
    required String title,
    required String value,
    required IconData icon,
  }) =>
      _MiniInfo(
          color: color, title: title, value: value, icon: icon, wide: true);

  final Color color;
  final String title, value;
  final IconData icon;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: wide ? 200 : 132, maxWidth: 280),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7C89FF).withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4E5BF6),
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

// ok çizimi (kıvrımlı, gradientli)
class _DiagonalArrowPainter extends CustomPainter {
  _DiagonalArrowPainter({
    required this.start,
    required this.end,
    required this.color1,
    required this.color2,
  });

  final Offset start;
  final Offset end;
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(colors: [color1, color2])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(start.dx, start.dy);
    // merkezden hafif aşağı/yan kontrol noktası ile zarif kavis
    final control = Offset(
      (start.dx + end.dx) / 2,
      start.dy + (end.dy - start.dy) * 0.65,
    );
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);

    // ok başı
    final arrowPaint = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;
    const arrowSize = 8.0;
    final angle = (end - control).direction;
    final p1 = end;
    final p2 = end - Offset.fromDirection(angle - 0.35, arrowSize);
    final p3 = end - Offset.fromDirection(angle + 0.35, arrowSize);
    canvas.drawPath(
        Path()
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(p3.dx, p3.dy)
          ..close(),
        arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// basit step modeli
class _TripStep {
  final String? saat, konum, aciklama;
  _TripStep({this.saat, this.konum, this.aciklama});
}
