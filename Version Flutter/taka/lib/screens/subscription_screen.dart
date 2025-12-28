import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taka2/models/user_model.dart';
import 'package:taka2/widgets/const.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool isLoggedIn;
  final UserModel? user;

  const SubscriptionScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    this.user,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String selectedPlan = '';
  String paymentMethod = 'mobile';
  Map<String, dynamic>? activeSubscription;

  Timer? _subscriptionTimer;

  @override
  void initState() {
    super.initState();
    fetchActiveSubscription();
    _startSubscriptionPolling();
    // Pour Flutter Web uniquement
    final uri = Uri.base;
    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      _affiliateRefController.text = ref;
    }
  }

  void _startSubscriptionPolling() {
    _subscriptionTimer?.cancel();
    _subscriptionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchActiveSubscription();
    });
  }

  @override
  void dispose() {
    _subscriptionTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchActiveSubscription() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/taka_api_subscriptions.php?user_id=${widget.user?.id}',
      ),
    );
    final List subs = jsonDecode(response.body);
    if (subs.isNotEmpty) {
      setState(() {
        activeSubscription = subs.first;
        if (activeSubscription != null &&
            (activeSubscription!['status'] == 'payé' ||
                activeSubscription!['status'] == 'pending') &&
            DateTime.parse(
              activeSubscription!['expires_at'],
            ).isAfter(DateTime.now())) {
          selectedPlan = activeSubscription!['plan'];
        }
      });
    }
  }

  bool isPlanActive(String planId) {
    if (activeSubscription == null) return false;
    if (activeSubscription!['plan'] != planId) return false;
    if (activeSubscription!['status'] != 'payé') return false;
    final expiresAt = DateTime.parse(activeSubscription!['expires_at']);
    return expiresAt.isAfter(DateTime.now());
  }

  // ...dans _SubscriptionScreenState...
  final TextEditingController _affiliateRefController = TextEditingController();
  Future<void> _handleSubscribe() async {
    if (selectedPlan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un plan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!widget.isLoggedIn || widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour vous abonner'),
          backgroundColor: Colors.red,
        ),
      );
      widget.onNavigate('login');
      return;
    }

    setState(() => isLoading = true); // <-- Affiche le loader

    try {
      final selectedPlanData = plans.firstWhere(
        (plan) => plan['id'] == selectedPlan,
      );
      final int amount =
          int.tryParse(selectedPlanData['price'].replaceAll('.', '')) ?? 0;
      final user = widget.user!;

      // Récupérer la devise sélectionnée par l'utilisateur
      final prefs = await SharedPreferences.getInstance();
      final selectedCurrency = prefs.getString('currency') ?? 'XOF';
      final selectedCountry = prefs.getString('country') ?? 'Bénin';

      final response = await http.post(
        Uri.parse('$baseUrl/moneroo_init.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': selectedCurrency,
          'country': selectedCountry,
          'description': 'Abonnement ${selectedPlanData['name'] ?? ''}',
          'email': user.email ?? '',
          'first_name': user.name.split(' ').first,
          'last_name': user.name.split(' ').length > 1
              ? user.name.split(' ').sublist(1).join(' ')
              : 'Client',
          'user_id': user.id,
          'plan_id': selectedPlan.toString(),
          'return_url': 'https://takaafrica.com',
          if (_affiliateRefController.text.isNotEmpty)
            'ref': _affiliateRefController.text,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false); // <-- Arrête le loader

      if (data['checkout_url'] != null) {
        final url = data['checkout_url'];
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          _waitForPaymentValidation(); // <-- continue le loader et vérifie le paiement
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d’ouvrir le paiement Moneroo'),
            ),
          );
        }
      } else {
        String errorMsg = 'Erreur lors de l\'initialisation du paiement';
        if (data['response'] != null) {
          errorMsg += '\n${data['response']}';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur réseau : $e')));
    }
  }

  Future<bool> subscribeUser({
    required String userId,
    required String plan,
    required String paymentMethod,
    String? transactionRef,
    String status = "en attente",
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taka_api_subscriptions.php?action=subscribe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'plan': plan,
        'payment_method': paymentMethod,
        'status': status,
        if (transactionRef != null) 'transaction_ref': transactionRef,
      }),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  final List<Map<String, dynamic>> plans = [
    {
      'id': 'monthly',
      'name': 'Abonnement mensuel',
      'price': '2000',
      'period': 'mois',
      'books': '',
      'popular': false,
      'oldPrice': null,
      'features': [],
    },
    {
      'id': '3months',
      'name': 'Abonnement 3 mois',
      'price': '5000',
      'period': '3 mois',
      'books': '',
      'popular': false,
      'oldPrice': '6000',
      'features': [],
    },
    {
      'id': 'annual',
      'name': 'Abonnement annuel',
      'price': '18000',
      'period': 'an',
      'books': '',
      'popular': false,
      'oldPrice': '24000',
      'features': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 16),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 24 : 48,
                horizontal: isMobile ? 30 : 30,
              ),
              child: Column(
                children: [
                  _buildHeader(isMobile: isMobile),
                  SizedBox(height: isMobile ? 32 : 64),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 100,
                    ),
                    child: _buildPlans(isMobile: isMobile),
                  ),
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildAdvantages(isMobile: isMobile),
                  SizedBox(height: isMobile ? 32 : 48),
                  if (selectedPlan.isNotEmpty)
                    _buildSubscribeButton(isMobile: isMobile),
                  SizedBox(height: isMobile ? 32 : 64),
                  _buildFAQ(isMobile: isMobile),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Future<void> _waitForPaymentValidation() async {
    bool paid = false;
    int maxTries = 30; // 30 x 5s = 2min30 max
    int tries = 0;
    while (!paid && tries < maxTries) {
      await Future.delayed(const Duration(seconds: 5));
      final response = await http.get(
        Uri.parse(
          '$baseUrl/check_payment_status.php?user_id=${widget.user?.id}&plan_id=$selectedPlan',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'paid') {
        paid = true;
      }
      tries++;
    }
    setState(() => isLoading = false);
    if (paid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paiement validé !')));
      fetchActiveSubscription(); // recharge l’abonnement
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement non validé ou annulé.')),
      );
    }
  }

  Widget _buildHeader({required bool isMobile}) {
    return Column(
      children: [
        Text(
          'Lire sans limite n\'a jamais été aussi simple.',
          style: TextStyle(
            fontSize: isMobile ? 18 : 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'PBold',
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Container(
          constraints: BoxConstraints(maxWidth: isMobile ? 400 : 768),
          child: Text(
            'Sur TAKA, certains livres sont gratuits, d\'autres payants à l\'unité.\nL\'abonnement Premium te permet de lire sans limite, sans payer à chaque livre.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Color(0xFF6B7280),
              fontFamily: 'PRegular',
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF97316), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🟠 CHOISIS TON ABONNEMENT PREMIUM',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PBold',
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool isLoading = false;
  Widget _buildPlans({required bool isMobile}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile
            ? 1
            : (MediaQuery.of(context).size.width >= 768 ? 3 : 1),
        crossAxisSpacing: isMobile ? 16 : 32,
        mainAxisSpacing: isMobile ? 16 : 32,
        childAspectRatio: isMobile ? 0.70 : 0.45,
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isSelected = selectedPlan == plan['id'];
        final bool hasActivePlan =
            activeSubscription != null &&
            isPlanActive(activeSubscription!['plan']);
        final bool planIsActive = isPlanActive(plan['id']);
        final bool isUserPlan =
            activeSubscription != null &&
            activeSubscription!['plan'] == plan['id'];

        // Le bouton doit être actif pour tous les plans SAUF celui déjà actif
        final bool canSelect = !planIsActive;

        return GestureDetector(
          onTap: canSelect
              ? () async {
                  setState(() => selectedPlan = plan['id']);
                  if (widget.user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez vous connecter pour vous abonner.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "PRegular",
                          ),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    widget.onNavigate('login');
                    return;
                  }
                  // Appel direct au paiement
                  await _handleSubscribe();
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFF97316)
                    : plan['popular']
                    ? const Color(0xFFFED7AA)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (planIsActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (plan['popular'])
                  Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Plus populaire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: plan['id'],
                        groupValue: selectedPlan,
                        onChanged: canSelect
                            ? (value) {
                                setState(() => selectedPlan = value!);
                                if (widget.user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Veuillez vous connecter pour vous abonner.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "PRegular",
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  widget.onNavigate('login');
                                  return;
                                }
                                _handleSubscribe();
                              }
                            : null,
                        activeColor: const Color(0xFFF97316),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan['name'],
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'PBold',
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  plan['price'],
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 22,
                                    fontFamily: 'PBold',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  ' FCFA / ${plan['period']}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 15,
                                    fontFamily: 'PRegular',
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            if (plan['oldPrice'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Au lieu de ',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      fontFamily: 'PRegular',
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  Text(
                                    '${plan['oldPrice']} FCFA',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      fontFamily: 'PRegular',
                                      color: const Color(0xFF9CA3AF),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    Map<String, dynamic> plan,
    bool isMobile,
  ) {
    setState(() {
      selectedPlan = plan['id'];
    });
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 120,
          vertical: isMobile ? 24 : 80,
        ),
        backgroundColor: Colors.transparent,
        child: Material(
          borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
          child: _buildPaymentSection(isMobile: isMobile),
        ),
      ),
    );
  }

  Widget _buildPaymentSection({required bool isMobile}) {
    if (widget.user == null) {
      final selectedPlanData = selectedPlan.isNotEmpty
          ? plans.firstWhere((plan) => plan['id'] == selectedPlan)
          : plans.first;

      return IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 16 : 50,
            horizontal: isMobile ? 16 : 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
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
              Text(
                'Détail du plan sélectionné',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: "PBold",
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 16 : 32),
              Container(
                constraints: BoxConstraints(maxWidth: isMobile ? 400 : 512),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan ${selectedPlanData['name']}',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontFamily: "PBold",
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                selectedPlanData['books'],
                                style: TextStyle(
                                  fontFamily: "PBold",
                                  fontSize: isMobile ? 12 : 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${selectedPlanData['price']} FCFA',
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "PRegular",
                                  color: Color(0xFFF97316),
                                ),
                              ),
                              Text(
                                'par ${selectedPlanData['period']}',
                                style: TextStyle(
                                  fontFamily: "PRegular",
                                  fontSize: isMobile ? 12 : 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fonctionnalités incluses',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: "PBold",
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: isMobile ? 10 : 16),
                        ...((selectedPlanData['features'] as List<String>).map(
                          (feature) => Padding(
                            padding: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Color(0xFF10B981),
                                  size: isMobile ? 16 : 20,
                                ),
                                SizedBox(width: isMobile ? 8 : 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 16,
                                      fontFamily: "PRegular",
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final selectedPlanData = plans.firstWhere(
      (plan) => plan['id'] == selectedPlan,
    );

    return IntrinsicHeight(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 50,
          horizontal: isMobile ? 16 : 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
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
            Text(
              'Finaliser votre abonnement',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                fontFamily: "PBold",
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 16 : 32),
            Container(
              constraints: BoxConstraints(maxWidth: isMobile ? 400 : 512),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan ${selectedPlanData['name']}',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontFamily: "PBold",
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              selectedPlanData['books'],
                              style: TextStyle(
                                fontFamily: "PBold",
                                fontSize: isMobile ? 12 : 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${selectedPlanData['price']} FCFA',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: "PRegular",
                                color: Color(0xFFF97316),
                              ),
                            ),
                            Text(
                              'par ${selectedPlanData['period']}',
                              style: TextStyle(
                                fontFamily: "PRegular",
                                fontSize: isMobile ? 12 : 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode de paiement',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "PBold",
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: isMobile ? 10 : 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => paymentMethod = 'mobile'),
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 10 : 16),
                                decoration: BoxDecoration(
                                  color: paymentMethod == 'mobile'
                                      ? const Color(0xFFFFF7ED)
                                      : Colors.white,
                                  border: Border.all(
                                    color: paymentMethod == 'mobile'
                                        ? const Color(0xFFF97316)
                                        : const Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    isMobile ? 8 : 12,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.smartphone,
                                      color: Color(0xFFF97316),
                                      size: isMobile ? 18 : 24,
                                    ),
                                    SizedBox(width: isMobile ? 8 : 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mobile Money',
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 13,
                                            fontFamily: "PBold",
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Orange Money, MTN, Moov',
                                          style: TextStyle(
                                            fontSize: isMobile ? 11 : 12,
                                            fontFamily: "PRegular",
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => paymentMethod = 'card'),
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 10 : 16),
                                decoration: BoxDecoration(
                                  color: paymentMethod == 'card'
                                      ? const Color(0xFFFFF7ED)
                                      : Colors.white,
                                  border: Border.all(
                                    color: paymentMethod == 'card'
                                        ? const Color(0xFFF97316)
                                        : const Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    isMobile ? 8 : 12,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.credit_card,
                                      color: Color(0xFFF97316),
                                      size: isMobile ? 18 : 24,
                                    ),
                                    SizedBox(width: isMobile ? 8 : 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Carte bancaire',
                                          style: TextStyle(
                                            fontFamily: "PBold",
                                            fontSize: isMobile ? 12 : 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Visa, Mastercard',
                                          style: TextStyle(
                                            fontSize: isMobile ? 11 : 12,
                                            fontFamily: "PRegular",
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 16 : 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isMobile ? 8 : 12,
                          ),
                        ),
                        textStyle: TextStyle(
                          fontSize: isMobile ? 14 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'S\'abonner maintenant',
                            style: TextStyle(
                              fontFamily: "PRegular",
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          Icon(Icons.arrow_forward, size: isMobile ? 16 : 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 16),
                  Text(
                    'Résiliable à tout moment. Premier mois offert pour les nouveaux utilisateurs.',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 14,
                      fontFamily: "PRegular",
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantages({required bool isMobile}) {
    final advantages = [
      'Lecture illimitée de tous les livres : Gratuits et Payants',
      'Accès prioritaire aux nouveautés',
      'Aucun paiement à chaque livre',
      'Lecture sécurisée sur TAKA',
      'Annule ton abonnement à tout moment',
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
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
              Text('📌 ', style: TextStyle(fontSize: isMobile ? 18 : 20)),
              Text(
                'VOS AVANTAGES',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PBold',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 24),
          ...advantages.map(
            (advantage) => Padding(
              padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✔ ',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      advantage,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontFamily: 'PRegular',
                        color: const Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () async {
            if (widget.user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez vous connecter pour vous abonner.',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "PRegular",
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              widget.onNavigate('login');
              return;
            }
            await _handleSubscribe();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 32 : 48,
              vertical: isMobile ? 16 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontSize: isMobile ? 15 : 17,
              fontFamily: 'PBold',
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Je m\'abonne'),
        ),
      ),
    );
  }

  Widget _buildFAQ({required bool isMobile}) {
    final faqs = [
      {
        'question': 'Puis-je changer de plan ?',
        'answer':
            'Oui, vous pouvez changer de plan à tout moment depuis votre espace personnel.',
      },
      {
        'question': 'Comment résilier ?',
        'answer':
            'Résiliation possible à tout moment, sans frais, depuis votre compte.',
      },
      {
        'question': 'Lecture hors ligne ?',
        'answer':
            'Tous nos plans incluent la lecture hors ligne sur mobile et tablette.',
      },
      {
        'question': 'Support technique ?',
        'answer':
            'Support par email, chat ou téléphone selon votre plan d\'abonnement.',
      },
    ];

    return Column(
      children: [
        Text(
          'Questions fréquentes',
          style: TextStyle(
            fontSize: isMobile ? 18 : 24,
            fontWeight: FontWeight.w700,
            fontFamily: "PBold",
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 16 : 32),
        Container(
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile
                  ? 1
                  : (MediaQuery.of(context).size.width >= 768 ? 2 : 1),
              crossAxisSpacing: isMobile ? 8 : 32,
              mainAxisSpacing: isMobile ? 8 : 32,
              childAspectRatio: isMobile ? 3.5 : 4.0,
            ),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
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
                    Text(
                      faq['question']!,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 16,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      faq['answer']!,
                      style: TextStyle(
                        fontFamily: "PRegular",
                        fontSize: isMobile ? 13 : 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
