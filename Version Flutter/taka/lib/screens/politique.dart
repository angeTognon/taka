import 'package:flutter/material.dart';

class PolitiqueConfidentialiteScreen extends StatelessWidget {
  const PolitiqueConfidentialiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': '1. Introduction',
        'content': 'TAKA AFRICA (ci-après "TAKA", "nous", "notre" ou "nos") s\'engage à protéger la confidentialité et la sécurité des informations personnelles de ses utilisateurs. Cette politique de confidentialité explique comment nous collectons, utilisons, partageons et protégeons vos informations lorsque vous utilisez notre plateforme de livres numériques.',
      },
      {
        'title': '2. Informations que nous collectons',
        'content': '''Nous collectons les types d'informations suivants :

• Informations d'identification : nom, adresse e-mail, numéro de téléphone
• Informations de paiement : données de carte bancaire, informations Mobile Money (traitées de manière sécurisée par nos partenaires de paiement)
• Informations de lecture : livres consultés, temps de lecture, préférences
• Données techniques : adresse IP, type de navigateur, système d'exploitation
• Informations de communication : messages envoyés via notre support client''',
      },
      {
        'title': '3. Comment nous utilisons vos informations',
        'content': '''Nous utilisons vos informations pour :

• Fournir et améliorer nos services de lecture numérique
• Traiter vos achats et abonnements
• Personnaliser votre expérience de lecture
• Communiquer avec vous concernant votre compte et nos services
• Assurer la sécurité de notre plateforme
• Respecter nos obligations légales et réglementaires''',
      },
      {
        'title': '4. Partage de vos informations',
        'content': '''Nous ne vendons jamais vos informations personnelles. Nous pouvons partager vos informations uniquement dans les cas suivants :

• Avec votre consentement explicite
• Avec nos prestataires de services (paiement, hébergement, support technique)
• Pour respecter une obligation légale ou une décision de justice
• Pour protéger nos droits, notre propriété ou notre sécurité''',
      },
      {
        'title': '5. Sécurité des données',
        'content': '''Nous mettons en place des mesures de sécurité appropriées pour protéger vos informations :

• Chiffrement SSL/TLS pour toutes les transmissions de données
• Stockage sécurisé avec accès restreint
• Surveillance continue de nos systèmes
• Formation régulière de notre personnel sur la sécurité des données''',
      },
      {
        'title': '6. Vos droits',
        'content': '''Conformément aux lois applicables, vous avez le droit de :

• Accéder à vos informations personnelles
• Corriger ou mettre à jour vos données
• Supprimer votre compte et vos données
• Vous opposer au traitement de vos données
• Demander la portabilité de vos données
• Retirer votre consentement à tout moment''',
      },
      {
        'title': '7. Cookies et technologies similaires',
        'content': '''Nous utilisons des cookies et technologies similaires pour :

• Améliorer la fonctionnalité de notre site
• Analyser l'utilisation de nos services
• Personnaliser votre expérience
• Assurer la sécurité de votre compte

Vous pouvez gérer vos préférences de cookies dans les paramètres de votre navigateur.''',
      },
      {
        'title': '8. Conservation des données',
        'content': 'Nous conservons vos informations personnelles aussi longtemps que nécessaire pour fournir nos services et respecter nos obligations légales. Les données de compte inactif peuvent être supprimées après 3 ans d\'inactivité.',
      },
      {
        'title': '9. Transferts internationaux',
        'content': 'Vos données peuvent être transférées et traitées dans des pays autres que votre pays de résidence. Nous nous assurons que ces transferts respectent les standards de protection appropriés.',
      },
      {
        'title': '10. Modifications de cette politique',
        'content': 'Nous pouvons mettre à jour cette politique de confidentialité périodiquement. Nous vous informerons de tout changement significatif par e-mail ou via notre plateforme.',
      },
    ];
          final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Politique de Confidentialité'),
        titleTextStyle:  TextStyle(
          color: Colors.black,
          fontFamily: "PBold",
          fontWeight: FontWeight.w700,
          fontSize: isMobile? 17: 20,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxCardWidth = 370;
          double spacing = 18;
          int crossAxisCount = (constraints.maxWidth / (maxCardWidth + spacing)).floor();
          if (crossAxisCount < 1) crossAxisCount = 1;
          if (crossAxisCount > 3) crossAxisCount = 3;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal:isMobile? 17: 150,vertical: 20),
                  // padding: const EdgeInsets.all(24.0),
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
                      Icon(
                        Icons.security,
                        size: 48,
                        color: Colors.orange[500],
                      ),
                      const SizedBox(height: 16),
                       Text(
                        'Politique de Confidentialité TAKA',
                        style: TextStyle(
                          fontSize: isMobile? 15:24,
                          fontFamily: "PBold",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "PRegular",
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Grille responsive
                Center(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: sections.map((section) {
                      double cardWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                      if (cardWidth > maxCardWidth) cardWidth = maxCardWidth;
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: cardWidth,
                          maxWidth: cardWidth,
                          minHeight: 220,
                        ),
                        child: IntrinsicHeight(
                          child: _buildSection(section['title']!, section['content']!,context),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                // Contact section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[500]!, Colors.orange[600]!],
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.contact_support,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Nous contacter',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "PBold",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pour toute question concernant cette politique de confidentialité :',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "PRegular",
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '📧 contact@takaafrica.com\n📱 WhatsApp : +229 0197147572\n🏢 TAKA AFRICA, Bénin',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "PRegular",
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content,BuildContext context) {
          final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(20.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontSize: isMobile? 15:18,
              fontFamily: "PBold",
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                fontFamily: "PRegular",
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}