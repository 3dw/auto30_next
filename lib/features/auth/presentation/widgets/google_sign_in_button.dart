import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInButton extends StatefulWidget {
  final String webClientId;
  final void Function(User?) onSignIn;
  final String viewType;

  const GoogleSignInButton({
    super.key,
    required this.webClientId,
    required this.onSignIn,
    this.viewType = 'gsi_button_html',
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // 註冊 view factory
      ui.platformViewRegistry.registerViewFactory(
        widget.viewType,
        (int viewId) => html.DivElement()..id = widget.viewType,
      );

      // 渲染 GSI 按鈕
      Future.delayed(const Duration(milliseconds: 100), () {
        js.context.callMethod('eval', ["""
          if (window.google && window.google.accounts && window.google.accounts.id) {
            window.google.accounts.id.initialize({
              client_id: '${widget.webClientId}',
              callback: (response) => {
                window.dispatchEvent(new CustomEvent('gsi_callback', {detail: response.credential}))
              }
            });
            window.google.accounts.id.renderButton(
              document.getElementById('${widget.viewType}'),
              { theme: 'outline', size: 'large', width: 240 }
            );
          }
        """]);
      });

      // 監聽 GSI callback
      html.window.addEventListener('gsi_callback', (event) async {
        final customEvent = event as html.CustomEvent;
        final idToken = customEvent.detail;
        if (idToken != null) {
          try {
            final credential = GoogleAuthProvider.credential(idToken: idToken);
            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            widget.onSignIn(userCredential.user);
          } catch (e) {
            widget.onSignIn(null);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SizedBox(
        width: 240,
        height: 50,
        child: HtmlElementView(viewType: widget.viewType),
      );
    } else {
      // 手機/桌面用原生按鈕
      return ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: const Text('Google 登入'),
        onPressed: () async {
          final googleSignIn = GoogleSignIn();
          final account = await googleSignIn.signIn();
          if (account != null) {
            final googleAuth = await account.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            widget.onSignIn(userCredential.user);
          } else {
            widget.onSignIn(null);
          }
        },
      );
    }
  }
} 