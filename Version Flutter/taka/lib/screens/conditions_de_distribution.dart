import 'package:flutter/material.dart';

class ConditionsDeDistribution extends StatelessWidget {
  const ConditionsDeDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': "1. Objet et Champ d'application",
        'content': '''Les présentes conditions de distribution régissent les relations entre TAKA AFRICA et les auteurs/éditeurs souhaitant distribuer leurs œuvres sur notre plateforme.

En soumettant votre œuvre sur TAKA, vous acceptez intégralement ces conditions.''',
      },
      {
        'title': "2. Conditions d'éligibilité",
        'content': '''Pour distribuer votre œuvre sur TAKA, vous devez :

• Être âgé de 18 ans minimum ou disposer d'une autorisation parentale
• Être propriétaire des droits d'auteur de l'œuvre soumise
• Garantir l'originalité et la qualité de votre contenu
• Respecter nos standards éditoriaux et éthiques
• Fournir des informations exactes et complètes''',
      },
      {
        'title': "3. Droits et Propriété Intellectuelle",
        'content': '''• Vous conservez l'intégralité de vos droits d'auteur
• TAKA obtient une licence non-exclusive pour distribuer votre œuvre
• Vous garantissez ne pas porter atteinte aux droits de tiers
• Toute violation de droits d'auteur entraîne la suppression immédiate
• Vous êtes responsable de la protection de vos œuvres''',
      },
      {
        'title': "4. Standards de Qualité",
        'content': '''Toute œuvre soumise doit respecter nos critères :

• Contenu original et inédit (pas de plagiat)
• Qualité rédactionnelle professionnelle
• Mise en page soignée et lisible
• Couverture professionnelle obligatoire
• Respect des normes éditoriales TAKA
• Aucun contenu généré à 100% par IA''',
      },
      {
        'title': "5. Processus de Validation",
        'content': '''• Examen éditorial de chaque soumission (5-10 jours ouvrables)
• Vérification de l'originalité et de la qualité
• Contrôle du respect des conditions générales
• Notification de validation ou de refus motivé
• Possibilité de resoumission après corrections''',
      },
      {
        'title': "6. Rémunération et Paiements",
        'content': '''Structure de rémunération :

• Offre Basique : 80% du prix de vente pour l'auteur
• Offre Premium : 50% du prix de vente pour l'auteur
• Paiements mensuels (entre le 1er et le 15)
• Seuil minimum : 15.000 FCFA
• Modes de paiement : Mobile Money, virement bancaire
• Aucun frais de transaction à votre charge''',
      },
      {
        'title': "7. Obligations de l'Auteur",
        'content': '''En tant qu'auteur partenaire, vous vous engagez à :

• Fournir un contenu original et de qualité
• Respecter les délais de livraison convenus
• Participer aux actions promotionnelles
• Maintenir la confidentialité des données TAKA
• Signaler tout problème technique ou commercial
• Respecter l'image de marque TAKA''',
      },
      {
        'title': "8. Obligations de TAKA",
        'content': '''TAKA s'engage à :

• Assurer la distribution de votre œuvre
• Protéger vos droits d'auteur
• Effectuer les paiements dans les délais
• Fournir des statistiques de vente transparentes
• Assurer un support technique et commercial
• Promouvoir vos œuvres selon l'offre choisie''',
      },
      {
        'title': "9. Promotion et Marketing",
        'content': '''Selon votre offre :

• Présence sur nos réseaux sociaux
• Inclusion dans nos newsletters
• Campagnes publicitaires sponsorisées (Premium+)
• Mise en avant sur la plateforme
• Participation aux événements TAKA
• Programme d'affiliation disponible''',
      },
      {
        'title': "10. Résiliation et Retrait",
        'content': '''• Résiliation possible à tout moment par l'une des parties
• Préavis de 30 jours pour retrait d'œuvre
• Conservation des droits acquis jusqu'à résiliation
• Paiement des sommes dues jusqu'à la date de résiliation
• Suppression des œuvres dans les 15 jours suivant la résiliation''',
      },
      {
        'title': "11. Responsabilités et Garanties",
        'content': '''L'auteur garantit :

• L'originalité de son œuvre
• Le respect des droits de tiers
• L'exactitude des informations fournies
• La conformité aux lois en vigueur

TAKA garantit :

• La sécurité de la plateforme
• La protection des données
• Le respect des conditions de paiement''',
      },
      {
        'title': "12. Résolution des Litiges",
        'content': '''• Tentative de résolution amiable privilégiée
• Médiation possible via organisme agréé
• Juridiction compétente : Tribunaux du Bénin
• Droit applicable : Droit béninois
• Langue de procédure : Français''',
      },
    ];
          final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Conditions de Distribution'),
        titleTextStyle:  TextStyle(
          color: Colors.black,
          fontFamily: "PBold",
          fontWeight: FontWeight.w700,
          fontSize: isMobile?17: 20,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Largeur max d'une carde
          double maxCardWidth = 370;
          // Espace horizontal entre les cards
          double spacing = 18;
          // Calcul du nombre de colonnes selon la largeur de l'écran
          int crossAxisCount = (constraints.maxWidth / (maxCardWidth + spacing)).floor();
          if (crossAxisCount < 1) crossAxisCount = 1;
          if (crossAxisCount > 3) crossAxisCount = 3;
          final bool isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
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
                        Icons.gavel,
                        size: 48,
                        color: Colors.orange[500],
                      ),
                      const SizedBox(height: 16),
                       Text(
                        'Conditions de Distribution TAKA',
                        style: TextStyle(
                          fontSize: isMobile?16: 24,
                          fontFamily: "PBold",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Conditions applicables aux auteurs et éditeurs',
                    textAlign: TextAlign.center,
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
                                               // ...dans le build...
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
                                          minHeight: 260, // hauteur mini pour l'uniformité, ajuste si besoin
                                        ),
                                        child: IntrinsicHeight(
                                          child: _buildSection(section['title']!, section['content']!,context),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                
                               
                const SizedBox(height: 32),
                // Contact & signature
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
                    children:  [
                      Icon(
                        Icons.handshake,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Acceptation des Conditions',
                        style: TextStyle(
                          fontSize: isMobile?16: 20,
                          fontFamily: "PBold",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'En soumettant votre œuvre sur TAKA, vous acceptez intégralement ces conditions de distribution.',
                        style: TextStyle(
                          fontFamily: "PRegular",
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Questions ? Contactez-nous :\n📧 contact@takaafrica.com\n📱 +229 0197147572',
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

   // ...et modifie _buildSection ainsi :
                                Widget _buildSection(String title, String content,BuildContext context){
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
                                            fontSize: isMobile?14:18,
                                            fontFamily: "PBold",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded( // Ajoute ceci pour que le texte prenne la place restante
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