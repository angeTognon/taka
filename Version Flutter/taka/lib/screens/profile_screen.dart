import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taka2/widgets/const.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final Function(String, [dynamic]) onNavigate;
  final bool isLoggedIn;
  final UserModel? user;
  final void Function(UserModel)? onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    this.user,
    this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String activeTab = 'reading';

  late TextEditingController _nameController;
  bool isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    loadCurrentlyReading();
    loadPurchasedBooks();
    loadRecommendations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (widget.user == null) return;
    setState(() => isSavingProfile = true);
    final url = Uri.parse('$baseUrl/taka_api_update_profile.php');
    final response = await http.post(
      url,
      body: {
        'user_id': widget.user!.id,
        'full_name': _nameController.text.trim(),
      },
    );
    final data = json.decode(response.body);
    setState(() => isSavingProfile = false);
    if (data['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profil mis à jour !')));
      if (widget.user != null) {
        widget.user!.name = _nameController.text.trim();
      }
      if (widget.onUserUpdated != null) {
        widget.onUserUpdated!(widget.user!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : ${data['error'] ?? 'Impossible de mettre à jour.'}',
          ),
        ),
      );
    }
  }

  void _showBookDetailDialog(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) {
        final coverUrl =
            (book['cover_path'] != null &&
                book['cover_path'].toString().isNotEmpty)
            ? (book['cover_path'].toString().startsWith('http')
                  ? book['cover_path']
                  : '$baseUrl/${book['cover_path']}')
            : null;
        final bool isMobile = MediaQuery.of(context).size.width < 700;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: isMobile ? double.infinity : 400,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: coverUrl != null
                          ? Image.network(
                              coverUrl,
                              width: isMobile ? 80 : 120,
                              height: isMobile ? 120 : 180,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: isMobile ? 80 : 120,
                              height: isMobile ? 120 : 180,
                              color: const Color(0xFFE5E7EB),
                              child: const Icon(
                                Icons.book,
                                color: Color(0xFF9CA3AF),
                                size: 48,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  Text(
                    book['title'] ?? '',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PBold",
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    book['author_bio'] ?? '',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Color(0xFF6B7280),
                      fontFamily: "PRegular",
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if ((book['genre'] ?? '').isNotEmpty)
                        Chip(
                          label: Text(
                            book['genre'],
                            style: TextStyle(fontSize: isMobile ? 11 : 12),
                          ),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                      if ((book['language'] ?? '').isNotEmpty)
                        Chip(
                          label: Text(
                            book['language'],
                            style: TextStyle(fontSize: isMobile ? 11 : 12),
                          ),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                      if ((book['plan'] ?? '').isNotEmpty)
                        Chip(
                          label: Text(
                            book['plan'],
                            style: TextStyle(fontSize: isMobile ? 11 : 12),
                          ),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  if ((book['summary'] ?? '').isNotEmpty) ...[
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
                      book['summary'],
                      style: TextStyle(
                        fontFamily: "PRegular",
                        fontSize: isMobile ? 12 : 14,
                      ),
                      maxLines: isMobile ? 4 : null,
                      overflow: isMobile ? TextOverflow.ellipsis : null,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                  ],
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     ElevatedButton.icon(
                  //       onPressed: () {
                  //         Navigator.pop(context);
                  //         widget.onNavigate('reader', book);
                  //       },
                  //       icon: const Icon(Icons.menu_book),
                  //       label: const Text('Lire'),
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: const Color(0xFFF97316),
                  //         foregroundColor: Colors.white,
                  //         textStyle: const TextStyle(fontFamily: "PBold"),
                  //         padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: isMobile ? 8 : 10),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> recommendations = [];
  bool isLoadingRecommendations = false;
  Widget _buildRecommendationsTab() {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
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
            'Recommandations personnalisées',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: "PBold",
            ),
          ),
          SizedBox(height: isMobile ? 16 : 32),
          if (isLoadingRecommendations)
            const Center(child: CircularProgressIndicator())
          else if (recommendations.isEmpty)
            Center(
              child: Text(
                'Aucune recommandation pour le moment.',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 16,
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile
                    ? 1
                    : (MediaQuery.of(context).size.width > 900 ? 2 : 2),
                crossAxisSpacing: isMobile ? 12 : 32,
                mainAxisSpacing: isMobile ? 12 : 32,
                childAspectRatio: isMobile ? 1.8 : 2.0,
              ),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final book = recommendations[index];
                final coverUrl =
                    (book['cover_path'] != null &&
                        book['cover_path'].toString().isNotEmpty)
                    ? (book['cover_path'].toString().startsWith('http')
                          ? book['cover_path']
                          : '$baseUrl/${book['cover_path']}')
                    : null;
                return Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                        child: coverUrl != null
                            ? Image.network(
                                coverUrl,
                                width: isMobile ? 48 : 80,
                                height: isMobile ? 72 : 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: isMobile ? 48 : 80,
                                  height: isMobile ? 72 : 120,
                                  color: const Color(0xFFE5E7EB),
                                  child: const Icon(
                                    Icons.book,
                                    color: Color(0xFF9CA3AF),
                                    size: 36,
                                  ),
                                ),
                              )
                            : Container(
                                width: isMobile ? 48 : 80,
                                height: isMobile ? 72 : 120,
                                color: const Color(0xFFE5E7EB),
                                child: const Icon(
                                  Icons.book,
                                  color: Color(0xFF9CA3AF),
                                  size: 36,
                                ),
                              ),
                      ),
                      SizedBox(width: isMobile ? 10 : 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              book['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "PBold",
                              ),
                            ),
                            SizedBox(height: isMobile ? 3 : 4),
                            Text(
                              book['author_bio'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 14,
                                color: Color(0xFF6B7280),
                                fontFamily: "PRegular",
                              ),
                            ),
                            SizedBox(height: isMobile ? 4 : 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if ((book['genre'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(
                                      book['genre'],
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    labelStyle: const TextStyle(
                                      fontFamily: "PRegular",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 6 : 8,
                                      vertical: 0,
                                    ),
                                  ),
                                if ((book['language'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(
                                      book['language'],
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    labelStyle: const TextStyle(
                                      fontFamily: "PRegular",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 6 : 8,
                                      vertical: 0,
                                    ),
                                  ),
                                if ((book['plan'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(
                                      book['plan'],
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    labelStyle: const TextStyle(
                                      fontFamily: "PRegular",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 6 : 8,
                                      vertical: 0,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 4 : 6),
                            Text(
                              book['summary'] ?? '',
                              maxLines: isMobile ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "PRegular",
                                color: Color(0xFF374151),
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                            SizedBox(height: isMobile ? 6 : 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showBookDetailDialog(book);
                                  },
                                  icon: Icon(
                                    Icons.info_outline,
                                    size: isMobile ? 16 : 18,
                                  ),
                                  label: Text(
                                    'Découvrir',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                      fontFamily: "PBold",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 16,
                                      vertical: isMobile ? 6 : 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
              },
            ),
        ],
      ),
    );
  }

  Future<void> loadRecommendations() async {
    if (widget.user == null) return;
    setState(() => isLoadingRecommendations = true);
    final url = Uri.parse(
      '$baseUrl/taka_api_recommendations.php?user_id=${widget.user!.id}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['books'] is List) {
        setState(() {
          recommendations = List<Map<String, dynamic>>.from(data['books']);
          isLoadingRecommendations = false;
        });
      } else {
        setState(() => isLoadingRecommendations = false);
      }
    } else {
      setState(() => isLoadingRecommendations = false);
    }
  }

  List<Map<String, dynamic>> currentlyReading = [];
  bool isLoadingCurrentlyReading = false;

  Future<void> loadCurrentlyReading() async {
    setState(() => isLoadingCurrentlyReading = true);
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('currentlyReading');
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      currentlyReading = (list ?? [])
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
      isLoadingCurrentlyReading = false;
    });
  }

  List<Map<String, dynamic>> purchasedBooks = [];
  bool isLoadingPurchased = false;
  Future<void> loadPurchasedBooks() async {
    if (widget.user == null) return;
    setState(() => isLoadingPurchased = true);
    final url = Uri.parse(
      '$baseUrl/taka_api_purchased_books.php?user_id=${widget.user!.id}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['books'] is List) {
        setState(() {
          purchasedBooks = List<Map<String, dynamic>>.from(data['books']);
          isLoadingPurchased = false;
        });
      } else {
        setState(() => isLoadingPurchased = false);
      }
    } else {
      setState(() => isLoadingPurchased = false);
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
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous devez être connecté pour accéder à cette page.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => widget.onNavigate('login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 24,
                    vertical: isMobile ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontFamily: "PBold"),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontFamily: "PBold"),
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
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 100),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 32),
          child: Column(
            children: [
              _buildProfileHeaderMobile(isMobile: isMobile),
              SizedBox(height: isMobile ? 16 : 32),
              _buildNavigationTabsMobile(isMobile: isMobile),
              SizedBox(height: isMobile ? 16 : 32),
              _renderTabContentMobile(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // Responsive header
  Widget _buildProfileHeaderMobile({required bool isMobile}) {
    final userProfile = {
      'name': widget.user?.name ?? 'Utilisateur TAKA',
      'email': widget.user?.id ?? 'user@taka.africa',
      'totalBooksRead': 47,
      'readingStreak': 23,
      'subscription': 'Confort',
      'joinDate': '2023-08-15',
    };

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: isMobile ? 64 : 96,
                    height: isMobile ? 64 : 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(isMobile ? 32 : 48),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 36,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: isMobile ? 20 : 32,
                      height: isMobile ? 20 : 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 16),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: isMobile ? 12 : 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile['name'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: "PBold",
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : 8),
                    Text(
                      userProfile['email'] as String,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 16,
                        color: Color(0xFF6B7280),
                        fontFamily: "PRegular",
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    // Statistiques en grille 2x2
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            value: userProfile['totalBooksRead'].toString(),
                            label: 'Livres lus',
                            icon: Icons.book,
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: _buildStatCard(
                            value: userProfile['readingStreak'].toString(),
                            label: 'Jours consécutifs',
                            icon: Icons.local_fire_department,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            value: userProfile['subscription'] as String,
                            label: 'Abonnement',
                            icon: Icons.star,
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final createdAtStr = widget.user?.createdAt;
                              int days = 0;
                              int months = 0;
                              String display = '';
                              if (createdAtStr != null &&
                                  createdAtStr.isNotEmpty) {
                                final createdAt = DateTime.tryParse(
                                  createdAtStr,
                                );
                                if (createdAt != null) {
                                  days = DateTime.now()
                                      .difference(createdAt)
                                      .inDays;
                                  months = days ~/ 30;
                                  if (days < 30) {
                                    display =
                                        '$days jour${days > 1 ? 's' : ''}';
                                  } else {
                                    display = '$months mois';
                                  }
                                }
                              }
                              return _buildStatCard(
                                value: display,
                                label: 'sur TAKA',
                                icon: Icons.calendar_today,
                                isMobile: isMobile,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 16 : 20,
        horizontal: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 20 : 24, color: const Color(0xFFF97316)),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF97316),
              fontFamily: "PBold",
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Color(0xFF6B7280),
              fontFamily: "PRegular",
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabsMobile({required bool isMobile}) {
    final tabs = [
      {'id': 'reading', 'label': 'Mes lectures', 'icon': Icons.book},
      {'id': 'purchased', 'label': 'Livres achetés', 'icon': Icons.download},
      {
        'id': 'recommendations',
        'label': 'Recommandations',
        'icon': Icons.favorite,
      },
      {'id': 'settings', 'label': 'Paramètres', 'icon': Icons.settings},
    ];

    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs
              .map(
                (tab) => GestureDetector(
                  onTap: () => setState(() => activeTab = tab['id'] as String),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 24,
                      vertical: isMobile ? 10 : 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: activeTab == tab['id']
                              ? const Color(0xFFF97316)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: isMobile ? 18 : 20,
                          color: activeTab == tab['id']
                              ? const Color(0xFFF97316)
                              : const Color(0xFF6B7280),
                        ),
                        SizedBox(width: isMobile ? 4 : 8),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 16,
                            fontWeight: FontWeight.w500,
                            color: activeTab == tab['id']
                                ? const Color(0xFFF97316)
                                : const Color(0xFF6B7280),
                            fontFamily: activeTab == tab['id']
                                ? "PBold"
                                : "PRegular",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _renderTabContentMobile({required bool isMobile}) {
    switch (activeTab) {
      case 'reading':
        return _buildReadingTab(isMobile: isMobile);
      case 'purchased':
        return _buildPurchasedTab(isMobile: isMobile);
      case 'recommendations':
        return _buildRecommendationsTab();
      case 'settings':
        return _buildSettingsTab(isMobile: isMobile);
      default:
        return _buildReadingTab(isMobile: isMobile);
    }
  }

  // Responsive version of reading tab
  Widget _buildReadingTab({bool isMobile = false}) {
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
                'En cours de lecture',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              SizedBox(height: isMobile ? 10 : 16),
              if (isLoadingCurrentlyReading)
                const Center(child: CircularProgressIndicator())
              else if (currentlyReading.isEmpty)
                Text(
                  'Aucun livre en cours de lecture.',
                  style: TextStyle(
                    fontFamily: "PRegular",
                    fontSize: isMobile ? 13 : 16,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile
                        ? 1
                        : (MediaQuery.of(context).size.width >= 768 ? 2 : 1),
                    crossAxisSpacing: isMobile ? 12 : 24,
                    mainAxisSpacing: isMobile ? 12 : 24,
                    childAspectRatio: isMobile ? 2.2 : 2.5,
                  ),
                  itemCount: currentlyReading.length,
                  itemBuilder: (context, index) {
                    final book = currentlyReading[index];
                    return Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isMobile ? 40 : 64,
                            height: isMobile ? 60 : 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.book,
                              color: Color(0xFF9CA3AF),
                              size: 32,
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: "PBold",
                                  ),
                                ),
                                SizedBox(height: isMobile ? 2 : 4),
                                Text(
                                  book['author'] ?? '',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 14,
                                    color: Color(0xFF6B7280),
                                    fontFamily: "PRegular",
                                  ),
                                ),
                                SizedBox(height: isMobile ? 6 : 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progression',
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 14,
                                        fontFamily: "PRegular",
                                      ),
                                    ),
                                    Text(
                                      '${book['progress'] ?? 0}%',
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 14,
                                        fontFamily: "PRegular",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isMobile ? 2 : 4),
                                LinearProgressIndicator(
                                  value: (book['progress'] ?? 0) / 100,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFF97316),
                                      ),
                                ),
                                SizedBox(height: isMobile ? 6 : 12),
                                ElevatedButton(
                                  onPressed: () => widget.onNavigate('reader'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 10 : 16,
                                      vertical: isMobile ? 6 : 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: isMobile ? 12 : 14,
                                      fontFamily: "PBold",
                                    ),
                                  ),
                                  child: const Text(
                                    'Continuer la lecture',
                                    style: TextStyle(fontFamily: "PBold"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Responsive purchased tab
  Widget _buildPurchasedTab({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Livres achetés',
            style: TextStyle(
              fontSize: isMobile ? 16 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: "PBold",
            ),
          ),
          SizedBox(height: isMobile ? 16 : 32),
          if (isLoadingPurchased)
            const Center(child: CircularProgressIndicator())
          else if (purchasedBooks.isEmpty)
            Center(
              child: Text(
                'Aucun livre acheté pour le moment',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 18,
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile
                    ? 1
                    : (MediaQuery.of(context).size.width > 900 ? 2 : 2),
                crossAxisSpacing: isMobile ? 12 : 32,
                mainAxisSpacing: isMobile ? 12 : 32,
                childAspectRatio: isMobile ? 1.7 : 2.2,
              ),
              itemCount: purchasedBooks.length,
              itemBuilder: (context, index) {
                final book = purchasedBooks[index];
                final coverUrl =
                    (book['cover_path'] != null &&
                        book['cover_path'].toString().isNotEmpty)
                    ? (book['cover_path'].toString().startsWith('http')
                          ? book['cover_path']
                          : '$baseUrl/${book['cover_path']}')
                    : null;
                return Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                        child: coverUrl != null
                            ? Image.network(
                                coverUrl,
                                width: isMobile ? 48 : 80,
                                height: isMobile ? 72 : 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: isMobile ? 48 : 80,
                                  height: isMobile ? 72 : 120,
                                  color: const Color(0xFFE5E7EB),
                                  child: const Icon(
                                    Icons.book,
                                    color: Color(0xFF9CA3AF),
                                    size: 36,
                                  ),
                                ),
                              )
                            : Container(
                                width: isMobile ? 48 : 80,
                                height: isMobile ? 72 : 120,
                                color: const Color(0xFFE5E7EB),
                                child: const Icon(
                                  Icons.book,
                                  color: Color(0xFF9CA3AF),
                                  size: 36,
                                ),
                              ),
                      ),
                      SizedBox(width: isMobile ? 10 : 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              book['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: "PBold",
                              ),
                            ),
                            SizedBox(height: isMobile ? 3 : 4),
                            Text(
                              book['author_bio'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 14,
                                color: Color(0xFF6B7280),
                                fontFamily: "PRegular",
                              ),
                            ),
                            SizedBox(height: isMobile ? 4 : 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if ((book['genre'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(
                                      book['genre'],
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    labelStyle: const TextStyle(
                                      fontFamily: "PRegular",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 6 : 8,
                                      vertical: 0,
                                    ),
                                  ),
                                if ((book['language'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(
                                      book['language'],
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    labelStyle: const TextStyle(
                                      fontFamily: "PRegular",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 6 : 8,
                                      vertical: 0,
                                    ),
                                  ),
                                if ((book['plan'] ?? '').isNotEmpty)
                                  Chip(
                                    label: Text(
                                      book['plan'],
                                      style: TextStyle(
                                        fontSize: isMobile ? 10 : 11,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    labelStyle: const TextStyle(
                                      fontFamily: "PRegular",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 6 : 8,
                                      vertical: 0,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 4 : 6),
                            Text(
                              book['summary'] ?? '',
                              maxLines: isMobile ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "PRegular",
                                color: Color(0xFF374151),
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                            SizedBox(height: isMobile ? 6 : 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Acheté le ${book['purchased_at'] != null ? DateTime.parse(book['purchased_at']).toLocal().toString().substring(0, 10) : ''}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12,
                                    color: Color(0xFF9CA3AF),
                                    fontFamily: "PRegular",
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final fileUrl =
                                        book['file_path'] != null &&
                                            book['file_path']
                                                .toString()
                                                .isNotEmpty
                                        ? (book['file_path']
                                                  .toString()
                                                  .startsWith('http')
                                              ? book['file_path']
                                              : '$baseUrl/${book['file_path']}')
                                        : null;
                                    if (fileUrl != null) {
                                      widget.onNavigate(
                                        'reader',
                                        book,
                                      ); // Passe le livre sélectionné ici
                                    }
                                  },
                                  icon: const Icon(Icons.menu_book, size: 18),
                                  label: const Text('Lire'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF97316),
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                      fontFamily: "PBold",
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 10 : 18,
                                      vertical: isMobile ? 8 : 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
              },
            ),
        ],
      ),
    );
  }

  // Responsive settings tab
  Widget _buildSettingsTab({bool isMobile = false}) {
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
                'Informations personnelles',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontFamily: "PRegular"),
                    ),
                    controller: _nameController,
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  TextField(
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontFamily: "PRegular"),
                    ),
                    controller: TextEditingController(
                      text: widget.user?.email ?? '',
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 16),
                  ElevatedButton(
                    onPressed: isSavingProfile ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontFamily: "PBold"),
                    ),
                    child: isSavingProfile
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sauvegarder les modifications',
                            style: TextStyle(fontFamily: "PBold"),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 32),
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
                'Notifications',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Nouvelles sorties',
                      style: TextStyle(fontFamily: "PBold"),
                    ),
                    subtitle: const Text(
                      'Recevoir des notifications pour les nouveaux livres',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: const Color(0xFFF97316),
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Recommandations',
                      style: TextStyle(fontFamily: "PBold"),
                    ),
                    subtitle: const Text(
                      'Suggestions personnalisées basées sur vos lectures',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: const Color(0xFFF97316),
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Rappels de lecture',
                      style: TextStyle(fontFamily: "PBold"),
                    ),
                    subtitle: const Text(
                      'Rappels pour continuer vos lectures en cours',
                      style: TextStyle(fontFamily: "PRegular"),
                    ),
                    value: false,
                    onChanged: (value) {},
                    activeThumbColor: const Color(0xFFF97316),
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
