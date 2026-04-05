import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agu_mobile/shared/services/firebase_user_account_service.dart';

/// Şifre sıfırlama: Firebase [sendPasswordResetEmail] ile e-posta gönderir.
/// [registeredOrSuggestedEmail]: oturumdaki hesap e-postası veya giriş ekranındaki alan.
Future<void> showPasswordResetFlow(
  BuildContext context, {
  String? registeredOrSuggestedEmail,
}) async {
  final fromAuth = FirebaseAuth.instance.currentUser?.email?.trim();
  final registered = (fromAuth != null && fromAuth.isNotEmpty)
      ? fromAuth
      : (registeredOrSuggestedEmail?.trim().isNotEmpty == true
          ? registeredOrSuggestedEmail!.trim()
          : null);

  await showDialog<void>(
    context: context,
    builder: (ctx) => _PasswordResetDialog(registeredEmail: registered),
  );
}

class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog({this.registeredEmail});

  final String? registeredEmail;

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _service = FirebaseUserAccountService();
  final _otherEmailController = TextEditingController();
  bool _useRegistered = true;
  bool _loading = false;

  bool get _hasRegistered =>
      widget.registeredEmail != null && widget.registeredEmail!.isNotEmpty;

  @override
  void dispose() {
    _otherEmailController.dispose();
    super.dispose();
  }

  Future<void> _send(String email) async {
    setState(() => _loading = true);
    try {
      await _service.sendPasswordResetEmail(email);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre sıfırlama bağlantısı gönderildi. Gelen kutunuzu ve spam/junk klasörünü kontrol edin.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'İstek gönderilemedi. Lütfen tekrar deneyin.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSendPressed() {
    if (_hasRegistered && _useRegistered) {
      _send(widget.registeredEmail!);
      return;
    }
    _send(_otherEmailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şifremi unuttum'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Şifre sıfırlama bağlantısı e-posta ile gönderilir. Bağlantı bazen '
              'spam veya gereksiz klasörüne düşebilir; lütfen bu klasörleri de kontrol edin.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'E-posta adresinizin @agu.edu.tr ile bitmesi gerekmez; '
              'hesabınızla ilişkili geçerli herhangi bir adresi kullanabilirsiniz.',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (_hasRegistered) ...[
              const Text('Hesap / oturum e-postası:'),
              const SizedBox(height: 6),
              SelectableText(
                widget.registeredEmail!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text('Şifre sıfırlama bağlantısını nereye gönderelim?'),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Kayıtlı adres'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Başka adres'),
                  ),
                ],
                selected: {_useRegistered},
                onSelectionChanged: _loading
                    ? null
                    : (Set<bool> selection) {
                        setState(() => _useRegistered = selection.first);
                      },
              ),
            ],
            if (!_hasRegistered || !_useRegistered) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _otherEmailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !_loading,
                decoration: const InputDecoration(
                  labelText: 'E-posta adresi',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: _loading
              ? null
              : () {
                  if (_hasRegistered && _useRegistered) {
                    _onSendPressed();
                    return;
                  }
                  final e = _otherEmailController.text.trim();
                  if (e.isEmpty || !e.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Geçerli bir e-posta adresi girin.'),
                      ),
                    );
                    return;
                  }
                  _onSendPressed();
                },
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Bağlantıyı gönder'),
        ),
      ],
    );
  }
}
