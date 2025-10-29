import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:developer' as developer; // [NEW] 导入 developer

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // [DEBUG LOG] 确认按钮点击事件被触发
    developer.log('Register button pressed. Attempting to submit form.', name: 'RegisterScreen._submitForm');

    // [DEBUG LOG] 检查 _formKey 是否存在
    developer.log('Form key state: ${_formKey.currentState}', name: 'RegisterScreen._submitForm');

    if (_formKey.currentState?.validate() ?? false) {
      // [DEBUG LOG] 确认表单验证通过
      developer.log('Form validation successful. Calling AuthProvider.register...', name: 'RegisterScreen._submitForm');

      final authProvider = context.read<AuthProvider>();
      try {
        final success = await authProvider.register(
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
          fullName: _fullNameController.text,
        );

        if (success && mounted) {
           // [DEBUG LOG] 确认注册成功回调
           developer.log('AuthProvider.register returned success.', name: 'RegisterScreen._submitForm');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ユーザー登録が成功しました。ログインしてください。'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // 登録成功後、ログイン画面に戻る
        } else if (!success && mounted) {
           // [DEBUG LOG] 确认注册失败回调 (来自 Provider)
           developer.log('AuthProvider.register returned failure. Error: ${authProvider.error}', name: 'RegisterScreen._submitForm');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('登録に失敗しました: ${authProvider.error ?? '不明なエラー'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
         // [DEBUG LOG] 捕获 Provider 调用本身的异常
         developer.log('Exception caught while calling AuthProvider.register', name: 'RegisterScreen._submitForm', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('登録中にエラーが発生しました: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
       // [DEBUG LOG] 确认表单验证失败
       developer.log('Form validation failed.', name: 'RegisterScreen._submitForm');
    }
  }


  @override
  Widget build(BuildContext context) {
    // AuthProvider の状態を監視して、ローディング表示を制御
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
      ),
      body: Stack( // ローディング表示のために Stack を使用
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView( // SingleChildScrollView の代わりに ListView を使うと、フォーカス移動などが改善される場合がある
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ユーザー名',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ユーザー名を入力してください';
                      }
                      if (value.length < 3) {
                        return 'ユーザー名は3文字以上で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                      // 簡単なメールアドレス形式の検証
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return '有効なメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: '氏名',
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '氏名を入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'パスワード',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'パスワードを入力してください';
                      }
                      if (value.length < 6) {
                        return 'パスワードは6文字以上で入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'パスワード (確認)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                       suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '確認用パスワードを入力してください';
                      }
                      if (value != _passwordController.text) {
                        return 'パスワードが一致しません';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm, // ローディング中はボタンを無効化
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('登録'),
                  ),
                ],
              ),
            ),
          ),
          // ローディングインジケーターを重ねて表示
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5), // 背景を少し暗くする
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

