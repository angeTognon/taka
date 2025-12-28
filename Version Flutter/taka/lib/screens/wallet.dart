import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:taka2/models/user_model.dart';
import 'package:taka2/widgets/const.dart';

class WalletPage extends StatefulWidget {
  final UserModel user;
  const WalletPage({super.key, required this.user});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int get balance {
    // Ne compter que les affiliations de type "book" (livre)
    int affiliationsTotal = transactions.fold<int>(
      0,
      (sum, tx) {
        // Filtrer uniquement les transactions de type "book"
        if (tx['type'] == 'book') {
          final amountStr = tx['amount']?.toString() ?? '0';
          final amountInt = int.tryParse(amountStr) ?? 0;
          return sum + amountInt;
        }
        return sum;
      },
    );
    return totalRevenue + affiliationsTotal;
  }

  Future<List<Map<String, dynamic>>> fetchAffiliateEarnings(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_affiliate_earnings.php?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['earnings'] != null) {
        return List<Map<String, dynamic>>.from(data['earnings']);
      }
    }
    return [];
  }

  List<Map<String, dynamic>> transactions = [];
  bool isLoadingTransactions = true;

  int totalSales = 0;
  int totalRevenue = 0;
  int totalReaders = 0;
  bool isLoadingStats = true;

 @override
    void initState() {
      super.initState();
      _loadAuthorStats();
      _loadAffiliateEarnings();
      checkWithdrawalStatus();
    }

  void _loadAffiliateEarnings() async {
    setState(() => isLoadingTransactions = true);
    final txs = await fetchAffiliateEarnings(widget.user.id.toString());
    setState(() {
      transactions = txs;
      isLoadingTransactions = false;
    });
  }

  Future<Map<String, dynamic>> fetchAuthorSales(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_author_sales.php?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      }
    }
    return {
      'totalSales': 0,
      'totalRevenue': 0,
      'totalReaders': 0,
    };
  }

  void _loadAuthorStats() async {
    setState(() => isLoadingStats = true);
    final stats = await fetchAuthorSales(widget.user.id.toString());
    setState(() {
      totalSales = stats['totalSales'] ?? 0;
      totalRevenue = stats['totalRevenue'] ?? 0;
      totalReaders = stats['totalReaders'] ?? 0;
      isLoadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBlock(context, isMobile),
              const SizedBox(height: 20),
              _buildBottomBlock(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // Bloc supérieur : Solde + Statistiques + Bouton de retrait
  Widget _buildTopBlock(BuildContext context, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 100, vertical: isMobile ? 16 : 30),
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 10 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.07),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: Column(
              children: [
                const Text(
                  'Solde disponible',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "PBold",
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance} FCFA',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF97316),
                    fontFamily: "PBold",
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Utilisez votre solde pour vos retraits et achats.',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                    fontFamily: "PRegular",
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            ),
            child: isLoadingStats
                ? const Center(child: CircularProgressIndicator())
                : isMobile
                    ? Column(
                        children: [
                          _statItem('Ventes', totalSales, Icons.shopping_cart, Colors.blue, isMobile),
                          const SizedBox(height: 8),
                          _statItem('Revenu', '$totalRevenue FCFA', Icons.monetization_on, Colors.green, isMobile),
                          const SizedBox(height: 8),
                          _statItem('Lecteurs', totalReaders, Icons.people, Colors.purple, isMobile),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('Ventes', totalSales, Icons.shopping_cart, Colors.blue, isMobile),
                          _statItem('Revenu', '$totalRevenue FCFA', Icons.monetization_on, Colors.green, isMobile),
                          _statItem('Lecteurs', totalReaders, Icons.people, Colors.purple, isMobile),
                        ],
                      ),
          ),
          const SizedBox(height: 20),
                    ElevatedButton.icon(
            onPressed: (balance >= 10000 && !hasRequestedWithdrawal)
                ? requestWithdrawal
                : null,
            icon: const Icon(Icons.arrow_circle_up),
            label: Text(
              hasRequestedWithdrawal
                ? 'Demande déjà envoyée.'
                : 'Demander un retrait',
              style: const TextStyle(fontFamily: "PRegular"),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 32, vertical: isMobile ? 10 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
              ),
              textStyle: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
                    // ...dans _buildTopBlock, juste après le bouton de retrait...
          if (hasRequestedWithdrawal)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 8 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_top, color: Colors.orange, size: isMobile ? 18 : 22),
                  const SizedBox(width: 8),
                  Text(
                    'Demande de retrait en attente',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: isMobile ? 13 : 15,
                      fontFamily: "PBold",
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 8 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: isMobile ? 18 : 22),
                  const SizedBox(width: 8),
                  Text(
                    'Aucune demande de retrait en cours',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: isMobile ? 13 : 15,
                      fontFamily: "PBold",
                    ),
                  ),
                ],
              ),
            ),
          if (balance < 10000)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 8 : 12),
              child: Text(
                'Le montant minimum pour un retrait est de 10 000 FCFA.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isMobile ? 12 : 14,
                  fontFamily: "PRegular",
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // Bloc inférieur : Historique des transactions
  Widget _buildBottomBlock(BuildContext context, bool isMobile) {
    // Filtrer pour ne garder que les transactions de type "book" (livre)
    final bookTransactions = transactions.where((tx) => tx['type'] == 'book').toList();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 100, vertical: isMobile ? 8 : 10),
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos Affiliations - Livres',
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              fontWeight: FontWeight.bold,
              fontFamily: "PBold",
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (isLoadingTransactions)
            const Center(child: CircularProgressIndicator())
          else if (bookTransactions.isEmpty)
            Text(
              'Aucune affiliation de livre trouvée.',
              style: TextStyle(fontFamily: "PRegular", fontSize: isMobile ? 12 : 14),
            )
          else
            ...bookTransactions.map(
              (tx) => Card(
                elevation: 0,
                margin: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                ),
                child: ListTile(
                  dense: isMobile,
                  contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: isMobile ? 4 : 8),
                  leading: Container(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.book,
                      color: Colors.blue,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  title: Text(
                    '+${tx['amount']} FCFA',
                    style: TextStyle(
                      fontFamily: "PBold",
                      color: const Color(0xFFF97316),
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  subtitle: Text(
                    'Affiliation - Livre',
                    style: TextStyle(fontFamily: "PRegular", fontSize: isMobile ? 12 : 14),
                  ),
                  trailing: Text(
                    tx['created_at'] ?? '',
                    style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Text(
              'Astuce : Pour toute question sur les retraits, contactez le support TAKA via le chat ou WhatsApp.',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: isMobile ? 12 : 14,
                fontFamily: "PRegular",
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher une statistique
  Widget _statItem(String label, dynamic value, IconData icon, Color color, bool isMobile) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: isMobile ? 16 : 20),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: isMobile ? 13 : 16,
            fontWeight: FontWeight.bold,
            fontFamily: "PBold",
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 11 : 13,
            fontFamily: "PRegular",
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
    bool hasRequestedWithdrawal = false;    
        Future<void> checkWithdrawalStatus() async {
      final response = await http.get(
        Uri.parse('$baseUrl/taka_api_wallet_withdraw.php?user_id=${widget.user.id}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hasRequestedWithdrawal = data['requested'] == true;
        });
      }
    }
    
   
    Future<void> requestWithdrawal() async {
      final response = await http.post(
        Uri.parse('$baseUrl/taka_api_wallet_withdraw.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': widget.user.id}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("=============$data========");
        if (data['success'] == true) {
          setState(() => hasRequestedWithdrawal = true);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title:  Text('Demande de retrait',style: TextStyle(fontFamily: "PBold",fontSize: 19),),
              content: const Text(
                'Votre demande de retrait a été envoyée à l\'équipe TAKA. Vous serez crédité sous 48h ouvrées.',style: TextStyle(fontFamily: "PRegular")
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK',style: TextStyle(fontFamily: "PBold",)),
                ),
              ],
            ),
          );
        }
      }
    }
}