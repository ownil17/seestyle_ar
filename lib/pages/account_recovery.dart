import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/components/button.dart';
import 'package:seestyle_firebase/components/text_field.dart';

class AccountRecoveryPage extends StatefulWidget {
  final Function()? onBack;
  const AccountRecoveryPage({super.key, this.onBack});

  @override
  State<AccountRecoveryPage> createState() => _AccountRecoveryPageState();
}

class _AccountRecoveryPageState extends State<AccountRecoveryPage> {
  final emailController = TextEditingController();

  void resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      displayMessage("Please enter your email.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) Navigator.pop(context); // close loading
      displayMessage(
        "Password reset link sent! Check your email.",
        title: "Success",
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      displayMessage(e.message ?? "Failed to send reset email.");
    } catch (e) {
      if (mounted) Navigator.pop(context);
      displayMessage("Something went wrong.");
    }
  }

  void displayMessage(String message, {String title = "Error"}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 40, 44, 52),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text("Account Recovery", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/SeeStyle.png', width: 250, height: 125),
              const SizedBox(height: 20),
              const Text(
                "Enter your email to receive a password reset link.",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: resetPassword,
                text: "Send Reset Link",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
