import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dışarıdan kontrol için (start/stop/reset/loop)
class ProgressRingController {
  _ProgressRingState? _state;

  void _attach(_ProgressRingState state) => _state = state;
  void _detach() => _state = null;

  /// 0..1 arası bir başlangıç değeriyle oynat
  void start({double from = 0.0}) => _state?._start(from: from);

  /// Animasyonu durdur (bulunduğu değerde kalır)
  void stop() => _state?._stop();

  /// 0'a alır ve durdurur
  void reset() => _state?._reset();

  /// Döngüyü aç/kapat
  void setLoop(bool loop) => _state?._setLoop(loop);

  /// Anlık ilerleme (0..1)
  double get value => _state?._value ?? 0.0;
}

/// Şık dairesel progress indicator (2D yay ile)
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    this.size = 140,
    this.strokeWidth = 10,
    this.duration = const Duration(seconds: 2), // dolma süresi
    this.ringColor, // tek renk
    this.gradientColors, // veya renk geçişi
    this.trackColor, // arka plan izi
    this.loop = false,
    this.autostart = true,
    this.roundedCaps = true,
    this.showPercent = true,
    this.label, // orta altına küçük etiket
    this.labelColor,
    this.controller,
    this.startAngle = -math.pi / 2, // tepe noktadan başlar
  });

  /// Boyut (en x boy)
  final double size;

  /// Çizgi kalınlığı
  final double strokeWidth;

  /// Tam dolma süresi
  final Duration duration;

  /// Tek renk halkaya zorlamak istersen
  final Color? ringColor;

  /// Gradient istiyorsan (>=2 renk önerilir). Verilirse ringColor yok sayılır.
  final List<Color>? gradientColors;

  /// Arka plan iz rengi (vermezsen tema üzerinden üretir)
  final Color? trackColor;

  /// Biter bitmez tekrar başlasın mı?
  final bool loop;

  /// Oluşur oluşmaz otomatik başlasın mı?
  final bool autostart;

  /// Uçlar yuvarlak mı?
  final bool roundedCaps;

  /// Ortada yüzde metni göster
  final bool showPercent;

  /// Yüzdenin altındaki küçük etiket (örn. "Loading")
  final String? label;

  /// Dış kontrol
  final ProgressRingController? controller;

  /// Başlangıç açısı (radyan). Varsayılan: -pi/2 (üst).
  final double startAngle;

  final Color? labelColor;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed && _loop) {
        _controller.forward(from: 0);
      }
    });

  bool _loop = false;

  double get _value => _controller.value;

  @override
  void initState() {
    super.initState();
    _loop = widget.loop;

    // Controller bağla
    widget.controller?._attach(this);

    if (widget.autostart) {
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _controller.dispose();
    super.dispose();
  }

  // ==== Controller API ====
  void _start({double from = 0.0}) =>
      _controller.forward(from: from.clamp(0.0, 1.0));
  void _stop() => _controller.stop();
  void _reset() => _controller.value = 0.0;
  void _setLoop(bool loop) => _loop = loop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackColor =
        widget.trackColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5);

    // Eğer gradientColors verilmişse onu kullan,
    // verilmemişse tek renk varsa tek renk, o da yoksa tema tabanlı yumuşak bir degrade.
    final SweepGradient gradient = _buildGradient(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(widget.size),
                painter: _RingPainter(
                  progress: _value,
                  strokeWidth: widget.strokeWidth,
                  trackColor: trackColor,
                  gradient: gradient,
                  startAngle: widget.startAngle,
                  roundedCaps: widget.roundedCaps,
                ),
              ),
              if (widget.showPercent || (widget.label?.isNotEmpty ?? false))
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showPercent)
                      Text(
                        '${(_value * 100).round()}%',
                        style: TextStyle(
                            fontSize: widget.size * 0.18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: widget.labelColor),
                      ),
                    if (widget.label?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontSize: widget.size * 0.10,
                          color: widget.labelColor,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  SweepGradient _buildGradient(BuildContext context) {
    if (widget.gradientColors != null && widget.gradientColors!.isNotEmpty) {
      final colors = widget.gradientColors!;
      final stops = List<double>.generate(
        colors.length,
        (i) => i / (colors.length - 1 == 0 ? 1 : (colors.length - 1)),
      );
      return SweepGradient(
        startAngle: widget.startAngle,
        endAngle: widget.startAngle + 2 * math.pi,
        colors: colors,
        stops: stops,
      );
    }

    final color = widget.ringColor ?? Theme.of(context).colorScheme.primary;
    // Tek renk için de shader kullanmak stroke birleşimlerinde banding'i azaltır.
    return SweepGradient(
      startAngle: widget.startAngle,
      endAngle: widget.startAngle + 2 * math.pi,
      colors: [color, color],
      stops: const [0.0, 1.0],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradient,
    required this.startAngle,
    required this.roundedCaps,
  });

  final double progress; // 0..1
  final double strokeWidth;
  final Color trackColor;
  final SweepGradient gradient;
  final double startAngle;
  final bool roundedCaps;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Arka plan izi
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt;
    canvas.drawCircle(center, radius, trackPaint);

    // İlerleme yayı
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = roundedCaps ? StrokeCap.round : StrokeCap.butt
      ..shader = gradient.createShader(rect);

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.progress != progress ||
        old.strokeWidth != strokeWidth ||
        old.trackColor != trackColor ||
        old.startAngle != startAngle ||
        old.roundedCaps != roundedCaps ||
        old.gradient != gradient;
  }
}
