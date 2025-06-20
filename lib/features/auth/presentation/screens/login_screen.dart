import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto30_next/core/config/app_config.dart';
import 'package:auto30_next/features/auth/presentation/providers/auth_provider.dart';
import 'package:auto30_next/features/auth/presentation/screens/register_screen.dart';
import 'package:auto30_next/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:auto30_next/features/auth/presentation/widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthProvider>().signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFFDE0B2),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 上方 Logo 與標題
              Container(
                margin: const EdgeInsets.only(top: 32, bottom: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.chat_bubble_outline,
                        size: 80, color: Colors.orange),
                    SizedBox(height: 16),
                    Text('Auto30',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                    SizedBox(height: 8),
                    Text('自主學習促進會',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('一起開始你的自主學習互助之旅 ',
                        style: TextStyle(fontSize: 16, color: Colors.black38)),
                  ],
                ),
              ),
              // 登入表單
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('登入帳號',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail, color: Colors.orange),
                          labelText: '電子郵件',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.orange),
                          labelText: '密碼',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.orange),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入密碼';
                          }
                          if (value.length < 6) {
                            return '密碼至少需 6 個字元';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text('忘記密碼?',
                              style: TextStyle(color: Colors.orange)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('登入', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('或',
                                style: TextStyle(color: Colors.black38)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Google 登入按鈕
                      GoogleSignInButton(
                        webClientId: AppConfig.googleClientId,
                        onSignIn: (user) async {
                          if (user != null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('歡迎回來，${user.displayName ?? '用戶'}！'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google 登入失敗'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => authProvider.signInAnonymously(),
                        icon: Icon(Icons.person, color: Colors.orange),
                        label: Text('以訪客身分進入',
                            style: TextStyle(color: Colors.orange)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text('沒有帳號？註冊'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
