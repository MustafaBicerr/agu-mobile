import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  bool isLoading = true; // Giriş tamamlanana kadar WebView gizlenecek

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true; // Yükleme başladı
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false; // Yükleme tamamlandı
            });
            _autoLogin(); // Sayfa yüklendiğinde otomatik giriş işlemini tetikleyin
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

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
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Yüklenirken sadece spinner göster
          : WebViewWidget(
              controller:
                  _controller), // Giriş tamamlandıktan sonra WebView göster
    );
  }
}
