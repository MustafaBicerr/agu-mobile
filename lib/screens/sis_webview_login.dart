// file: lib/screens/sis_webview_fullscreen.dart
// Fullscreen SIS WebView: user logs in on the real page.
// We detect timetable inside an iframe, wait until it loads, scrape HTML,
// parse lessons, and save to DB. Logs are verbose for easy debugging.

import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:home_page/animations/progress_ring_widget.dart';
import 'package:home_page/bottom.dart';
import 'package:home_page/notifications.dart';
import 'package:home_page/screens/TimeTableDetail.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' as dom;

import 'package:home_page/services/dbHelper.dart';
import 'package:home_page/models/lesson.dart';

const String SIS_LOGIN_PAGE = "https://sis.agu.edu.tr/oibs/std/login.aspx";

class SisWebViewFullscreen extends StatefulWidget {
  const SisWebViewFullscreen({super.key});
  @override
  State<SisWebViewFullscreen> createState() => _SisWebViewFullscreenState();
}

class _SisWebViewFullscreenState extends State<SisWebViewFullscreen> {
  late final WebViewController _wv;
  // final CookieManager _cookies = CookieManager();
  final Dbhelper _db = Dbhelper();

  bool _loggedIn = false;
  double _progress = 0;

  bool _scrapeInProgress = false;
  bool _scrapeCompleted = false;
  String? _lastHtmlHash;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  Future<void> _setupWebView() async {
    // Clean cookies to avoid "same browser multiple login" warning
    // await _cookies.clearCookies();

    _wv = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100.0),
          onPageStarted: (url) => debugPrint('[SIS][WV] started: $url'),
          onUrlChange: (c) => debugPrint('[SIS][WV] urlChange: ${c.url}'),
          onPageFinished: (url) async {
            debugPrint('[SIS][WV] finished: $url');
            if (_isLoginUrl(url)) return;

            if (!_loggedIn) {
              final stillLogin = await _hasLoginInputs();
              if (!stillLogin) {
                _loggedIn = true;
                debugPrint('[SIS] Giris yapildi ✅');
                if (!_scrapeCompleted && !_scrapeInProgress) {
                  await _tryScrapeAndSave();
                }
              }
            } else {
              if (!_scrapeCompleted && !_scrapeInProgress) {
                await _tryScrapeAndSave();
              }
            }
          },
          onWebResourceError: (err) => debugPrint('[SIS][WV][ERR] $err'),
        ),
      )
      ..loadRequest(Uri.parse(SIS_LOGIN_PAGE));
  }

  Future<void> _clearIframeReadyHtml() async {
    try {
      await _wv
          .runJavaScriptReturningResult("window.__SIS_IFR_READY_HTML=''; 'ok'");
    } catch (_) {}
  }

  bool _isLoginUrl(String url) =>
      url.toLowerCase().contains('/oibs/std/login.aspx');

  // returns "1" if login inputs exist on the page
  Future<bool> _hasLoginInputs() async {
    const js = """
      (function(){
        var u = document.getElementsByName('txtParamT01');
        var p = document.getElementsByName('txtParamT02');
        return (u && u.length>0 && p && p.length>0) ? '1' : '0';
      })();
    """;
    final r = await _wv.runJavaScriptReturningResult(js);
    final s = r.toString().replaceAll('"', '');
    return s == '1';
  }

  /// Install hooks that watch the timetable iframe (src changes + load event),
  /// and store ready HTML into window.__SIS_IFR_READY_HTML.
  Future<void> _installIframeHooks() async {
    const js = r"""
      (function(){
        if (window.__SIS_HOOKED) return 'already';
        window.__SIS_HOOKED = true;
        window.__SIS_IFR_READY_HTML = '';

        function dumpIframeHtml(){
          try{
            var f = document.getElementById('IFRAME1') || document.querySelector('iframe');
            if(!f) return;
            var d = f.contentDocument || f.contentWindow.document;
            if(!d) return;
            var html = d.documentElement && d.documentElement.outerHTML || '';
            if (html.indexOf('grd0')>-1 || html.indexOf('grd1')>-1 || html.indexOf('<table')>-1){
              window.__SIS_IFR_READY_HTML = html;
            }
          }catch(e){}
        }

        function ensureHooks(){
          var f = document.getElementById('IFRAME1') || document.querySelector('iframe');
          if(!f) return;
          try{
            f.addEventListener('load', function(){
              setTimeout(dumpIframeHtml, 50);
              setTimeout(dumpIframeHtml, 300);
              setTimeout(dumpIframeHtml, 1000);
              setTimeout(dumpIframeHtml, 2000);
            }, {once:false});
          }catch(e){}
          try{
            var mo = new MutationObserver(function(){ dumpIframeHtml(); });
            mo.observe(f, {attributes:true, attributeFilter:['src']});
          }catch(e){}
        }

        ensureHooks();
        setInterval(function(){ ensureHooks(); dumpIframeHtml(); }, 500);
        return 'installed';
      })();
    """;
    final res = await _wv.runJavaScriptReturningResult(js);
    debugPrint('[SIS][HOOK] ${_normalizeJsString(res)}');
  }

  /// Try to force iframe src to a likely timetable URL (by scanning href/onclick).
  Future<String?> _forceIframeToTimetable() async {
    const js = r"""
      (function(){
        function abs(u){ try { return new URL(u, location.href).href; } catch(e){ return u; } }
        var f = document.getElementById('IFRAME1') || document.querySelector('iframe');
        if(!f) return JSON.stringify({ok:false, reason:'no-iframe'});

        var urls = new Set();
        document.querySelectorAll('a[href]').forEach(function(a){
          var h = a.getAttribute('href') || '';
          if(h && !h.startsWith('javascript:')) urls.add(abs(h));
        });
        document.querySelectorAll('[onclick]').forEach(function(el){
          var oc = el.getAttribute('onclick') || '';
          var rx = /'([^']+)'|"([^"]+)"/g, m;
          while((m = rx.exec(oc))){
            var u = (m[1] || m[2] || '');
            if(u && u.indexOf('/') >= 0) urls.add(abs(u));
          }
          var m2 = oc.match(/src\s*=\s*['"]([^'"]+)['"]/i);
          if(m2) urls.add(abs(m2[1]));
        });

        var keys = ['program','Program','PROGRAM','ders','Ders','timetable','schedule','zaman','Zaman'];
        var cands = Array.from(urls).filter(function(u){
          return keys.some(function(k){ return u.indexOf(k) >= 0; });
        });

        if(cands.length === 0){
          return JSON.stringify({ok:false, reason:'no-candidate', sample:Array.from(urls).slice(0,10)});
        }

        var origin = location.origin;
        var chosen = cands.find(function(u){ return u.startsWith(origin); }) || cands[0];

        try { f.src = chosen; return JSON.stringify({ok:true, url:chosen}); }
        catch(e){ return JSON.stringify({ok:false, reason:String(e), urlTried:chosen}); }
      })();
    """;
    final raw = await _wv.runJavaScriptReturningResult(js);
    final s = _normalizeJsString(raw);
    debugPrint('[SIS][IFR] force src result: $s');
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return m['ok'] == true ? m['url'] as String : null;
    } catch (_) {
      return null;
    }
  }

  /// Wait until window.__SIS_IFR_READY_HTML populated, or timeout.
  Future<String?> _waitIframeReadyHtml(
      {int timeoutMs = 15000, int pollMs = 300}) async {
    final t0 = DateTime.now();
    while (DateTime.now().difference(t0).inMilliseconds < timeoutMs) {
      final raw = await _wv
          .runJavaScriptReturningResult("window.__SIS_IFR_READY_HTML || ''");
      final html = _normalizeJsString(raw);
      if (html.isNotEmpty && html.length > 1000) {
        debugPrint('[SIS][WAIT] iframe html ready (len=${html.length})');
        return html;
      }
      await Future.delayed(Duration(milliseconds: pollMs));
    }
    debugPrint('[SIS][WAIT] timeout (no iframe html)');
    return null;
  }

  Future<void> _tryScrapeAndSave() async {
    if (_scrapeCompleted || _scrapeInProgress) {
      debugPrint('[SIS] scrape skipped (completed or in-progress)');
      return;
    }
    _scrapeInProgress = true;
    debugPrint('[SIS] Ders programi sayfasi acildi ✅ (pipeline basliyor)');

    try {
      // _db.deleteDatabaseFile();
      await _installIframeHooks();
      await _forceIframeToTimetable();

      final iframeHtml =
          await _waitIframeReadyHtml(timeoutMs: 15000, pollMs: 300);
      if (iframeHtml == null || iframeHtml.isEmpty) {
        // fallback outer...
        final rawOuter = await _wv
            .runJavaScriptReturningResult("document.documentElement.outerHTML");
        final outerHtml = _normalizeJsString(rawOuter);
        debugPrint('[SIS] fallback OUTER len: ${outerHtml.length}');
        final sample = outerHtml.substring(0, outerHtml.length.clamp(0, 800));
        debugPrint('[SIS] OUTER PREVIEW:\n$sample');
        return;
      }

      // === HASH KONTROLÜ (aynı HTML geldiyse ekleme yapma) ===
      // pubspec'te crypto yoksa bu bloğu kaldırabilirsin; ama iyi emniyet sağlar.
      // import 'package:crypto/crypto.dart' as crypto; import 'dart:convert' show utf8;
      final currHash =
          crypto.sha256.convert(utf8.encode(iframeHtml)).toString();
      if (_lastHtmlHash == currHash) {
        debugPrint('[SIS] same timetable HTML detected; skipping inserts.');
        return;
      }
      _lastHtmlHash = currHash;
      // ======================================================

      debugPrint('[SIS] Dersler cekiliyor (iframe/event) ...');
      final parsed = _parseTimetableAndGroup(iframeHtml);

      // (opsiyonel) aynı oturum içinde RAM üzerinde de küçük bir dedup:
      final seen = <String>{};
      final items = parsed.where((it) {
        final key =
            '${it['day']}|${it['lesson']}|${it['teacher']}|${it['hour1']}|${it['hour2']}|${it['hour3']}|${it['place']}';
        if (seen.contains(key)) return false;

        seen.add(key);

        return true;
      }).toList();

      debugPrint('[SIS] Pars edilen grup sayisi: ${items.length}');
      if (items.isEmpty) {
        final sample = iframeHtml.substring(0, iframeHtml.length.clamp(0, 800));
        debugPrint('[SIS] IFRAME PREVIEW (first 800):\n$sample');
      }

      // int inserted = 0;
      // items -> Lesson dönüştür
      final lessons = <Lesson>[];
      for (final it in items) {
        try {
          for (final it in items) {
            lessons.add(Lesson(
                it['lesson']!.toLowerCase(),
                it['place'],
                it['day'],
                it['hour1'],
                it['hour2'],
                it['hour3'],
                it['teacher']));
          }
          ;

// Toplu ekleme: var olanları atlayarak
          final inserted =
              await _db.insertManyIfNotExistsPreserveAttendance(lessons);
          debugPrint('[SIS] DB inserted (dedup): $inserted');
          // await _db.insert(Lesson(it['lesson'], it['place'], it['day'],
          //     it['hour1'], it['hour2'], it['hour3'], it['teacher']));
          debugPrint('[SIS] DB inserted lessons: $lessons');
          debugPrint('[SIS] Dersler cekildi ✅');
        } catch (e) {
          debugPrint('[SIS][DB] insert error: $e');
        }
      }

      // Tek sefer çalıştık: tekrarını engelle
      _scrapeCompleted = true;
    } finally {
      // JS tarafındaki hazır HTML’i temizle ki tekrar tetiklenmesin
      await _clearIframeReadyHtml();
      _scrapeInProgress = false;
    }
  }

  // ======================== parsing helpers ========================

  String _normalizeJsString(dynamic jsResult) {
    final s = jsResult?.toString() ?? '';
    if (s.startsWith('"') && s.endsWith('"')) {
      try {
        return jsonDecode(s) as String;
      } catch (_) {}
      return s.substring(1, s.length - 1);
    }
    return s;
  }

  List<Map<String, String?>> _parseTimetableAndGroup(String htmlBody) {
    final doc = dom.parse(htmlBody);

    // Try known ids first (grd0..grd4)
    final dayMap = <String, String>{
      'grd0': 'Pazartesi',
      'grd1': 'Salı',
      'grd2': 'Çarşamba',
      'grd3': 'Perşembe',
      'grd4': 'Cuma',
    };

    final Map<String, Map<String, dynamic>> grouped = {};
    int foundTables = 0;

    for (final e in dayMap.entries) {
      final table = doc.querySelector('#${e.key}');
      if (table == null) continue;
      foundTables++;
      final rows = table.querySelectorAll('tr');
      for (final tr in rows.skip(1)) {
        final tds = tr.querySelectorAll('td');
        if (tds.length < 5) continue; // hour, section, lesson, place, teacher
        final hour = tds[0].text.trim();
        final section = tds[1].text.trim();
        final lesson = tds[2].text.trim();
        final place = tds[3].text.trim();
        final teacher = tds[4].text.trim();

        final key = '${e.value}::$lesson::$teacher';
        grouped.putIfAbsent(
            key,
            () => {
                  'lesson': lesson,
                  'section': section,
                  'teacher': teacher,
                  'place': place,
                  'day': e.value,
                  'hours': <String>[],
                });
        (grouped[key]!['hours'] as List<String>).add(hour);
      }
    }

    // Fallback: scan generic tables (5+ columns), infer day from header text
    if (foundTables == 0) {
      for (final table in doc.querySelectorAll('table')) {
        final rows = table.querySelectorAll('tr');
        if (rows.length < 2) continue;
        final cols = rows[1].querySelectorAll('td');
        if (cols.length < 5) continue;

        final head = rows.first.text.toLowerCase();
        String day = 'Bilinmeyen Gun';
        if (head.contains('pazartesi'))
          day = 'Pazartesi';
        else if (head.contains('sal'))
          day = 'Salı';
        else if (head.contains('çar') || head.contains('car'))
          day = 'Çarşamba';
        else if (head.contains('per'))
          day = 'Perşembe';
        else if (head.contains('cuma')) day = 'Cuma';

        for (final tr in rows.skip(1)) {
          final tds = tr.querySelectorAll('td');
          if (tds.length < 5) continue;
          final hour = tds[0].text.trim();
          final section = tds[1].text.trim();
          final lesson = tds[2].text.trim();
          final place = tds[3].text.trim();
          final teacher = tds[4].text.trim();

          final key = '$day::$lesson::$teacher';
          grouped.putIfAbsent(
              key,
              () => {
                    'lesson': lesson,
                    'section': section,
                    'teacher': teacher,
                    'place': place,
                    'day': day,
                    'hours': <String>[],
                  });
          (grouped[key]!['hours'] as List<String>).add(hour);
        }
      }
    }

    final out = <Map<String, String?>>[];
    for (final g in grouped.values) {
      final hours = (g['hours'] as List<String>)..sort();

      out.add({
        'lesson': g['lesson'] as String,
        'place': g['place'] as String,
        'day': g['day'] as String,
        'hour1': hours.isNotEmpty ? hours[0] : null,
        'hour2': hours.length > 1 ? hours[1] : null,
        'hour3': hours.length > 2 ? hours[2] : null,
        'teacher': g['teacher'] as String,
      });
    }
    return out;
  }

  // ======================== UI ========================

  @override
  Widget build(BuildContext context) {
    // Fullscreen WebView; only a thin progress bar and a refresh button.
    return Scaffold(
      bottomNavigationBar: bottomBar2(context, 0),
      appBar: AppBar(
        // leadingWidth: 0,
        // leading: Container(),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Timetabledetail()),
              );
              printColored("sis ekranınadn çıkış", "32");
            },
            icon: const Icon(Icons.arrow_back_rounded)),
        title: const Text('Sis > Genel İşlemler > Ders Programı',
            style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(
              onPressed: () {
                if (!_scrapeCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Dersler henüz çekilmedi veya kaydedilmedi. Lütfen Sis e giriş yapıp, "Genel İşlemler" menüsünden "Ders Programı" sekmesine gidin.')),
                  );
                  return;
                }
                openSuccessNotification(context);
              },
              icon: const Icon(
                Icons.save_alt_outlined,
                color: Colors.green,
              )),
          IconButton(
            tooltip: 'Yeniden Yükle',
            onPressed: () async {
              _loggedIn = false;
              // await _cookies.clearCookies();
              await _wv.loadRequest(Uri.parse(SIS_LOGIN_PAGE));
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.blue,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress > 0 && _progress < 1
              ? LinearProgressIndicator(value: _progress)
              : const SizedBox.shrink(),
        ),
      ),
      body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 39, 113, 148),
            Color.fromARGB(255, 255, 255, 255),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: WebViewWidget(controller: _wv)),
    );
  }
}

void openSuccessNotification(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AlertDialog(
            icon: const ProgressRing(
              size: 60,
              strokeWidth: 4,
              duration: Duration(milliseconds: 500),
              ringColor: Colors.green,
              label: '',
              labelColor: Colors.white,
              autostart: true,
              loop: false,
            ),
            backgroundColor: Colors.blueGrey[900],
            title: const Text(
              "Bilgilendirme",
              style: TextStyle(color: Colors.amber),
            ),
            content: const Text(
                "Dersler başarıyla çekildi. Ders programı ekranına dönebilirsiniz.",
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                child: const Text(
                  "Ders Programına Dön",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Timetabledetail()),
                  );
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
