import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../services/local_storage.dart';
import 'register_page.dart';
import '../teacher/teacher_home.dart';
import '../student/student_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final res = await ApiService.login(
        username: _usernameCtrl.text, 
        password: _passwordCtrl.text
      );
      
      if (res['success'] == true) {
        await LocalStorage.saveUserInfo(res['user']);
        if (!mounted) return;
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        if (!mounted) return;

        final role = res['user']['mType'];
        if (role == 'TEACHER') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherHomePage()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentHomePage()));
        }
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Background Gradient Container
                Container(
                  height: size.height * 0.4, // Increased height for better centering
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
                  ),
                ),
                
                // Language Button (Top Right)
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.language, color: Colors.white),
                    onPressed: () => lang.toggleLanguage(),
                  ),
                ),

                // [KEY CHANGE] Centered Branding Content
                SizedBox(
                  height: size.height * 0.4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school_rounded, size: 60, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          lang.t('app_title'), 
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Learn without limits", 
                          style: TextStyle(color: Colors.white70, fontSize: 16)
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _usernameCtrl,
                      label: lang.t('email'),
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordCtrl,
                      label: lang.t('password'),
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isObscure: _isObscure,
                      onTogglePass: () => setState(() => _isObscure = !_isObscure),
                    ),
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : Text(lang.t('login'), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("New here? ", style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                          child: Text(lang.t('register'), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onTogglePass,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && isObscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
          suffixIcon: isPassword 
            ? IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onTogglePass) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }
}
