// vigilant_forgot_password.dart - Forgot Password Screen
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/vigilant_theme.dart';

class VigilantForgotPassword extends StatefulWidget {
  @override
  _VigilantForgotPasswordState createState() => _VigilantForgotPasswordState();
}

class _VigilantForgotPasswordState extends State<VigilantForgotPassword> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String _message = '';

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = "Please enter your email");
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/v1/auth/forgot-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _sent = true;
          _message = "Reset link sent! Check your email.";
        });
      } else {
        setState(() => _message = "Something went wrong. Try again.");
      }
    } catch (e) {
      setState(() => _message = "Network error. Check your connection.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: vigilantPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset, size: 100, color: vigilantAccent),
            SizedBox(height: 40),
            Text(
              "Reset Your Password",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Enter your email address and we'll send you a link to reset your password.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 24),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(color: _sent ? Colors.green : Colors.red),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text(_sent ? "Resend Link" : "Send Reset Link", style: TextStyle(fontSize: 18)),
              ),
            ),
            if (_sent) ...[
              SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text("Back to Login"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
