import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:taka2/models/user_model.dart';
import 'package:taka2/widgets/const.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  final Function(String, [dynamic]) onNavigate;
  final bool isLoggedIn;
  final UserModel? user;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = 'month';

  Map<String, int> stats = {
    'totalBooks': 0,
    'totalSales': 0,
    'totalRevenue': 0,
    'totalReaders': 0,
  };
  List<Map<String, dynamic>> books = [];
  Map<String, int> subsStats = {};
  int totalBooks = 0;

  // Données de performance
  Map<String, dynamic> performanceData = {
    'averageRating': 0.0,
    'completionRate': 0.0,
  };

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      fetchBooksCount(int.parse(widget.user!.id)).then((count) {
        setState(() {
          totalBooks = count;
        });
      });
      fetchSalesChartData(int.parse(widget.user!.id));
      fetchAuthorBooks(int.parse(widget.user!.id), period: selectedPeriod);
      fetchPerformanceData(int.parse(widget.user!.id));
    }
    fetchAuthorSalesStats(int.parse(widget.user!.id));
  }

  Future<void> fetchAuthorSalesStats(int userId) async {
    final url = Uri.parse('$baseUrl/taka_api_author_sales.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          stats['totalSales'] = data['totalSales'] ?? 0;
          stats['totalRevenue'] = data['totalRevenue'] ?? 0;
          stats['totalReaders'] = data['totalReaders'] ?? 0;
        });
      }
    }
  }

  Future<void> fetchAuthorBooks(int userId, {String period = 'month'}) async {
    final url = Uri.parse(
      '$baseUrl/taka_api_author_books.php?user_id=$userId&period=$period',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['books'] is List) {
        setState(() {
          books = List<Map<String, dynamic>>.from(data['books']);
        });
      }
    }
  }

  Future<int> fetchBooksCount(int userId) async {
    final url = Uri.parse('$baseUrl/taka_api_books_count.php?user_id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalBooks'] ?? 0;
    } else {
      throw Exception('Erreur lors de la récupération du nombre de livres');
    }
  }

  Future<void> fetchPerformanceData(int userId) async {
    final url = Uri.parse(
      '$baseUrl/taka_api_author_performance.php?user_id=$userId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          performanceData['averageRating'] =
              double.tryParse(data['averageRating']?.toString() ?? '0') ?? 0.0;
          performanceData['completionRate'] =
              double.tryParse(data['completionRate']?.toString() ?? '0') ?? 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    if (!widget.isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Accès restreint',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "PBold",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous devez être connecté pour accéder au tableau de bord auteur.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "PRegular",
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => widget.onNavigate('login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 24,
                    vertical: isMobile ? 12 : 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(color: Colors.white, fontFamily: "PRegular"),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 16 : 32,
            horizontal: isMobile ? 20 : 20,
          ),
          child: Column(
            children: [
              _buildHeader(isMobile: isMobile),
              SizedBox(height: isMobile ? 16 : 32),
              _buildStatsCards(isMobile: isMobile),
              SizedBox(height: isMobile ? 16 : 32),
              isMobile
                  ? Column(
                      children: [
                        _buildBooksManagement(isMobile: isMobile),
                        SizedBox(height: isMobile ? 16 : 32),
                        _buildSalesChart(isMobile: isMobile),
                        SizedBox(height: isMobile ? 16 : 32),
                        _buildSidebar(isMobile: isMobile),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildBooksManagement(isMobile: isMobile),
                              SizedBox(height: 32),
                              _buildSalesChart(isMobile: isMobile),
                            ],
                          ),
                        ),
                        if (MediaQuery.of(context).size.width >= 1024) ...[
                          const SizedBox(width: 32),
                          SizedBox(
                            width: 320,
                            child: _buildSidebar(isMobile: isMobile),
                          ),
                        ],
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> plans = [
    {
      'id': 'essential',
      'name': 'Essentielle',
      'price': '2.000',
      'period': 'mois',
      'books': '5 livres/mois',
      'popular': false,
    },
    {
      'id': 'comfort',
      'name': 'Confort',
      'price': '3.500',
      'period': 'mois',
      'books': '10 livres/mois',
      'popular': true,
    },
    {
      'id': 'unlimited',
      'name': 'Illimitée',
      'price': '5.000',
      'period': 'mois',
      'books': 'Lecture illimitée',
      'popular': false,
    },
  ];

  Widget _buildHeader({required bool isMobile}) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tableau de bord auteur',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "PBold",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              const Text(
                'Suivez les performances de vos publications',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "PRegular",
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigate('publish'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Nouveau livre',
                  style: TextStyle(fontFamily: "PBold"),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: "PRegular",
                  ),
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tableau de bord auteur',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Suivez les performances de vos publications',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "PRegular",
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigate('publish'),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Nouveau livre',
                  style: TextStyle(fontFamily: "PBold"),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: "PRegular",
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildStatsCards({required bool isMobile}) {
    final statsData = [
      {
        'title': 'Livres publiés',
        'value': totalBooks.toString(),
        'icon': Icons.book,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Ventes totales',
        'value': stats['totalSales'].toString(),
        'icon': Icons.trending_up,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Revenus nets',
        'value': '${stats['totalRevenue']!} FCFA',
        'icon': Icons.attach_money,
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Lecteurs uniques',
        'value': '${stats['totalReaders']}',
        'icon': Icons.people,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile
            ? 1
            : MediaQuery.of(context).size.width >= 1024
            ? 4
            : MediaQuery.of(context).size.width >= 768
            ? 2
            : 1,
        crossAxisSpacing: isMobile ? 12 : 24,
        mainAxisSpacing: isMobile ? 12 : 24,
        childAspectRatio: isMobile ? 2.2 : 2.5,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final stat = statsData[index];
        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['title'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Color(0xFF6B7280),
                        fontFamily: "PRegular",
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    Text(
                      stat['value'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: "PBold",
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: isMobile ? 36 : 48,
                height: isMobile ? 36 : 48,
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: isMobile ? 18 : 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBooksManagement({required bool isMobile}) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes livres',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              DropdownButton<String>(
                value: selectedPeriod,
                onChanged: (value) {
                  setState(() => selectedPeriod = value!);
                  if (widget.user != null) {
                    fetchAuthorBooks(
                      int.parse(widget.user!.id),
                      period: selectedPeriod,
                    );
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'week',
                    child: Text(
                      'Cette semaine',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'month',
                    child: Text(
                      'Ce mois',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'year',
                    child: Text(
                      'Cette année',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 24),
          ...books.map(
            (book) => Container(
              margin: EdgeInsets.only(bottom: isMobile ? 10 : 16),
              padding: EdgeInsets.all(isMobile ? 10 : 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
              ),
              child: Row(
                children: [
                  Container(
                    width: isMobile ? 40 : 64,
                    height: isMobile ? 60 : 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(8),
                      image:
                          book['cover_path'] != null &&
                              (book['cover_path'] as String).isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                book['cover_path'].toString().startsWith('http')
                                    ? book['cover_path']
                                    : '$baseUrl/${book['cover_path']}',
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        (book['cover_path'] == null ||
                            (book['cover_path'] as String).isEmpty)
                        ? const Icon(
                            Icons.book,
                            color: Color(0xFF9CA3AF),
                            size: 32,
                          )
                        : null,
                  ),
                  SizedBox(width: isMobile ? 8 : 16),
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
                                    book['title'],
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontFamily: "PBold",
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 2 : 4),
                                  Text(
                                    'Publié le ${DateTime.parse(book['publishDate']).day}/${DateTime.parse(book['publishDate']).month}/${DateTime.parse(book['publishDate']).year}',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 14,
                                      color: Color(0xFF6B7280),
                                      fontFamily: "PRegular",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 6 : 8,
                                vertical: isMobile ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: book['statut_validation'] == 'Publié'
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                book['statut_validation'],
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: book['statut_validation'] == 'Publié'
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF92400E),
                                  fontFamily: "PBold",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 8 : 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ventes',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 14,
                                      color: Color(0xFF6B7280),
                                      fontFamily: "PRegular",
                                    ),
                                  ),
                                  Text(
                                    book['sales'].toString(),
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "PBold",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Revenus',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 14,
                                      color: Color(0xFF6B7280),
                                      fontFamily: "PRegular",
                                    ),
                                  ),
                                  Text(
                                    '${(book['revenue'])} FCFA',
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "PBold",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Note',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 14,
                                      color: Color(0xFF6B7280),
                                      fontFamily: "PRegular",
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        book['rating'].toString(),
                                        style: TextStyle(
                                          fontSize: isMobile ? 13 : 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "PBold",
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 2 : 4),
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFFBBF24),
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lecteurs',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 14,
                                      color: Color(0xFF6B7280),
                                      fontFamily: "PRegular",
                                    ),
                                  ),
                                  Text(
                                    book['readers'].toString(),
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "PBold",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 8 : 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => _buildBookDetailDialog(
                                    book,
                                    isMobile: isMobile,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text(
                                'Voir',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF3B82F6),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                widget.onNavigate('publish', book);
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text(
                                'Modifier',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF6B7280),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final filePath = book['file_path'] as String?;
                                if (filePath != null && filePath.isNotEmpty) {
                                  final url = filePath.startsWith('http')
                                      ? filePath
                                      : '$baseUrl/$filePath';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Impossible d\'ouvrir le fichier.',
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Aucun fichier disponible pour ce livre.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Version imprimée',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF6B7280),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Supprimer ce livre ?'),
                                    content: const Text(
                                      'Cette action est irréversible.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  final url = Uri.parse(
                                    '$baseUrl/taka_api_delete_book.php',
                                  );
                                  final response = await http.post(
                                    url,
                                    body: {
                                      'id': book['id'].toString(),
                                      'user_id': widget.user?.id ?? '',
                                    },
                                  );
                                  final data = json.decode(response.body);
                                  if (data['success'] == true) {
                                    setState(() {
                                      books.removeWhere(
                                        (b) => b['id'] == book['id'],
                                      );
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Livre supprimé.'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur: ${data['error'] ?? 'Suppression impossible.'}',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete, size: 16),
                              label: const Text(
                                'Supprimer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "PRegular",
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
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> salesChartData = [];
  Future<void> fetchSalesChartData(int userId) async {
    final url = Uri.parse(
      '$baseUrl/taka_api_author_sales_chart.php?user_id=$userId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['sales'] is List) {
        setState(() {
          salesChartData = List<Map<String, dynamic>>.from(data['sales']);
        });
      }
    }
  }

  Widget _buildBookDetailDialog(
    Map<String, dynamic> book, {
    required bool isMobile,
  }) {
    final String title = book['title'] ?? '';
    final String genre = book['genre'] ?? '';
    final String language = book['language'] ?? '';
    final String summary = book['summary'] ?? '';
    final String authorBio = book['author_bio'] ?? '';
    final String authorLinks = book['author_links'] ?? '';
    final String excerpt = book['excerpt'] ?? '';
    final String quote = book['quote'] ?? '';
    final String plan = book['plan'] ?? '';
    final String? coverPath = book['cover_path'] as String?;
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: SizedBox(
          width: isMobile ? double.infinity : 430,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: isMobile ? 120 : 180,
                      height: isMobile ? 160 : 240,
                      fit: BoxFit.cover,
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
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: isMobile ? 4 : 8,
                runSpacing: isMobile ? 4 : 8,
                children: [
                  if (genre.isNotEmpty)
                    Chip(
                      label: Text(
                        genre,
                        style: TextStyle(fontSize: isMobile ? 11 : 12),
                      ),
                    ),
                  if (language.isNotEmpty)
                    Chip(
                      label: Text(
                        language,
                        style: TextStyle(fontSize: isMobile ? 11 : 12),
                      ),
                    ),
                  if (plan.isNotEmpty)
                    Chip(
                      label: Text(
                        plan,
                        style: TextStyle(fontSize: isMobile ? 11 : 12),
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
                SizedBox(height: 4),
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
                SizedBox(height: 4),
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
                SizedBox(height: 4),
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
                SizedBox(height: 4),
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
                SizedBox(height: 4),
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

  Widget _buildSalesChart({required bool isMobile}) {
    // Générer les 6 derniers mois dynamiquement
    List<Map<String, dynamic>> getLastSixMonths() {
      final now = DateTime.now();
      final months = [
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Jun',
        'Jul',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ];
      List<Map<String, dynamic>> lastMonths = [];

      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthIndex = monthDate.month - 1; // 0-based index
        lastMonths.add({'month': months[monthIndex], 'sales': 0});
      }
      return lastMonths;
    }

    final salesData = salesChartData.isNotEmpty
        ? salesChartData
        : getLastSixMonths();

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
            'Évolution des ventes',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: "PBold",
            ),
          ),
          SizedBox(height: isMobile ? 12 : 24),
          SizedBox(
            height: isMobile ? 120 : 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: salesData.map((data) {
                final maxSales = salesData
                    .map((d) => d['sales'] as int)
                    .fold<int>(0, (a, b) => a > b ? a : b);
                final height = maxSales > 0
                    ? ((data['sales'] as int) / maxSales) *
                          (isMobile ? 80 : 160)
                    : 0.0;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF97316),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        Text(
                          data['month'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                          ),
                        ),
                        Text(
                          data['sales'].toString(),
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: "PBold",
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    return Column(
      children: [
        Container(
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
                'Performances',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              SizedBox(height: isMobile ? 10 : 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Note moyenne',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 14,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                      Text(
                        '${performanceData['averageRating'].toStringAsFixed(1)}/5',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "PBold",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  LinearProgressIndicator(
                    value: performanceData['averageRating'] / 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFBBF24),
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taux d\'achèvement',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 14,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                      Text(
                        '${(performanceData['completionRate'] * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "PBold",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  LinearProgressIndicator(
                    value: performanceData['completionRate'],
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
