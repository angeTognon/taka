import 'dart:async';
import 'package:taka2/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'package:taka2/models/user_model.dart';
import 'package:taka2/screens/reader_screen.dart';
import 'package:taka2/screens/book_detail_screen.dart';
import 'package:taka2/widgets/const.dart';
import 'package:taka2/widgets/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ExploreScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Function(String, [Map<String, dynamic>?]) onNavigate;
  final UserModel? user;

  const ExploreScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    required this.user,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchTerm = '';
  String viewMode = 'grid';
  String selectedGenre = 'Tous';
  String selectedLanguage = 'Toutes';
  String selectedCountry = 'Tous';
  String priceFilter = 'all';
  String sortBy = 'recent';

  final List<String> genres = [
    'Tous',
    'Argent & Richesse',
    'Business & Entrepreneuriat',
    'Leadership & Pouvoir',
    'Psychologie & Comportement humain',
    'Spiritualité & Conscience',
    'Philosophie & Sagesse',
    'Histoire & Géopolitique',
    'Sociétés & Civilisations',
    'Science & Connaissance',
    'Développement personnel',
    'Relations & Sexualité',
    'Politique & Stratégie',
    'Ésotérisme & Savoirs cachés',
    'Religion & Textes sacrés',
    'Afrique & Identité',
    'Livres rares & interdits',
  ];
  final List<String> languages = [
    'Toutes',
    'Français',
    'Anglais',
    'Arabe',
    'Swahili',
    'Wolof',
    'Hausa',
  ];
  Future<Map<String, dynamic>> fetchBooks({
    String search = '',
    String genre = 'Tous',
    String language = 'Toutes',
    String country = 'Tous',
    String price = 'all',
    String sort = 'recent',
    int page = 1,
    int perPage = 8,
  }) async {
    final Map<String, String> queryParams = {
      if (search.isNotEmpty) 'search': search,
      if (genre != 'Tous') 'genre': genre,
      if (language != 'Toutes') 'language': language,
      if (country != 'Tous') 'country': country,
      'sort': sort,
      'page': '$page',
      'per_page': '$perPage', // Utiliser le paramètre perPage
    };

    final uri = Uri.parse(
      '$baseUrl/taka_api_books.php',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    return jsonDecode(response.body);
  }

  List<Map<String, dynamic>> books = [];
  int totalBooks = 0;
  int currentPage = 1;
  int perPage = 8;
  bool isLoading = false;
  List<int> purchasedBookIds = [];

  // Variables pour détecter les changements de filtres
  String _lastSearchTerm = '';
  String _lastSelectedGenre = '';
  String _lastSelectedLanguage = '';
  String _lastSelectedCountry = '';
  String _lastPriceFilter = '';
  String _lastSortBy = '';

  // Timer pour debounce de la recherche
  Timer? _searchDebounce;

  void loadBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Toujours utiliser la pagination côté serveur pour optimiser les performances
      final data = await fetchBooks(
        search: searchTerm,
        genre: selectedGenre,
        language: selectedLanguage,
        country: selectedCountry,
        price: priceFilter,
        sort: sortBy,
        page: currentPage,
        perPage: perPage,
      );

      List<Map<String, dynamic>> fetchedBooks = List<Map<String, dynamic>>.from(
        data['books'] ?? [],
      );

      // Filtrage côté client si nécessaire (pour le filtre de prix qui n'est peut-être pas géré côté serveur)
      books = _filterBooksByPrice(fetchedBooks, priceFilter);

      // Récupérer le total depuis l'API si disponible, sinon utiliser la longueur de la liste
      totalBooks =
          int.tryParse(data['total']?.toString() ?? '0') ??
          (currentPage == 1 ? books.length : totalBooks);

      // Mettre à jour les filtres sauvegardés si les filtres ont changé
      if (_filtersChanged()) {
        _updateLastFilters();
      }
    } catch (e) {
      print('Erreur lors du chargement des livres: $e');
      setState(() {
        books = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _filtersChanged() {
    return _lastSearchTerm != searchTerm ||
        _lastSelectedGenre != selectedGenre ||
        _lastSelectedLanguage != selectedLanguage ||
        _lastSelectedCountry != selectedCountry ||
        _lastPriceFilter != priceFilter ||
        _lastSortBy != sortBy;
  }

  void _updateLastFilters() {
    _lastSearchTerm = searchTerm;
    _lastSelectedGenre = selectedGenre;
    _lastSelectedLanguage = selectedLanguage;
    _lastSelectedCountry = selectedCountry;
    _lastPriceFilter = priceFilter;
    _lastSortBy = sortBy;
  }

  List<Map<String, dynamic>> _filterBooksByPrice(
    List<Map<String, dynamic>> books,
    String priceFilter,
  ) {
    return books.where((book) {
      final String priceType =
          book['price_type']?.toString().toLowerCase() ?? '';
      final String priceStr = book['price']?.toString() ?? '';
      final double? price = double.tryParse(priceStr);

      if (priceFilter == 'free') {
        // Livres gratuits : price_type = 'gratuit' OU price = 0 OU price = null
        return priceType == 'gratuit' ||
            price == 0 ||
            price == null ||
            priceStr.isEmpty;
      } else if (priceFilter == 'paid') {
        // Livres payants : price > 0 ET price_type != 'gratuit'
        return price != null && price > 0 && priceType != 'gratuit';
      }

      return true; // 'all' - pas de filtre
    }).toList();
  }

  final TextEditingController _affiliateRefController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBooks();
    if (widget.isLoggedIn && widget.user != null) {
      fetchPurchasedBooks(widget.user!.id);
    }
    final uri = Uri.base;
    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      _affiliateRefController.text = ref;
    }
    print(_affiliateRefController.text);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _affiliateRefController.dispose();
    super.dispose();
  }

  Future<void> fetchPurchasedBooks(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_user_books.php?user_id=$userId'),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['books'] is List) {
      setState(() {
        purchasedBookIds = List<int>.from(
          data['books'].map((e) => int.tryParse(e.toString()) ?? 0),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: isMobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile: true),
              const SizedBox(height: 16),
              _buildSearchBar(isMobile: true),
              const SizedBox(height: 16),
              _buildFilters(isMobile: true),
              const SizedBox(height: 16),
              _buildSortAndViewControls(isMobile: true),
              const SizedBox(height: 12),
              _buildResultsCount(),
              const SizedBox(height: 8),
              _buildBooksGrid(isMobile: true),
              const SizedBox(height: 24),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 100),
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isMobile: false),
            const SizedBox(height: 32),
            _buildSearchBar(isMobile: false),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width >= 1024) ...[
                  SizedBox(width: 256, child: _buildFilters(isMobile: false)),
                  const SizedBox(width: 32),
                ],
                Expanded(
                  child: Column(
                    children: [
                      _buildSortAndViewControls(isMobile: false),
                      const SizedBox(height: 24),
                      _buildResultsCount(),
                      const SizedBox(height: 16),
                      _buildBooksGrid(isMobile: false),
                      const SizedBox(height: 48),
                      _buildPagination(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explorer les livres',
          style: TextStyle(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: "PBold",
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Découvrez la richesse de la littérature africaine',
          style: TextStyle(
            fontSize: isMobile ? 13 : 16,
            color: Color(0xFF6B7280),
            fontFamily: "PRegular",
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchTerm = value;
            currentPage = 1;
          });

          // Debounce : annuler le timer précédent
          _searchDebounce?.cancel();

          // Créer un nouveau timer qui attend 500ms avant de charger
          _searchDebounce = Timer(const Duration(milliseconds: 500), () {
            loadBooks();
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher par titre, auteur, mot-clé...',
          hintStyle: TextStyle(
            fontFamily: "PRegular",
            fontSize: isMobile ? 13 : 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: isMobile ? 20 : 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(isMobile ? 8 : 12)),
            borderSide: BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(isMobile ? 8 : 12)),
            borderSide: BorderSide(color: Color(0xFFF97316), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isMobile ? 8 : 12,
          ),
        ),
        style: TextStyle(fontFamily: "PRegular", fontSize: isMobile ? 13 : 15),
      ),
    );
  }

  Widget _buildFilters({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Color(0xFF6B7280),
                size: isMobile ? 18 : 24,
              ),
              SizedBox(width: 8),
              Text(
                'Filtres',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          _buildFilterSection('Genre', genres, selectedGenre, (value) {
            setState(() {
              selectedGenre = value;
              currentPage = 1;
            });
            loadBooks();
          }, isMobile: isMobile),
          SizedBox(height: isMobile ? 16 : 24),
          _buildFilterSection('Langue', languages, selectedLanguage, (value) {
            setState(() {
              selectedLanguage = value;
              currentPage = 1;
            });
            loadBooks();
          }, isMobile: isMobile),
          SizedBox(height: isMobile ? 16 : 24),
          _buildPriceFilter(isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selected,
    Function(String) onChanged, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: "PBold",
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          initialValue: selected,
          onChanged: (value) => onChanged(value!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(isMobile ? 8 : 12),
              ),
              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(isMobile ? 8 : 12),
              ),
              borderSide: BorderSide(color: Color(0xFFF97316), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isMobile ? 6 : 8,
            ),
          ),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontFamily: "PRegular",
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prix',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: "PBold",
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Column(
          children: [
            RadioListTile<String>(
              title: Text(
                'Tous',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontFamily: "PRegular",
                ),
              ),
              value: 'all',
              groupValue: priceFilter,
              onChanged: (value) {
                setState(() {
                  priceFilter = value!;
                  currentPage = 1;
                });
                loadBooks();
              },
              activeColor: const Color(0xFFF97316),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: Text(
                'Gratuit',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontFamily: "PRegular",
                ),
              ),
              value: 'free',
              groupValue: priceFilter,
              onChanged: (value) {
                setState(() {
                  priceFilter = value!;
                  currentPage = 1;
                });
                loadBooks();
              },
              activeColor: const Color(0xFFF97316),
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<String>(
              title: Text(
                'Payant',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontFamily: "PRegular",
                ),
              ),
              value: 'paid',
              groupValue: priceFilter,
              onChanged: (value) {
                setState(() {
                  priceFilter = value!;
                  currentPage = 1;
                });
                loadBooks();
              },
              activeColor: const Color(0xFFF97316),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortAndViewControls({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Trier par:',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                  fontSize: isMobile ? 13 : 15,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              DropdownButton<String>(
                value: sortBy,
                onChanged: (value) {
                  setState(() {
                    sortBy = value!;
                    currentPage = 1;
                  });
                  loadBooks();
                },
                items: const [
                  DropdownMenuItem(
                    value: 'recent',
                    child: Text(
                      'Nouveautés',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'title',
                    child: Text(
                      'Titre',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Affichage:',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: isMobile ? 13 : 14,
                  fontFamily: "PRegular",
                ),
              ),
              SizedBox(width: isMobile ? 4 : 8),
              IconButton(
                onPressed: () => setState(() => viewMode = 'grid'),
                icon: Icon(
                  Icons.grid_view,
                  color: viewMode == 'grid'
                      ? Colors.white
                      : const Color(0xFF6B7280),
                  size: isMobile ? 18 : 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: viewMode == 'grid'
                      ? const Color(0xFFF97316)
                      : const Color(0xFFF3F4F6),
                ),
              ),
              isMobile
                  ? SizedBox()
                  : IconButton(
                      onPressed: () => setState(() => viewMode = 'list'),
                      icon: Icon(
                        Icons.list,
                        color: viewMode == 'list'
                            ? Colors.white
                            : const Color(0xFF6B7280),
                        size: isMobile ? 18 : 22,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: viewMode == 'list'
                            ? const Color(0xFFF97316)
                            : const Color(0xFFF3F4F6),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCount() {
    return Text(
      isLoading ? 'Chargement...' : '$totalBooks livres trouvés',
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 16,
        fontFamily: "PRegular",
      ),
    );
  }

  Widget _buildBooksGrid({required bool isMobile}) {
    // List<Map<String, dynamic>> paginatedBooks = books.skip((currentPage - 1) * perPage).take(perPage).toList();
    List<Map<String, dynamic>> paginatedBooks = books;

    if (isLoading) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Chargement des livres...',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: "PRegular",
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<String>(
      valueListenable: currencyNotifier,
      builder: (context, currency, _) {
        String formatPrice(String price, String priceType) {
          if (priceType.toLowerCase() == 'gratuit') return 'Gratuit';

          final double p = double.tryParse(price) ?? 0;
          const Map<String, double> conversionRates = {
            'EUR': 655.0,
            'USD': 600.0,
            'GBP': 770.0,
            'JPY': 4.5,
            'CNY': 85.0,
            'INR': 7.3,
            'RUB': 6.5,
            'KRW': 0.45,
            'NGN': 1.3,
            'GNF': 0.07,
            'MAD': 60.0,
            'DZD': 45.0,
            'CAD': 440.0,
            'AUD': 390.0,
            'NZD': 370.0,
            'CHF': 670.0,
            'ZAR': 32.0,
            'EGP': 20.0,
            'KES': 5.0,
            'GHS': 50.0,
            'MXN': 35.0,
            'ARS': 0.7,
            'CLP': 0.65,
            'COP': 0.15,
            'PEN': 160.0,
            'TRY': 22.0,
            'SAR': 160.0,
            'AED': 163.0,
            'QAR': 165.0,
            'KWD': 1950.0,
            'BHD': 1590.0,
            'PKR': 2.2,
            'THB': 17.0,
            'VND': 0.025,
            'IDR': 0.04,
            'MYR': 130.0,
            'SGD': 440.0,
            'HKD': 77.0,
            'TWD': 19.0,
            'PLN': 145.0,
            'SEK': 59.0,
            'NOK': 56.0,
            'DKK': 88.0,
            'CZK': 27.0,
            'HUF': 1.8,
            'RON': 133.0,
            'UAH': 16.0,
            'ILS': 165.0,
            'IRR': 0.014,
            'IQD': 0.46,
            'ETB': 11.0,
            'TZS': 0.24,
            'UGX': 0.16,
            'RWF': 0.49,
            'MGA': 0.13,
            'ZMW': 36.0,
            'BWP': 44.0,
            'AOA': 1.2,
            'XPF': 5.5,
            'FJD': 270.0,
          };

          double rate = conversionRates[currency.toUpperCase()] ?? 1.0;
          switch (currency.toUpperCase()) {
            case 'EUR':
              return '${(p / conversionRates['EUR']!).toStringAsFixed(2)} €';
            case 'USD':
              return '${(p / conversionRates['USD']!).toStringAsFixed(2)} \$';
            case 'GBP':
              return '${(p / conversionRates['GBP']!).toStringAsFixed(2)} £';
            case 'JPY':
              return '${(p / conversionRates['JPY']!).toStringAsFixed(0)} ¥';
            case 'CNY':
              return '${(p / conversionRates['CNY']!).toStringAsFixed(2)} ¥';
            case 'XOF':
            case 'XAF':
              return '${p.toStringAsFixed(0)} FCFA';
            default:
              return '${(p / rate).toStringAsFixed(2)} $currency';
          }
        }

        if (viewMode == 'grid') {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile
                  ? 1
                  : MediaQuery.of(context).size.width >= 1280
                  ? 4
                  : MediaQuery.of(context).size.width >= 768
                  ? 3
                  : MediaQuery.of(context).size.width >= 640
                  ? 2
                  : 1,
              crossAxisSpacing: isMobile ? 12 : 24,
              mainAxisSpacing: isMobile ? 12 : 24,
              childAspectRatio: isMobile ? 0.7 : 0.45,
            ),
            itemCount: paginatedBooks.length,
            itemBuilder: (context, index) {
              final book = paginatedBooks[index];
              final String price = book['price']?.toString() ?? '';
              final String priceType = book['price_type']?.toString() ?? '';
              return _buildBookCardWithCurrency(
                book,
                formatPrice(price, priceType),
              );
            },
          );
        } else {
          return Column(
            children: paginatedBooks
                .map(
                  (book) => Padding(
                    padding: EdgeInsets.only(bottom: isMobile ? 8 : 16),
                    child: _buildBookListItemWithCurrency(
                      book,
                      formatPrice(
                        book['price']?.toString() ?? '',
                        book['price_type']?.toString() ?? '',
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        }
      },
    );
  }

  Future<void> startBookPurchasePolling(int bookId) async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/check_book_payment_status.php?user_id=${widget.user?.id}&book_id=$bookId',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'paid') {
        timer.cancel();
        await fetchPurchasedBooks(widget.user!.id);
        setState(() {}); // Force le rebuild pour mettre à jour le bouton
      }
    });
  }

  Widget _buildBookListItemWithCurrency(
    Map<String, dynamic> book,
    String displayPrice,
  ) {
    final int bookId = book['id'] is int
        ? book['id']
        : int.tryParse('${book['id']}') ?? 0;
    final bool isPurchased = purchasedBookIds.contains(bookId);

    final String title = book['title']?.toString() ?? '';
    final String author = book['author']?.toString() ?? '';
    final String description =
        book['description']?.toString() ?? book['summary']?.toString() ?? '';
    final String genre = book['genre']?.toString() ?? '';
    final String country = book['country']?.toString() ?? '';
    final String priceType = book['price_type'] != null
        ? book['price_type'].toString()
        : '';

    final int pages = book['pages'] is int
        ? book['pages']
        : int.tryParse('${book['pages'] ?? '0'}') ?? 0;
    final double rating = book['rating'] is double
        ? book['rating']
        : (book['rating'] is int
              ? (book['rating'] as int).toDouble()
              : double.tryParse('${book['rating'] ?? '0'}') ?? 0.0);
    final bool isBestseller = book['isBestseller'] == true;

    final String? coverPath = book['cover_path']?.toString();
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (imageUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 112,
                  color: const Color(0xFFE5E7EB),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 112,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Color(0xFFE5E7EB),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFF97316),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Color(0xFFE5E7EB),
                      child: const Icon(
                        Icons.error,
                        size: 48,
                        color: Color.fromARGB(255, 220, 11, 11),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, size: 32, color: Color(0xFF9CA3AF)),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: "PBold",
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            author,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: "PRegular",
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: "PRegular",
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 16,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  genre,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontFamily: "PRegular",
                                  ),
                                ),
                              ),
                              Text(
                                country,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "PRegular",
                                ),
                              ),
                              Text(
                                '$pages pages',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "PRegular",
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: priceType == 'gratuit'
                                              ? const Color.fromARGB(
                                                  255,
                                                  0,
                                                  159,
                                                  56,
                                                )
                                              : const Color.fromARGB(
                                                  255,
                                                  223,
                                                  46,
                                                  10,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          priceType.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: priceType == 'gratuit'
                                                ? const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255,
                                                  )
                                                : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                            fontFamily: "PBold",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    displayPrice,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 8, 133, 25),
                                      fontFamily: "PBold",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (isBestseller)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Best-seller',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: "PBold",
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              book: book,
                              isLoggedIn: widget.isLoggedIn,
                              user: widget.user,
                              onNavigate: widget.onNavigate,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF97316),
                        side: const BorderSide(color: Color(0xFFF97316)),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Détails',
                        style: TextStyle(fontFamily: "PRegular"),
                      ),
                    ),

                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (priceType == 'gratuit' || isPurchased) {
                          widget.onNavigate('reader', book);
                        } else {
                          await handleBookPurchase(book);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: "PBold",
                        ),
                      ),
                      child: Text(
                        (priceType == 'gratuit' || isPurchased)
                            ? 'Lire'
                            : 'Acheter',
                        style: const TextStyle(fontFamily: "PRegular"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bouton share
                    Material(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _shareBook(context, book),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.share,
                            color: Color(0xFFF97316),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCardWithCurrency(
    Map<String, dynamic> book,
    String displayPrice,
  ) {
    // Copie de _buildBookCard, mais remplace l'affichage du prix par displayPrice
    final int bookId = book['id'] is int
        ? book['id']
        : int.tryParse('${book['id']}') ?? 0;
    final bool isPurchased = purchasedBookIds.contains(bookId);

    final String title = book['title'] as String? ?? '';
    final String author = book['author'] as String? ?? '';
    final String description = book['summary'] as String? ?? '';
    final String genre = book['genre'] as String? ?? '';
    final String country = book['country'] as String? ?? '';
    final String priceType = book['price_type'] != null
        ? book['price_type'].toString()
        : '';
    final int pages = book['pages'] is int
        ? book['pages']
        : int.tryParse('${book['pages'] ?? '0'}') ?? 0;
    final double rating = book['rating'] is double
        ? book['rating']
        : (book['rating'] is int
              ? (book['rating'] as int).toDouble()
              : double.tryParse('${book['rating'] ?? '0'}') ?? 0.0);
    final bool isBestseller = book['isBestseller'] == true;

    final String? coverPath = book['cover_path'] as String?;
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Color(0xFFE5E7EB),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF97316),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Color(0xFFE5E7EB),
                              child: const Center(
                                child: Icon(
                                  Icons.book,
                                  size: 48,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Color(0xFFE5E7EB),
                            child: const Center(
                              child: Icon(
                                Icons.book,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        if (isBestseller)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Best-seller',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: "PBold",
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priceType == 'gratuit'
                                ? const Color.fromARGB(255, 0, 159, 56)
                                : const Color.fromARGB(255, 223, 46, 10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            priceType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: priceType == 'gratuit'
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 255, 255, 255),
                              fontFamily: "PBold",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Icon(
                      Icons.favorite_border,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "PBold",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: "PRegular",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "PBold",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 8, 133, 25),
                          fontFamily: "PBold",
                        ),
                      ),
                      Text(
                        '$pages pages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailScreen(
                                  book: book,
                                  isLoggedIn: widget.isLoggedIn,
                                  user: widget.user,
                                  onNavigate: widget.onNavigate,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF97316),
                            side: const BorderSide(color: Color(0xFFF97316)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Détails',
                            style: TextStyle(fontFamily: "PRegular"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (priceType == 'gratuit' || isPurchased) {
                              widget.onNavigate('reader', book);
                            } else {
                              await handleBookPurchase(book);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "PBold",
                            ),
                          ),
                          child: Text(
                            (priceType == 'gratuit' || isPurchased)
                                ? 'Lire'
                                : 'Acheter',
                            style: const TextStyle(fontFamily: "PRegular"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bouton share
                      Material(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => _shareBook(context, book),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.share,
                              color: Color(0xFFF97316),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final int bookId = book['id'] is int
        ? book['id']
        : int.tryParse('${book['id']}') ?? 0;
    final bool isPurchased = purchasedBookIds.contains(bookId);

    final String title = book['title'] as String? ?? '';
    final String author = book['author'] as String? ?? '';
    final String description = book['summary'] as String? ?? '';
    final String genre = book['genre'] as String? ?? '';
    final String country = book['country'] as String? ?? '';
    final String price = book['price'] != null ? book['price'].toString() : '';
    final String priceType = book['price_type'] != null
        ? book['price_type'].toString()
        : '';
    final int pages = book['pages'] is int
        ? book['pages']
        : int.tryParse('${book['pages'] ?? '0'}') ?? 0;
    final double rating = book['rating'] is double
        ? book['rating']
        : (book['rating'] is int
              ? (book['rating'] as int).toDouble()
              : double.tryParse('${book['rating'] ?? '0'}') ?? 0.0);
    final bool isBestseller = book['isBestseller'] == true;

    final String? coverPath = book['cover_path'] as String?;
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Color(0xFFE5E7EB),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF97316),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Color(0xFFE5E7EB),
                              child: const Center(
                                child: Icon(
                                  Icons.book,
                                  size: 48,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Color(0xFFE5E7EB),
                            child: const Center(
                              child: Icon(
                                Icons.book,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        if (isBestseller)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Best-seller',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: "PBold",
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priceType == 'gratuit'
                                ? const Color.fromARGB(255, 0, 159, 56)
                                : const Color.fromARGB(255, 223, 46, 10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            priceType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: priceType == 'gratuit'
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color.fromARGB(255, 255, 255, 255),
                              fontFamily: "PBold",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Icon(
                      Icons.favorite_border,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: "PBold",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: "PRegular",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "PBold",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price.isNotEmpty ? '$price FCFA' : 'Gratuit',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 8, 133, 25),
                          fontFamily: "PBold",
                        ),
                      ),
                      Text(
                        '$pages pages',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailScreen(
                                  book: book,
                                  isLoggedIn: widget.isLoggedIn,
                                  user: widget.user,
                                  onNavigate: widget.onNavigate,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF97316),
                            side: const BorderSide(color: Color(0xFFF97316)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Détails',
                            style: TextStyle(fontFamily: "PRegular"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            print('🔘 Bouton Acheter cliqué');
                            print('💰 Type de prix: $priceType');
                            print('✅ Déjà acheté: $isPurchased');
                            print('🔐 Connecté: ${widget.isLoggedIn}');

                            if (priceType == 'gratuit' || isPurchased) {
                              print('📖 Navigation directe vers le lecteur');
                              widget.onNavigate('reader', book);
                            } else {
                              if (!widget.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Veuillez vous connecter pour acheter ce livre.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              final paid = await processBookPayment(
                                context,
                                book,
                              );
                              if (paid) {
                                final userId = int.tryParse(
                                  widget.user?.id ?? '',
                                );
                                if (userId != null && bookId != 0) {
                                  await addBookPurchase(userId, bookId);
                                  setState(() {
                                    purchasedBookIds.add(bookId);
                                  });
                                }
                                widget.onNavigate('reader', book);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "PBold",
                            ),
                          ),
                          child: Text(
                            (priceType == 'gratuit' || isPurchased)
                                ? 'Lire'
                                : 'Acheter',
                            style: const TextStyle(fontFamily: "PRegular"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bouton share
                      Material(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => _shareBook(context, book),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.share,
                              color: Color(0xFFF97316),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addBookPurchase(int userId, int bookId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taka_api_purchase.php'),
      body: {'user_id': userId.toString(), 'book_id': bookId.toString()},
    );
    // Optionnel : vérifier la réponse
  }

  bool isBookPaying = false;

  Future<void> handleBookPurchase(Map<String, dynamic> book) async {
    if (!widget.isLoggedIn || widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour acheter ce livre.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String? bookId = book['id']?.toString();
    final String? priceStr = book['price']?.toString();
    final int? amount = int.tryParse(priceStr ?? '');
    final String? email = widget.user?.email;
    final String? name = widget.user?.name;

    // Gestion plus flexible des noms
    String firstName = '';
    String lastName = '';

    if (name != null && name.trim().isNotEmpty) {
      final nameParts = name.trim().split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : nameParts.first;
    } else {
      // Si pas de nom, utiliser l'email comme fallback
      firstName = email?.split('@').first ?? 'Utilisateur';
      lastName = 'TAKA';
    }

    final String? userId = widget.user?.id.toString();
    final String? title = book['title']?.toString();

    print('=== DEBUG ACHAT LIVRE ===');
    print('bookId: $bookId');
    print('priceStr: $priceStr');
    print('amount: $amount');
    print('email: $email');
    print('name: $name');
    print('firstName: $firstName');
    print('lastName: $lastName');
    print('userId: $userId');
    print('title: $title');
    print('========================');

    // Vérification des champs obligatoires avec messages d'erreur spécifiques
    if (amount == null || amount <= 0) {
      setState(() => isBookPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prix du livre invalide.')));
      return;
    }

    if (bookId == null || bookId.isEmpty) {
      setState(() => isBookPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID du livre manquant.')));
      return;
    }

    if (email == null || email.isEmpty) {
      setState(() => isBookPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email utilisateur manquant.')),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      setState(() => isBookPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID utilisateur manquant.')));
      return;
    }

    if (title == null || title.isEmpty) {
      setState(() => isBookPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Titre du livre manquant.')));
      return;
    }

    setState(() => isBookPaying = true);
    print('🔄 Début du processus de paiement...');

    try {
      // Récupérer la devise et le pays sélectionnés par l'utilisateur
      print('📱 Récupération des préférences...');
      final prefs = await SharedPreferences.getInstance();
      final selectedCurrency = prefs.getString('currency') ?? 'XOF';
      final selectedCountry = prefs.getString('country') ?? 'Bénin';
      print('💰 Devise sélectionnée: $selectedCurrency');
      print('🌍 Pays sélectionné: $selectedCountry');

      print('🌐 Préparation de la requête API...');
      final response = await http.post(
        Uri.parse('$baseUrl/moneroo_init_book.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': selectedCurrency,
          'country': selectedCountry,
          'description': 'Achat livre: $title',
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'user_id': userId,
          'book_id': bookId,
          'return_url': 'https://takaafrica.com',
          if (_affiliateRefController.text.isNotEmpty)
            'ref': _affiliateRefController.text,
        }),
      );

      print('📡 Réponse reçue - Status: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      final data = jsonDecode(response.body);
      print('📊 Données décodées: $data');

      if (data['checkout_url'] != null) {
        final url = data['checkout_url'];
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
          await waitForBookPayment(bookId);
          startBookPurchasePolling(int.tryParse(bookId.toString()) ?? 0);
        } else {
          setState(() => isBookPaying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d’ouvrir le paiement')),
          );
        }
      } else {
        setState(() => isBookPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'initialisation du paiement'),
          ),
        );
      }
    } catch (e) {
      setState(() => isBookPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
    }
  }

  Future<void> waitForBookPayment(dynamic bookId) async {
    bool paid = false;
    int maxTries = 60; // 1 minute max
    int tries = 0;
    Timer? timer;

    setState(() => isBookPaying = true);

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      tries++;
      final response = await http.get(
        Uri.parse(
          '$baseUrl/check_book_payment_status.php?user_id=${widget.user?.id}&book_id=$bookId',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'paid') {
        paid = true;
        timer?.cancel();
        setState(() => isBookPaying = false);
        // Recharge la liste et rafraîchis l'UI
        await fetchPurchasedBooks(widget.user!.id);
        setState(() {}); // Force le rebuild pour mettre à jour les boutons
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paiement validé !')));
      } else if (tries >= maxTries) {
        timer?.cancel();
        setState(() => isBookPaying = false);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Paiement non validé ou annulé.')),
        // );
      }
    });
  }

  Future<bool> processBookPayment(
    BuildContext context,
    Map<String, dynamic> book,
  ) async {
    print('🚀 processBookPayment appelée');
    print('📚 Livre: ${book['title']}');

    final String? bookId = book['id']?.toString();
    final String? priceStr = book['price']?.toString();
    final int? amount = int.tryParse(priceStr ?? '');
    final String? email = widget.user?.email;
    final String? name = widget.user?.name;
    final String firstName = name != null && name.trim().isNotEmpty
        ? name.trim().split(' ').first
        : '';
    final String lastName = name != null && name.trim().split(' ').length > 1
        ? name.trim().split(' ').sublist(1).join(' ')
        : '';
    final String? userId = widget.user?.id.toString();
    final String? title = book['title']?.toString();

    if (amount == null ||
        amount <= 0 ||
        bookId == null ||
        bookId.isEmpty ||
        email == null ||
        email.isEmpty ||
        userId == null ||
        userId.isEmpty ||
        firstName == null ||
        firstName.isEmpty ||
        lastName == null ||
        lastName.isEmpty ||
        title == null ||
        title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations manquantes pour le paiement.'),
        ),
      );
      return false;
    }

    try {
      // Récupérer la devise et le pays sélectionnés par l'utilisateur
      final prefs = await SharedPreferences.getInstance();
      final selectedCurrency = prefs.getString('currency') ?? 'XOF';
      final selectedCountry = prefs.getString('country') ?? 'Bénin';

      final response = await http.post(
        Uri.parse('$baseUrl/moneroo_init_book.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': selectedCurrency,
          'country': selectedCountry,
          'description': 'Achat livre: $title',
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'user_id': userId,
          'book_id': bookId,
          'return_url': 'https://takaafrica.com',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['checkout_url'] != null) {
        final url = data['checkout_url'];
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir le paiement')),
          );
          return false;
        }
      } else {
        // Afficher plus de détails sur l'erreur
        String errorMessage = 'Erreur inconnue';
        if (data['error'] != null) {
          errorMessage = data['error'].toString();
        }
        if (data['details'] != null) {
          errorMessage += '\nDétails: ${data['details'].toString()}';
        }
        if (data['httpcode'] != null) {
          errorMessage += '\nCode HTTP: ${data['httpcode']}';
        }

        print('Erreur de paiement: $data');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $errorMessage'),
            duration: Duration(seconds: 5),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
      return false;
    }
  }

  Widget _buildBookDetailDialog(Map<String, dynamic> book) {
    final String title = book['title'] ?? '';
    final String genre = book['genre'] ?? '';
    final String language = book['language'] ?? '';
    final String summary = book['summary'] ?? '';
    final String authorBio = book['author_bio'] ?? '';
    final String authorLinks = book['author_links'] ?? '';
    final String excerpt = book['excerpt'] ?? '';
    final String quote = book['quote'] ?? '';
    final String plan = book['plan'] ?? '';
    final String priceType = book['price_type']?.toString() ?? '';
    final String price = book['price']?.toString() ?? '';
    final String? coverPath = book['cover_path'] as String?;
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        child: SizedBox(
          width: isMobile ? double.infinity : 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: isMobile ? 120 : 180,
                      height: isMobile ? 160 : 240,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: isMobile ? 120 : 180,
                        height: isMobile ? 160 : 240,
                        color: Color(0xFFE5E7EB),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFF97316),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: isMobile ? 120 : 180,
                        height: isMobile ? 160 : 240,
                        color: Color(0xFFE5E7EB),
                        child: const Icon(
                          Icons.book,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: isMobile ? 10 : 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "PBold",
                ),
                maxLines: isMobile ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Row(
                children: [
                  Chip(
                    label: Text(
                      genre,
                      style: TextStyle(fontSize: isMobile ? 11 : 13),
                    ),
                  ),
                  SizedBox(width: 6),
                  Chip(
                    label: Text(
                      language,
                      style: TextStyle(fontSize: isMobile ? 11 : 13),
                    ),
                  ),
                  SizedBox(width: 6),
                  Chip(
                    label: Text(
                      plan,
                      style: TextStyle(fontSize: isMobile ? 11 : 13),
                    ),
                  ),
                  SizedBox(width: 6),
                  Chip(
                    label: Text(
                      priceType == 'gratuit' ? 'Gratuit' : '$price FCFA',
                      style: TextStyle(fontSize: isMobile ? 11 : 13),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 10 : 16),
              if (summary.isNotEmpty) ...[
                Text(
                  'Résumé',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  summary,
                  style: TextStyle(
                    fontFamily: "PRegular",
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 4 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: isMobile ? 8 : 12),
              ],
              if (authorBio.isNotEmpty) ...[
                Text(
                  'Bio de l\'auteur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  authorBio,
                  style: TextStyle(
                    fontFamily: "PRegular",
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 3 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: isMobile ? 8 : 12),
              ],
              if (authorLinks.isNotEmpty) ...[
                Text(
                  'Liens auteur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  authorLinks,
                  style: TextStyle(
                    fontFamily: "PRegular",
                    color: Colors.blue,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 2 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: isMobile ? 8 : 12),
              ],
              if (excerpt.isNotEmpty) ...[
                Text(
                  'Extrait',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  excerpt,
                  style: TextStyle(
                    fontFamily: "PRegular",
                    fontStyle: FontStyle.italic,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 3 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: isMobile ? 8 : 12),
              ],
              if (quote.isNotEmpty) ...[
                Text(
                  'Citation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '« $quote »',
                  style: TextStyle(
                    fontFamily: "PRegular",
                    fontStyle: FontStyle.italic,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 2 : null,
                  overflow: isMobile ? TextOverflow.ellipsis : null,
                ),
                SizedBox(height: isMobile ? 8 : 12),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      fontFamily: "PRegular",
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookListItem(Map<String, dynamic> book) {
    final int bookId = book['id'] is int
        ? book['id']
        : int.tryParse('${book['id']}') ?? 0;
    final bool isPurchased = purchasedBookIds.contains(bookId);

    final String title = book['title']?.toString() ?? '';
    final String author = book['author']?.toString() ?? '';
    final String description =
        book['description']?.toString() ?? book['summary']?.toString() ?? '';
    final String genre = book['genre']?.toString() ?? '';
    final String country = book['country']?.toString() ?? '';
    final String price = book['price']?.toString() ?? '';
    final String priceType = book['price_type'] != null
        ? book['price_type'].toString()
        : '';

    final int pages = book['pages'] is int
        ? book['pages']
        : int.tryParse('${book['pages'] ?? '0'}') ?? 0;
    final double rating = book['rating'] is double
        ? book['rating']
        : (book['rating'] is int
              ? (book['rating'] as int).toDouble()
              : double.tryParse('${book['rating'] ?? '0'}') ?? 0.0);
    final bool isBestseller = book['isBestseller'] == true;

    final String? coverPath = book['cover_path']?.toString();
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (imageUrl != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 112,
                  color: const Color(0xFFE5E7EB),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 112,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Color(0xFFE5E7EB),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFF97316),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Color(0xFFE5E7EB),
                      child: const Icon(
                        Icons.error,
                        size: 48,
                        color: Color.fromARGB(255, 220, 11, 11),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, size: 32, color: Color(0xFF9CA3AF)),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: "PBold",
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            author,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: "PRegular",
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontFamily: "PRegular",
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 16,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  genre,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontFamily: "PRegular",
                                  ),
                                ),
                              ),
                              Text(
                                country,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "PRegular",
                                ),
                              ),
                              Text(
                                '$pages pages',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  fontFamily: "PRegular",
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: priceType == 'gratuit'
                                              ? const Color.fromARGB(
                                                  255,
                                                  0,
                                                  159,
                                                  56,
                                                )
                                              : const Color.fromARGB(
                                                  255,
                                                  223,
                                                  46,
                                                  10,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          priceType.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: priceType == 'gratuit'
                                                ? const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255,
                                                  )
                                                : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                            fontFamily: "PBold",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: SizedBox(width: 100)),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BookDetailScreen(
                                                    book: book,
                                                    isLoggedIn:
                                                        widget.isLoggedIn,
                                                    user: widget.user,
                                                    onNavigate:
                                                        widget.onNavigate,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFFF97316,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFF97316),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Détails',
                                          style: TextStyle(
                                            fontFamily: "PRegular",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      ElevatedButton(
                                        onPressed: () async {
                                          if (priceType == 'gratuit' ||
                                              isPurchased) {
                                            widget.onNavigate('reader', book);
                                          } else {
                                            if (!widget.isLoggedIn) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Veuillez vous connecter pour acheter ce livre.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            final paid =
                                                await processBookPayment(
                                                  context,
                                                  book,
                                                );
                                            if (paid) {
                                              final userId = int.tryParse(
                                                widget.user?.id ?? '',
                                              );
                                              if (userId != null &&
                                                  bookId != 0) {
                                                await addBookPurchase(
                                                  userId,
                                                  bookId,
                                                );
                                                setState(() {
                                                  purchasedBookIds.add(bookId);
                                                });
                                              }
                                              widget.onNavigate('reader', book);
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFF97316,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "PBold",
                                          ),
                                        ),
                                        child: Text(
                                          (priceType == 'gratuit' ||
                                                  isPurchased)
                                              ? 'Lire'
                                              : 'Acheter',
                                          style: const TextStyle(
                                            fontFamily: "PRegular",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Bouton share
                                      Material(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(8),
                                        child: InkWell(
                                          onTap: () =>
                                              _shareBook(context, book),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.share,
                                              color: Color(0xFFF97316),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (isBestseller)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Best-seller',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: "PBold",
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final totalPages = (totalBooks / perPage).ceil();
    final showPagination = totalBooks > perPage;

    if (!showPagination) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1 && !isLoading
              ? () {
                  setState(() => currentPage--);
                  loadBooks();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontFamily: "PRegular"),
          ),
          child: const Text('Précédent'),
        ),
        const SizedBox(width: 16),
        Text(
          '$currentPage / $totalPages',
          style: const TextStyle(fontFamily: "PBold", fontSize: 16),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: currentPage < totalPages && !isLoading
              ? () {
                  setState(() => currentPage++);
                  loadBooks();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontFamily: "PRegular"),
          ),
          child: const Text('Suivant'),
        ),
      ],
    );
  }

  // Fonction pour convertir un titre en slug
  String _titleToSlug(String title) {
    // Convertir en minuscules
    String slug = title.toLowerCase();

    // Remplacer les caractères accentués
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

    // Remplacer les caractères spéciaux et espaces par des tirets
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    // Enlever les tirets en début et fin
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    return slug;
  }

  void _shareBook(BuildContext context, Map<String, dynamic> book) {
    final bookTitle = book['title'] ?? '';
    final bookSlug = _titleToSlug(bookTitle);

    // Générer l'URL du livre avec le nom du livre
    String bookUrl;
    if (kIsWeb) {
      // En web, utiliser l'URL actuelle si on est déjà sur la page du livre
      final currentUrl = Uri.base.toString();
      final currentPath = Uri.base.path;

      // Si on est déjà sur une page de livre, utiliser l'URL actuelle
      if (currentPath.contains(bookSlug) ||
          currentPath
              .split('/')
              .any(
                (segment) =>
                    segment.isNotEmpty &&
                    segment != 'home' &&
                    segment != 'explore',
              )) {
        bookUrl = currentUrl.split(
          '?',
        )[0]; // Enlever les query params si présents
      } else {
        // Construire l'URL à partir de l'URL de base
        final baseUri = Uri.base;
        bookUrl =
            '${baseUri.scheme}://${baseUri.host}${baseUri.port != 80 && baseUri.port != 443 ? ':${baseUri.port}' : ''}/$bookSlug';
      }
    } else {
      // Pour mobile/desktop, utiliser une URL par défaut
      // Vous pouvez remplacer ceci par votre domaine réel
      bookUrl = 'https://takaafrica.com/$bookSlug';
    }

    // Copier l'URL dans le presse-papiers
    Clipboard.setData(ClipboardData(text: bookUrl)).then((_) {
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Lien copié !',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "PBold",
                      ),
                    ),
                    Text(
                      'Partagez "$bookTitle"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: "PRegular",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    });
  }
}
