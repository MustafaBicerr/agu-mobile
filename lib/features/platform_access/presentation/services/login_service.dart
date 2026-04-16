import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../downloads/services/download_helper.dart';

/// Verilen URL'nin dosya indirme bağlantısı olup olmadığını kontrol eder.
bool _isDownloadUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  final path = uri.path.toLowerCase();

  // Canvas API dosya indirme desenleri
  if (path.contains('/files/') && path.contains('/download')) return true;
  if (uri.queryParameters.containsKey('download_frd')) return true;
  if (uri.queryParameters['verifier'] != null && path.contains('/files/')) {
    return true;
  }

  // Genel dosya uzantıları
  const downloadExtensions = [
    '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
    '.zip', '.rar', '.7z', '.tar', '.gz',
    '.mp4', '.mp3', '.avi', '.mkv', '.mov',
    '.csv', '.txt', '.rtf', '.odt',
    '.apk', '.exe', '.dmg',
  ];

  for (final ext in downloadExtensions) {
    if (path.endsWith(ext)) return true;
  }

  return false;
}

class LoginService extends StatefulWidget {
  final String title;
  final String url;
  final String mail;
  final String password;
  final String mailFieldName;
  final String passwordFieldName;
  final String loginButtonFieldXPath;
  final String keyword;

  const LoginService(
      {super.key,
      required this.title,
      required this.url,
      required this.mail,
      required this.password,
      required this.mailFieldName,
      required this.passwordFieldName,
      required this.loginButtonFieldXPath,
      required this.keyword});

  @override
  State<LoginService> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<LoginService> {
  late final WebViewController _controller;
  bool isLoading = true;

  // İndirme overlay durumu
  OverlayEntry? _downloadOverlay;
  final ValueNotifier<_DownloadState> _dlState = ValueNotifier(
    _DownloadState.idle,
  );
  final ValueNotifier<String> _dlFileName = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterDownload',
        onMessageReceived: (message) => _onDownloadMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
            _autoLogin();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_isDownloadUrl(request.url)) {
              _startDownload(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// JavaScript fetch() ile dosyayı WebView içinde indirir ve
  /// base64 olarak Flutter'a gönderir.
  void _startDownload(String url) {
    _showDownloadOverlay('İndiriliyor...');
    _dlState.value = _DownloadState.downloading;

    // JavaScript: fetch ile indir → blob → base64 → FlutterDownload channel
    _controller.runJavaScript('''
      (async function() {
        try {
          const response = await fetch("$url", {
            credentials: 'include',
            redirect: 'follow'
          });

          if (!response.ok) {
            FlutterDownload.postMessage(JSON.stringify({
              type: 'error',
              message: 'HTTP ' + response.status
            }));
            return;
          }

          // Dosya adını Content-Disposition header'dan al
          let filename = '';
          const disposition = response.headers.get('content-disposition');
          if (disposition) {
            // filename*=UTF-8''encoded_name formatı
            const utf8Match = disposition.match(/filename\\*=(?:UTF-8|utf-8)''(.+?)(?:;|\$)/);
            if (utf8Match) {
              filename = decodeURIComponent(utf8Match[1]);
            } else {
              // filename="name" formatı
              const match = disposition.match(/filename[^;=\\n]*=(['\"]?)([^'\"\\n;]+)\\1/);
              if (match) filename = match[2];
            }
          }

          // Dosya adı bulunamadıysa URL'den çıkar
          if (!filename) {
            const urlPath = new URL("$url").pathname;
            const segments = urlPath.split('/');
            const last = segments[segments.length - 1];
            if (last && last.includes('.')) {
              filename = decodeURIComponent(last);
            } else {
              filename = 'dosya_' + Date.now();
            }
          }

          // Dosya adını Flutter'a bildir
          FlutterDownload.postMessage(JSON.stringify({
            type: 'start',
            filename: filename
          }));

          const blob = await response.blob();
          const totalSize = blob.size;

          // Küçük dosyalar (< 10MB) direkt base64
          if (totalSize < 10 * 1024 * 1024) {
            const reader = new FileReader();
            reader.onloadend = function() {
              const base64 = reader.result.split(',')[1];
              FlutterDownload.postMessage(JSON.stringify({
                type: 'complete',
                filename: filename,
                data: base64
              }));
            };
            reader.onerror = function() {
              FlutterDownload.postMessage(JSON.stringify({
                type: 'error',
                message: 'Dosya okuma hatasi'
              }));
            };
            reader.readAsDataURL(blob);
          } else {
            // Büyük dosyalar: chunk'lar halinde gönder
            const CHUNK_SIZE = 1024 * 1024; // 1MB
            const arrayBuffer = await blob.arrayBuffer();
            const uint8Array = new Uint8Array(arrayBuffer);
            const totalChunks = Math.ceil(uint8Array.length / CHUNK_SIZE);

            for (let i = 0; i < totalChunks; i++) {
              const start = i * CHUNK_SIZE;
              const end = Math.min(start + CHUNK_SIZE, uint8Array.length);
              const chunk = uint8Array.slice(start, end);

              // Uint8Array → base64
              let binary = '';
              for (let j = 0; j < chunk.length; j++) {
                binary += String.fromCharCode(chunk[j]);
              }
              const base64Chunk = btoa(binary);

              FlutterDownload.postMessage(JSON.stringify({
                type: 'chunk',
                filename: filename,
                index: i,
                total: totalChunks,
                data: base64Chunk
              }));
            }

            FlutterDownload.postMessage(JSON.stringify({
              type: 'chunk_done',
              filename: filename
            }));
          }
        } catch (e) {
          FlutterDownload.postMessage(JSON.stringify({
            type: 'error',
            message: e.toString()
          }));
        }
      })();
    ''');
  }

  // Chunk'ları biriktirmek için buffer
  final Map<String, List<int>> _chunkBuffers = {};

  /// JavaScript channel'dan gelen mesajları işler.
  Future<void> _onDownloadMessage(String raw) async {
    try {
      final msg = jsonDecode(raw) as Map<String, dynamic>;
      final type = msg['type'] as String;

      switch (type) {
        case 'start':
          final filename = msg['filename'] as String;
          _dlFileName.value = filename;
          _dlState.value = _DownloadState.downloading;
          break;

        case 'complete':
          // Küçük dosya — tek seferde geldi
          final filename = msg['filename'] as String;
          final base64Data = msg['data'] as String;
          final bytes = base64Decode(base64Data);
          await _saveFile(filename, bytes);
          break;

        case 'chunk':
          // Büyük dosya chunk'ı
          final filename = msg['filename'] as String;
          final base64Data = msg['data'] as String;
          final chunkBytes = base64Decode(base64Data);
          _chunkBuffers.putIfAbsent(filename, () => []);
          _chunkBuffers[filename]!.addAll(chunkBytes);

          final index = msg['index'] as int;
          final total = msg['total'] as int;
          _dlFileName.value = '$filename  (${index + 1}/$total)';
          break;

        case 'chunk_done':
          // Büyük dosyanın tüm chunk'ları geldi
          final filename = msg['filename'] as String;
          final allBytes = _chunkBuffers.remove(filename);
          if (allBytes != null) {
            await _saveFile(filename, allBytes);
          }
          break;

        case 'error':
          final errorMsg = msg['message'] as String? ?? 'Bilinmeyen hata';
          debugPrint('[LoginService] İndirme hatası: $errorMsg');
          _dlState.value = _DownloadState.error;
          _dlFileName.value = errorMsg;
          _autoDismissOverlay();
          break;
      }
    } catch (e) {
      debugPrint('[LoginService] Mesaj parse hatası: $e');
      _dlState.value = _DownloadState.error;
      _dlFileName.value = e.toString();
      _autoDismissOverlay();
    }
  }

  /// Dosyayı cihaza kaydeder.
  Future<void> _saveFile(String filename, List<int> bytes) async {
    try {
      // Kayıt dizinini belirle
      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = await getExternalStorageDirectory();
      }
      saveDir ??= await getApplicationDocumentsDirectory();

      // Çakışma kontrolü
      String finalPath = '${saveDir.path}/$filename';
      int counter = 1;
      while (await File(finalPath).exists()) {
        final dotIndex = filename.lastIndexOf('.');
        if (dotIndex != -1) {
          finalPath =
              '${saveDir.path}/${filename.substring(0, dotIndex)} ($counter)${filename.substring(dotIndex)}';
        } else {
          finalPath = '${saveDir.path}/$filename ($counter)';
        }
        counter++;
      }

      final file = File(finalPath);
      await file.writeAsBytes(bytes);

      debugPrint('[LoginService] Dosya kaydedildi: $finalPath');

      // Public Downloads klasörüne de kaydet
      // (diğer uygulamalar görebilsin)
      await DownloadHelper.saveToPublicDownloads(filename, bytes);

      _dlState.value = _DownloadState.done;
      _dlFileName.value = filename;
      _autoDismissOverlay();
    } catch (e) {
      debugPrint('[LoginService] Kayıt hatası: $e');
      _dlState.value = _DownloadState.error;
      _dlFileName.value = 'Kayıt hatası: $e';
      _autoDismissOverlay();
    }
  }

  // ─── Overlay Yönetimi ────────────────────────────────────

  void _showDownloadOverlay(String initialText) {
    _dismissOverlay();
    _dlFileName.value = initialText;

    _downloadOverlay = OverlayEntry(
      builder: (_) => _DownloadBanner(
        state: _dlState,
        fileName: _dlFileName,
        onDismiss: _dismissOverlay,
      ),
    );

    Overlay.of(context).insert(_downloadOverlay!);
  }

  void _autoDismissOverlay() {
    Future.delayed(const Duration(seconds: 4), _dismissOverlay);
  }

  void _dismissOverlay() {
    _downloadOverlay?.remove();
    _downloadOverlay = null;
  }

  @override
  void dispose() {
    _dismissOverlay();
    _dlState.dispose();
    _dlFileName.dispose();
    super.dispose();
  }

  // ─── Otomatik Giriş ──────────────────────────────────────

  Future<void> _autoLogin() async {
    if (widget.title.toLowerCase().contains("zimbra")) {
      await _controller.runJavaScript('''
              document.body.style.zoom = '0.50';
              document.body.style.transformOrigin = '0 0';
            ''');
    }

    await _controller.runJavaScript('''
      let checkFormInterval = setInterval(function() {
        let usernameField = document.getElementsByName("${widget.mailFieldName}")[0];
        let passwordField = document.getElementsByName("${widget.passwordFieldName}")[0];
        
        if (usernameField && passwordField) {
          clearInterval(checkFormInterval);

          usernameField.value = "${widget.mail}";
          passwordField.value = "${widget.password}";

          let loginButton = document.evaluate(
            "${widget.loginButtonFieldXPath}",
            document,
            null,
            XPathResult.FIRST_ORDERED_NODE_TYPE,
            null
          ).singleNodeValue;

          if (loginButton) {
            loginButton.click();
            console.log("Giriş butonuna tıklama başarılı!");
          } else {
            console.log("Giriş butonu bulunamadı!");
          }
        }
      }, 500);
    ''');

    // Giriş işleminin sonucunu kontrol et
    //   Future.delayed(const Duration(seconds: 5), () async {
    //     if (!mounted) return;

    //     final currentUrl = await _controller.currentUrl();
    //     if (currentUrl != null && currentUrl.contains(widget.keyword)) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text("Giriş başarılı!"),
    //           backgroundColor: Colors.green,
    //         ),
    //       );
    //       setState(() {
    //         isLoading = false; // Giriş tamamlandı, WebView gösterilecek
    //       });
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text("Giriş başarısız! Lütfen bilgileri kontrol edin."),
    //           backgroundColor: Colors.red,
    //         ),
    //       );
    //       setState(() {
    //         isLoading = false; // Giriş başarısız olsa da WebView açılacak
    //       });
    //     }
    //   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}

// ─── İndirme Durumu ──────────────────────────────────────────

enum _DownloadState { idle, downloading, done, error }

// ─── İndirme Banner Widget'ı ─────────────────────────────────

class _DownloadBanner extends StatelessWidget {
  final ValueNotifier<_DownloadState> state;
  final ValueNotifier<String> fileName;
  final VoidCallback onDismiss;

  const _DownloadBanner({
    required this.state,
    required this.fileName,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(14),
        child: ValueListenableBuilder<_DownloadState>(
          valueListenable: state,
          builder: (context, st, _) {
            return ValueListenableBuilder<String>(
              valueListenable: fileName,
              builder: (context, name, _) {
                final isError = st == _DownloadState.error;
                final isDone = st == _DownloadState.done;
                final isDownloading = st == _DownloadState.downloading;

                final Color accent = isError
                    ? Colors.red
                    : isDone
                        ? Colors.green
                        : Colors.blue;

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // İkon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isDownloading
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: accent,
                                ),
                              )
                            : Icon(
                                isError
                                    ? Icons.error_outline_rounded
                                    : Icons.check_circle_outline_rounded,
                                color: accent,
                                size: 22,
                              ),
                      ),
                      const SizedBox(width: 12),
                      // İçerik
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isError
                                  ? 'İndirme başarısız'
                                  : isDone
                                      ? 'İndirme tamamlandı!'
                                      : 'İndiriliyor...',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isError
                                    ? Colors.red
                                    : isDone
                                        ? Colors.green.shade700
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Kapat butonu
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onDismiss,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
