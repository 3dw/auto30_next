import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().resetPassword(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('忘記密碼')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '電子郵件',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入電子郵件';
                      }
                      if (!value.contains('@')) {
                        return '請輸入有效的電子郵件';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (authProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authProvider.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleReset,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('發送重設密碼信'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('返回登入'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 