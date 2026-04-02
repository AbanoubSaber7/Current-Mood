import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_app/screens/detection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _isObscured = true; // التحكم في إظهار/إخفاء الباسورد

  void handleSignUp() async {
    String userName = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;

    // 1. التأكد أن الحقول ليست فارغة
    if (userName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // 2. الميزة المطلوبة: التأكد أن الباسورد لا يقل عن 8 حروف
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 8 characters long"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // تخزين البيانات في Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'full_name': userName,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // حفظ الاسم في الذاكرة المحلية
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', userName);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetectionScreen(userName: userName),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFBECEB), Color(0xFFEDB1AA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Create Account",
                    style: TextStyle(
                        color: Color(0xFFC04F4C),
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                    )
                ),
                const SizedBox(height: 30),

                _buildTextField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 15),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 15),

                // خانة الباسورد مع ميزة الإظهار والإخفاء
                _buildTextField(
                    passwordController,
                    "Password",
                    Icons.lock,
                    isPasswordField: true // برامتر جديد مخصص للباسورد
                ),

                const SizedBox(height: 25),
                isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFC04F4C))
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC04F4C),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login",
                      style: TextStyle(color: Color(0xFFC04F4C), fontWeight: FontWeight.w600)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // تعديل الـ Widget المساعد ليدعم أيقونة العين
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPasswordField = false}) {
    return TextField(
      controller: controller,
      obscureText: isPasswordField ? _isObscured : false, // الإخفاء فقط لو كانت خانة باسورد
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFC04F4C)),
        // إضافة أيقونة العين فقط لو كانت خانة باسورد
        suffixIcon: isPasswordField
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFFC04F4C),
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}