import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'periodic_report_screen.dart'; 
// [NEW] 导入新的页面
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';
// [NEW] 导入上一轮添加的 account_update_screen
import 'account_update_screen.dart';


class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      // 背景色を設定
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context, user?.username ?? 'Guest'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionTitle(context, 'アカウント設定'),
                  _buildOptionCard(
                    context,
                    options: [
                      // [MODIFIED] 整合为一个按钮
                      _buildListTile(
                        context,
                        icon: Icons.manage_accounts_outlined,
                        title: 'アカウント情報変更',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            // 导航到上一轮创建的页面
                            builder: (_) => const AccountUpdateScreen(),
                          ));
                        },
                      ),
                      // [REMOVED] 移除了“メールアドレス変更”按钮
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'その他'),
                  _buildOptionCard(
                    context,
                    options: [
                      _buildListTile( 
                        context,
                        icon: Icons.bar_chart_outlined,
                        title: '定期レポート',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const PeriodicReportScreen(),
                          ));
                        },
                      ), 
                      _buildListTile(
                        context,
                        icon: Icons.help_outline,
                        title: 'ヘルプ',
                        onTap: () {},
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.description_outlined,
                        title: '利用規約',
                        // [MODIFIED] 添加导航
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ));
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'プライバシーポリシー',
                        // [MODIFIED] 添加导航
                        onTap: () {
                           Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ));
                        },
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.logout,
                        title: 'ログアウト',
                        isLogout: true,
                        onTap: () {
                          // ログアウト処理
                          context.read<AuthProvider>().logout();
                          // ログイン画面に戻る
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader(BuildContext context, String username) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }


  Widget _buildOptionCard(BuildContext context,
      {required List<Widget> options}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: options,
      ),
    );
  }


  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isLogout = false}) {
    final color = isLogout ? Colors.red : Colors.black;
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: color),
                ),
              ),
              if (!isLogout)
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

