import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taka2/widgets/const.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class TakaAdmin extends StatefulWidget {
  const TakaAdmin({super.key});

  @override
  State<TakaAdmin> createState() => _TakaAdminState();
}

class _TakaAdminState extends State<TakaAdmin> {
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
    fetchStats();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_admin_books.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        books = List<Map<String, dynamic>>.from(data['books']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> validateBook(int bookId) async {
    setState(() {
      isValidating = true;
      validatingBookId = bookId;
    });
    final response = await http.post(
      Uri.parse('$baseUrl/taka_api_admin_books.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'validate', 'book_id': bookId}),
    );
    setState(() {
      isValidating = false;
      validatingBookId = null;
    });
    if (response.statusCode == 200) {
      fetchBooks();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Livre validé !')));
    }
  }

  bool isValidating = false;
  int? validatingBookId;
  int totalUsers = 0;
  int totalBooks = 0;
  int totalPending = 0;
  int totalValidated = 0;
  Future<void> fetchStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/taka_api_admin_stats.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalUsers = data['total_users'] ?? 0;
        totalBooks = data['total_books'] ?? 0;
        totalPending = data['total_pending'] ?? 0;
        totalValidated = data['total_validated'] ?? 0;
      });
    }
  }

  Widget _adminStatItem(
    String label,
    int value,
    IconData icon,
    Color color, {
    required bool isMobile,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isMobile ? 32 : 48),
        SizedBox(height: isMobile ? 2 : 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
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
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administration TAKA',
          style: TextStyle(
            fontFamily: "PBold",
            fontSize: isMobile ? 18 : 22,
            color: Color(0xFFF97316),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
          ? const Center(child: Text('Aucun livre à afficher.'))
          : Column(
              children: [
                SizedBox(height: isMobile ? 10 : 15),
                _buildStatsSection(isMobile),
                SizedBox(height: isMobile ? 15 : 20),
                Expanded(child: _buildBooksGrid(isMobile)),
              ],
            ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 4 : 8,
      ),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 12 : 18,
            horizontal: isMobile ? 16 : 24,
          ),
          child: isMobile ? _buildMobileStats() : _buildDesktopStats(),
        ),
      ),
    );
  }

  Widget _buildMobileStats() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _adminStatItem(
              'Utilisateurs',
              totalUsers,
              Icons.person,
              Colors.blue,
              isMobile: true,
            ),
            _adminStatItem(
              'Livres',
              totalBooks,
              Icons.menu_book,
              Colors.orange,
              isMobile: true,
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _adminStatItem(
              'En attente',
              totalPending,
              Icons.hourglass_top,
              Colors.amber,
              isMobile: true,
            ),
            _adminStatItem(
              'Validés',
              totalValidated,
              Icons.check_circle,
              Colors.green,
              isMobile: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _adminStatItem(
          'Utilisateurs',
          totalUsers,
          Icons.person,
          Colors.blue,
          isMobile: false,
        ),
        _adminStatItem(
          'Livres publiés',
          totalBooks,
          Icons.menu_book,
          Colors.orange,
          isMobile: false,
        ),
        _adminStatItem(
          'En attente',
          totalPending,
          Icons.hourglass_top,
          Colors.amber,
          isMobile: false,
        ),
        _adminStatItem(
          'Validés',
          totalValidated,
          Icons.check_circle,
          Colors.green,
          isMobile: false,
        ),
      ],
    );
  }

  Widget _buildBooksGrid(bool isMobile) {
    return GridView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile
            ? 1
            : (MediaQuery.of(context).size.width >= 1200 ? 4 : 3),
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
        childAspectRatio: isMobile ? 1.2 : 0.9,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(book, isMobile);
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, bool isMobile) {
    if (isMobile) {
      return _buildMobileBookCard(book);
    } else {
      return _buildDesktopBookCard(book);
    }
  }

  Widget _buildMobileBookCard(Map<String, dynamic> book) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du livre
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child:
                  book['cover_path'] != null &&
                      book['cover_path'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$baseUrl/${book['cover_path']}',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, color: Colors.grey),
                        ),
                      ),
                    )
                  : const Icon(Icons.book, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            // Contenu du livre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PBold",
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auteur: ${book['author_bio'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "PRegular",
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Genre: ${book['genre'] ?? ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Statut: ${book['statut_validation'] ?? 'En attente'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: book['statut_validation'] == 'Validé'
                          ? Colors.green
                          : Colors.orange,
                      fontFamily: "PRegular",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prix : ${book['price'] ?? 'N/A'} FCFA',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: "PBold",
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMobileActionButtons(book),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopBookCard(Map<String, dynamic> book) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book['cover_path'] != null &&
                book['cover_path'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  '$baseUrl/taka/${book['cover_path']}',
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              book['title'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "PBold",
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Auteur: ${book['author_bio'] ?? ''}',
              style: const TextStyle(fontSize: 13, fontFamily: "PRegular"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Genre: ${book['genre'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Langue: ${book['language'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Statut: ${book['statut_validation'] ?? 'En attente'}',
              style: TextStyle(
                fontSize: 12,
                color: book['statut_validation'] == 'Validé'
                    ? Colors.green
                    : Colors.orange,
                fontFamily: "PRegular",
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                book['summary'] ?? '',
                style: const TextStyle(fontSize: 12, fontFamily: "PRegular"),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prix : ${book['price'] ?? 'N/A'} FCFA',
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: "PBold",
                    color: Colors.orange,
                  ),
                ),
                _buildDesktopActionButtons(book),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileActionButtons(Map<String, dynamic> book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (book['statut_validation'] != 'Validé')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => validateBook(int.parse(book['id'].toString())),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('Valider', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        if (book['statut_validation'] != 'Validé') const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showBookDetailsDialog(book),
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('Détails', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ),
        if (isValidating &&
            validatingBookId == int.parse(book['id'].toString()))
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopActionButtons(Map<String, dynamic> book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (book['statut_validation'] != 'Validé')
          ElevatedButton.icon(
            onPressed: () => validateBook(int.parse(book['id'].toString())),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Valider', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showBookDetailsDialog(book),
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('i', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(12, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (isValidating &&
            validatingBookId == int.parse(book['id'].toString()))
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  void _showBookDetailsDialog(Map<String, dynamic> book) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 400),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      book['title'] ?? '',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "PBold",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Nom du publieur : ${book['author_name'] ?? 'Non disponible'}',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontFamily: "PBold",
                ),
              ),
              Text(
                'Email : ${book['author_email'] ?? 'Non disponible'}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: const Color.fromARGB(255, 36, 36, 36),
                ),
              ),
              Text(
                'Inscrit le : ${book['author_created_at'] ?? ''}',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  color: const Color.fromARGB(255, 36, 36, 36),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prix : ${book['price'] ?? 'N/A'} FCFA',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontFamily: "PBold",
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Résumé :\n${book['summary'] ?? ''}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontFamily: "PRegular",
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = '$baseUrl/taka/${book['file_path']}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  label: Text(
                    'Voir le livre',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Future<void> payoutToAuthor(Map<String, dynamic> book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/taka_api_payout_init.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'author_id': book['author_id'].toString(),
        'email': book['author_email'] ?? '',
        'first_name': (book['author_name'] ?? '').toString().split(' ').first,
        'last_name':
            (book['author_name'] ?? '').toString().split(' ').length > 1
            ? (book['author_name'] ?? '').toString().split(' ').last
            : '',
        'amount': int.tryParse(book['price'].toString()) ?? 0,
        'currency': 'USD',
        'description': 'Versement test Moneroo',
        'method': 'moneroo_payout_demo',
        'recipient': {
          'account_number':
              '4149518162', // <-- doit être un objet, pas une liste
        },
      }),
    );
    print('Payout response: ${response.body}');
    final data = json.decode(response.body);
    final isSuccess =
        data['success'] == true ||
        (data['message']?.toString().toLowerCase().contains('successfully') ??
            false);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Versement initié ! Transaction ID : ${data['data']?['id'] ?? ''}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur versement : ${data['message'] ?? data['error'] ?? 'Erreur inconnue'}',
          ),
        ),
      );
    }
  }
}
