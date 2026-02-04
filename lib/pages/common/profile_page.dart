import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member_model.dart';
import '../../services/local_storage.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart'; // 引入 UserProvider

class ProfilePage extends StatelessWidget {
  final Member member;
  const ProfilePage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[100],
              child: Text(member.fName.isNotEmpty ? member.fName[0] : 'U', style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text("${member.fName} (${member.nName})", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(member.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Chip(label: Text(member.mType)),
            const Divider(height: 40),
            _infoTile(lang.t('fName'), member.fName),
            _infoTile(lang.t('nName'), member.nName),
            _infoTile(lang.t('tel'), member.tel.toString()),
            _infoTile(lang.t('address'), member.address),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  // 1. 清除本地存儲
                  await LocalStorage.logout();
                  
                  if (context.mounted) {
                    // 2. 清除 Provider 狀態
                    Provider.of<UserProvider>(context, listen: false).clearUser();
                    
                    // 3. 跳轉回登入頁
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                  }
                },
                child: Text(lang.t('logout')),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
