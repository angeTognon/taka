import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka2/widgets/const.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AffiliateScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool isLoggedIn;
  final int userId; // Ajoute ce paramètre pour passer l'id utilisateur

  const AffiliateScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    required this.userId,
  });

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen> {
  String selectedPeriod = 'month';
  String copiedLink = '';
  bool isLoading = false;
  bool isCreating = false;

  final Map<String, dynamic> stats = {
    'totalClicks': 0,
    'conversions': 0,
    'conversionRate': 0.0,
    'totalEarnings': 0,
    'pendingPayment': 0,
    'thisMonthEarnings': 0,
  };

  List<Map<String, dynamic>> affiliateLinks = [];

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _fetchAffiliateLinks();
      _fetchAffiliateStats(); // Ajouté
    }
  }
  Future<void> _fetchAffiliateLinks() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/taka_api_list_affiliate_links.php?user_id=${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          affiliateLinks = List<Map<String, dynamic>>.from(data['links'] ?? []);
        });
      }
    } catch (e) {
      // Optionally show error
    }
    setState(() => isLoading = false);
  }

    Future<void> _createAffiliateLink({
    required String title,
    required String type,
    String? bookId,
  }) async {
    setState(() => isCreating = true);
    try {
      final body = {
        'user_id': widget.userId,
        'type': type,
        'title': title,
        if (type == 'book' && bookId != null && bookId.isNotEmpty) 'book_id': int.parse(bookId),
      };
      final response = await http.post(
      Uri.parse('$baseUrl/taka_api_create_affiliate_link.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _fetchAffiliateLinks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lien créé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur lors de la création')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
    setState(() => isCreating = false);
  }

  
Future<void> _fetchAffiliateStats() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_affiliate_stats.php?user_id=${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        stats['totalClicks'] = data['totalClicks'];
        stats['conversions'] = data['conversions'];
        stats['conversionRate'] = data['conversionRate'];
        stats['totalEarnings'] = data['totalEarnings'];
        stats['pendingPayment'] = data['pendingPayment'];
        stats['thisMonthEarnings'] = data['thisMonthEarnings'];
      });
    }
  } catch (e) {
    // Optionally show error
  }
}

  @override
  Widget build(BuildContext context) {
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
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous devez être connecté pour accéder au programme d\'affiliation.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => widget.onNavigate('login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontFamily: "PRegular"),
                ),
                child: const Text('Se connecter', style: TextStyle(fontFamily: "PRegular")),
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
          margin: const EdgeInsets.symmetric(horizontal: 100),
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStatsCards(),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildAffiliateLinks(),
                        const SizedBox(height: 32),
                        _buildPerformanceChart(),
                      ],
                    ),
                  ),
                  if (MediaQuery.of(context).size.width >= 1024) ...[
                    const SizedBox(width: 32),
                    SizedBox(
                      width: 320,
                      child: _buildSidebar(),
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

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Programme d\'affiliation TAKA',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: "PBold",
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Gagnez de l\'argent en recommandant TAKA à votre audience',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
            fontFamily: "PRegular",
          ),
        ),
      ],
    );
  }

        Widget _buildStatsCards() {
      final statsData = [
        {
          'title': 'Clics totaux',
          'value': (stats['totalClicks'] ?? 0).toString(),
          'icon': Icons.visibility,
          'color': const Color(0xFF3B82F6),
        },
        {
          'title': 'Conversions',
          'value': (stats['conversions'] ?? 0).toString(),
          'icon': Icons.trending_up,
          'color': const Color(0xFF10B981),
        },
        {
          'title': 'Gains totaux',
          'value': '${(stats['totalEarnings'] ?? 0)} FCFA',
          'icon': Icons.attach_money,
          'color': const Color(0xFFF97316),
        },
        {
          'title': 'En attente',
          'value': '${(stats['totalEarnings'] ?? 0)} FCFA',
          'icon': Icons.schedule,
          'color': const Color(0xFFFBBF24),
        },
      ];
    
      return GridView.builder(
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
          childAspectRatio: 2.5,
        ),
        itemCount: statsData.length,
        itemBuilder: (context, index) {
          final stat = statsData[index];
          return Container(
            padding: const EdgeInsets.all(24),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontFamily: "PRegular",
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.2,
                          fontFamily: "PBold",
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  Widget _buildAffiliateLinks() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes liens d\'affiliation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              ElevatedButton(
                onPressed: isCreating ? null : _showAddLinkDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 14, fontFamily: "PRegular"),
                ),
                child: isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Créer un nouveau lien', style: TextStyle(fontFamily: "PRegular")),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (affiliateLinks.isEmpty)
            const Text('Aucun lien d\'affiliation pour le moment.')
                    // ...existing code...
          else
            ...affiliateLinks.map((link) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
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
                              link['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: "PBold",
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      link['url'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _copyToClipboard(link['url'] ?? '', link['id']),
                                        icon: Icon(
                                          copiedLink == (link['id']?.toString() ?? '')
                                              ? Icons.check_circle
                                              : Icons.copy,
                                          size: 16,
                                          color: const Color(0xFFF97316),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _openLink(link['url'] ?? ''),
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                       IconButton(
                            onPressed: () => _showEditLinkDialog(link),
                            icon: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                                                    IconButton(
                            onPressed: () => _showDeleteLinkDialog(link),
                            icon: const Icon(
                              Icons.delete,
                              size: 16,
                              color: Color(0xFFF87171),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Clics',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Color(0xFF6B7280),
                  //               fontFamily: "PRegular",
                  //             ),
                  //           ),
                  //           Text(
                  //             (link['clicks'] ?? 0).toString(),
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.w600,
                  //               fontFamily: "PBold",
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Conversions',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Color(0xFF6B7280),
                  //               fontFamily: "PRegular",
                  //             ),
                  //           ),
                  //           Text(
                  //            (stats['conversions'] ?? 0).toString(),
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.w600,
                  //               fontFamily: "PBold",
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Gains',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Color(0xFF6B7280),
                  //               fontFamily: "PRegular",
                  //             ),
                  //           ),
                  //           Text(
                  //             '${((stats['totalEarnings'] ?? 0) / 1000).round()}k FCFA',
                  //             style: const TextStyle(
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.w600,
                  //               fontFamily: "PBold",
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            )),
        ],
      ),
    );
  }
    void _showDeleteLinkDialog(Map<String, dynamic> link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Supprimer le lien',style: TextStyle(fontFamily: "PBold",fontSize: 19),),
        content: const Text('Voulez-vous vraiment supprimer ce lien d\'affiliation ?',style: TextStyle(fontFamily: "PRegular"),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',style: TextStyle(fontFamily: "PBold"),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF87171),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAffiliateLink(link['id']);
            },
            child: const Text('Supprimer',style: TextStyle(fontFamily: "PBold"),),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAffiliateLink(dynamic linkId) async {
    setState(() => isCreating = true);
    try {
      final body = {'link_id': linkId, 'user_id': widget.userId};
      final response = await http.post(
        Uri.parse('$baseUrl/taka_api_delete_affiliate_link.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _fetchAffiliateLinks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lien supprimé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur lors de la suppression')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
    setState(() => isCreating = false);
  }
  void _showEditLinkDialog(Map<String, dynamic> link) {
    String title = link['title'] ?? '';
    String type = link['type'] ?? 'subscription';
    String? selectedBookId = link['book_id']?.toString();
    List<Map<String, dynamic>> authorBooks = [];
    bool isLoadingBooks = false;
    bool dialogActive = true;
  
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          Future<void> loadBooks() async {
            if (!isLoadingBooks && authorBooks.isEmpty && type == 'book') {
              setStateDialog(() => isLoadingBooks = true);
              final books = await fetchAuthorBooks(widget.userId);
              if (!dialogActive) return;
              setStateDialog(() {
                authorBooks = books;
                isLoadingBooks = false;
              });
            }
          }
  
          if (type == 'book' && authorBooks.isEmpty && !isLoadingBooks) {
            loadBooks();
          }
  
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Modifier le lien',
                style: TextStyle(fontFamily: "PBold", fontSize: 18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Titre du lien'),
                  controller: TextEditingController(text: title),
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  style: TextStyle(fontFamily: "PRegular"),
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type de lien'),
                  items: const [ 
                    // DropdownMenuItem(value: 'subscription', child: Text('Page d\'abonnement')),
                    DropdownMenuItem(value: 'book', child: Text('Livre spécifique')),
                  ],
                  onChanged: (value) {
                    setStateDialog(() {
                      type = value ?? 'subscription';
                      selectedBookId = null;
                    });
                  },
                ),
                if (type == 'book') ...[
                  const SizedBox(height: 12),
                  isLoadingBooks
                      ? const Center(child: CircularProgressIndicator())
                      : authorBooks.isEmpty
                          ? const Text('Aucun livre publié.')
                          : DropdownButtonFormField<String>(
                              value: selectedBookId,
                              decoration: const InputDecoration(labelText: 'Sélectionner un livre'),
                              items: authorBooks
                                  .map((book) => DropdownMenuItem(
                                        value: book['id'].toString(),
                                        child: Text(book['title']),
                                      ))
                                  .toList(),
                              onChanged: (value) => setStateDialog(() => selectedBookId = value),
                            ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  dialogActive = false;
                  Navigator.pop(context);
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (title.isEmpty) return;
                  if (type == 'book' && (selectedBookId == null || selectedBookId!.isEmpty)) return;
                  dialogActive = false;
                  _editAffiliateLink(
                    linkId: link['id'],
                    title: title,
                    type: type,
                    bookId: selectedBookId,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
  }
    Future<void> _editAffiliateLink({
    required dynamic linkId,
    required String title,
    required String type,
    String? bookId,
  }) async {
    setState(() => isCreating = true);
    try {
      final body = {
        'link_id': linkId,
        'user_id': widget.userId,
        'type': type,
        'title': title,
        if (type == 'book' && bookId != null && bookId.isNotEmpty) 'book_id': int.parse(bookId),
      };
      final response = await http.post(
        Uri.parse('$baseUrl/taka_api_edit_affiliate_link.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _fetchAffiliateLinks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lien modifié avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur lors de la modification')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
    setState(() => isCreating = false);
  }
    Future<List<Map<String, dynamic>>> fetchAuthorBooks(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_get_author_book.php?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['books'] ?? []);
    }
    return [];
  }

  void _showAddLinkDialog() {
      String title = '';
      String type = 'book';
      String? selectedBookId;
      List<Map<String, dynamic>> authorBooks = [];
      bool isLoadingBooks = false;
      bool dialogActive = true;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> loadBooks() async {
              if (!isLoadingBooks && authorBooks.isEmpty && type == 'book') {
                setStateDialog(() => isLoadingBooks = true);
                final books = await fetchAuthorBooks(widget.userId);
                if (!dialogActive) return; // <-- Ajouté
                setStateDialog(() {
                  authorBooks = books;
                  isLoadingBooks = false;
                });
              }
            }
            if (type == 'book' && authorBooks.isEmpty && !isLoadingBooks) {
              loadBooks();
            }
            return AlertDialog(
              backgroundColor: Colors.white,
              title:  Text('Créer un nouveau lien',
                    style: TextStyle(fontFamily: "PBold",fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Titre du lien'),
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    style: TextStyle(fontFamily: "PRegular"),
                    value: type,
                    decoration: const InputDecoration(labelText: 'Type de lien'),
                    items: const [
                      // DropdownMenuItem(value: 'general', child: Text('Lien général TAKA')),
                      // DropdownMenuItem(value: 'subscription', child: Text('Page d\'abonnement')),
                      DropdownMenuItem(value: 'book', child: Text('Livre spécifique')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        type = value ?? 'subscription';
                        selectedBookId = null;
                      });
                    },
                  ),
                  if (type == 'book') ...[
                    const SizedBox(height: 12),
                    isLoadingBooks
                        ? const Center(child: CircularProgressIndicator())
                        : authorBooks.isEmpty
                            ? const Text('Aucun livre publié.')
                            : DropdownButtonFormField<String>(
                                value: selectedBookId,
                                decoration: const InputDecoration(labelText: 'Sélectionner un livre'),
                                items: authorBooks
                                    .map((book) => DropdownMenuItem(
                                          value: book['id'].toString(),
                                          child: Text(book['title']),
                                        ))
                                    .toList(),
                                onChanged: (value) => setStateDialog(() => selectedBookId = value),
                              ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogActive = false; // <-- Ajouté
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () {
                          if (title.isEmpty) return;
                          if (type == 'book' && (selectedBookId == null || selectedBookId!.isEmpty)) return;
                          dialogActive = false; // <-- Ajouté
                          _createAffiliateLink(title: title, type: type, bookId: selectedBookId);
                          Navigator.pop(context);
                        },
                  child: isCreating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Ajouter'),
                ),
              ],
            );
          },
        ),
      );
    }

  void _copyToClipboard(String text, dynamic linkId) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() => copiedLink = linkId.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lien copié dans le presse-papiers', style: TextStyle(fontFamily: "PRegular")),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => copiedLink = '');
    });
  }

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }
Widget _buildPerformanceChart() {
    final monthlyData = [
      {'month': 'Jan', 'earnings': 12500},
      {'month': 'Fév', 'earnings': 18900},
      {'month': 'Mar', 'earnings': 28900},
      {'month': 'Avr', 'earnings': 22100},
      {'month': 'Mai', 'earnings': 31200},
      {'month': 'Jun', 'earnings': 35600},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Évolution des gains',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              DropdownButton<String>(
                value: selectedPeriod,
                onChanged: (value) => setState(() => selectedPeriod = value!),
                items: const [
                  DropdownMenuItem(value: 'week', child: Text('Cette semaine', style: TextStyle(fontFamily: "PRegular"))),
                  DropdownMenuItem(value: 'month', child: Text('Ce mois', style: TextStyle(fontFamily: "PRegular"))),
                  DropdownMenuItem(value: 'year', child: Text('Cette année', style: TextStyle(fontFamily: "PRegular"))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyData.map((data) {
                final maxEarnings = monthlyData.map((d) => d['earnings'] as int).reduce((a, b) => a > b ? a : b);
                final height = ((data['earnings'] as int) / maxEarnings) * 160;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
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
                        const SizedBox(height: 8),
                        Text(
                          data['month'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontFamily: "PRegular",
                          ),
                        ),
                        Text(
                          '${((data['earnings'] as int) / 1000).round()}k',
                          style: const TextStyle(
                            fontSize: 12,
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

  Widget _buildSidebar() {
    return Column(
      children: [
        // Quick Stats
        // Container(
        //   padding: const EdgeInsets.all(24),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: const [
        //       BoxShadow(
        //         color: Color(0x0A000000),
        //         blurRadius: 8,
        //         offset: Offset(0, 1),
        //       ),
        //     ],
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Text(
        //         'Mon Portefeuille Taka',
        //         style: TextStyle(
        //           fontSize: 18,
        //           fontWeight: FontWeight.w600,
        //           color: Colors.black,
        //           fontFamily: "PBold",
        //         ),
        //       ),
        //       const SizedBox(height: 16),
        //       Column(
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               const Text(
        //                 'Gains',
        //                 style: TextStyle(color: Color(0xFF6B7280), fontFamily: "PRegular"),
        //               ),
        //               Text(
        //                 '+${(stats['thisMonthEarnings'] / 1000).round()}k FCFA',
        //                 style: const TextStyle(
        //                   fontWeight: FontWeight.w600,
        //                   color: Color(0xFF10B981),
        //                   fontFamily: "PBold",
        //                 ),
        //               ),
        //             ],
        //           ),
        //           const SizedBox(height: 16),
        //           const Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Text(
        //                 'Nouveaux clics',
        //                 style: TextStyle(color: Color(0xFF6B7280), fontFamily: "PRegular"),
        //               ),
        //               Text(
        //                 '+234',
        //                 style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "PBold"),
        //               ),
        //             ],
        //           ),
        //           const SizedBox(height: 16),
        //           const Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Text(
        //                 'Conversions',
        //                 style: TextStyle(color: Color(0xFF6B7280), fontFamily: "PRegular"),
        //               ),
        //               Text(
        //                 '+18',
        //                 style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "PBold"),
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
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
              const Text(
                'Structure des commissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              const SizedBox(height: 16),
              const Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Abonnement Essentielle', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                  //     Text('400 FCFA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "PBold")),
                  //   ],
                  // ),
                  // SizedBox(height: 12),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Abonnement Confort', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                  //     Text('700 FCFA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "PBold")),
                  //   ],
                  // ),
                  // SizedBox(height: 12),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Abonnement Illimitée', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                  //     Text('1.000 FCFA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "PBold")),
                  //   ],
                  // ),
                  // SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Achat de livre', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                      Text('20% du prix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: "PBold")),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Payment Info
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informations de paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: "PBold",
                ),
              ),
              const SizedBox(height: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fréquence: Mensuelle', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                  SizedBox(height: 8),
                  Text('Seuil minimum: 10.000 FCFA', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                  SizedBox(height: 8),
                  Text('Méthode: Mobile Money / Virement', style: TextStyle(fontSize: 14, fontFamily: "PRegular")),
                ],
              ),
              // const SizedBox(height: 16),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFFF97316),
              //       foregroundColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(vertical: 8),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       textStyle: const TextStyle(fontFamily: "PRegular"),
              //     ),
              //     child: const Text('Modifier les infos de paiement', style: TextStyle(fontFamily: "PRegular")),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
  
  // ... _buildPerformanceChart() et _buildSidebar() restent inchangés ...
  // (reprends-les de ta version précédente)
}