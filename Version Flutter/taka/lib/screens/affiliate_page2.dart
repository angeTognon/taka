import 'package:flutter/material.dart';
import 'package:taka2/widgets/footer.dart';

class AffiliatePage extends StatelessWidget {
  const AffiliatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programme d\'Affiliation TAKA'),
        centerTitle: true,
        titleTextStyle:  TextStyle(
          fontFamily: "PBold", fontSize:isMobile? 14: 18
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(isMobile,context),
            _buildHowItWorksSection(isMobile),
            _buildWhoCanJoinSection(isMobile),
            _buildPaymentSection(isMobile),
            _buildTransparencySection(isMobile),
            _buildFAQSection(isMobile),
            _buildContactSection(isMobile),
            Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile, BuildContext context) {
    return Container(
      height: isMobile ? 420 : 520,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.handshake,
                    size: 70,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 18),
                   Text(
                    '🤝 Programme d\'Affiliation TAKA',
                    style: TextStyle(
                      fontSize: isMobile?17: 22,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'Fais la promotion des livres africains.\nGagne de l\'argent. Inspire ton audience.',
                    style: TextStyle(
                      fontSize: isMobile?13: 15,
                      fontFamily: "PRegular",
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 14 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                         Text(
                          'C\'est simple :',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 18,
                            fontFamily: "PBold",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        isMobile
                            ? Column(
                                children: [
                                  _buildHeroStepMobile('1.', 'Tu recommandes',context),
                                  const SizedBox(height: 10),
                                  _buildHeroStepMobile('2.', 'Ils achètent',context),
                                  const SizedBox(height: 10),
                                  _buildHeroStepMobile('3.', 'Tu encaisses',context),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildHeroStep('1.', 'Tu recommandes'),
                                  _buildHeroStep('2.', 'Ils achètent'),
                                  _buildHeroStep('3.', 'Tu encaisses'),
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

  Widget _buildHeroStep(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "PBold")),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildHeroStepMobile(String number, String label, BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(number, style:  TextStyle(fontSize: isMobile ? 15 : 26, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: "PBold")),
        const SizedBox(width: 10),
        Text(label, style:  TextStyle(color: Colors.white, fontSize:isMobile ? 13 :  15)),
      ],
    );
  }

  Widget _buildHowItWorksSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 80,
        horizontal: isMobile ? 12 : 150,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Comment ça marche ?',
            style: TextStyle(
              fontSize: isMobile ? 16 : 23,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 64),
          Column(
            children: [
              _buildStepCard(
                '1',
                'Inscris-toi gratuitement',
                'En quelques clics, tu obtiens ton tableau de bord personnel',
                Icons.person_add,
                Colors.blue,
                isMobile,
              ),
              SizedBox(height: isMobile ? 16 : 32),
              _buildStepCard(
                '2',
                'Partage tes liens personnalisés',
                'Choisis des livres, génère tes liens uniques et partage-les sur tes réseaux',
                Icons.share,
                Colors.orange,
                isMobile,
              ),
              SizedBox(height: isMobile ? 16 : 32),
              _buildStepCard(
                '3',
                'Gagne des commissions',
                '20% de commission par livre vendu, paiement mensuel transparent',
                Icons.monetization_on,
                Colors.green,
                isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String description, IconData icon, MaterialColor color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade50, color.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 54 : 80,
            height: isMobile ? 54 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.shade500, color.shade700],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: "PBold",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 14 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 19,
                    fontFamily: "PBold",
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    fontFamily: "PRegular",
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: isMobile ? 32 : 48, color: color.shade600),
        ],
      ),
    );
  }

  Widget _buildWhoCanJoinSection(bool isMobile) {
    final cards = [
      _buildProfileCard('📲', 'Influenceur ou micro-influenceur', Colors.purple, isMobile),
      _buildProfileCard('📖', 'Passionné de lecture', Colors.blue, isMobile),
      _buildProfileCard('📝', 'Blogueur ou chroniqueur littéraire', Colors.green, isMobile),
      _buildProfileCard('🎓', 'Enseignant, étudiant ou documentaliste', Colors.indigo, isMobile),
      _buildProfileCard('💼', 'Entrepreneur digital ou community manager', Colors.orange, isMobile),
      _buildProfileCard('❤️', 'Lecteur fidèle qui veut recommander ses coups de cœur', Colors.red, isMobile),
    ];
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 80,
        horizontal: isMobile ? 10 : 150,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            'Qui peut devenir affilié TAKA ?',
            style: TextStyle(
              fontSize: isMobile ? 16 : 25,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 64),
          isMobile
              ? Column(
                  children: cards
                      .map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: card,
                          ))
                      .toList(),
                )
              : GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.8,
                  children: cards,
                ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String emoji, String description, MaterialColor color, bool isMobile) {
    return SizedBox(
      height: isMobile ? 90 : 100,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isMobile ? 32 : 48),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: "PRegular",
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 80,
        horizontal: isMobile ? 10 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      child: Column(
        children: [
          Text(
            '💳 Paiement & Conditions',
            style: TextStyle(
              fontSize: isMobile ? 16 : 24,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 28 : 48),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildPaymentRow(Icons.calendar_month, 'Paiement entre le 1er et le 15 du mois', isMobile),
                const SizedBox(height: 12),
                _buildPaymentRow(Icons.account_balance_wallet, 'Minimum de 15.000 FCFA pour déclencher un paiement', isMobile),
                const SizedBox(height: 12),
                _buildPaymentRow(Icons.phone_android, 'Paiement par Mobile Money (Orange, MTN, Wave)', isMobile),
                const SizedBox(height: 12),
                _buildPaymentRow(Icons.money_off, 'Pas de frais, pas d\'intermédiaires', isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(IconData icon, String text, bool isMobile) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: isMobile ? 20 : 24),
        SizedBox(width: isMobile ? 10 : 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              color: Colors.white,
              fontFamily: "PRegular",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransparencySection(bool isMobile) {
    final features = [
      _buildDashboardFeature(Icons.mouse, 'Tes clics', Colors.blue, isMobile),
      _buildDashboardFeature(Icons.shopping_cart, 'Tes ventes confirmées', Colors.green, isMobile),
      _buildDashboardFeature(Icons.attach_money, 'Tes revenus', Colors.orange, isMobile),
      _buildDashboardFeature(Icons.trending_up, 'Tes livres les plus performants', Colors.purple, isMobile),
      _buildDashboardFeature(Icons.analytics, 'Les supports qui marchent le mieux', Colors.red, isMobile),
    ];
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 80,
        horizontal: isMobile ? 10 : 24,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            '🔐 Transparent, fiable, sécurisé',
            style: TextStyle(
              fontSize: isMobile ? 16 : 24,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 32),
          Text(
            'Ton tableau de bord affiche en temps réel :',
            style: TextStyle(
              fontSize: isMobile ? 14 : 18,
              fontFamily: "PRegular",
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 24 : 48),
          isMobile
              ? Column(
                  children: features
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: f,
                          ))
                      .toList(),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 10,
                  spacing: 10,
                  children: features,
                ),
        ],
      ),
    );
  }

  Widget _buildDashboardFeature(IconData icon, String title, MaterialColor color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 250,
      height: isMobile ? 70 : 100,
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade50, color.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade600, size: isMobile ? 22 : 32),
          SizedBox(width: isMobile ? 10 : 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 13 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(bool isMobile) {
    final faqs = [
      {
        'q': 'Qu\'est-ce que TAKA ?',
        'a': 'TAKA est une plateforme panafricaine de vente et promotion de livres numériques et imprimés, mettant en avant les auteurs africains et afro-descendants.',
      },
      {
        'q': 'En quoi consiste le programme d\'affiliation TAKA ?',
        'a': 'C\'est un système qui te permet de promouvoir nos livres et de toucher 20% de commission sur chaque vente réalisée via ton lien personnalisé.',
      },
      {
        'q': 'Puis-je suivre mes ventes en direct ?',
        'a': 'Oui. Ton tableau de bord te permet de suivre tes clics, ventes et revenus à tout moment.',
      },
      {
        'q': 'Je suis auteur, puis-je être affilié ?',
        'a': 'Oui. Et si tu fais la promo de ton propre livre, tu cumules ta rémunération d\'auteur + la commission d\'affilié.',
      },
      {
        'q': 'Quelles sont les règles de communication ?',
        'a': 'Pas de spam, pas de contenu trompeur, pas de pratiques frauduleuses. Respecte les lois et les règles des plateformes où tu postes.',
      },
      {
        'q': 'Que se passe-t-il si je ne respecte pas les règles ?',
        'a': 'Suspension ou exclusion définitive du programme.',
      },
    ];
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 80,
        horizontal: isMobile ? 10 : 24,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            '📌 FAQ Affiliés TAKA',
            style: TextStyle(
              fontSize: isMobile ? 16 : 24,
              fontWeight: FontWeight.bold,
              fontFamily: "PBold",
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 32 : 64),
          Column(
            children: faqs
                .map((faq) => _buildFAQItem(
                      faq['q']!,
                      faq['a']!,
                      isMobile,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            fontFamily: "PRegular",
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 16),
            child: Text(
              answer,
              style: TextStyle(
                fontFamily: "PRegular",
                fontSize: isMobile ? 13 : 15,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 36 : 80,
        horizontal: isMobile ? 10 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Besoin d\'aide ?',
            style: TextStyle(
              fontSize: isMobile ? 16 : 24,
              fontWeight: FontWeight.bold,
              fontFamily: "PBold",
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 28 : 48),
          isMobile
              ? Column(
                  children: [
                    _buildContactMethod(Icons.email, 'Email', 'contact@takaafrica.com', Colors.blue, isMobile),
                    const SizedBox(height: 18),
                    _buildContactMethod(Icons.phone, 'WhatsApp', '+229 0197147572', Colors.green, isMobile),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactMethod(Icons.email, 'Email', 'contact@takaafrica.com', Colors.blue, isMobile),
                    _buildContactMethod(Icons.phone, 'WhatsApp', '+229 0197147572', Colors.green, isMobile),
                  ],
                ),
          SizedBox(height: isMobile ? 28 : 48),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: isMobile ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            child: Text(
              'Devenir Affilié Maintenant',
              style: TextStyle(
                fontSize: isMobile ? 15 : 18,
                fontFamily: "PRegular",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String method, String contact, MaterialColor color, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 220,
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      margin: EdgeInsets.only(bottom: isMobile ? 0 : 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade400, size: isMobile ? 32 : 48),
          SizedBox(height: isMobile ? 10 : 16),
          Text(
            method,
            style: TextStyle(
              fontFamily: "PBold",
              fontSize: isMobile ? 15 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            contact,
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              fontFamily: "PRegular",
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}