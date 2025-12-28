import 'package:flutter/material.dart';

class FAQLecteurPage extends StatefulWidget {
  const FAQLecteurPage({super.key});

  @override
  _FAQLecteurPageState createState() => _FAQLecteurPageState();
}

class _FAQLecteurPageState extends State<FAQLecteurPage> {
  int? _expandedIndex;
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Général',
    'Lecture',
    'Paiement',
    'Sécurité',
    'Technique',
    'Compte',
    'Offrir',
    'Support',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Général',
      'question': 'Qu’est-ce que TAKA ?',
      'answer': '''TAKA est une plateforme 100 % africaine qui vous permet d’acheter, lire et découvrir des livres numériques directement depuis votre téléphone, tablette ou ordinateur.

Notre mission : rendre la littérature africaine et francophone accessible à tous, partout.''',
    },
    {
      'category': 'Lecture',
      'question': 'Comment fonctionne la lecture sur TAKA ?',
      'answer': '''• Tu choisis ton livre (gratuit, payant ou via abonnement)
• Tu lis en ligne, directement depuis l’application
• Tu ajoutes des signets, reprends où tu t’étais arrêté
• Pas de téléchargement → pas de piratage, pas de perte
• Ton historique est conservé dans ton compte''',
    },
    {
      'category': 'Lecture',
      'question': 'Quelles sont les 3 façons de lire sur TAKA ?',
      'answer': '''1. 📘 Lire gratuitement
Accède à notre Bibliothèque Gratuite : une sélection d’œuvres offertes par leurs auteurs. Zéro inscription, zéro paiement.

2. 💳 Acheter un livre en quelques clics
Tu vois un livre que tu veux lire ? Tu l’achètes une seule fois. Paiement rapide et sécurisé, lecture instantanée, tu le gardes à vie dans ta bibliothèque TAKA.

3. 🔐 T'abonner pour tout lire
Devient membre du TAKA READING CLUB, notre formule d’abonnement premium. Accès à 2000 livres africains, lecture illimitée ou limitée selon ton forfait, zéro pub, résiliation à tout moment.''',
    },
    {
      'category': 'Lecture',
      'question': 'Comment lire un livre acheté sur TAKA ?',
      'answer': '''Dès que vous achetez un livre, il est automatiquement ajouté à votre bibliothèque TAKA. Vous pouvez le lire immédiatement en ligne via notre lecteur intégré sécurisé, sans téléchargement illégal possible.''',
    },
    {
      'category': 'Lecture',
      'question': 'Quels types de livres vais-je trouver sur TAKA ?',
      'answer': '''Vous trouverez tous les genres :
• Romans, poésie, nouvelles
• Livres business et développement personnel
• Essais, biographies, documents historiques, Religion et Spiritualité
• Littérature jeunesse et scolaire
• Ouvrages en langues africaines

Tous nos livres respectent des standards de qualité élevés.''',
    },
    {
      'category': 'Lecture',
      'question': 'Est-ce que la lecture est gratuite ?',
      'answer': '''La plupart des livres sont payants (à prix très accessibles), mais nous proposons aussi une sélection de livres gratuits via notre compte officiel "TAKA Gratuit" pour vous permettre de découvrir de nouveaux auteurs.''',
    },
    {
      'category': 'Paiement',
      'question': 'Comment payer sur TAKA ?',
      'answer': '''Nous acceptons plusieurs moyens de paiement sécurisés :
• Mobile Money (Orange, MTN, Moov, Wave…)
• Carte bancaire (Visa, Mastercard)''',
    },
    {
      'category': 'Sécurité',
      'question': 'Mon paiement est-il sécurisé ?',
      'answer': '''Oui. Toutes les transactions sont protégées par un cryptage SSL et gérées par des partenaires de paiement reconnus. TAKA ne conserve jamais vos informations bancaires.''',
    },
    {
      'category': 'Lecture',
      'question': 'Puis-je lire sans connexion internet ?',
      'answer': '''Oui, une fois le livre acheté, vous pouvez l’ajouter à votre mode lecture hors ligne dans l’application TAKA.''',
    },
    {
      'category': 'Offrir',
      'question': 'Est-ce que je peux offrir un livre à quelqu’un ?',
      'answer': '''Oui ! Vous pouvez acheter un livre et l’envoyer directement à un ami via son compte TAKA ou par email.''',
    },
    {
      'category': 'Support',
      'question': 'Comment signaler un problème ou un bug ?',
      'answer': '''Vous pouvez contacter notre support 24h/24.''',
    },
    {
      'category': 'Compte',
      'question': 'Que faire si je perds l’accès à mon compte ?',
      'answer': '''Pas de panique. Utilisez la fonction “Mot de passe oublié” ou contactez notre support pour récupérer l’accès à votre bibliothèque.''',
    },
    {
      'category': 'Général',
      'question': 'Astuce TAKA : Comment recevoir des livres gratuits et des promos ?',
      'answer': '''Abonnez-vous à notre newsletter et rejoignez notre groupe WhatsApp "Lecteurs TAKA" pour recevoir des livres gratuits, des promos et des avant-premières.''',
    },
  ];

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_selectedCategory == 'Tous') {
      return _faqs;
    }
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:  Text(
          'FAQ Lecteurs TAKA',
          style: TextStyle(
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            fontSize: isMobile? 16: 20,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal:isMobile? 16: 150,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children:  [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Questions fréquentes – Lecteurs TAKA',
                    style: TextStyle(
                      fontSize: isMobile? 14 : 24,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tout ce que tu dois savoir pour lire, acheter et profiter de la bibliothèque TAKA',
                    style: TextStyle(
                      fontSize:isMobile? 14 : 16,
                      fontFamily: "PRegular",
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Container(
                    margin: const EdgeInsets.only(right: 12.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _expandedIndex = null;
                        });
                      },
                      selectedColor: Colors.blue[100],
                      checkmarkColor: Colors.blue[700],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue[700] : Colors.grey[700],
                        fontFamily: "PRegular",
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // FAQ List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredFAQs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFAQs[index];
                final isExpanded = _expandedIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          faq['question'],
                          style:  TextStyle(
                            fontSize:isMobile? 14 : 16,
                            fontFamily: "PBold",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: _selectedCategory == 'Tous'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Text(
                                    faq['category'],
                                    style: TextStyle(
                                      fontFamily: "PRegular",
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        trailing: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.blue[500],
                        ),
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                      ),
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          child: Text(
                            faq['answer'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "PRegular",
                              color: Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Contact CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                   Text(
                    'Vous ne trouvez pas votre réponse ?',
                    style: TextStyle(
                      fontSize: isMobile? 14 : 18,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Notre équipe est là pour vous aider 24h/24',
                    style: TextStyle(
                      fontFamily: "PRegular",
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Naviguer vers la page contact ou ouvrir un support
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Nous contacter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "PRegular",
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
}