import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart'; // WebView için gerekli paket

class WebPage extends StatefulWidget {
  final String url;
  final String title;

  const WebPage({super.key, required this.url, required this.title});

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
