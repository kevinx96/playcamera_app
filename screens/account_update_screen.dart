import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart'; // AuthProvider をインポート
import 'dart:developer' as developer; // ログ出力用

class AccountUpdateScreen extends StatefulWidget {
  const AccountUpdateScreen({super.key});

  @override
  State<AccountUpdateScreen> createState() => _AccountUpdateScreenState();
}

class _AccountUpdateScreenState extends State<AccountUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newUsernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // [NEW] フォームに現在のユーザー情報を事前入力
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null) {
      _usernameController.text = currentUser.username;
      _emailController.text = currentUser.email;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _newUsernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- [MODIFIED] API呼び出しロジック ---
  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // [NEW] 新しいユーザー名も新しいパスワードも入力されていない場合は何もしない
    if (_newUsernameController.text.isEmpty && 
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('変更する新しいユーザー名またはパスワードを入力してください。'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final apiService = context.read<ApiService>();
    final authProvider = context.read<AuthProvider>();

    try {
      // [REMOVED] クライアントサイドのチェックを削除 (API が行うため)
      
      developer.log('Calling apiService.updateAccount...', name: 'AccountUpdateScreen');

      // [MODIFIED] 新しい API サービスメソッドを呼び出す
      final response = await apiService.updateAccount(
        currentUsername: _usernameController.text,
        currentEmail: _emailController.text,
        newUsername: _newUsernameController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      // API 呼び出しが成功 (HTTP 200) し、
      // かつ API がロジック上の成功 (success: true) を返した場合
      if (response['success'] == true && mounted) {
        
        // [NEW] AuthProvider のローカルユーザー情報を更新
        if (_newUsernameController.text.isNotEmpty) {
          authProvider.updateLocalUser(
            newUsername: _newUsernameController.text.trim(),
            // (もしAPIが更新後のemailやfull_nameを返すなら、ここも更新する)
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'アカウント情報が更新されました。'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // 成功したら前のページに戻る
      }
      
      // [FIXED] APIがロジック上のエラー (success: false) を返した場合
      // _handleResponse がこれを Exception に変換するはずだが、念のため
      else if (mounted) {
         throw Exception(response['message'] ?? '不明なエラーが発生しました');
      }

    } catch (e) {
      // [MODIFIED] エラーハンドリングを改善
      developer.log('Update failed', name: 'AccountUpdateScreen', error: e);
      if (mounted) {
        // e.toString() には "Exception: " が含まれている可能性があるので、それを整形する
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新に失敗しました: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // [NEW] ユーザー情報をリッスンして、万が一ログアウトされたら入力欄を無効化
    final currentUser = context.watch<AuthProvider>().user;
    final bool isEnabled = currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント情報の変更'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- 認証セクション ---
              Text(
                '現在の情報を入力してください',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                enabled: isEnabled, // [MODIFIED]
                decoration: const InputDecoration(
                  labelText: '現在のユーザー名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '必須項目です' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: isEnabled, // [MODIFIED]
                decoration: const InputDecoration(
                  labelText: '現在のメールアドレス',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? '必須項目です' : null,
              ),

              const Divider(height: 40),

              // --- 更新セクション ---
              Text(
                '変更後の情報を入力 (任意)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newUsernameController,
                enabled: isEnabled, // [MODIFIED]
                decoration: const InputDecoration(
                  labelText: '新しいユーザー名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                // [NEW] 新しいユーザー名が現在のものと同じ場合はエラー
                validator: (value) {
                  if (value != null && value.isNotEmpty && value == _usernameController.text) {
                    return '新しいユーザー名は現在と同じにできません';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                enabled: isEnabled, // [MODIFIED]
                decoration: const InputDecoration(
                  labelText: '新しいパスワード (6文字以上)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                // [NEW] パスワードのバリデーション
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'パスワードは6文字以上で入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: isEnabled, // [MODIFIED]
                decoration: const InputDecoration(
                  labelText: '新しいパスワード (確認)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  // [FIXED] 新しいパスワードが入力されている場合のみ、一致チェックを行う
                  if (_newPasswordController.text.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return 'パスワードが一致しません';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                // [MODIFIED] isEnabled もチェック
                onPressed: _isLoading || !isEnabled ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

