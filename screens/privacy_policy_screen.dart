import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プライバシーポリシー',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              '[あなたの会社名]（以下「当社」といいます。）は、当社の提供する安全監視サービス（以下「本サービス」といいます。）における、ユーザーの個人情報を含む利用者情報の取扱いについて、以下のとおりプライバシーポリシー（以下「本ポリシー」といいます。）を定めます。',
            ),
            _buildSectionTitle(context, '第1条（利用者情報及び個人情報の定義）'),
            _buildParagraph(
              '1. 「利用者情報」とは、ユーザーの識別に係る情報、通信サービス上の行動履歴、その他ユーザーまたはユーザーの端末に関連して生成または蓄積された情報であって、本ポリシーに基づき当社が収集するものを意味します。',
            ),
            _buildParagraph(
              '2. 「個人情報」とは、利用者情報のうち、個人情報の保護に関する法律（以下「個人情報保護法」といいます。）第2条第1項に定める「個人情報」を意味します。具体的には、氏名、メールアドレス、その他の記述等により特定の個人を識別できる情報（他の情報と容易に照合でき、それにより特定の個人を識別できるものを含む）を指します。',
            ),
            _buildSectionTitle(context, '第2条（収集する利用者情報及び収集方法）'),
            _buildParagraph(
              '本サービスにおいて当社が収集する利用者情報は、その収集方法に応じて、以下のようなものとなります。\n'
              '(1) ユーザーからご提供いただく情報\n'
              '・氏名、メールアドレス、電話番号、その他当社が定める登録フォームにてユーザーが入力する情報\n'
              '(2) ユーザーが本サービスを利用するにあたって、当社が収集する情報\n'
              '・リファラ、IPアドレス、サーバーアクセスログに関する情報、Cookie、その他の識別子\n'
              '・端末の個体識別情報、OS情報、位置情報（ユーザーが許可した場合）\n'
              '(3) 本サービスが収集する映像データ\n'
              '・本サービスが分析のためにカメラから取得する映像データ。当該データには、個人を識別可能な画像（顔など）が含まれる場合がありますが、当社はこれを分析目的（例：異常行動の検出）のためにのみ機械的に処理します。',
            ),
            _buildSectionTitle(context, '第3条（利用目的）'),
            _buildParagraph(
              '当社は、取得した利用者情報を、以下の目的のために利用します。\n'
              '(1) 本サービスの提供、維持、保護及び改善のため（例：受付、本人確認、利用料金の計算、通知）\n'
              '(2) 本サービスに関するご案内、お問い合わせ等への対応のため\n'
              '(3) 本サービスに関する当社の規約、ポリシー等（以下「規約等」といいます。）に違反する行為に対する対応のため\n'
              '(4) 本サービスに関する規約等の変更などを通知するため\n'
              '(5) 属性情報、端末情報、位置情報、行動履歴等に基づく広告・コンテンツ等の配信・表示のため\n'
              '(6) マーケティングデータの調査・分析、新たなサービス開発のため\n'
              '(7) 上記の利用目的に付随する目的のため',
            ),
            _buildSectionTitle(context, '第4条（第三者提供）'),
            _buildParagraph(
              '当社は、利用者情報のうち、個人情報については、あらかじめユーザーの同意を得ないで、第三者（日本国外にある者を含みます。）に提供しません。但し、次に掲げる必要があり第三者に提供する場合はこの限りではありません。\n'
              '(1) 当社が利用目的の達成に必要な範囲内において個人情報の取扱いの全部または一部を委託する場合\n'
              '(2) 合併その他の事由による事業の承継に伴って個人情報が提供される場合\n'
              '(3) 法令に基づき開示を求められた場合\n'
              '(4) 人の生命、身体または財産の保護のために必要がある場合であって、本人の同意を得ることが困難であるとき\n'
              '(5) 公衆衛生の向上または児童の健全な育成の推進のために特に必要がある場合であって、本人の同意を得ることが困難であるとき\n'
              '(6) 国の機関もしくは地方公共団体またはその委託を受けた者が法令の定める事務を遂行することに対して協力する必要がある場合であって、本人の同意を得ることにより当該事務の遂行に支障を及ぼすおそれがあるとき',
            ),
             _buildSectionTitle(context, '第5条（安全管理措置）'),
            _buildParagraph(
              '当社は、その取り扱う個人情報の漏えい、滅失またはき損の防止その他の個人情報の安全管理のために、組織的、人的、物理的、技術的な各観点から、必要かつ適切な措置（アクセス制御、不正アクセス防止措置、特権アクセスの管理等）を講じます。',
            ),
            _buildSectionTitle(context, '第6条（クッキー（Cookie）の使用）'),
            _buildParagraph(
              '本サービスは、ユーザーの利便性の向上、広告の効果測定、および統計データの取得のため、クッキーを使用することがあります。これはユーザーのプライバシーを侵害するものではなく、またユーザーのコンピューターへ悪影響を及ぼすものではありません。ユーザーは、ブラウザの設定によりクッキーの送受信を無効にすることができますが、その場合、本サービスの一部が正常に機能しなくなる可能性があります。',
            ),
            _buildSectionTitle(context, '第7条（本ポリシーの変更）'),
            _buildParagraph(
              '当社は、法令の変更または事業上の必要に応じて、本ポリシーを随時変更することができるものとします。変更後のポリシーは、本サービス上または当社のウェブサイト上に掲載された時点から効力を生じるものとし、ユーザーが変更後に本サービスを利用した場合は、変更後のポリシーに同意したものとみなします。',
            ),
            const SizedBox(height: 32),
            const Text('2025年11月3日 制定'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF333333)),
      ),
    );
  }
}

