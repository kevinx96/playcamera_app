import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// [MODIFIED] dart:developer import を削除 (以前のUIでは不要なため)
// import 'dart:developer' as developer; 

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

  // [MODIFIED] 状態変数の名前を以前のコードに合わせる
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // [MODIFIED] メソッド名を _submit に変更 (以前のコードに合わせる)
  // ただし、機能は現在の堅牢な try-catch ロジックを維持
  Future<void> _submit() async {
    // developer.log('Register button pressed. ...'); // [MODIFIED] ログを削除

    // developer.log('Form key state: ...'); // [MODIFIED] ログを削除

    // [MODIFIED] バリデーションを以前のコードの形式に戻す
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // developer.log('Form validation successful. ...'); // [MODIFIED] ログを削除

    final authProvider = context.read<AuthProvider>();
    try {
      final success = await authProvider.register(
        // [MODIFIED] AuthProvider.register に渡す引数を修正
        fullName: _fullNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        // developer.log('AuthProvider.register returned success.'); // [MODIFIED] ログを削除
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ユーザー登録が成功しました。ログインしてください。'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // 登録成功後、ログイン画面に戻る
      } else if (!success && mounted) {
        // developer.log('AuthProvider.register returned failure. ...'); // [MODIFIED] ログを削除
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録に失敗しました: ${authProvider.error ?? '不明なエラー'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // developer.log('Exception caught while calling ...'); // [MODIFIED] ログを削除
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登録中にエラーが発生しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // AuthProvider の状態を監視して、ローディング表示を制御
    final isLoading = context.watch<AuthProvider>().isLoading;

    // [MODIFIED] UI全体を以前のコード (Center + SingleChildScrollView) に差し替え
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '新しいアカウントを作成',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '必要な情報を入力してください',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: '氏名',
                    prefixIcon: Icon(Icons.badge_outlined),
                    // [MODIFIED] OutlineInputBorder を削除
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? '氏名を入力してください。' : null,
                ),
                const SizedBox(height: 20),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ユーザー名',
                    prefixIcon: Icon(Icons.person_outline),
                    // [MODIFIED] OutlineInputBorder を削除
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'ユーザー名を入力してください。' : null,
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.email_outlined),
                    // [MODIFIED] OutlineInputBorder を削除
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'メールアドレスを入力してください。';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return '有効なメールアドレスを入力してください。';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // [MODIFIED] 状態変数名を変更
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      // [MODIFIED] 状態変数名とトグルロジックを以前のコードに合わせる
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    // [MODIFIED] OutlineInputBorder を削除
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください。';
                    }
                    if (value.length < 6) {
                      return 'パスワードは6文字以上で入力してください。';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible, // [MODIFIED] 状態変数名を変更
                  decoration: InputDecoration(
                    labelText: 'パスワード（確認）',
                    prefixIcon: const Icon(Icons.lock_outline),
                     suffixIcon: IconButton(
                      // [MODIFIED] 状態変数名とトグルロジックを以前のコードに合わせる
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                    // [MODIFIED] OutlineInputBorder を削除
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '確認用パスワードを入力してください。';
                    }
                    if (value != _passwordController.text) {
                      return 'パスワードが一致しません。';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                isLoading // [MODIFIED] authProvider.isLoading -> isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        // [MODIFIED] onPressed を _submit に変更し、スタイルを削除
                        onPressed: _submit, 
                        child: const Text('登録'),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('すでにアカウントをお持ちですか？'),
                    TextButton(
                      onPressed: isLoading ? null : () { // [MODIFIED] authProvider.isLoading -> isLoading
                        Navigator.of(context).pop();
                      },
                      child: const Text('ログイン'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
