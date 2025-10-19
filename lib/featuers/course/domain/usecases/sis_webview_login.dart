import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_page/featuers/course/domain/entities/lessonEntity.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_bloc.dart';
import 'package:home_page/featuers/course/presentation/bloc/lesson_event.dart';
import 'package:home_page/featuers/course/presentation/pages/TimeTableDetail.dart';
import 'package:home_page/featuers/home/presentation/widgets/bottom.dart';
import 'package:home_page/featuers/splash/presentation/widgets/progress_ring_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' as dom;

const String SIS_LOGIN_PAGE = "https://sis.agu.edu.tr/oibs/std/login.aspx";

class SisWebViewFullscreen extends StatefulWidget {
  const SisWebViewFullscreen({super.key});

  @override
  State<SisWebViewFullscreen> createState() => _SisWebViewFullscreenState();
}

class _SisWebViewFullscreenState extends State<SisWebViewFullscreen> {
  late final WebViewController _wv;
  bool _loggedIn = false;
  bool _scrapeInProgress = false;
  bool _scrapeCompleted = false;
  double _progress = 0;
  String? _lastHtmlHash;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  Future<void> _setupWebView() async {
    _wv = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100.0),
          onPageFinished: (url) async {
            if (!_isLoginUrl(url) && !_scrapeCompleted && !_scrapeInProgress) {
              final stillLogin = await _hasLoginInputs();
              if (!stillLogin) {
                _loggedIn = true;
                await _tryScrapeAndDispatch(context);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(SIS_LOGIN_PAGE));
  }

  bool _isLoginUrl(String url) =>
      url.toLowerCase().contains('/oibs/std/login.aspx');

  Future<bool> _hasLoginInputs() async {
    const js = """
      (function(){
        var u=document.getElementsByName('txtParamT01');
        var p=document.getElementsByName('txtParamT02');
        return (u&&u.length>0&&p&&p.length>0)?'1':'0';
      })();
    """;
    final r = await _wv.runJavaScriptReturningResult(js);
    return r.toString().replaceAll('"', '') == '1';
  }

  // 🔹 Dersleri çek, parse et, Bloc’a gönder
  Future<void> _tryScrapeAndDispatch(BuildContext context) async {
    _scrapeInProgress = true;
    try {
      await _installIframeHooks();
      await _forceIframeToTimetable();

      final iframeHtml = await _waitIframeReadyHtml();
      if (iframeHtml == null || iframeHtml.isEmpty) return;

      final currHash =
          crypto.sha256.convert(utf8.encode(iframeHtml)).toString();
      if (_lastHtmlHash == currHash) return;
      _lastHtmlHash = currHash;

      final parsed = _parseTimetable(iframeHtml);

      if (parsed.isEmpty) {
        debugPrint('[SIS] hiçbir ders bulunamadı.');
        return;
      }

      // Convert to LessonEntity
      final lessons = parsed
          .map((e) => LessonEntity(
                name: e['lesson']!,
                place: e['place']!,
                day: e['day']!,
                hour1: e['hour1'],
                hour2: e['hour2'],
                hour3: e['hour3'],
                teacher: e['teacher']!,
              ))
          .toList();

      // Bloc’a event gönder
      context.read<LessonBloc>().add(AddLessonBatchEvent(lessons));

      _scrapeCompleted = true;

      if (mounted) {
        openSuccessNotification(context);
      }
    } catch (e) {
      debugPrint('[SIS][ERR] $e');
    } finally {
      _scrapeInProgress = false;
    }
  }

  Future<void> _installIframeHooks() async {
    const js = """
      (function(){
        if(window.__SIS_HOOKED) return;
        window.__SIS_HOOKED=true;
        window.__SIS_IFR_READY_HTML='';
        function dumpIframe(){
          try{
            var f=document.getElementById('IFRAME1')||document.querySelector('iframe');
            if(!f)return;
            var d=f.contentDocument||f.contentWindow.document;
            if(!d)return;
            var html=d.documentElement.outerHTML;
            if(html.indexOf('<table')>-1){window.__SIS_IFR_READY_HTML=html;}
          }catch(e){}
        }
        setInterval(dumpIframe,500);
      })();
    """;
    await _wv.runJavaScript(js);
  }

  Future<void> _forceIframeToTimetable() async {
    const js = """
      (function(){
        var f=document.getElementById('IFRAME1')||document.querySelector('iframe');
        if(!f)return;
        var a=document.querySelector("a[href*='ders']")||document.querySelector("a[href*='Program']");
        if(a) f.src=a.href;
      })();
    """;
    await _wv.runJavaScript(js);
  }

  Future<String?> _waitIframeReadyHtml({int timeoutMs = 15000}) async {
    final t0 = DateTime.now();
    while (DateTime.now().difference(t0).inMilliseconds < timeoutMs) {
      final raw =
          await _wv.runJavaScriptReturningResult("window.__SIS_IFR_READY_HTML");
      final html = raw.toString().replaceAll('"', '');
      if (html.length > 1000) return html;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return null;
  }

  List<Map<String, String?>> _parseTimetable(String html) {
    final doc = dom.parse(html);
    final dayMap = {
      'grd0': 'Pazartesi',
      'grd1': 'Salı',
      'grd2': 'Çarşamba',
      'grd3': 'Perşembe',
      'grd4': 'Cuma',
    };
    final grouped = <String, Map<String, dynamic>>{};

    for (final e in dayMap.entries) {
      final table = doc.querySelector('#${e.key}');
      if (table == null) continue;
      for (final tr in table.querySelectorAll('tr').skip(1)) {
        final tds = tr.querySelectorAll('td');
        if (tds.length < 5) continue;
        final hour = tds[0].text.trim();
        final lesson = tds[2].text.trim();
        final place = tds[3].text.trim();
        final teacher = tds[4].text.trim();

        final key = '${e.value}::$lesson::$teacher';
        grouped.putIfAbsent(
          key,
          () => {
            'lesson': lesson,
            'teacher': teacher,
            'place': place,
            'day': e.value,
            'hours': <String>[],
          },
        );
        (grouped[key]!['hours'] as List<String>).add(hour);
      }
    }

    final out = <Map<String, String?>>[];
    for (final g in grouped.values) {
      final hours = (g['hours'] as List<String>)..sort();
      out.add({
        'lesson': g['lesson'],
        'place': g['place'],
        'day': g['day'],
        'hour1': hours.isNotEmpty ? hours[0] : null,
        'hour2': hours.length > 1 ? hours[1] : null,
        'hour3': hours.length > 2 ? hours[2] : null,
        'teacher': g['teacher'],
      });
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 0),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Timetabledetail()),
          ),
        ),
        title: const Text(
          'Sis > Genel İşlemler > Ders Programı',
          style: TextStyle(fontSize: 14),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress > 0 && _progress < 1
              ? LinearProgressIndicator(value: _progress)
              : const SizedBox.shrink(),
        ),
      ),
      body: WebViewWidget(controller: _wv),
    );
  }
}

void openSuccessNotification(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      icon: const ProgressRing(
        size: 60,
        strokeWidth: 4,
        duration: Duration(milliseconds: 500),
        ringColor: Colors.green,
        label: '',
        autostart: true,
      ),
      backgroundColor: Colors.blueGrey[900],
      title: const Text(
        "Bilgilendirme",
        style: TextStyle(color: Colors.amber),
      ),
      content: const Text(
        "Dersler başarıyla çekildi. Ders programı ekranına dönebilirsiniz.",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          child: const Text("Ders Programına Dön",
              style: TextStyle(color: Colors.green)),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Timetabledetail()),
          ),
        ),
      ],
    ),
  );
}
