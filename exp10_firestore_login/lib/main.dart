// pubspec.yaml -> dependencies:
//   firebase_core: ^3.6.0   cloud_firestore: ^5.4.4   crypto: ^3.0.5
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AuthApp());
}

final users = FirebaseFirestore.instance.collection('users');

// Passwords are stored as a SHA-256 hash, never as plain text
String hashPassword(String p) => sha256.convert(utf8.encode(p)).toString();

String? validateEmail(String? v) =>
    RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$').hasMatch(v?.trim() ?? '')
        ? null
        : 'Enter a valid email';

String? validatePassword(String? v) =>
    (v ?? '').length < 6 ? 'Password must be at least 6 characters' : null;

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Login',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3949AB), useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

// Common layout: gradient background with a centered card
class AuthCard extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> children;
  const AuthCard({super.key, required this.title,
      required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3949AB), Color(0xFF00ACC1)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircleAvatar(
                      radius: 32, child: Icon(Icons.lock_outline, size: 32)),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ...children,
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration inputStyle(String label, IconData icon, {Widget? suffix}) =>
    InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _hidePassword = true, _loading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() => _error = '');
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final snap = await users
        .where('email', isEqualTo: _emailCtrl.text.trim().toLowerCase())
        .limit(1)
        .get();
    setState(() => _loading = false);

    if (snap.docs.isEmpty) {
      setState(() => _error = 'No account found for this email');
    } else if (snap.docs.first['password'] != hashPassword(_passCtrl.text)) {
      setState(() => _error = 'Incorrect password');
    } else if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HomePage(user: snap.docs.first.data())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      title: 'Welcome Back',
      subtitle: 'Login to continue',
      children: [
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: inputStyle('Email', Icons.email_outlined),
                validator: validateEmail),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: _hidePassword,
              decoration: inputStyle('Password', Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  )),
              validator: validatePassword,
            ),
          ]),
        ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_error, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Login', style: TextStyle(fontSize: 16)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const RegisterPage())),
          child: const Text("Don't have an account? Register"),
        ),
      ],
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim().toLowerCase();
    final existing = await users.where('email', isEqualTo: email).limit(1).get();
    if (!mounted) return;
    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered')));
      return;
    }
    await users.add({
      'name': _nameCtrl.text.trim(),
      'email': email,
      'password': hashPassword(_passCtrl.text),
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please login.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      title: 'Create Account',
      subtitle: 'Register a new user',
      children: [
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
                controller: _nameCtrl,
                decoration: inputStyle('Full Name', Icons.person_outline),
                validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null),
            const SizedBox(height: 14),
            TextFormField(
                controller: _emailCtrl,
                decoration: inputStyle('Email', Icons.email_outlined),
                validator: validateEmail),
            const SizedBox(height: 14),
            TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: inputStyle('Password', Icons.lock_outline),
                validator: validatePassword),
            const SizedBox(height: 14),
            TextFormField(
                obscureText: true,
                decoration: inputStyle('Confirm Password', Icons.lock_reset),
                validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(onPressed: _register, child: const Text('Register')),
        ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const LoginPage())),
          ),
        ],
      ),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
              radius: 44,
              child: Text(user['name'][0], style: const TextStyle(fontSize: 36))),
          const SizedBox(height: 16),
          Text('Hello, ${user['name']}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(user['email'], style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Chip(
            avatar: Icon(Icons.verified_user, color: Colors.green),
            label: Text('Logged in securely via Firestore'),
          ),
        ]),
      ),
    );
  }
}
