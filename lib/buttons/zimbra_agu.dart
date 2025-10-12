import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZimbraPage extends StatefulWidget {
  const ZimbraPage({super.key});

  @override
  State<ZimbraPage> createState() => _ZimbraPageState();
}

class _ZimbraPageState extends State<ZimbraPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Görünüm oranını küçültüp ekrana sığdır
            await _controller.runJavaScript('''
              document.body.style.zoom = '0.55';
              document.body.style.transformOrigin = '0 0';
            ''');
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse("https://posta.agu.edu.tr/#1"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zimbra AGÜ',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
