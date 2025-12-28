import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taka2/widgets/global.dart';
import '../models/user_model.dart';

class Header extends StatefulWidget {
  final String currentPage;
  final Function(String) onNavigate;
  final bool isLoggedIn;
  final UserModel? user;
  final VoidCallback onLogout;

  const Header({
    super.key,
    required this.currentPage,
    required this.onNavigate,
    required this.isLoggedIn,
    this.user,
    required this.onLogout,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool showUserMenu = false;
  String? selectedCountry;
  String? selectedCurrency;

final List<Map<String, String>> countries = [
  // Zone UEMOA (XOF) - Pays supportés par Moneroo
  {'name': 'Bénin', 'currency': 'XOF', 'flag': '🇧🇯'},
  {'name': 'Burkina Faso', 'currency': 'XOF', 'flag': '🇧🇫'},
  {'name': 'Côte d\'Ivoire', 'currency': 'XOF', 'flag': '🇨🇮'},
  {'name': 'Mali', 'currency': 'XOF', 'flag': '🇲🇱'},
  {'name': 'Niger', 'currency': 'XOF', 'flag': '🇳🇪'},
  {'name': 'Sénégal', 'currency': 'XOF', 'flag': '🇸🇳'},
  {'name': 'Togo', 'currency': 'XOF', 'flag': '🇹🇬'},
  
  // Zone CEMAC (XAF) - Pays supportés par Moneroo
  {'name': 'Cameroun', 'currency': 'XAF', 'flag': '🇨🇲'},
  {'name': 'Centrafrique', 'currency': 'XAF', 'flag': '🇨🇫'},
  {'name': 'Congo', 'currency': 'XAF', 'flag': '🇨🇬'},
  {'name': 'Guinée équatoriale', 'currency': 'XAF', 'flag': '🇬🇶'},
  {'name': 'Gabon', 'currency': 'XAF', 'flag': '🇬🇦'},
  {'name': 'Tchad', 'currency': 'XAF', 'flag': '🇹🇩'},
  
  // Autres pays africains supportés par Moneroo
  {'name': 'Nigeria', 'currency': 'NGN', 'flag': '🇳🇬'},
  {'name': 'Ghana', 'currency': 'GHS', 'flag': '🇬🇭'},
  {'name': 'Guinée', 'currency': 'GNF', 'flag': '🇬🇳'},
  {'name': 'Afrique du Sud', 'currency': 'ZAR', 'flag': '🇿🇦'},
  
  // Pays occidentaux - Utilisation de card_usd (supporté mondialement)
  {'name': 'États-Unis', 'currency': 'USD', 'flag': '🇺🇸'},
];

   @override
  void initState() {
    super.initState();
    _loadCountryCurrency();
  }

Future<void> _loadCountryCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCountry = prefs.getString('country');
      selectedCurrency = prefs.getString('currency');
    });
  }

  Future<void> _setCountryCurrency(String country, String currency) async {
  print('🌍 Pays sélectionné: $country, Devise: $currency');
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('country', country);
  await prefs.setString('currency', currency);
  currencyNotifier.value = currency; // <-- Notifie tous les listeners
  setState(() {
    selectedCountry = country;
    selectedCurrency = currency;
  });
  print('✅ Pays et devise mis à jour avec succès');
}
  final List<Map<String, String>> menuItems = [
    {'id': 'home', 'label': 'Accueil'},
    // {'id': 'about', 'label': 'À propos'},
    {'id': 'explore', 'label': 'Lire'},
    {'id': 'publish', 'label': 'Publier'},
    {'id': 'subscription', 'label': 'Abonnement'},
  ];

  Widget _buildCountrySelector() {
    return PopupMenuButton<Map<String, String>>(
      color: Colors.white,
      tooltip: 'Choisir un pays',
      onSelected: (country) {
        _setCountryCurrency(country['name']!, country['currency']!);
      },
      itemBuilder: (context) => countries
          .map(
            (country) => PopupMenuItem<Map<String, String>>(
              value: country,
              child: Row(
                children: [
                  Text(country['flag'] ?? '', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(country['name'] ?? ''),
                  const SizedBox(width: 8),
                  Text('(${country['currency']})', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Text(
              selectedCountry != null
                  ? countries.firstWhere((c) => c['name'] == selectedCountry, orElse: () => countries[0])['flag'] ?? '🌍'
                  : '🌍',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCountry ?? 'Pays',
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
            ),
            const SizedBox(width: 6),
            Text(
              selectedCurrency != null ? '(${selectedCurrency!})' : '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    GestureDetector(
                      onTap: () => widget.onNavigate('home'),
                      child: Image.asset("assets/images/logo.jpeg")
                      // Stack(
                      //   children: [
                      //     Text(
                      //       'TAKA',
                      //       style: TextStyle(
                      //         fontSize: 24,
                      //         fontWeight: FontWeight.w700,
                      //         color: Colors.black,
                      //         letterSpacing: 0.5,
                      //       ),
                      //     ),
                      //     Positioned(
                      //       bottom: -2,
                      //       left: 0,
                      //       right: 0,
                      //       child: Container(
                      //         height: 4,
                      //         decoration: BoxDecoration(
                      //           gradient: const LinearGradient(
                      //             colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                      //           ),
                      //           borderRadius: BorderRadius.circular(2),
                      //         ),
                      //         transform: Matrix4.rotationZ(0.017), // ~1 degree
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ),

                    // Desktop Navigation
                    if (MediaQuery.of(context).size.width >= 768)
                      Row(
                        children: [
                          ...menuItems.map((item) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextButton(
                                  onPressed: () => widget.onNavigate(item['id']!),
                                  style: TextButton.styleFrom(
                                    foregroundColor: widget.currentPage == item['id']
                                        ? const Color(0xFFF97316)
                                        : const Color(0xFF374151),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  child: Text(item['label']!),
                                ),
                              )),
                          const SizedBox(width: 16),
                                        _buildCountrySelector(),
                          const SizedBox(width: 16),
                          if (widget.isLoggedIn)
                            _buildUserMenu()
                          else
                            _buildLoginButton(),
                        ],
                      ),

                    // Mobile menu button and country selector
                    if (MediaQuery.of(context).size.width < 768)
                      Row(
                        children: [
                          _buildCountrySelector(),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              // Trouver le Scaffold parent et ouvrir le drawer
                              final scaffoldState = context.findAncestorStateOfType<ScaffoldState>();
                              scaffoldState?.openDrawer();
                            },
                            icon: const Icon(Icons.menu),
                          ),
                        ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      surfaceTintColor: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'profile':
            widget.onNavigate('profile');
            break;
          case 'dashboard':
            widget.onNavigate('dashboard');
            break;
          // case 'affiliate':
          //   widget.onNavigate('affiliate');
          //   break;
             case 'wallet':
      widget.onNavigate('wallet');
      break;
          case 'logout':
            widget.onLogout();
            break;
        }
      },
      color: Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Text('Mon profil'),
        ),
        PopupMenuItem(
          value: 'dashboard',
          child: Text('Tableau de bord'),
        ),
        // PopupMenuItem(
        //   value: 'affiliate',
        //   child: Text('Affiliation'),
        // ),
          PopupMenuItem(
          value: 'wallet',
          child: Text('Mon Portefeuille TAKA'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Text('Se déconnecter', style: TextStyle(color: Colors.red)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 16, color: Color(0xFF374151)),
            const SizedBox(width: 8),
            Text(
              widget.user?.name.split(' ').first ?? 'Utilisateur',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
      children: [
            // Header du drawer
        Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF97316),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/logo.jpeg",
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'TAKA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...menuItems.map((item) => ListTile(
                        leading: Icon(
                          _getIconForMenuItem(item['id']!),
                          color: widget.currentPage == item['id']
                              ? const Color(0xFFF97316)
                              : const Color(0xFF6B7280),
                        ),
                        title: Text(
                          item['label']!,
                          style: TextStyle(
                            color: widget.currentPage == item['id']
                                ? const Color(0xFFF97316)
                                : const Color(0xFF374151),
                            fontWeight: widget.currentPage == item['id']
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onNavigate(item['id']!);
                        },
                      )),
                  const Divider(),
                  // Section utilisateur
                  if (widget.isLoggedIn) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
          child: Text(
            'Connecté en tant que ${widget.user?.name.split(' ').first}',
            style: const TextStyle(
                          fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF374151)),
                      title: const Text('Mon profil'),
                      onTap: () {
                        Navigator.pop(context);
                  widget.onNavigate('profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard, color: Color(0xFF374151)),
                      title: const Text('Tableau de bord'),
                      onTap: () {
                        Navigator.pop(context);
                  widget.onNavigate('dashboard');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF374151)),
                      title: const Text('Mon Portefeuille TAKA'),
                      onTap: () {
                        Navigator.pop(context);
                  widget.onNavigate('wallet');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Se déconnecter',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onLogout();
                      },
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildLoginButton(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMenuItem(String id) {
    switch (id) {
      case 'home':
        return Icons.home;
      case 'explore':
        return Icons.book;
      case 'publish':
        return Icons.edit;
      case 'subscription':
        return Icons.star;
      default:
        return Icons.menu;
    }
  }

  Widget _buildLoginButton() {
    return ElevatedButton.icon(
      onPressed: () => widget.onNavigate('login'),
      icon: const Icon(Icons.person, size: 16),
      label: const Text('Se connecter'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}