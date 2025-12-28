import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taka2/widgets/const.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final Function(UserModel) onLogin;

  const LoginScreen({
    super.key,
    required this.onNavigate,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    bool rememberMe = false;
  bool isLogin = true;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool acceptTerms = false;
final TextEditingController _affiliateRefController = TextEditingController();
@override
void initState() {
  super.initState();
  // Pour Flutter Web uniquement
  final uri = Uri.base;
  final ref = uri.queryParameters['ref'];
  if (ref != null && ref.isNotEmpty) {
    _affiliateRefController.text = ref;
  }
  _loadSavedEmail();
}

void _loadSavedEmail() async {
  final prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString('saved_email');
  if (savedEmail != null && savedEmail.isNotEmpty) {
    setState(() {
      _emailController.text = savedEmail;
      rememberMe = true;
    });
  }
}
  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isLogin && !acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez accepter les conditions d\'utilisation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    if (isLogin) {
      // Connexion
      final user = await loginUser(_emailController.text, _passwordController.text);
      setState(() => isLoading = false);
      if (user != null) {
        widget.onLogin(UserModel(
          id: user['id'].toString(),
          createdAt: user['created_at'] ?? '',
          name: user['full_name'] ?? 'Utilisateur TAKA',
          email: user['email'],
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie ! Bienvenue sur TAKA.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Identifiants invalides'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Inscription
      final result = await registerUser(
        _fullNameController.text,
        _emailController.text,
        _passwordController.text,
      );
      setState(() => isLoading = false);
      if (result != null && result['success'] == true) {
        widget.onLogin(UserModel(
          id: result['id'].toString(),
          name: _fullNameController.text,
          createdAt: result['created_at'] ?? '',
          email: _emailController.text,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Bienvenue sur TAKA.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['error'] ?? 'Erreur lors de l\'inscription (email déjà utilisé ?)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  String? affiliateRef;


  // Register
  Future<Map<String, dynamic>?> registerUser(String fullName, String email, String password) async {
  final body = {
  'full_name': fullName,
  'email': email,
  'password': password,
  if (_affiliateRefController.text.isNotEmpty) 'ref': _affiliateRefController.text,
};
  final response = await http.post(
    Uri.parse('$baseUrl/taka_api_users.php?action=register'),
    body: jsonEncode(body),
    headers: {'Content-Type': 'application/json'},
  );
  final data = jsonDecode(response.body);
  return data;
}

  // Login
    Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taka_api_users.php?action=login'),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      final userData = data['user'];
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_user_id', userData['id'].toString());
        await prefs.setString('saved_user_name', userData['full_name'] ?? 'Utilisateur TAKA');
        await prefs.setString('saved_user_created_at', userData['created_at'] ?? '');
        await prefs.setBool('is_logged_in', true);
      } else {
        // Si "se souvenir de moi" n'est pas coché, on nettoie les données sauvegardées
        // mais on garde la session active pour la session courante
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('saved_email');
        await prefs.remove('saved_user_id');
        await prefs.remove('saved_user_name');
        await prefs.remove('saved_user_created_at');
        // On ne met pas is_logged_in à false ici car l'utilisateur est connecté
        // Il sera déconnecté automatiquement au prochain redémarrage de l'app
      }
      return userData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7ED), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 8 : 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 448),
                    child: Column(
                      children: [
                        _buildLogoMobile(isMobile: isMobile),
                        SizedBox(height: isMobile ? 18 : 32),
                        _buildFormMobile(isMobile: isMobile),
                        if (!isLogin) ...[
                          SizedBox(height: isMobile ? 18 : 32),
                          _buildBenefitsMobile(isMobile: isMobile),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMobile({required bool isMobile}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => widget.onNavigate('home'),
          child: Stack(
            children: [
              Text(
                'TAKA',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 32,
                  fontFamily: 'PBold',
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              Positioned(
                bottom: -2,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  transform: Matrix4.rotationZ(0.017),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 14 : 24),
        Text(
          isLogin ? 'Connectez-vous à votre compte' : 'Créez votre compte TAKA',
          style: TextStyle(
            fontSize: isMobile ? 18 : 24,
            fontFamily: 'PBold',
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          isLogin
              ? 'Retrouvez votre bibliothèque personnelle'
              : 'Rejoignez la communauté des lecteurs africains',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontFamily: 'PRegular',
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormMobile({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (!isLogin) ...[
              _buildTextField(
                controller: _fullNameController,
                label: 'Nom complet',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom complet est requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: isMobile ? 14 : 24),
            ],
            _buildTextField(
              controller: _emailController,
              label: 'Adresse email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format d\'email invalide';
                }
                return null;
              },
            ),
            SizedBox(height: isMobile ? 14 : 24),
            _buildTextField(
              controller: _passwordController,
              label: 'Mot de passe',
              icon: Icons.lock,
              obscureText: !showPassword,
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est requis';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
            if (!isLogin) ...[
              SizedBox(height: isMobile ? 14 : 24),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirmer le mot de passe',
                icon: Icons.lock,
                obscureText: !showConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                  icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmez votre mot de passe';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: isMobile ? 14 : 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) => setState(() => acceptTerms = value!),
                    activeColor: const Color(0xFFF97316),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isLogin) ...[
              SizedBox(height: isMobile ? 14 : 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                                            Checkbox(
                        value: rememberMe,
                        onChanged: (value) => setState(() => rememberMe = value!),
                        activeColor: const Color(0xFFF97316),
                      ),
                      Text(
                        'Se souvenir de moi',
                        style: TextStyle(
                          fontFamily: 'PRegular',
                          fontSize: isMobile ? 12 : 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité de récupération de mot de passe à venir'),
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isMobile ? 18 : 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontFamily: 'PRegular',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(isLogin ? 'Connexion...' : 'Inscription...',
                            style: TextStyle(
                              fontFamily: 'PRegular',
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLogin ? 'Se connecter' : 'Créer mon compte',
                            style: TextStyle(
                              fontFamily: 'PRegular',
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
              ),
            ),
            SizedBox(height: isMobile ? 14 : 24),
            // _buildSocialLoginMobile(isMobile: isMobile),
            SizedBox(height: isMobile ? 14 : 24),
            _buildToggleLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            fontFamily: 'PBold',
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            suffixIcon: suffixIcon,
            hintStyle: TextStyle(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFF97316), width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginMobile({required bool isMobile}) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white,
              child: Text(
                'Ou continuez avec',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontFamily: 'PBold',
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleSocialLogin('Facebook'),
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                label: Text('Facebook',
                  style: TextStyle(
                    fontFamily: 'PRegular',
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleSocialLogin('WhatsApp'),
                icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
                label: Text('WhatsApp',
                  style: TextStyle(
                    fontFamily: 'PRegular',
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Vous n'avez pas de compte ?" : 'Vous avez déjà un compte ?',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'PRegular',
            color: Color(0xFF6B7280),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
              _formKey.currentState?.reset();
              _emailController.clear();
              _passwordController.clear();
              _confirmPasswordController.clear();
              _fullNameController.clear();
              acceptTerms = false;
            });
          },
          child: Text(
            isLogin ? 'Inscrivez-vous' : 'Connectez-vous',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'PBold',
              fontWeight: FontWeight.w500,
              color: Color(0xFFF97316),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsMobile({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Pourquoi rejoindre TAKA ?',
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'PBold',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 10 : 16),
          ...[
            'Accès à des milliers de livres africains',
            'Recommandations personnalisées',
            'Lecture hors ligne sur tous vos appareils',
            'Soutenez les auteurs africains',
          ].map((benefit) => Padding(
                padding: EdgeInsets.only(bottom: isMobile ? 5 : 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontFamily: 'PRegular',
                          fontSize: isMobile ? 12 : 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    final userData = UserModel(
      id: '-1', // id fictif, à remplacer si tu fais une vraie intégration sociale
      name: 'Utilisateur $provider',
      email: 'user@example.com',
      createdAt: DateTime.now().toString(), // Date actuelle comme date d'inscription
    );

    widget.onLogin(userData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion via $provider réussie !'),
        backgroundColor: Colors.green,
      ),
    );
  }
}