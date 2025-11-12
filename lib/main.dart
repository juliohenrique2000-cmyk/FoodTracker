import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home.dart';
import 'registration_screen.dart';
import 'recipe_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodTracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: const Color(0x1F000000).withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      debugShowCheckedModeBanner: false,
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email != null && mounted) {
      setState(() {
        _emailController.text = email;
      });
    }
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email != null && password != null) {
      // Attempt auto-login
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          _userData = responseData['user'];
          _logger.info("Auto-login successful for: $email");

          // Login to external recipe API
          try {
            await RecipeApiService.login(email, password);
            _logger.info("External API auto-login successful for: $email");
          } catch (e) {
            _logger.warning("External API auto-login failed for: $email - $e");
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FitnessHomePage(
                  userName: _userData?['name'] ?? 'Usuário',
                  userData: _userData!,
                ),
              ),
            );
          }
        } else {
          // Auto-login failed, stay on login screen
          // Keep email for pre-filling
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        _logger.warning("Auto-login error: $e");
        // Keep email for pre-filling
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

        if (!mounted) return;

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          _userData = responseData['user'];
          _logger.info("Login successful for: $email");

          // Save credentials for auto-login
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('password', senha);

          // Login to external recipe API
          try {
            await RecipeApiService.login(email, senha);
            _logger.info("External API login successful for: $email");
          } catch (e) {
            _logger.warning("External API login failed for: $email - $e");
            // Continue anyway, as local login succeeded
          }

          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => FitnessHomePage(
                userName: _userData?['name'] ?? 'Usuário',
                userData: _userData!,
              ),
            ),
          );
        } else {
          _logger.warning("Login failed for: $email");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciais inválidas')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        _logger.severe("Error during login: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ).animate().fadeIn(duration: 500.ms).scale(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo/Title with animation
              Text(
                '🍎 FoodTracker',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                    'Sua jornada nutricional começa aqui',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 200.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 48),
              // Login form with staggered animations
              TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 16),
              TextField(
                    controller: _senhaController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 500.ms)
                  .slideX(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              // Buttons with animations
              SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _fazerLogin,
                      child: const Text('Entrar'),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
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
              ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FitnessHomePage(
                        userName: 'Convidado',
                        userData: {},
                      ),
                    ),
                  );
                },
                child: const Text('Acessar sem cadastro'),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
