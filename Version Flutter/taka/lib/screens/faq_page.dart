import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int? _expandedIndex;
  String _selectedCategory = 'Tous';
  
  final List<String> _categories = [
    'Tous',
    'Publication',
    'Qualité',
    'Rémunération',
    'Promotion',
    'Technique',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'Publication',
      'question': 'Comment publier un livre sur TAKA ?',
      'answer': '''Publier sur TAKA se fait en 6 étapes rapides :

1. Informations du livre : Catégorie, titre, résumé, prix
2. Fichier du livre : Upload au format Word, EPUB ou PDF
3. Couverture : Image JPG professionnelle (1500x2500px)
4. Plan de publication : Choix de l'offre (Basique, Premium, etc.)
5. Profil auteur : Biographie, photo, liens réseaux sociaux
6. Promotion : Textes d'accroche et stratégie marketing

Le processus prend en moyenne 10 jours ouvrables.'''
    },
    {
      'category': 'Qualité',
      'question': 'Quels sont les critères de qualité exigés ?',
      'answer': '''TAKA applique une charte qualité rigoureuse :

Contenu :
• Originalité absolue (pas de plagiat)
• Utilisation IA limitée (pas 100% généré par IA)
• Cohérence culturelle africaine

Qualité d'écriture :
• Orthographe, grammaire parfaites
• Texte clair, fluide, structuré
• Mise en forme professionnelle

Couverture :
• Design professionnel
• Pas 100% générée par IA
• Titre et auteur lisibles'''
    },
    {
      'category': 'Rémunération',
      'question': 'Comment et quand vais-je recevoir mes gains ?',
      'answer': '''Paiements :
• Chaque début de mois (au plus tard le 15)
• Seuil minimum : 15.000 FCFA
• Modes : Mobile Money (Orange, MTN, Wave) ou virement bancaire

Rémunération selon l'offre :
• Offre Basique : 80% du prix de vente
• Offre Premium : 50% du prix de vente
• + Programme d'affiliation disponible

Si le seuil n'est pas atteint, les gains sont reportés au mois suivant.'''
    },
    {
      'category': 'Promotion',
      'question': 'Qu\'est-ce que TAKA m\'apporte en termes de visibilité ?',
      'answer': '''TAKA offre une plateforme à fort trafic :

Audience :
• 500.000 visiteurs mensuels sur le site
• 3 millions de personnes atteintes/mois sur les réseaux
• Présence active : TikTok, Instagram, Facebook, WhatsApp

Services promotionnels :
• Campagnes sponsorisées (Facebook/Instagram Ads)
• Reels viraux et vidéos TikTok
• Accompagnement marketing personnalisé
• Création de visuels impactants

Certains livres atteignent plus de 9 millions FCFA de CA cumulés !'''
    },
    {
      'category': 'Technique',
      'question': 'Mon livre sera-t-il bien protégé sur TAKA ?',
      'answer': '''Protection maximale :
• Aucun téléchargement possible
• Lecteur sécurisé intégré uniquement
• Système de cryptage avancé
• Token de lecture unique par utilisateur

Sécurité :
• Empêche le piratage par fichier PDF
• Pas de partage illégal sur WhatsApp/Telegram
• Pas de copie ou impression sauvage
• Suspension immédiate en cas de tentative de contournement

TAKA = Lire. Pas pirater.'''
    },
    {
      'category': 'Publication',
      'question': 'Quels formats de fichiers sont acceptés ?',
      'answer': '''Formats acceptés :
• Word (.doc/.docx) - Recommandé pour traitement rapide
• PDF - Accepté mais traitement plus long
• EPUB - Si disponible

Couverture obligatoire :
• Format JPG
• Dimensions : 1500x2500px
• Titre et nom d'auteur lisibles
• Design professionnel'''
    },
    {
      'category': 'Publication',
      'question': 'Puis-je publier un livre en langue africaine ?',
      'answer': '''Oui, absolument !

Nous encourageons vivement la publication en langues africaines :
• Fon, Wolof, Lingala, Bambara, etc.
• L'Afrique parle plusieurs langues
• TAKA donne à chacune sa place dans notre bibliothèque

L'Afrique a une richesse linguistique que nous célébrons !'''
    },
    {
      'category': 'Rémunération',
      'question': 'Mon livre doit-il être exclusivement publié sur TAKA ?',
      'answer': '''Non, contrat non exclusif :

• Vous restez propriétaire à 100% de vos droits
• Vous pouvez vendre sur d'autres plateformes
• Aucune exclusivité demandée
• Aucun engagement contraignant
• Liberté totale de distribution

TAKA respecte votre indépendance d'auteur.'''
    },
    {
      'category': 'Promotion',
      'question': 'Quelles sont les différentes offres publicitaires ?',
      'answer': '''🟢 Offre BASIQUE :
• Mise en ligne + réseaux sociaux
• 80% de rémunération auteur
• +15% via programme d'affiliation

🔵 Offre PREMIUM :
• Tout Basique + publicité sponsorisée
• Facebook + Instagram Ads (pris en charge par TAKA)
• 50% de rémunération + 70% affiliation

🌍 WRITING BOOST :
• Aide à l'écriture/réécriture
• Coaching éditorial (40.000 FCFA)
• Tous avantages Premium

🟣 ÉLÉGANCE INTERNATIONALE :
• Publication TAKA + Amazon KDP
• Coaching éditorial (50.000 FCFA)
• Distribution mondiale'''
    },
    {
      'category': 'Qualité',
      'question': 'Est-ce que TAKA accepte tous les livres ?',
      'answer': '''Non, TAKA vise l'excellence.

Processus de validation :
• Examen éditorial rigoureux de chaque manuscrit
• Évaluation qualité avant validation
• Seuls les ouvrages originaux et bien rédigés sont retenus

Refus automatique :
• Œuvres à caractère haineux ou discriminatoire
• Contenu incitant à des comportements illégaux
• Plagiat ou contenu non original

Notre ambition : créer LA référence de la littérature africaine de qualité.'''
    },
    {
      'category': 'Technique',
      'question': 'Combien de temps dure la publication ?',
      'answer': '''Délai moyen : 10 jours ouvrables

Facteurs influençant le délai :
• Format du fichier (Word/EPUB = plus rapide)
• Complétude du dossier
• Charge de traitement

Conseils pour accélérer :
• Envoyer tous les éléments en une fois
• Utiliser le format Word ou EPUB
• Respecter la charte qualité

Vous serez informé par message/mail dès mise en ligne.'''
    },
    {
      'category': 'Publication',
      'question': 'Puis-je publier plusieurs livres à la fois ?',
      'answer': '''Oui, tout à fait !

Si vous êtes :
• Éditeur avec plusieurs titres
• Auteur prolifique
• Maison d'édition

Recommandation :
Soumettez vos livres en lot pour faciliter le traitement et bénéficier d'un suivi groupé.

Contactez-nous pour les soumissions multiples.'''
    }
  ];

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_selectedCategory == 'Tous') {
      return _faqs;
    }
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('FAQ Auteurs TAKA', style: TextStyle(
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            fontSize: isMobile?16: 20,
            color: Color.fromARGB(255, 0, 0, 0),
          ),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal:  isMobile?16:150,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[500]!, Colors.orange[600]!],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_center,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Foire aux Questions AUTEURS',
                    style: TextStyle(
                      fontSize: isMobile?14: 24,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tout ce que tu dois savoir pour publier, protéger et monétiser ton livre avec TAKA',
                    style: TextStyle(
                      fontSize: isMobile?13: 16,
                      fontFamily: "PRegular",
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // TAKA Promise
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🚀 TAKA ne se contente pas de publier ton livre. Elle le propulse.',
                    style: TextStyle(
                      fontSize: isMobile? 14: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "PBold",
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Que tu sois auteur débutant ou éditeur expérimenté, TAKA t\'offre des solutions publicitaires clés en main, ciblées et efficaces, pour faire rayonner ton œuvre sur toute l\'Afrique… et au-delà.',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "PRegular",
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Objectif : te faire connaître, vendre plus, et construire ta marque d\'auteur solide, visible, et rentable.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "PBold",
                      color: Colors.orange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
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
                    margin: EdgeInsets.only(right: 12.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _expandedIndex = null; // Reset expanded state
                        });
                      },
                      selectedColor: Colors.orange[100],
                      checkmarkColor: Colors.orange[700],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.orange[700] : Colors.grey[700],
                      fontFamily: "PRegular",
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 20),
            
            // FAQ List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _filteredFAQs.length,
              itemBuilder: (context, index) {
                final faq = _filteredFAQs[index];
                final isExpanded = _expandedIndex == index;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
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
                          style: TextStyle(
                            fontSize:  isMobile?14:16,
                      fontFamily: "PBold",
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: _selectedCategory == 'Tous' ? Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              faq['category'],
                              style: TextStyle(
                      fontFamily: "PRegular",
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ) : null,
                        trailing: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.orange[500],
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
                          padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          child: Text(
                            faq['answer'],
                            style: TextStyle(
                              fontSize: 13,
                      fontFamily: "PRegular",
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            
            SizedBox(height: 24),
            
            // Contact CTA
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[500]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Vous ne trouvez pas votre réponse ?',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Notre équipe est là pour vous aider 24h/24',
                    style: TextStyle(
                      fontFamily: "PRegular",
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to contact page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Nous contacter',
                      style: TextStyle(fontWeight: FontWeight.bold,
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