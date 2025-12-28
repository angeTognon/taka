import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:taka2/screens/about_page.dart';
import 'package:taka2/screens/affiliate_page2.dart';
import 'package:taka2/screens/takaadmin.dart';
import 'package:taka2/screens/wallet.dart';
import 'package:taka2/test.dart';
import 'package:taka2/widgets/const.dart';
import 'package:taka2/widgets/footer.dart';
import 'package:taka2/widgets/global.dart';
import 'package:taka2/widgets/header.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/publish_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/affiliate_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/book_detail_screen.dart';
import 'models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Color mainColor = Color(0xFFF97316);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  currencyNotifier.value = prefs.getString('currency') ?? 'XOF';
  runApp(TakaApp());
}

class TakaApp extends StatelessWidget {
  const TakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAKA - Plateforme panafricaine d\'ebooks',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFF97316),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const TakaAdmin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String currentPage = 'home';
  bool isAdminRoute = false;

  bool isLoggedIn = false;
  UserModel? user;

  // Pour gérer les URLs de livres
  bool isBookRoute = false;
  String? bookSlugFromUrl;
  Map<String, dynamic>? bookFromUrl;
  bool isLoadingBook = false;

  Widget? _buildDrawer(BuildContext context, String currentPage) {
    if (MediaQuery.of(context).size.width >= 768) return null;

    final menuItems = [
      {'id': 'home', 'label': 'Accueil'},
      {'id': 'explore', 'label': 'Lire'},
      {'id': 'publish', 'label': 'Publier'},
      {'id': 'subscription', 'label': 'Abonnement'},
    ];

    IconData getIconForMenuItem(String id) {
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

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header du drawer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFF97316)),
              child: Row(
                children: [
                  Image.asset("assets/images/logo.jpeg", height: 40, width: 40),
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
                  ...menuItems.map(
                    (item) => ListTile(
                      leading: Icon(
                        getIconForMenuItem(item['id']!),
                        color: currentPage == item['id']
                            ? const Color(0xFFF97316)
                            : const Color(0xFF6B7280),
                      ),
                      title: Text(
                        item['label']!,
                        style: TextStyle(
                          color: currentPage == item['id']
                              ? const Color(0xFFF97316)
                              : const Color(0xFF374151),
                          fontWeight: currentPage == item['id']
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        handleNavigate(item['id']!);
                      },
                    ),
                  ),
                  const Divider(),
                  // Section utilisateur
                  if (isLoggedIn) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Connecté en tant que ${user?.name.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF374151),
                      ),
                      title: const Text('Mon profil'),
                      onTap: () {
                        Navigator.pop(context);
                        handleNavigate('profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.dashboard,
                        color: Color(0xFF374151),
                      ),
                      title: const Text('Tableau de bord'),
                      onTap: () {
                        Navigator.pop(context);
                        handleNavigate('dashboard');
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF374151),
                      ),
                      title: const Text('Mon Portefeuille TAKA'),
                      onTap: () {
                        Navigator.pop(context);
                        handleNavigate('wallet');
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
                        handleLogout();
                      },
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          handleNavigate('login');
                        },
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Se connecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedUserId = prefs.getString('saved_user_id');
    final savedUserName = prefs.getString('saved_user_name');
    final savedUserCreatedAt = prefs.getString('saved_user_created_at');
    final isLogged = prefs.getBool('is_logged_in') ?? false;

    // Vérification plus robuste de la session
    if (isLogged &&
        savedEmail != null &&
        savedEmail.isNotEmpty &&
        savedUserId != null &&
        savedUserId.isNotEmpty) {
      // Vérifier que l'email a un format valide
      if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(savedEmail)) {
        setState(() {
          isLoggedIn = true;
          // Ne pas changer currentPage si on est sur une route de livre
          if (!isBookRoute) {
            currentPage = 'home';
          }
          user = UserModel(
            id: savedUserId,
            name: savedUserName ?? 'Utilisateur TAKA',
            email: savedEmail,
            createdAt: savedUserCreatedAt ?? '',
          );
        });
      } else {
        // Email invalide, nettoyer la session
        await _clearSessionData();
      }
    } else {
      // Données de session incomplètes, nettoyer
      await _clearSessionData();
    }
  }

  // Fonction utilitaire pour nettoyer les données de session
  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_user_id');
    await prefs.remove('saved_user_name');
    await prefs.remove('saved_user_created_at');
    await prefs.setBool('is_logged_in', false);
  }

  // Fonction pour convertir un titre en slug (identique au PHP)
  String _titleToSlug(String title) {
    String slug = title.toLowerCase();

    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
      'ñ': 'n',
      'ç': 'c',
    };

    accents.forEach((key, value) {
      slug = slug.replaceAll(key, value);
    });

    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    return slug;
  }

  // Fonction pour charger un livre par son slug (nom) - DIRECTEMENT depuis l'API existante
  Future<void> _loadBookBySlug(String bookSlug) async {
    setState(() => isLoadingBook = true);
    print('🔍 Chargement du livre avec slug: $bookSlug');

    try {
      // Utiliser l'API existante qui retourne tous les livres
      final apiUrl =
          '$baseUrl/taka_api_books.php?per_page=1000'; // Charger tous les livres
      print('🌐 URL API: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));

      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('📦 Structure de la réponse: ${data.keys}');

        if (data['books'] != null && data['books'] is List) {
          final List<dynamic> books = data['books'];
          print('✅ ${books.length} livres chargés');

          // Chercher le livre dont le slug correspond
          Map<String, dynamic>? foundBook;
          for (var book in books) {
            final bookTitle = book['title']?.toString() ?? '';
            final bookSlugGenerated = _titleToSlug(bookTitle);

            print('📚 Comparaison: "$bookSlugGenerated" vs "$bookSlug"');

            if (bookSlugGenerated == bookSlug) {
              foundBook = book as Map<String, dynamic>;
              print('✅ Livre trouvé: $bookTitle');
              break;
            }
          }

          if (foundBook != null) {
            setState(() {
              bookFromUrl = foundBook;
              isLoadingBook = false;
            });
          } else {
            print('❌ Aucun livre ne correspond au slug: $bookSlug');
            print('❌ Slugs disponibles:');
            for (var book in books.take(5)) {
              print(
                '   - ${_titleToSlug(book['title'] ?? '')} (${book['title']})',
              );
            }
            setState(() {
              isLoadingBook = false;
              isBookRoute = false;
            });
          }
        } else {
          print('❌ Erreur dans la réponse API - pas de books');
          setState(() {
            isLoadingBook = false;
            isBookRoute = false;
          });
        }
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        setState(() {
          isLoadingBook = false;
          isBookRoute = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du livre: $e');
      setState(() {
        isLoadingBook = false;
        isBookRoute = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Détection de l'URL (Flutter Web uniquement)
    if (kIsWeb) {
      final uri = Uri.base;

      // Vérifier si c'est la route admin
      if (uri.path.contains('/takaadmin')) {
        setState(() {
          isAdminRoute = true;
        });
      }
      // Vérifier si c'est une route de livre : /nom-du-livre/
      else if (uri.pathSegments.isNotEmpty &&
          uri.pathSegments[0].isNotEmpty &&
          ![
            'home',
            'explore',
            'login',
            'profile',
            'dashboard',
            'publish',
            'subscription',
            'affiliate',
            'about',
            'wallet',
          ].contains(uri.pathSegments[0])) {
        final bookSlug = uri.pathSegments[0];
        print('📚 Route de livre détectée: $bookSlug');
        print('📚 URI complet: ${uri.toString()}');
        print('📚 Path segments: ${uri.pathSegments}');
        setState(() {
          isBookRoute = true;
          bookSlugFromUrl = bookSlug;
        });
        _loadBookBySlug(bookSlug);
      } else {
        print('❌ Pas une route de livre');
        print('❌ Path segments: ${uri.pathSegments}');
      }
    }

    _checkRememberMe();
  }

  // Dans MainScreen
  void handleNavigate(String page, [dynamic data]) {
    setState(() {
      currentPage = page;
      if (data != null) selectedBook = data;
      // Sortir du mode "route de livre" quand on navigue
      if (isBookRoute) {
        isBookRoute = false;
        bookFromUrl = null;
        bookSlugFromUrl = null;
      }
    });
  }

  void handleUserUpdate(UserModel updatedUser) {
    setState(() {
      user = updatedUser;
    });
  }

  void handleLogin(UserModel userData) {
    setState(() {
      isLoggedIn = true;
      user = userData;
      currentPage = 'home';
      // Sortir du mode "route de livre" lors de la connexion
      if (isBookRoute) {
        isBookRoute = false;
        bookFromUrl = null;
        bookSlugFromUrl = null;
      }
    });
  }

  void handleLogout() async {
    // Utiliser la fonction utilitaire pour nettoyer les données
    await _clearSessionData();
    setState(() {
      isLoggedIn = false;
      user = null;
      currentPage = 'home';
      // Sortir du mode "route de livre" lors de la déconnexion
      if (isBookRoute) {
        isBookRoute = false;
        bookFromUrl = null;
        bookSlugFromUrl = null;
      }
    });
  }

  Map<String, dynamic>? selectedBook;

  Widget renderCurrentPage() {
    switch (currentPage) {
      case 'home':
        return HomeScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          user: user,
        );
      case 'explore':
        return ExploreScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          user: user,
        );
      case 'reader':
        if (selectedBook != null) {
          print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
          print('File Path:  +  + ${"$baseUrl/" + selectedBook!['file_path']}');
          print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
          return ReaderScreen(
            onNavigate: handleNavigate,
            isLoggedIn: isLoggedIn,
            bookTitle: selectedBook!['title'] ?? '',
            bookAuthor: selectedBook!['author'] ?? '',
            // ignore: prefer_interpolation_to_compose_strings
            filePath: "$baseUrl/" + (selectedBook!['file_path'] ?? ''),
            totalPages: selectedBook!['pages'] ?? 1,
          );
        } else {
          return const Center(child: Text('Aucun livre sélectionné'));
        }
      case 'publish':
        if (user != null) {
          return PublishScreen(
            onNavigate: handleNavigate,
            isLoggedIn: isLoggedIn,
            user: user!,
            bookToEdit: selectedBook, // <-- Utilise selectedBook ici
          );
        } else {
          return LoginScreen(onNavigate: handleNavigate, onLogin: handleLogin);
        }
      case 'wallet':
        return WalletPage(user: user!);
      case 'subscription':
        return SubscriptionScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          user: user,
        );

      // case 'subscription':
      // if (user != null) {
      //   return SubscriptionScreen(
      //     onNavigate: handleNavigate,
      //     isLoggedIn: isLoggedIn,
      //     user: user!,
      //   );
      // } else {
      //   // Redirige vers login si pas connecté
      //   return LoginScreen(onNavigate: handleNavigate, onLogin: handleLogin);
      // }
      case 'dashboard':
        return DashboardScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          user: user,
        );
      // case 'affiliate':
      //   return AffiliatePage(
      //   );
      case 'affiliate':
        return AffiliateScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          userId: user != null ? int.tryParse(user!.id.toString()) ?? 0 : 0,
        );
      case 'about':
        return AboutPage();
      case 'login':
        return LoginScreen(onNavigate: handleNavigate, onLogin: handleLogin);
      case 'profile':
        return ProfileScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          user: user,
          onUserUpdated: handleUserUpdate, // Ajoute ceci
        );
      default:
        return HomeScreen(
          onNavigate: handleNavigate,
          isLoggedIn: isLoggedIn,
          user: user,
        );
    }
  }

  bool get shouldShowHeaderFooter => currentPage != 'reader';

  @override
  Widget build(BuildContext context) {
    if (isAdminRoute) {
      return const TakaAdmin();
    }

    // Si c'est une route de livre, afficher la page de détails
    if (isBookRoute) {
      if (isLoadingBook) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFF97316)),
          ),
        );
      } else if (bookFromUrl != null) {
        return Scaffold(
          backgroundColor: Colors.white,
          drawer: _buildDrawer(context, 'explore'),
          body: Column(
            children: [
              Header(
                currentPage: 'explore',
                onNavigate: handleNavigate,
                isLoggedIn: isLoggedIn,
                user: user,
                onLogout: handleLogout,
              ),
              Expanded(
                child: BookDetailScreen(
                  book: bookFromUrl!,
                  isLoggedIn: isLoggedIn,
                  user: user,
                  onNavigate: handleNavigate,
                  isFromDirectUrl: true,
                ),
              ),
            ],
          ),
        );
      } else {
        // Livre non trouvé, rediriger vers la page d'accueil
        return Scaffold(
          backgroundColor: Colors.white,
          drawer: _buildDrawer(context, currentPage),
          body: Column(
            children: [
              Header(
                currentPage: currentPage,
                onNavigate: handleNavigate,
                isLoggedIn: isLoggedIn,
                user: user,
                onLogout: handleLogout,
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Livre non trouvé',
                    style: TextStyle(fontSize: 18, fontFamily: "PBold"),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: shouldShowHeaderFooter
          ? _buildDrawer(context, currentPage)
          : null,
      body: Column(
        children: [
          if (shouldShowHeaderFooter)
            Header(
              currentPage: currentPage,
              onNavigate: handleNavigate,
              isLoggedIn: isLoggedIn,
              user: user,
              onLogout: handleLogout,
            ),
          Expanded(child: renderCurrentPage()),
          // if (shouldShowHeaderFooter) const Footer(),
        ],
      ),
    );
  }
}
