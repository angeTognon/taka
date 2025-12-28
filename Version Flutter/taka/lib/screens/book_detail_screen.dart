import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:taka2/models/user_model.dart';
import 'package:taka2/widgets/const.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final bool isLoggedIn;
  final UserModel? user;
  final Function(String, [Map<String, dynamic>?]) onNavigate;
  final bool isFromDirectUrl;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.isLoggedIn,
    required this.user,
    required this.onNavigate,
    this.isFromDirectUrl = false,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  List<Map<String, dynamic>> authorBooks = [];
  List<Map<String, dynamic>> categoryBooks = [];
  bool isLoadingAuthorBooks = true;
  bool isLoadingCategoryBooks = true;
  bool isPurchased = false;
  bool isBookPaying = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedBooks();
    _checkIfPurchased();
  }

  Future<void> _checkIfPurchased() async {
    if (!widget.isLoggedIn || widget.user == null) {
      setState(() => isPurchased = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/taka_api_user_books.php?user_id=${widget.user!.id}',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['books'] is List) {
          final purchasedBookIds = List<int>.from(
            data['books'].map((e) => int.tryParse(e.toString()) ?? 0),
          );

          final int bookId = widget.book['id'] is int
              ? widget.book['id']
              : int.tryParse('${widget.book['id']}') ?? 0;

          setState(() {
            isPurchased = purchasedBookIds.contains(bookId);
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification du statut d\'achat: $e');
    }
  }

  Future<void> _loadRelatedBooks() async {
    // Charger les livres du même auteur
    _loadAuthorBooks();
    // Charger les livres de la même catégorie
    _loadCategoryBooks();
  }

  Future<void> _loadAuthorBooks() async {
    setState(() => isLoadingAuthorBooks = true);
    try {
      // Utiliser user_id au lieu de author pour filtrer correctement
      final userId = widget.book['user_id'] ?? '';
      if (userId == null || userId.toString().isEmpty) {
        setState(() => isLoadingAuthorBooks = false);
        return;
      }

      // Utiliser l'API des livres d'auteur avec période 'all' pour récupérer tous les livres
      final response = await http.get(
        Uri.parse(
          '$baseUrl/taka_api_author_books.php?user_id=$userId&period=all',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['books'] != null) {
          final List<dynamic> books = data['books'] ?? [];
          setState(() {
            // Filtrer pour exclure le livre actuel et ne garder que les livres publiés
            // Retirer .take(5) pour afficher TOUS les livres du même auteur
            authorBooks = books
                .where(
                  (b) => b['id'].toString() != widget.book['id'].toString(),
                )
                .where(
                  (b) =>
                      b['statut_validation'] == 'Publié' ||
                      b['statut_validation'] == 'approved' ||
                      b['statut_validation'] == 'Validé',
                )
                .map((b) => b as Map<String, dynamic>)
                .toList();
            isLoadingAuthorBooks = false;
          });
        } else {
          setState(() => isLoadingAuthorBooks = false);
        }
      } else {
        setState(() => isLoadingAuthorBooks = false);
      }
    } catch (e) {
      print('Error loading author books: $e');
      setState(() => isLoadingAuthorBooks = false);
    }
  }

  Future<void> _loadCategoryBooks() async {
    setState(() => isLoadingCategoryBooks = true);
    try {
      final genre = widget.book['genre'] ?? '';
      final response = await http.get(
        Uri.parse(
          '$baseUrl/taka_api_books.php?genre=${Uri.encodeComponent(genre)}&per_page=6',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> books = data['books'] ?? [];
        setState(() {
          categoryBooks = books
              .where((b) => b['id'].toString() != widget.book['id'].toString())
              .take(6)
              .map((b) => b as Map<String, dynamic>)
              .toList();
          isLoadingCategoryBooks = false;
        });
      }
    } catch (e) {
      print('Error loading category books: $e');
      setState(() => isLoadingCategoryBooks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final String title = widget.book['title'] ?? '';
    final String author = widget.book['author'] ?? '';
    final String genre = widget.book['genre'] ?? '';
    final String summary = widget.book['summary'] ?? '';
    final String priceType = widget.book['price_type']?.toString() ?? '';
    final String price = widget.book['price']?.toString() ?? '';
    final int pages =
        int.tryParse(widget.book['pages']?.toString() ?? '0') ?? 0;
    final String? coverPath = widget.book['cover_path'] as String?;
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;
    final String authorBio = widget.book['author_bio'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            widget.isFromDirectUrl ? Icons.home : Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            if (widget.isFromDirectUrl) {
              widget.onNavigate('home');
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          // Bouton share - toujours visible sur mobile et desktop
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _shareBook(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.share,
                  color: Color(0xFFF97316),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section principale avec image et détails
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 100,
                vertical: isMobile ? 20 : 40,
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildBookCover(imageUrl, isMobile),
                        const SizedBox(height: 24),
                        _buildBookInfo(
                          title,
                          author,
                          genre,
                          pages,
                          price,
                          priceType,
                          summary,
                          isMobile,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBookCover(imageUrl, isMobile),
                        const SizedBox(width: 60),
                        Expanded(
                          child: _buildBookInfo(
                            title,
                            author,
                            genre,
                            pages,
                            price,
                            priceType,
                            summary,
                            isMobile,
                          ),
                        ),
                      ],
                    ),
            ),

            // Section "À propos de l'auteur"
            if (authorBio.isNotEmpty)
              _buildAuthorSection(author, authorBio, isMobile),

            // Section "Livres du même auteur"
            if (authorBooks.isNotEmpty) _buildAuthorBooksSection(isMobile),

            // Section "Livres de la même catégorie"
            if (categoryBooks.isNotEmpty)
              _buildCategoryBooksSection(genre, isMobile),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover(String? imageUrl, bool isMobile) {
    return Column(
      children: [
        Container(
          width: isMobile ? 200 : 280,
          height: isMobile ? 280 : 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.book['excerpt'] != null &&
            widget.book['excerpt'].toString().isNotEmpty)
          OutlinedButton(
            onPressed: () => _showExcerpt(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF97316),
              side: const BorderSide(color: Color(0xFFF97316)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lire un extrait',
              style: TextStyle(fontFamily: "PRegular", fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Icon(Icons.book, size: 80, color: Color(0xFF9CA3AF)),
    );
  }

  Widget _buildBookInfo(
    String title,
    String author,
    String genre,
    int pages,
    String price,
    String priceType,
    String summary,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 20 : 32,
            fontWeight: FontWeight.bold,
            fontFamily: "PBold",
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Évaluation (placeholder)
        Row(
          children: [
            ...List.generate(
              5,
              (index) => const Icon(
                Icons.star_border,
                color: Color(0xFFF97316),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Aucune évaluation',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontFamily: "PRegular",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Auteur et catégorie
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: "PRegular",
            ),
            children: [
              const TextSpan(
                text: 'de ',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              TextSpan(
                text: author,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: "PBold",
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(
                text: ' • ',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              TextSpan(
                text: genre,
                style: const TextStyle(fontFamily: "PBold"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Prix et pages
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                priceType == 'gratuit' ? 'Gratuit' : '$price FCFA',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "PBold",
                  color: const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'le livre complet / $pages pages',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontFamily: "PRegular",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Description
        SelectableText(
          summary,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            height: 1.6,
            color: const Color(0xFF374151),
            fontFamily: "PRegular",
          ),
        ),
        const SizedBox(height: 8),

        // Bouton "Lire plus"
        TextButton(
          onPressed: () => _showFullDescription(context, summary),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFF97316),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'Lire plus',
            style: TextStyle(
              fontFamily: "PBold",
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Boutons d'action
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBookPaying
                    ? null
                    : () async {
                        if (!widget.isLoggedIn) {
                          // Rediriger vers la page de connexion
                          Navigator.pop(context);

                          widget.onNavigate('login');
                          return;
                        }

                        // Si connecté
                        if (priceType == 'gratuit' || isPurchased) {
                          // Lire le livre
                          widget.onNavigate('reader', widget.book);
                        } else {
                          // Acheter le livre
                          await _handleBookPurchase();
                        }
                      },
                icon: isBookPaying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        widget.isLoggedIn ? Icons.shopping_cart : Icons.login,
                      ),
                label: Text(
                  isBookPaying
                      ? 'Traitement...'
                      : !widget.isLoggedIn
                      ? 'Se connecter pour acheter'
                      : (priceType == 'gratuit' || isPurchased
                            ? 'Lire'
                            : 'Acheter'),
                  style: const TextStyle(fontFamily: "PRegular"),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Bouton share - toujours visible sur mobile et desktop
            Material(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => _shareBook(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.share,
                    color: Color(0xFFF97316),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Paiement dans tous les pays par téléphone ou carte bancaire.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontFamily: "PRegular",
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorSection(String author, String bio, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 100,
        vertical: 32,
      ),
      color: const Color(0xFFF9FAFB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À propos de l\'auteur',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: "PBold",
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "PBold",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${authorBooks.length + 1} livres',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontFamily: "PRegular",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF374151),
                        fontFamily: "PRegular",
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildAuthorBooksSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 100,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Livres du même auteur',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: "PBold",
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          isLoadingAuthorBooks
              ? const Center(child: CircularProgressIndicator())
              : isMobile
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: authorBooks
                        .map(
                          (book) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildBookCard(book, 140, 200),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: authorBooks
                      .map((book) => _buildBookCard(book, 180, 260))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryBooksSection(String genre, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 100,
        vertical: 32,
      ),
      color: const Color(0xFFF9FAFB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Livres de la même catégorie',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: "PBold",
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          isLoadingCategoryBooks
              ? const Center(child: CircularProgressIndicator())
              : isMobile
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categoryBooks
                        .map(
                          (book) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildBookCard(book, 140, 200),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: categoryBooks
                      .map((book) => _buildBookCard(book, 180, 260))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildBookCard(
    Map<String, dynamic> book,
    double width,
    double height,
  ) {
    final String? coverPath = book['cover_path'] as String?;
    final String? imageUrl = (coverPath != null && coverPath.isNotEmpty)
        ? (coverPath.startsWith('http') ? coverPath : '$baseUrl/$coverPath')
        : null;
    final String title = book['title'] ?? '';
    final String priceType = book['price_type']?.toString() ?? '';
    final String price = book['price']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
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
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: "PBold",
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              priceType == 'gratuit' ? 'Gratuit' : '$price FCFA',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF97316),
                fontFamily: "PBold",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExcerpt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Extrait',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PBold",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SelectableText(
                widget.book['excerpt'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontFamily: "PRegular",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Description complète',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PBold",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SelectableText(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  fontFamily: "PRegular",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logique d'achat de livre (copiée depuis explore_screen)
  Future<void> _handleBookPurchase() async {
    if (!widget.isLoggedIn || widget.user == null) {
      widget.onNavigate('login');
      return;
    }

    final String? bookId = widget.book['id']?.toString();
    final String? priceStr = widget.book['price']?.toString();
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
      firstName = email?.split('@').first ?? 'Utilisateur';
      lastName = 'TAKA';
    }

    final String? userId = widget.user?.id.toString();
    final String? title = widget.book['title']?.toString();

    // Vérification des champs obligatoires
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
          await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
          await _waitForBookPayment(bookId);
        } else {
          setState(() => isBookPaying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir le paiement')),
          );
        }
      } else {
        setState(() => isBookPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  Future<void> _waitForBookPayment(dynamic bookId) async {
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
        timer?.cancel();
        // Recharger le statut d'achat depuis l'API
        await _checkIfPurchased();
        setState(() {
          isBookPaying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Paiement réussi! Vous pouvez maintenant lire le livre.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (tries >= maxTries) {
        timer?.cancel();
        setState(() => isBookPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Délai d\'attente du paiement dépassé')),
        );
      }
    });
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

  void _shareBook(BuildContext context) {
    final bookTitle = widget.book['title'] ?? '';
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
      bookUrl = 'https://votre-domaine.com/$bookSlug';
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
