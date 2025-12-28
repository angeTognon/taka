import 'package:flutter/material.dart';
import 'package:taka2/main.dart';
import 'package:taka2/widgets/footer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
       appBar: AppBar(
        title: const Text('A Propos'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: "PBold", fontSize: isMobile ? 16 : 18
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context),
            // Stats Section
            _buildStatsSection(context),
            // What is TAKA
            _buildWhatIsTakaSection(context),
            // Origin Story
            _buildOriginSection(context),
            // Mission
            _buildMissionSection(context),
            // Values
            _buildValuesSection(context),
            // What TAKA Offers
            _buildOffersSection(context),
            // Coming Soon
            _buildComingSoonSection(context),
            // Legal Information
            _buildLegalSection(context),
            // Call to Action
            _buildCallToActionSection(context),
          Footer()

          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      height: 550,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // colors: [Color(0xFFF97316), Color(0xFFFB923C)],

          colors: [Color.fromARGB(255, 24, 193, 201), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.menu_book,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                   Text(
                    'À propos de TAKA',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 26,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'La première plateforme littéraire panafricaine qui donne du pouvoir aux lecteurs… et de la liberté aux auteurs.',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 17,
                      fontFamily: "PRegular",
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 128,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade300,
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildStatsSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.menu_book, '+1.000', 'Livres disponibles', Colors.orange,context),
              _buildStatItem(Icons.public, 'Toute', "l'Afrique", Colors.green,context),
              _buildStatItem(Icons.visibility, 'Jeunes', 'Lecteurs passionnés', Colors.blue,context),
              _buildStatItem(Icons.smartphone, '100%', 'Mobile Money', Colors.yellow,context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String number, String label, MaterialColor color,BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:isMobile? 30: 64,
            height: isMobile? 30:64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade500, color.shade700],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size:isMobile? 20: 32),
          ),
          const SizedBox(height: 16),
          Text(
            number,
            style:  TextStyle(
              fontSize: isMobile? 14: 19,
              fontWeight: FontWeight.bold,
                      fontFamily: "PBold",

              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style:  TextStyle(
              fontSize: isMobile? 13 : 15,
              color: Colors.grey,
              fontFamily: "PRegular",
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsTakaSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9FAFB), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
           Text(
            'TAKA, c\'est bien plus qu\'une bibliothèque numérique',
            style: TextStyle(
              fontSize: isMobile?16 : 23,
              fontWeight: FontWeight.bold,
                      fontFamily: "PBold",

              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          isMobile? Column(
            children: [
               Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.public,
                  'Un mouvement culturel',
                  'Révéler la richesse littéraire africaine au monde entier',
                  Colors.orange,
                  context
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  Icons.rocket_launch,
                  'Une révolution éditoriale',
                  'Démocratiser l\'accès à l\'édition pour tous les auteurs africains',
                  Colors.red,
                                 context
),
              ),
             
            ],
          ),
           const SizedBox(height: 16),
              _buildFeatureCard(
                Icons.menu_book,
                'Une nouvelle ère',
                'Transformer la lecture et l\'auto-édition en Afrique',
                Colors.yellow,
                context
              ),
            ],
          ): Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.public,
                  'Un mouvement culturel',
                  'Révéler la richesse littéraire africaine au monde entier',
                  Colors.orange,
                  context
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  Icons.rocket_launch,
                  'Une révolution éditoriale',
                  'Démocratiser l\'accès à l\'édition pour tous les auteurs africains',
                  Colors.red,
                                 context
),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  Icons.menu_book,
                  'Une nouvelle ère',
                  'Transformer la lecture et l\'auto-édition en Afrique',
                  Colors.yellow,
                  context
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, MaterialColor color,BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding:  EdgeInsets.all(isMobile?13: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: isMobile?30: 48, color: color.shade600),
          const SizedBox(height: 16),
          Text(
            title,
            style:  TextStyle(
              fontSize: isMobile? 14 : 17,
                      fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style:  TextStyle(
              fontSize:  isMobile? 12 :14,
              color: Colors.grey,
                      fontFamily: "PRegular",
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOriginSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: isMobile ? 16 : 24),
      color: Colors.white,
      child: Column(
        children: [
           Text(
            '🌍 L\'Origine de TAKA',
            style: TextStyle(
              fontSize: isMobile?16: 23,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
                      fontFamily: "PBold",

            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile?16:100),
            padding: EdgeInsets.all(isMobile?24:48),
            decoration: BoxDecoration(
              gradient:  LinearGradient(
          colors: [Color.fromARGB(255, 245, 224, 210), Color.fromARGB(255, 232, 188, 151)],

                // colors: [mainColor, Color(0xFFFECDD3)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                 Text(
                  'L\'idée de TAKA est née d\'un constat : Les livres africains sont souvent absents des rayons, oubliés des plateformes internationales, et inaccessibles à ceux qui en ont le plus besoin.',
                  style: TextStyle(
                      fontFamily: "PRegular",
                    fontSize: isMobile?14:17,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                 Column(
                  children: [
                    Text(
                      'En Afrique, trop d\'auteurs écrivent sans être lus.',
                      style: TextStyle(fontSize: isMobile?13: 17, color: Colors.black54,
                      fontFamily: "PRegular",
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trop de lecteurs cherchent sans jamais trouver.',
                      style: TextStyle(fontSize: isMobile?13: 17, color: Colors.black54
                      ,
                      fontFamily: "PRegular",
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Trop de talents se perdent dans le silence.',
                      style: TextStyle(fontSize: isMobile?13: 17, color: Colors.black54,
                      fontFamily: "PRegular",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                 Text(
                  'TAKA veut réparer cette injustice culturelle.',
                  style: TextStyle(
                    fontSize: isMobile?15: 20,
                      fontFamily: "PBold",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC2410C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(color: Colors.orange.shade500, width: 4),
                    ),
                  ),
                  child:  Column(
                    children: [
                      Text(
                        '"TAKA, c\'est notre voix. Notre mémoire. Notre puissance intellectuelle."',
                        style: TextStyle(
                          fontSize: isMobile?15:20,
                      fontFamily: "PRegular",

                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '➡️ Publie. Sois lu. Sois payé. Sois libre.',
                        style: TextStyle(
                          fontSize: isMobile?15:18,
                          fontWeight: FontWeight.w600,
                      fontFamily: "PBold",
                          color: Color(0xFFC2410C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: isMobile ? 16 : 104),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEA580C),  Color(0xFFF97316)],
        ),
      ),
      child:  Column(
        children: [
          Text(
            '🎯 Notre Mission',
            style: TextStyle(
              fontSize: isMobile ? 15 : 23,
              fontWeight: FontWeight.bold,
                      fontFamily: "PBold",

              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Text(
            'Offrir à chaque Africain, où qu\'il soit, le pouvoir de lire, publier et partager sa voix avec le monde. Créer un écosystème juste, accessible et durable pour la culture africaine, par les Africains, pour les Africains.',
            style: TextStyle(
              fontSize: isMobile ? 14 : 17,
                      fontFamily: "PRegular",

              color: Colors.white,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 80, horizontal: isMobile ? 16 : 24),
      color: Colors.grey.shade50,
      child: Column(
        children: [
           Text(
            '🧭 Nos Valeurs',
            style: TextStyle(
              fontSize: isMobile ? 17 : 23,
              fontWeight: FontWeight.bold,
                      fontFamily: "PBold",

              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 64),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildValueCard(
                Icons.favorite,
                '✨ Autonomie',
                'Tu écris ? Tu publies. Tu fixes ton prix. Tu reçois tes redevances. Point. Pas d\'intermédiaires obscurs.',
                const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFDC2626)]),
                context
              ),
              _buildValueCard(
                Icons.hearing,
                '💬 Écoute Active',
                'Chez TAKA, tu n\'es jamais seul. Tu es entouré. Écouté. Soutenu. On grandit ensemble.',
                const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF14B8A6)]),
                context
              ),
              _buildValueCard(
                Icons.rocket_launch,
                '🚀 Innovation',
                'Paiement mobile local, lecture offline, impression à la demande… TAKA est conçu pour nos réalités.',
                const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                context
              ),
              _buildValueCard(
                Icons.eco,
                '🌱 Impact durable',
                'TAKA n\'est pas une start-up de plus. C\'est un projet pour les générations futures.',
                const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                context
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String description, Gradient gradient, BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style:  TextStyle(
              fontSize: isMobile? 15: 18,
                      fontFamily: "PBold",

              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
                      fontFamily: "PRegular",
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 80, horizontal: isMobile ? 16 : 100),
      color: Colors.white,
      child: Column(
        children: [
           Text(
            '📚 Ce que propose TAKA',
            style: TextStyle(
              fontSize: isMobile? 16: 23,
                      fontFamily: "PBold",

              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 64),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (constraints.maxWidth < 900) {
                crossAxisCount = 1;
              } else if (constraints.maxWidth < 1400) {
                crossAxisCount = 3;
              }
              final offers = [
                _buildOfferCard('📖 Lire des livres', 'Accès immédiat à des ebooks africains modernes', Colors.orange, context),
                _buildOfferCard('🧠 Explorer par thème', 'Roman, argent, amour, ésotérisme, entrepreneuriat, etc.', Colors.blue, context),
                _buildOfferCard('💡 Publier ton livre', 'Simple, rapide, 100% autonome', Colors.purple, context),
                _buildOfferCard('💰 Être payé', 'Recevoir tes revenus en Mobile Money ou carte bancaire', Colors.green, context),
                _buildOfferCard('📈 Suivre tes ventes', 'Tableau de bord : stats, revenus, lectorat', Colors.yellow, context),
                _buildOfferCard('🌐 Devenir affilié', 'Gagne de l\'argent en partageant les livres que tu aimes', Colors.indigo, context),
              ];
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio:  isMobile? 2.0: 1.8,
                children: offers,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String description, MaterialColor color, BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade50, color.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style:  TextStyle(
              fontSize: isMobile ? 15 : 17,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style:  TextStyle(
              fontFamily: "PRegular",
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF97316), mainColor],
        ),
      ),
      child: Column(
        children: [
           Text(
            '📦 À venir : Impression + Livraison en Afrique',
            style: TextStyle(
              fontSize:isMobile? 17 : 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "PBold"
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 32),
          Text(
            'TAKA ne s\'arrête pas au digital. Très bientôt, tu pourras :',
            style: TextStyle(
              fontSize: isMobile ? 14 : 20,
              fontFamily: "PRegular",
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 17 : 48),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.print, color: Colors.white, size:isMobile? 17 : 48),
                      SizedBox(height: 16),
                      Text(
                        'Commander en papier',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 20,
                          fontWeight: FontWeight.bold,
              fontFamily: "PBold",
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Ton livre préféré en version physique',
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 16,
                          fontFamily: "PRegular",
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:  Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: isMobile ? 17 : 48),
                      SizedBox(height: 16),
                      Text(
                        'Livraison à domicile',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 20,
              fontFamily: "PBold",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Reçois-le chez toi ou dans un point relais',
                        style: TextStyle(
                          fontFamily: "PRegular",
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80, horizontal: isMobile ? 16 : 24),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Text(
            '📑 Informations Légales',
            style: TextStyle(
              fontSize: isMobile ? 17 : 23,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: isMobile
                    ? Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nom commercial',
                                style: TextStyle(
                                  fontFamily: "PBold",
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade400,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'TAKA AFRICA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: "PRegular",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registre du commerce',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "PBold",
                                  color: Colors.orange.shade400,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Parakou – N° RB/PKO/25 A 26975',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: "PRegular",
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nom commercial',
                                style: TextStyle(
                                  fontFamily: "PBold",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade400,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'TAKA AFRICA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: "PRegular",
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registre du commerce',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "PBold",
                                  color: Colors.orange.shade400,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Parakou – N° RB/PKO/25 A 26975',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: "PRegular",
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
    );
  }

  Widget _buildCallToActionSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 80),
      child: Container(
        width: double.infinity,
        // constraints: const BoxConstraints(maxWidth: 1024),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
             Text(
              'Rejoins la révolution littéraire TAKA',
              style: TextStyle(
                fontSize: isMobile ? 15 : 25,
                fontWeight: FontWeight.w700,
                fontFamily: "PBold",
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 17 : 24),
            Text(
              'Plus de 50 000 lecteurs nous font déjà confiance. Et vous ?',
              style: TextStyle(
                fontSize: isMobile ? 14 : 20,
                fontFamily: "PRegular",
                color: Color(0xFFFED7AA),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFF97316),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle:  TextStyle(
                  fontSize: isMobile ? 15 : 16,
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
}