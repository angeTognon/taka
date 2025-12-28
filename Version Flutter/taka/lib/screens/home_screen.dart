import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taka2/models/user_model.dart';
import 'package:taka2/widgets/const.dart';
import 'package:http/http.dart' as http;
import 'package:taka2/widgets/footer.dart';
import 'package:taka2/widgets/global.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:taka2/screens/book_detail_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  final Function(String, [Map<String, dynamic>?]) onNavigate;
  final bool isLoggedIn;
  final UserModel? user;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownCommunityDialog = false;
  bool rememberMe = false;
  final _emailController = TextEditingController();
  Timer? _periodicTimer;

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

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
    loadTrendingBooks();

    // Rafraîchit la liste des livres achetés toutes les 1 seconde
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.isLoggedIn && widget.user != null) {
        fetchPurchasedBooks(widget.user!.id.toString());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (!_hasShownCommunityDialog) {
      //   _showCommunityDialog(context);
      //   _hasShownCommunityDialog = true;
      // }
    });
    final uri = Uri.base;
    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      _affiliateRefController.text = ref;
    }
    print(_affiliateRefController.text);
  }

  final TextEditingController _affiliateRefController = TextEditingController();
  bool isBookPaying = false;
  Future<void> waitForBookPayment(int bookId) async {
    int tries = 0;
    const maxTries = 60; // 1 minute
    Timer? timer;

    if (mounted) {
      setState(() => isBookPaying = true);
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      tries++;
      final response = await http.get(
        Uri.parse(
          '$baseUrl/check_book_payment_status.php?user_id=${user?.id}&book_id=$bookId',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'paid') {
        timer?.cancel();
        if (mounted) {
          setState(() => isBookPaying = false);
          await fetchPurchasedBooks(
            user!.id,
          ); // recharge la liste des livres achetés
          setState(() {});
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Paiement validé !')));
        }
      } else if (tries >= maxTries) {
        timer?.cancel();
        if (mounted) {
          setState(() => isBookPaying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paiement non validé ou annulé.')),
          );
        }
      }
    });
  }

  Future<void> handleBookPurchase(Map<String, dynamic> book) async {
    if (!widget.isLoggedIn) {
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
    final String firstName = name != null && name.trim().isNotEmpty
        ? name.trim().split(' ').first
        : '';
    final String lastName = name != null && name.trim().split(' ').length > 1
        ? name.trim().split(' ').sublist(1).join(' ')
        : '';
    final String? userId = widget.user?.id.toString();
    final String? title = book['title']?.toString();

    print('bookId: $bookId');
    print('priceStr: $priceStr');
    print('amount: $amount');
    print('email: $email');
    print('name: $name');
    print('firstName: $firstName');
    print('lastName: $lastName');
    print('userId: $userId');
    print('title: $title');
    print(_affiliateRefController.text);

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
      if (mounted) {
        setState(() => isBookPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations manquantes pour le paiement.'),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => isBookPaying = true);
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
          if (_affiliateRefController.text.isNotEmpty)
            'ref': _affiliateRefController.text,
        }),
      );
      final data = jsonDecode(response.body);

      print('Réponse Moneroo: $data');

      // ...dans handleBookPurchase, remplace ceci :
      if (data['checkout_url'] != null) {
        final url = data['checkout_url'];
        print('checkout_url: $url');
        // Ancien code (dialog) :
        // await showPaymentDialog(context, url);
        // await waitForBookPayment(int.parse(bookId));

        // Nouveau code : ouvrir dans un nouvel onglet/fenêtre
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          await waitForBookPayment(int.parse(bookId));
        } else {
          if (mounted) {
            setState(() => isBookPaying = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d\'ouvrir le paiement')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isBookPaying = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
      }
    }
  }

  Future<void> showPaymentDialog(BuildContext context, String url) async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          height: 600,
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  Future<void> fetchPurchasedBooks(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_user_books.php?user_id=$userId'),
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['books'] is List) {
      if (mounted) {
        setState(() {
          purchasedBookIds = List<int>.from(
            data['books'].map((e) => int.tryParse(e.toString()) ?? 0),
          );
        });
      }
    }
  }

  void _showCommunityDialog(BuildContext context) {
    final bool isMobileView = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: isMobileView
              ? MediaQuery.of(context).size.width * 0.95
              : MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rejoins la communauté TAKA !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                    color: Color(0xFFF97316),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                isMobileView
                    ? _buildCommunityLinkMobile(
                        icon: Image.asset(
                          'assets/images/telegram.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Canal TAKA (Telegram)',
                        url: 'https://t.me/takalivresafricains',
                        color: const Color(0xFF229ED9),
                      )
                    : _buildCommunityLink(
                        icon: Image.asset(
                          'assets/images/telegram.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Canal TAKA (Telegram)',
                        url: 'https://t.me/takalivresafricains',
                        color: const Color(0xFF229ED9),
                      ),
                const SizedBox(height: 14),
                isMobileView
                    ? _buildCommunityLinkMobile(
                        icon: Image.asset(
                          'assets/images/whatsapp.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Groupe LECTEURS WhatsApp',
                        url: 'https://chat.whatsapp.com/LvJCVoz7DJR4K8K6sm7rgi',
                        color: const Color(0xFF25D366),
                      )
                    : _buildCommunityLink(
                        icon: Image.asset(
                          'assets/images/whatsapp.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Groupe LECTEURS WhatsApp',
                        url: 'https://chat.whatsapp.com/LvJCVoz7DJR4K8K6sm7rgi',
                        color: const Color(0xFF25D366),
                      ),
                const SizedBox(height: 14),
                isMobileView
                    ? _buildCommunityLinkMobile(
                        icon: Image.asset(
                          'assets/images/whatsapp.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Groupe AUTEURS WhatsApp',
                        url: 'https://chat.whatsapp.com/DCNEoG8uU58HdanJDxIWLS',
                        color: const Color(0xFF25D366),
                      )
                    : _buildCommunityLink(
                        icon: Image.asset(
                          'assets/images/whatsapp.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Groupe AUTEURS WhatsApp',
                        url: 'https://chat.whatsapp.com/DCNEoG8uU58HdanJDxIWLS',
                        color: const Color(0xFF25D366),
                      ),
                const SizedBox(height: 14),
                isMobileView
                    ? _buildCommunityLinkMobile(
                        icon: Image.asset(
                          'assets/images/facebook.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Facebook TAKA',
                        url: 'https://www.facebook.com/takalivresafricains',
                        color: const Color(0xFF1877F2),
                      )
                    : _buildCommunityLink(
                        icon: Image.asset(
                          'assets/images/facebook.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Facebook TAKA',
                        url: 'https://www.facebook.com/takalivresafricains',
                        color: const Color(0xFF1877F2),
                      ),
                const SizedBox(height: 14),
                isMobileView
                    ? _buildCommunityLinkMobile(
                        icon: Image.asset(
                          'assets/images/instagram.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Instagram TAKA',
                        url:
                            'https://www.instagram.com/takafrique/?utm_source=qr&r=nametag',
                        color: const Color(0xFFE4405F),
                      )
                    : _buildCommunityLink(
                        icon: Image.asset(
                          'assets/images/instagram.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'Instagram TAKA',
                        url:
                            'https://www.instagram.com/takafrique/?utm_source=qr&r=nametag',
                        color: const Color(0xFFE4405F),
                      ),
                const SizedBox(height: 14),
                isMobileView
                    ? _buildCommunityLinkMobile(
                        icon: Image.asset(
                          'assets/images/tiktok.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'TikTok TAKA',
                        url:
                            'https://www.tiktok.com/@takalivresafricains?_t=ZM-8ymz7cz5WR6&_r=1',
                        color: const Color(0xFF000000),
                      )
                    : _buildCommunityLink(
                        icon: Image.asset(
                          'assets/images/tiktok.png',
                          width: 36,
                          height: 36,
                        ),
                        label: 'TikTok TAKA',
                        url:
                            'https://www.tiktok.com/@takalivresafricains?_t=ZM-8ymz7cz5WR6&_r=1',
                        color: const Color(0xFF000000),
                      ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: "PBold",
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityLinkMobile({
    required Widget icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: "PBold",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new, size: 18, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityLink({
    required Widget icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: "PBold",
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 18, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  // Ajoute ceci dans ta classe _HomeScreenState si ce n'est pas déjà fait :
  List<int> purchasedBookIds = [];
  UserModel? get user => null; // ou récupère ton user actuel si besoin

  List<Map<String, dynamic>> trendingBooks = [];
  bool isLoadingTrending = false;
  Future<void> loadTrendingBooks() async {
    if (mounted) {
      setState(() => isLoadingTrending = true);
    }
    final uri = Uri.parse('$baseUrl/taka_api_books.php').replace(
      queryParameters: {
        'sort': 'bestseller', // ou 'trending' selon ton API
        'per_page': '4',
        'page': '1',
      },
    );
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (mounted) {
      setState(() {
        trendingBooks = List<Map<String, dynamic>>.from(data['books'] ?? []);
        isLoadingTrending = false;
      });
    }
  }

  bool get isMobile {
    final width = MediaQuery.of(context).size.width;
    return width < 780;
  }

  Widget _buildTrendingBooksSection(BuildContext context) {
    final bool isMobileView = MediaQuery.of(context).size.width < 600;

    // Utilise ValueListenableBuilder pour que la devise change dynamiquement
    return ValueListenableBuilder<String>(
      valueListenable: currencyNotifier,
      builder: (context, currency, _) {
        String formatPrice(String price, String currency, String priceType) {
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
            // ... tu peux compléter si un pays de ta liste manque ...
          };

          double rate = conversionRates[currency.toUpperCase()] ?? 1.0;
          double converted = p / rate;

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
            case 'INR':
              return '${(p / conversionRates['INR']!).toStringAsFixed(2)} ₹';
            case 'RUB':
              return '${(p / conversionRates['RUB']!).toStringAsFixed(2)} ₽';
            case 'KRW':
              return '${(p / conversionRates['KRW']!).toStringAsFixed(0)} ₩';
            case 'NGN':
              return '${(p / conversionRates['NGN']!).toStringAsFixed(2)} ₦';
            case 'GNF':
              return '${(p / conversionRates['GNF']!).toStringAsFixed(0)} FG';
            case 'MAD':
              return '${(p / conversionRates['MAD']!).toStringAsFixed(2)} DH';
            case 'DZD':
              return '${(p / conversionRates['DZD']!).toStringAsFixed(2)} DA';
            case 'CAD':
              return '${(p / conversionRates['CAD']!).toStringAsFixed(2)} \$CA';
            case 'AUD':
              return '${(p / conversionRates['AUD']!).toStringAsFixed(2)} \$AU';
            case 'NZD':
              return '${(p / conversionRates['NZD']!).toStringAsFixed(2)} \$NZ';
            case 'CHF':
              return '${(p / conversionRates['CHF']!).toStringAsFixed(2)} CHF';
            case 'ZAR':
              return '${(p / conversionRates['ZAR']!).toStringAsFixed(2)} R';
            case 'EGP':
              return '${(p / conversionRates['EGP']!).toStringAsFixed(2)} £E';
            case 'KES':
              return '${(p / conversionRates['KES']!).toStringAsFixed(2)} Sh';
            case 'GHS':
              return '${(p / conversionRates['GHS']!).toStringAsFixed(2)} ₵';
            case 'MXN':
              return '${(p / conversionRates['MXN']!).toStringAsFixed(2)} \$MX';
            case 'ARS':
              return '${(p / conversionRates['ARS']!).toStringAsFixed(2)} \$AR';
            case 'CLP':
              return '${(p / conversionRates['CLP']!).toStringAsFixed(0)} \$CL';
            case 'COP':
              return '${(p / conversionRates['COP']!).toStringAsFixed(2)} \$CO';
            case 'PEN':
              return '${(p / conversionRates['PEN']!).toStringAsFixed(2)} S/';
            case 'TRY':
              return '${(p / conversionRates['TRY']!).toStringAsFixed(2)} ₺';
            case 'SAR':
              return '${(p / conversionRates['SAR']!).toStringAsFixed(2)} ﷼';
            case 'AED':
              return '${(p / conversionRates['AED']!).toStringAsFixed(2)} د.إ';
            case 'QAR':
              return '${(p / conversionRates['QAR']!).toStringAsFixed(2)} ﷼';
            case 'KWD':
              return '${(p / conversionRates['KWD']!).toStringAsFixed(2)} د.ك';
            case 'BHD':
              return '${(p / conversionRates['BHD']!).toStringAsFixed(2)} ب.د';
            case 'PKR':
              return '${(p / conversionRates['PKR']!).toStringAsFixed(2)} ₨';
            case 'THB':
              return '${(p / conversionRates['THB']!).toStringAsFixed(2)} ฿';
            case 'VND':
              return '${(p / conversionRates['VND']!).toStringAsFixed(0)} ₫';
            case 'IDR':
              return '${(p / conversionRates['IDR']!).toStringAsFixed(0)} Rp';
            case 'MYR':
              return '${(p / conversionRates['MYR']!).toStringAsFixed(2)} RM';
            case 'SGD':
              return '${(p / conversionRates['SGD']!).toStringAsFixed(2)} \$SG';
            case 'HKD':
              return '${(p / conversionRates['HKD']!).toStringAsFixed(2)} \$HK';
            case 'TWD':
              return '${(p / conversionRates['TWD']!).toStringAsFixed(2)} \$TW';
            case 'PLN':
              return '${(p / conversionRates['PLN']!).toStringAsFixed(2)} zł';
            case 'SEK':
              return '${(p / conversionRates['SEK']!).toStringAsFixed(2)} kr';
            case 'NOK':
              return '${(p / conversionRates['NOK']!).toStringAsFixed(2)} kr';
            case 'DKK':
              return '${(p / conversionRates['DKK']!).toStringAsFixed(2)} kr';
            case 'CZK':
              return '${(p / conversionRates['CZK']!).toStringAsFixed(2)} Kč';
            case 'HUF':
              return '${(p / conversionRates['HUF']!).toStringAsFixed(0)} Ft';
            case 'RON':
              return '${(p / conversionRates['RON']!).toStringAsFixed(2)} lei';
            case 'UAH':
              return '${(p / conversionRates['UAH']!).toStringAsFixed(2)} ₴';
            case 'ILS':
              return '${(p / conversionRates['ILS']!).toStringAsFixed(2)} ₪';
            case 'IRR':
              return '${(p / conversionRates['IRR']!).toStringAsFixed(0)} ﷼';
            case 'IQD':
              return '${(p / conversionRates['IQD']!).toStringAsFixed(0)} ع.د';
            case 'ETB':
              return '${(p / conversionRates['ETB']!).toStringAsFixed(2)} Br';
            case 'TZS':
              return '${(p / conversionRates['TZS']!).toStringAsFixed(0)} Sh';
            case 'UGX':
              return '${(p / conversionRates['UGX']!).toStringAsFixed(0)} Sh';
            case 'RWF':
              return '${(p / conversionRates['RWF']!).toStringAsFixed(0)} FRw';
            case 'MGA':
              return '${(p / conversionRates['MGA']!).toStringAsFixed(0)} Ar';
            case 'ZMW':
              return '${(p / conversionRates['ZMW']!).toStringAsFixed(2)} ZK';
            case 'BWP':
              return '${(p / conversionRates['BWP']!).toStringAsFixed(2)} P';
            case 'AOA':
              return '${(p / conversionRates['AOA']!).toStringAsFixed(2)} Kz';
            case 'XPF':
              return '${(p / conversionRates['XPF']!).toStringAsFixed(2)} ₣';
            case 'FJD':
              return '${(p / conversionRates['FJD']!).toStringAsFixed(2)} \$FJ';
            case 'XOF':
            case 'XAF':
              return '${p.toStringAsFixed(0)} FCFA';
            default:
              return '$price $currency';
          }
        }

        return Container(
          padding: isMobileView
              ? const EdgeInsets.symmetric(vertical: 32, horizontal: 0)
              : const EdgeInsets.symmetric(vertical: 80, horizontal: 100),
          child: Container(
            width: double.infinity,
            margin: isMobileView
                ? const EdgeInsets.symmetric(horizontal: 0)
                : const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobileView
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tendance',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "PBold",
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => widget.onNavigate('explore'),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text(
                                'Voir tout',
                                style: TextStyle(fontFamily: "PBold"),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFF97316),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Livres en tendance',
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: "PBold",
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => widget.onNavigate('explore'),
                            icon: const Icon(Icons.arrow_forward, size: 20),
                            label: const Text(
                              'Voir tout',
                              style: TextStyle(fontFamily: "PBold"),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFF97316),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: isMobileView ? 24 : 48),
                if (isLoadingTrending)
                  const Center(child: CircularProgressIndicator())
                else if (trendingBooks.isEmpty)
                  const Center(
                    child: Text(
                      'Aucun livre en tendance pour le moment.',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                  )
                else if (isMobileView)
                  // Version mobile : liste verticale compacte
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: trendingBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final book = trendingBooks[index];
                      final String price = book['price']?.toString() ?? '';
                      final String priceType =
                          book['price_type']?.toString() ?? '';
                      return _buildBookCardMobileWithCurrency(
                        book,
                        formatPrice(price, currency, priceType),
                      );
                    },
                  )
                else
                  // Desktop/tablette : grille
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width >= 1024
                          ? 4
                          : MediaQuery.of(context).size.width >= 768
                          ? 2
                          : 1,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.47,
                    ),
                    itemCount: trendingBooks.length,
                    itemBuilder: (context, index) {
                      final book = trendingBooks[index];
                      final String price = book['price']?.toString() ?? '';
                      final String priceType =
                          book['price_type']?.toString() ?? '';
                      return _buildBookCardWithCurrency(
                        book,
                        formatPrice(price, currency, priceType),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ajoute ces deux helpers pour injecter la devise dans l'affichage du prix

  Widget _buildBookCardMobileWithCurrency(
    Map<String, dynamic> book,
    String displayPrice,
  ) {
    // Copie _buildBookCardMobile mais remplace l'affichage du prix par displayPrice
    final int bookId = book['id'] is int
        ? book['id']
        : int.tryParse('${book['id']}') ?? 0;
    final bool isPurchased = purchasedBookIds.contains(bookId);

    final String title = book['title'] as String? ?? '';
    final String author = book['author'] as String? ?? '';
    final String description = book['summary'] as String? ?? '';
    final String genre = book['genre'] as String? ?? '';
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Couverture
          Container(
            width: 90,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? const Center(
                    child: Icon(Icons.book, size: 36, color: Color(0xFF9CA3AF)),
                  )
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBestseller)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: "PBold",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontFamily: "PRegular",
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
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
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: Color(0xFFFBBF24),
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: "PBold",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        displayPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 8, 133, 25),
                          fontFamily: "PBold",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$pages pages',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontFamily: "PRegular",
                            ),
                          ),
                          child: const Text('Détail'),
                        ),
                      ),
                      const SizedBox(width: 6),
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
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

  Widget _buildBookCardWithCurrency(
    Map<String, dynamic> book,
    String displayPrice,
  ) {
    // Copie _buildBookCard mais remplace l'affichage du prix par displayPrice
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
          // 📕 Image couverture (hauteur fixe)
          SizedBox(
            height: 370,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  if (imageUrl == null)
                    const Center(
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: Color(0xFF9CA3AF),
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
                                ? const Color(0xFFF97316)
                                : const Color.fromARGB(255, 0, 159, 56),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            priceType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

          // 📖 Infos livre
          Padding(
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
                const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildBookCardMobile(Map<String, dynamic> book) {
    final int bookId = book['id'] is int
        ? book['id']
        : int.tryParse('${book['id']}') ?? 0;
    final bool isPurchased = purchasedBookIds.contains(bookId);

    final String title = book['title'] as String? ?? '';
    final String author = book['author'] as String? ?? '';
    final String description = book['summary'] as String? ?? '';
    final String genre = book['genre'] as String? ?? '';
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Couverture
          Container(
            width: 90,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? const Center(
                    child: Icon(Icons.book, size: 36, color: Color(0xFF9CA3AF)),
                  )
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBestseller)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: "PBold",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontFamily: "PRegular",
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
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
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: Color(0xFFFBBF24),
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: "PBold",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        price.isNotEmpty ? '$price FCFA' : 'Gratuit',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 8, 133, 25),
                          fontFamily: "PBold",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$pages pages',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontFamily: "PRegular",
                            ),
                          ),
                          child: const Text('Détail'),
                        ),
                      ),
                      const SizedBox(width: 6),
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
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
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

  Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency') ?? 'XOF';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildAdvantagesSection(context),
          _buildThreeWaysToReadSection(context),
          // _buildWaysToReadSection(context),
          _buildPublishSection(context),
          _buildTrendingBooksSection(context),
          SizedBox(height: isMobile ? 20 : 100),
          _buildTestimonialsSection(context),
          _buildFinalCTASection(context),
          Footer(),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FAFB), Colors.white],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width >= 768 ? 48 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: "PBold",
                  height: 1.1,
                ),
                children: [
                  const TextSpan(text: 'Lis pour comprendre. '),
                  TextSpan(
                    text: 'Pense librement',
                    style: const TextStyle(color: Color(0xFFF97316)),
                  ),
                  const TextSpan(text: '.\nEt progresse autrement.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.3,
              child: Text(
                'Livres africains, internationaux et rares. Gratuit ou premium. Lis sur ton téléphone. Publie ton livre. Gagne.',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildCTAButton(
                  'Lire des livres maintenant',
                  const Color(0xFFF97316),
                  Colors.white,
                  Icons.book,
                  () => widget.onNavigate('explore'),
                ),
                _buildCTAButton(
                  'Publier mon livre',
                  Colors.black,
                  Colors.white,
                  Icons.play_arrow,
                  () => widget.onNavigate(
                    widget.isLoggedIn ? 'publish' : 'login',
                  ),
                ),
                _buildCTAButton(
                  'Découvrir les abonnements',
                  Colors.transparent,
                  const Color(0xFFF97316),
                  null,
                  () => widget.onNavigate(
                    widget.isLoggedIn ? 'subscription' : 'login',
                  ),
                  bordered: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton(
    String text,
    Color backgroundColor,
    Color textColor,
    IconData? icon,
    VoidCallback onPressed, {
    bool bordered = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 42,
          vertical: isMobile ? 15 : 25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: bordered
              ? const BorderSide(color: Color(0xFFF97316), width: 2)
              : BorderSide.none,
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 15,
          fontFamily: "PRegular",
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 24), const SizedBox(width: 8)],
          Text(text, style: TextStyle(fontFamily: "PRegular")),
        ],
      ),
    );
  }

  Widget _buildAdvantagesSection(BuildContext context) {
    final advantages = [
      {
        'icon': Icons.book,
        'title': 'Un large choix de livres',
        'description':
            'Romans, business, argent, psychologie, spiritualité, histoire, développement personnel… ',
        'iconBg': const Color(0xFFF9FAFB),
        'iconColor': const Color(0xFFFB923C),
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Lecture gratuite',
        'description':
            'Accès à des livres 100% gratuits via notre Bibliothèque Libre',
        'iconBg': const Color(0xFFFFF1F3),
        'iconColor': const Color(0xFFF472B6),
      },
      {
        'icon': Icons.smartphone,
        'title': 'Paiement mobile & simple',
        'description':
            'Orange Money, MTN, Wave ou carte bancaire. Tu paies facilement directement depuis ton téléphone.',
        'iconBg': const Color(0xFFF0FDF4),
        'iconColor': const Color(0xFF10B981),
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Lecture 100% sécurisée',
        'description':
            'Tu lis directement sur TAKA, via un lecteur intégré, pour protéger le contenu et soutenir les auteurs.',
        'iconBg': const Color(0xFFF1F5FE),
        'iconColor': const Color(0xFF2563EB),
      },
    ];

    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 48 : 80,
        horizontal: isMobile ? 16 : 40,
      ),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Pourquoi Lire sur TAKA ?',
            style: TextStyle(
              fontSize: isMobile ? 18 : 30,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: "PBold",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          if (!isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: advantages.map((adv) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: adv['iconBg'] as Color,
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Icon(
                            adv['icon'] as IconData,
                            color: adv['iconColor'] as Color,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          adv['title'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: "PBold",
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          adv['description'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Column(
              children: advantages.map((adv) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: adv['iconBg'] as Color,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          adv['icon'] as IconData,
                          color: adv['iconColor'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adv['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "PBold",
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              adv['description'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontFamily: "PRegular",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildThreeWaysToReadSection(BuildContext context) {
    final bool isMobileView = MediaQuery.of(context).size.width < 900;

    final ways = [
      {
        'icon': Icons.book_outlined,
        'iconBg': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFF97316),
        'title': 'Lire gratuitement',
        'description':
            'Accède à une sélection de livres offerts par leurs auteurs. Découvre, explore et commence à lire sans payer.',
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'iconBg': const Color(0xFFDBEAFE),
        'iconColor': const Color(0xFF2563EB),
        'title': 'Acheter un livre',
        'description':
            'Un livre t\'intéresse ? Achète-le une seule fois et lis-le directement sur TAKA.',
      },
      {
        'icon': Icons.all_inclusive_outlined,
        'iconBg': const Color(0xFFF3E8FF),
        'iconColor': const Color(0xFF8B5CF6),
        'title': 'S\'abonner et lire sans limite',
        'description':
            'Accède à une large sélection de livres premium et rares, sans te poser de questions.',
      },
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isMobileView ? 48 : 80,
        horizontal: isMobileView ? 16 : 40,
      ),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            '3 façons de lire sur TAKA ',
            style: TextStyle(
              fontSize: isMobileView ? 18 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: "PBold",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          if (!isMobileView)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ways.map((way) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: way['iconBg'] as Color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            way['icon'] as IconData,
                            color: way['iconColor'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          way['title'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: "PBold",
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          way['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Column(
              children: ways.map((way) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: way['iconBg'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          way['icon'] as IconData,
                          color: way['iconColor'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              way['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "PBold",
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              way['description'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontFamily: "PRegular",
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPublishSection(BuildContext context) {
    final bool isMobileView = MediaQuery.of(context).size.width < 900;

    final features = [
      {
        'icon': Icons.publish_outlined,
        'iconBg': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFF97316),
        'title': 'Publie librement',
        'description': 'Gratuit ou payant, c\'est toi qui choisis.',
      },
      {
        'icon': Icons.attach_money_outlined,
        'iconBg': const Color(0xFFD1FAE5),
        'iconColor': const Color(0xFF10B981),
        'title': 'Monétise facilement',
        'description': 'Fixe ton prix. Reçois tes revenus.',
      },
      {
        'icon': Icons.settings_outlined,
        'iconBg': const Color(0xFFDBEAFE),
        'iconColor': const Color(0xFF2563EB),
        'title': 'Zéro technique',
        'description': 'TAKA gère tout pour toi.',
      },
    ];

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(
        vertical: isMobileView ? 48 : 80,
        horizontal: isMobileView ? 16 : 40,
      ),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Tu écris ? Publie et gagne avec TAKA',
            style: TextStyle(
              fontSize: isMobileView ? 17 : 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: "PBold",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ton livre mérite d\'être lu.',
            style: TextStyle(
              fontSize: isMobileView ? 16 : 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
              fontFamily: "PRegular",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'TAKA te donne une plateforme pour publier simplement et toucher tes revenus.',
            style: TextStyle(
              fontSize: isMobileView ? 14 : 18,
              color: const Color(0xFF6B7280),
              fontFamily: "PRegular",
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          if (!isMobileView)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: feature['iconBg'] as Color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: feature['iconColor'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: "PBold",
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feature['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Column(
              children: features.map((feature) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: feature['iconBg'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: feature['iconColor'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "PBold",
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feature['description'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontFamily: "PRegular",
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
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

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 180,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "PBold",
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(genre)),
                  const SizedBox(width: 8),
                  Chip(label: Text(language)),
                  const SizedBox(width: 8),
                  Chip(label: Text(plan)),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      priceType == 'gratuit' ? 'Gratuit' : '$price FCFA',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (summary.isNotEmpty) ...[
                const Text(
                  'Résumé',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: TextStyle(
                    fontFamily: "PRegular",
                    fontSize: isMobile ? 13 : 13,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (authorBio.isNotEmpty) ...[
                const Text(
                  'Bio de l\'auteur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                  ),
                ),
                const SizedBox(height: 4),
                Text(authorBio, style: const TextStyle(fontFamily: "PRegular")),
                const SizedBox(height: 12),
              ],
              if (authorLinks.isNotEmpty) ...[
                const Text(
                  'Liens auteur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authorLinks,
                  style: const TextStyle(
                    fontFamily: "PRegular",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (excerpt.isNotEmpty) ...[
                const Text(
                  'Extrait',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  excerpt,
                  style: const TextStyle(
                    fontFamily: "PRegular",
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (quote.isNotEmpty) ...[
                const Text(
                  'Citation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "PBold",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '« $quote »',
                  style: const TextStyle(
                    fontFamily: "PRegular",
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontFamily: "PRegular"),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          // 📕 Image couverture (hauteur fixe)
          SizedBox(
            height: 370,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  if (imageUrl == null)
                    const Center(
                      child: Icon(
                        Icons.book,
                        size: 48,
                        color: Color(0xFF9CA3AF),
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
                                ? const Color(0xFFF97316)
                                : const Color.fromARGB(255, 0, 159, 56),
                            // : const Color.fromARGB(255, 223, 46, 10),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            priceType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

          // 📖 Infos livre
          Padding(
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
                const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    final testimonials = [
      {
        'name': 'Alex Konate',
        'country': '',
        'quote':
            'Sur TAKA, j\'ai découvert des livres puissants que je n\'aurais jamais trouvés ailleurs. On lit gratuitement, puis on a envie d\'aller plus loin. C\'est devenu mon espace de lecture quotidien.',
        'image': 'assets/images/aminata.png',
      },
      {
        'name': 'Amina Dambaba',
        'country': '',
        'quote':
            'J\'adore ! Je suis une grande passionnée d\'écriture, je vis d\'ailleurs de l\'écriture. Voir une plateforme qui met en avant les écrivains africains, c\'est vraiment intéressant. De plus, la plateforme est très facile à comprendre, tout y est, sans parler de l\'abonnement qui est très accessible.',
        'image': 'assets/images/Amina Dambaba.jpg',
      },
      {
        'name': 'Habib Hountchegnon',
        'country': '',
        'quote':
            'Publier sur TAKA a tout changé pour moi. J\'ai gagné en visibilité et mes livres se vendent mieux. La plateforme est simple et respecte vraiment les auteurs.',
        'image': 'assets/images/Habib Hountchegnon.jpg',
      },
    ];

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
        child: Column(
          children: [
            Text(
              'Ce qu\'ils disent de TAKA',
              style: TextStyle(
                fontSize: isMobile ? 17 : 30,
                fontFamily: "PBold",
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Témoignages de notre communauté',
              style: TextStyle(
                fontSize: isMobile ? 14 : 17,
                fontFamily: "PRegular",
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24 : 64),
            isMobile
                ? Column(
                    children: testimonials.map((testimonial) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        padding: const EdgeInsets.all(18),
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
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    testimonial['image'] as String,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      testimonial['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "PBold",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if ((testimonial['country'] as String)
                                        .isNotEmpty)
                                      Text(
                                        testimonial['country'] as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: "PRegular",
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '"${testimonial['quote']}"',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                                fontStyle: FontStyle.italic,
                                fontFamily: "PRegular",
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width >= 768
                            ? 3
                            : 1,
                        crossAxisSpacing: 32,
                        childAspectRatio: 1.9,
                      ),
                      itemCount: testimonials.length,
                      itemBuilder: (context, index) {
                        final testimonial = testimonials[index];
                        return IntrinsicHeight(
                          child: Container(
                            padding: const EdgeInsets.all(32),
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
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.asset(
                                        testimonial['image'] as String,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          testimonial['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: "PBold",
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if ((testimonial['country'] as String)
                                            .isNotEmpty)
                                          Text(
                                            testimonial['country'] as String,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: "PRegular",
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '"${testimonial['quote']}"',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF374151),
                                    fontStyle: FontStyle.italic,
                                    fontFamily: "PRegular",
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalCTASection(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 80,
        horizontal: isMobile ? 16 : 0,
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
        child: Column(
          children: [
            Text(
              'Rejoins la révolution littéraire TAKA',
              style: TextStyle(
                fontSize: isMobile ? 14 : 30,
                fontWeight: FontWeight.w700,
                fontFamily: "PBold",
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              'Plus de 50 000 lecteurs nous font déjà confiance. Et vous ?',
              style: TextStyle(
                fontSize: isMobile ? 15 : 20,
                fontFamily: "PRegular",
                color: Color(0xFFFED7AA),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => widget.onNavigate('explore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFF97316),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 32,
                  vertical: isMobile ? 14 : 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  fontSize: isMobile ? 13 : 16,
                  fontFamily: "PBold",
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Commencer maintenant'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour convertir un titre en slug
  String _titleToSlug(String title) {
    // Convertir en minuscules
    String slug = title.toLowerCase();
    
    // Remplacer les caractères accentués
    const accents = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ý': 'y', 'ÿ': 'y',
      'ñ': 'n', 'ç': 'c',
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
      if (currentPath.contains(bookSlug) || currentPath.split('/').any((segment) => segment.isNotEmpty && segment != 'home' && segment != 'explore')) {
        bookUrl = currentUrl.split('?')[0]; // Enlever les query params si présents
      } else {
        // Construire l'URL à partir de l'URL de base
        final baseUri = Uri.base;
        bookUrl = '${baseUri.scheme}://${baseUri.host}${baseUri.port != 80 && baseUri.port != 443 ? ':${baseUri.port}' : ''}/$bookSlug';
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
