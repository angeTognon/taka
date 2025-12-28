import 'package:flutter/material.dart';
import 'package:taka2/screens/Contact_page.dart';
import 'package:taka2/screens/about_page.dart';
import 'package:taka2/screens/affiliate_page2.dart';
import 'package:taka2/screens/affiliate_screen.dart';
import 'package:taka2/screens/conditions_de_distribution.dart';
import 'package:taka2/screens/faq_lecteur.dart';
import 'package:taka2/screens/faq_page.dart';
import 'package:taka2/screens/politique.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobileView = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      color: const Color(0xFF111827),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(
          vertical: 48,
          horizontal: isMobileView ? 20 : 100,
        ),
        child: Column(
          children: [
            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 768) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and description
                      Expanded(flex: 2, child: _buildLogoSection()),
                      const SizedBox(width: 32),
                      // Links
                      Expanded(child: _buildLinksSection(context)),
                      const SizedBox(width: 32),
                      // Community
                      Expanded(child: _buildCommunitySection(context)),
                      const SizedBox(width: 32),
                      // Legal
                      Expanded(child: _buildLegalSection(context)),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogoSection(),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLinksSection(context)),
                          const SizedBox(width: 32),
                          Expanded(child: _buildCommunitySection(context)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildLegalSection(context)),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            // Copyright
            Container(
              margin: const EdgeInsets.only(top: 32),
              padding: const EdgeInsets.only(top: 32),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF1F2937), width: 1),
                ),
              ),
              child: const Text(
                '© 2026 TAKA. Tous droits réservés.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Image.asset("assets/images/logo.jpeg"),
        ),
        const SizedBox(height: 16),
        const Text(
          "Lis africain. Pense libre. Découvre autrement.\nTAKA, c'est ta librairie digitale nouvelle génération, 100% adaptée à la réalité africaine.",
          style: TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 14,
            fontFamily: "PRegular",
            height: 1.5,
          ),
        ),
        // const SizedBox(height: 24),
        // Social icons with links
        // Row(
        //   children: [
        //     _buildSocialSvgIcon(
        //       url: 'https://www.facebook.com/takalivresafricains',
        //       assetUrl: 'assets/images/facebook.png',
        //       tooltip: 'Facebook',
        //     ),
        //     const SizedBox(width: 16),
        //     _buildSocialSvgIcon(
        //       url:
        //           'https://www.instagram.com/takalivresafricains?igsh=MXBqM3N3ZjM2cmwxdA==',
        //       assetUrl: 'assets/images/instagram.png',
        //       tooltip: 'Instagram',
        //     ),
        //     const SizedBox(width: 16),
        //     _buildSocialSvgIcon(
        //       url:
        //           'https://www.tiktok.com/@takalivresafricains?_t=ZM-8ymz7cz5WR6&_r=1',
        //       assetUrl: 'assets/images/tiktok.png',
        //       tooltip: 'TikTok',
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSocialSvgIcon({
    required String url,
    required String assetUrl,
    required String tooltip,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            assetUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.link, color: Color(0xFF9CA3AF), size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    final links = [
      {'label': 'À propos', 'route': AboutPage()},
      {'label': 'Auteurs', 'route': FAQPage()},
      {'label': 'Lecteurs', 'route': FAQLecteurPage()},
      // {'label': 'Programme d\'affiliation', 'route': AffiliatePage()},
      {'label': 'Contact', 'route': ContactPage()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Liens utiles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: item['route'] != null
                  ? () {
                      if (item['route'] is String) {
                        Navigator.of(
                          context,
                        ).pushNamed(item['route'] as String);
                      } else if (item['route'] is Widget) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => item['route'] as Widget,
                          ),
                        );
                      }
                    }
                  : null,
              child: Text(
                item['label'] as String,
                style: const TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final legalLinks = [
      {
        'label': 'Politique de confidentialité',
        'route': PolitiqueConfidentialiteScreen(),
      },
      {
        'label': 'Conditions de distribution',
        'route': ConditionsDeDistribution(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Légal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...legalLinks.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: item['route'] != null
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => item['route'] as Widget,
                        ),
                      );
                    }
                  : null,
              child: Text(
                item['label'] as String,
                style: const TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    final communityLinks = [
      // {
      //   'label': 'Canal TAKA (Telegram)',
      //   'url': 'https://t.me/takalivresafricains',
      //   'icon': 'assets/images/telegram.png',
      //   'color': const Color(0xFF229ED9),
      // },
      {
        'label': 'Groupe LECTEURS WhatsApp',
        'url':
            'https://chat.whatsapp.com/KqnaLGneaI93fA0sjxef3j?mode=ems_copy_t',
        'icon': 'assets/images/whatsapp.png',
        'color': const Color(0xFF25D366),
      },
      {
        'label': 'Groupe AUTEURS WhatsApp',
        'url': 'https://chat.whatsapp.com/DCNEoG8uU58HdanJDxIWLS',
        'icon': 'assets/images/whatsapp.png',
        'color': const Color(0xFF25D366),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Communauté',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...communityLinks.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse(item['url'] as String);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      item['icon'] as String,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.link,
                        color: item['color'] as Color,
                        size: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
