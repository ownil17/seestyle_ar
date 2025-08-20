import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/components/button.dart';
import 'package:seestyle_firebase/components/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // controllers
  final fullNameController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // visibility toggles
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // terms checkbox
  bool _agreedToTerms = false;

  // Password validation method
  bool isValidPassword(String password) {
    // Minimum 8 characters, at least 1 uppercase, 1 lowercase, and 1 number
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // sign user up
  void signUp() async {
    if (!_agreedToTerms) {
      displayMessage("You must agree to the Terms and Privacy Policy to continue.");
      return;
    }

    if (passwordTextController.text != confirmPasswordTextController.text) {
      displayMessage("Passwords don't match!");
      return;
    }
    
    if (!isValidPassword(passwordTextController.text.trim())) {
      displayMessage(
        "Password must be at least 8 characters long, include uppercase and lowercase letters, and contain a number."
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
        'full_name': fullNameController.text.trim(),
        'username': emailTextController.text.split('@')[0].trim(),
        'email': emailTextController.text.trim(),
        'age': '',
        'birthday': '',
        'contact': '',
        'role': 'customer',
      });

      if (mounted) Navigator.pop(context);
      if (mounted) widget.onTap?.call(); // Go to login page
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      displayMessage(e.message ?? e.code);
    }
  }

  // display a dialog message
  void displayMessage(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  // show Terms and Agreement dialog
  void showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Agreement'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: const Text(
              '''Effective Date: May 21, 2025

Welcome to SeeStyle , operated by CE Optical Clinic. By using our App, you agree to the following terms and conditions. Please read them carefully.

1. Use of the App
You agree to use the App only for its intended purposes: viewing optical products, requesting appointments, tracking your glasses order status, and communicating with the clinic. You must provide accurate and complete information when using the App.

2. User Information and Privacy
We collect personal information such as your full name, age, birthday, contact number, and optionally your eye prescription history. This information is used to provide our services and manage your orders and appointments. Please review our Privacy Policy for details on how we protect and use your data.

3. Account Management
You are responsible for maintaining the confidentiality of your account and contact information. You agree to notify us immediately of any unauthorized use of your account.

4. Accuracy of Information
While we strive to ensure the accuracy of product availability, appointment scheduling, and order status, we do not guarantee that all information on the App is error-free or up-to-date at all times.

5. Limitation of Liability
We are not responsible for any direct or indirect damages arising from the use or inability to use the App, including errors in orders, delays, or data loss.

6. Changes to Terms
We may update these Terms from time to time. Continued use of the App after changes indicates your acceptance of the new Terms.

7. Governing Law
These Terms are governed by the laws of Philippines.

8. Contact
If you have questions about these Terms, please contact us at ceoptical@email.com .''',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // show Privacy Policy dialog
  void showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: const Text(
              '''Effective Date: May 21, 2025

At CE Optical Clinic, your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information when you use our app, Seestyle.

1. Information We Collect
We collect the following personal information you provide:

Full name

Age

Birthday

Contact number

Optional eye prescription history

2. How We Use Your Information
We use your information to:

Manage your account and appointments

Process and track your orders for prescription glasses

Communicate with you about your orders and appointments

Improve our services

3. How We Protect Your Information
We implement appropriate technical and organizational security measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction.

4. Sharing Your Information
We do not sell or rent your personal information. We may share your data only with authorized personnel within our clinic or service providers who help us operate the App, under strict confidentiality agreements.

5. Your Rights
You may:

Access and update your personal information by contacting us

Request deletion of your personal data, subject to legal and operational requirements

6. Data Retention
We retain your personal information only as long as necessary to provide our services or comply with legal obligations.

7. Children’s Privacy
Our App is intended for customers of legal age. We do not knowingly collect personal information from children under [insert minimum age].

8. Changes to This Policy
We may update this Privacy Policy occasionally. We will notify you of any significant changes.

9. Contact Us
For questions or concerns about your privacy, please contact us at:
ceoptical@email.com .
''',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('assets/images/SeeStyle.png', width: 300, height: 150),
                const SizedBox(height: 20),
                const Text(
                  "Let's create an account for you",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // full name
                MyTextField(
                  controller: fullNameController,
                  hintText: 'Full Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // email
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password with visibility toggle
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // confirm password with visibility toggle
                MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirm Password',
                  obscureText: !_showConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Terms and Privacy Policy checkbox + text with dialogs
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            children: [
                              const TextSpan(text: "I agree to the "),
                              TextSpan(
                                text: "Terms and Agreement",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = showTermsDialog,
                              ),
                              const TextSpan(text: " and "),
                              TextSpan(
                                text: "Privacy Policy",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = showPrivacyDialog,
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                MyButton(onTap: signUp, text: 'Sign Up'),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
