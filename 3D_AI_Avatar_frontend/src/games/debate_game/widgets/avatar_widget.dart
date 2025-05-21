import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AvatarWidget extends StatefulWidget {
  final bool isUser;
  final String? text;
  final String? emotion;
  final int avatarId;

  const AvatarWidget({
    super.key,
    required this.isUser,
    this.text,
    this.emotion,
    this.avatarId = 1,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  late final WebViewController _controller;
  bool _isWebViewReady = false;
  static bool _iframeRegistered = false;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _registerIframeOnce();
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(onPageFinished: (url) {
            _isWebViewReady = true;
          }),
        )
        ..loadRequest(
          Uri.parse('http://localhost:5173?avatar=${widget.avatarId}'),
        );
    }
  }

  void _registerIframeOnce() {
    if (_iframeRegistered) return;

    ui_web.platformViewRegistry.registerViewFactory(
      'avatar-iframe',
      (int viewId) {
        final element = html.IFrameElement()
          ..src = 'http://localhost:5173?avatar=${widget.avatarId}'
          ..style.border = 'none'
          ..style.width = '50%'
          ..style.height = '50%'
          ..style.display = 'block';
        return element;
      },
    );

    _iframeRegistered = true;
  }

  @override
  void didUpdateWidget(covariant AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!kIsWeb &&
        _isWebViewReady &&
        widget.text != null &&
        widget.emotion != null) {
      final js =
          'window.animateAvatar(${jsonEncode(widget.text)}, ${jsonEncode(widget.emotion)})';
      _controller.runJavaScript(js);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUser) return const SizedBox();

    final avatarView = kIsWeb
        ? const HtmlElementView(viewType: 'avatar-iframe')
        : WebViewWidget(controller: _controller);

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF9BE1A), width: 3),
      ),
      clipBehavior: Clip.hardEdge,
      child: avatarView,
    );
  }
}
