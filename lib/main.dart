import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'registration_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tela de Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final Logger _logger = Logger('LoginScreen');
  Map<String, dynamic>? _userData;

  Future<void> _fazerLogin() async {
    String email = _emailController.text;
    String senha = _senhaController.text;

    if (email.isNotEmpty && senha.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': senha}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          _userData = responseData['user'];
          _logger.info("Login successful for: $email");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FitnessHomePage(userName: _userData?['name'] ?? 'Usuário'),
            ),
          );
        } else {
          _logger.warning("Login failed for: $email");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciais inválidas')),
          );
        }
      } catch (e) {
        _logger.severe("Error during login: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Nutrição',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _fazerLogin, child: const Text('Entrar')),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  ),
                );
              },
              child: const Text('Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}
