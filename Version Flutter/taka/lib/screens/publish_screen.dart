import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:taka2/models/user_model.dart';
import 'package:taka2/widgets/const.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class PublishScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool isLoggedIn;
  final UserModel user;
  final Map<String, dynamic>? bookToEdit;

  const PublishScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    required this.user,
    this.bookToEdit,
  });

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  int currentStep = 1;
  bool isSubmitting = false;

  final Map<String, dynamic> formData = {
    'title': '',
    'genre': '',
    'language': 'Français', // Par défaut français
    'summary': '',
    'file': null,
    'cover': null,
    'plan': '',
    'authorBio': '',
    'authorPhoto': null,
    'authorLinks': '',
    'excerpt': '',
    'quote': '',
    'priceType': 'gratuit',
    'price': '',
  };

  Uint8List? coverPreviewBytes;
  int? oldPlanAmount;

  final List<Map<String, dynamic>> steps = [
    {'number': 1, 'title': 'Informations du livre', 'icon': Icons.description},
    {'number': 2, 'title': 'Fichier du livre', 'icon': Icons.upload_file},
    {'number': 3, 'title': 'Couverture', 'icon': Icons.image},
    {'number': 4, 'title': 'Plan de publication', 'icon': Icons.attach_money},
  ];

  final List<String> themes = [
    'Roman',
    'Fiction',
    'Non-fiction',
    'Biographie',
    'Histoire',
    'Poésie',
    'Essai',
    'Jeunesse',
    'Science-fiction',
    'Fantastique',
    'Thriller',
    'Romance',
    'Argent & Richesse',
    'Business & Entrepreneuriat',
    'Leadership & Pouvoir',
    'Psychologie & Comportement humain',
    'Spiritualité & Conscience',
    'Philosophie & Sagesse',
    'Histoire & Géopolitique',
    'Sociétés & Civilisations',
    'Science & Connaissance',
    'Développement personnel',
    'Relations & Sexualité',
    'Politique & Stratégie',
    'Ésotérisme & Savoirs cachés',
    'Religion & Textes sacrés',
    'Afrique & Identité',
    'Livres rares & interdits',
  ];

  final List<String> languages = [
    'Français',
    'Anglais',
    'Arabe',
    'Swahili',
    'Wolof',
    'Hausa',
    'Lingala',
  ];

  final List<Map<String, dynamic>> plans = [
    {
      'id': 'basic',
      'name': 'BASIQUE',
      'price': '0 FCFA',
      'features': [
        'Mise en ligne de ton livre sur la plateforme TAKA',
        'Présence sur nos réseaux sociaux (Facebook, Instagram, TikTok)',
        'Rémunération auteur : 80% du prix de vente',
      ],
    },
    {
      'id': 'premium',
      'name': 'PREMIUM',
      'price': '0 FCFA',
      'features': [
        'Tous les avantages de l\'Offre Basique',
        'Publicité sponsorisée Facebook + Instagram (coût pris en charge par TAKA)',
        'Rémunération auteur : 50% sur ventes générées',
      ],
    },
    {
      'id': 'international',
      'name': 'VENDRE A L\INTERNATIONNAL',
      'price': '30.000 FCFA',
      'features': [
        'Publié sur TAKA + Amazon KDP (ebook et papier)',
        'Analysé et optimisé par notre maison d\'édition partenaire',
        'Coaching éditorial obligatoire à 50.000 FCFA',
        'Rémunération Amazon : 30% des ventes',
        'Publicité sponsorisée Facebook + Instagram',
        'Rémunération auteur : 40% sur ventes générées',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.bookToEdit != null) {
      final book = widget.bookToEdit!;
      formData['title'] = book['title'] ?? '';
      formData['genre'] = book['genre'] ?? '';
      formData['language'] =
          book['language'] ?? 'Français'; // Par défaut français
      formData['summary'] = book['summary'] ?? '';
      formData['plan'] = book['plan'] ?? '';
      formData['authorBio'] = book['author_bio'] ?? '';
      formData['authorLinks'] = book['author_links'] ?? '';
      formData['excerpt'] = book['excerpt'] ?? '';
      formData['quote'] = book['quote'] ?? '';
      formData['priceType'] = book['price_type'] ?? 'gratuit';
      formData['price'] = book['price']?.toString() ?? '';
      final oldPlan = plans.firstWhere(
        (p) => p['id'] == book['plan'],
        orElse: () => plans[0],
      );
      oldPlanAmount =
          int.tryParse(
            (oldPlan['price'] as String)
                .replaceAll('.', '')
                .replaceAll(' FCFA', ''),
          ) ??
          0;
    }
  }

  @override
  void dispose() {
    // Cleanup handled by Flutter
    super.dispose();
  }

  Future<bool> submitBook(Map<String, dynamic> formData) async {
    var uri = Uri.parse('$baseUrl/taka_api_publish.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['title'] = formData['title'];
    request.fields['genre'] = formData['genre'];
    request.fields['language'] = formData['language'];
    request.fields['summary'] = formData['summary'];
    request.fields['plan'] = formData['plan'];
    request.fields['authorBio'] = formData['authorBio'];
    request.fields['authorLinks'] = formData['authorLinks'];
    request.fields['excerpt'] = formData['excerpt'];
    request.fields['quote'] = formData['quote'];
    request.fields['priceType'] = formData['priceType'];
    request.fields['price'] = formData['price'];
    request.fields['user_id'] = formData['user_id'].toString();

    // Handle file uploads - support both String paths and PlatformFile
    if (formData['file'] != null) {
      if (formData['file'] is String) {
        request.files.add(
          await http.MultipartFile.fromPath('file', formData['file']),
        );
      } else if (formData['file'] is PlatformFile) {
        final platformFile = formData['file'] as PlatformFile;
        if (platformFile.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath('file', platformFile.path!),
          );
        } else if (platformFile.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          );
        }
      }
    }

    if (formData['cover'] != null) {
      if (formData['cover'] is String) {
        request.files.add(
          await http.MultipartFile.fromPath('cover', formData['cover']),
        );
      } else if (formData['cover'] is PlatformFile) {
        final platformFile = formData['cover'] as PlatformFile;
        if (platformFile.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath('cover', platformFile.path!),
          );
        } else if (platformFile.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'cover',
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          );
        }
      }
    }

    if (formData['authorPhoto'] != null) {
      if (formData['authorPhoto'] is String) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'authorPhoto',
            formData['authorPhoto'],
          ),
        );
      } else if (formData['authorPhoto'] is PlatformFile) {
        final platformFile = formData['authorPhoto'] as PlatformFile;
        if (platformFile.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'authorPhoto',
              platformFile.path!,
            ),
          );
        } else if (platformFile.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'authorPhoto',
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          );
        }
      }
    }

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print('API response: $respStr');
    try {
      final json = jsonDecode(respStr);
      return json['success'] == true;
    } catch (e) {
      return response.statusCode == 200;
    }
  }

  Future<bool> updateBook(Map<String, dynamic> formData) async {
    var uri = Uri.parse('$baseUrl/taka_api_update_book.php');
    var request = http.MultipartRequest('POST', uri);

    request.fields['id'] = formData['id'].toString();
    request.fields['title'] = formData['title'];
    request.fields['genre'] = formData['genre'];
    request.fields['language'] = formData['language'];
    request.fields['summary'] = formData['summary'];
    request.fields['plan'] = formData['plan'];
    request.fields['authorBio'] = formData['authorBio'];
    request.fields['authorLinks'] = formData['authorLinks'];
    request.fields['excerpt'] = formData['excerpt'];
    request.fields['quote'] = formData['quote'];
    request.fields['priceType'] = formData['priceType'];
    request.fields['price'] = formData['price'];
    request.fields['user_id'] = formData['user_id'].toString();

    // Handle file uploads - support both String paths and PlatformFile
    if (formData['file'] != null) {
      if (formData['file'] is String) {
        request.files.add(
          await http.MultipartFile.fromPath('file', formData['file']),
        );
      } else if (formData['file'] is PlatformFile) {
        final platformFile = formData['file'] as PlatformFile;
        if (platformFile.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath('file', platformFile.path!),
          );
        } else if (platformFile.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          );
        }
      }
    }

    if (formData['cover'] != null) {
      if (formData['cover'] is String) {
        request.files.add(
          await http.MultipartFile.fromPath('cover', formData['cover']),
        );
      } else if (formData['cover'] is PlatformFile) {
        final platformFile = formData['cover'] as PlatformFile;
        if (platformFile.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath('cover', platformFile.path!),
          );
        } else if (platformFile.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'cover',
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          );
        }
      }
    }

    if (formData['authorPhoto'] != null) {
      if (formData['authorPhoto'] is String) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'authorPhoto',
            formData['authorPhoto'],
          ),
        );
      } else if (formData['authorPhoto'] is PlatformFile) {
        final platformFile = formData['authorPhoto'] as PlatformFile;
        if (platformFile.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'authorPhoto',
              platformFile.path!,
            ),
          );
        } else if (platformFile.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'authorPhoto',
              platformFile.bytes!,
              filename: platformFile.name,
            ),
          );
        }
      }
    }

    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print('API response: $respStr');
    try {
      final json = jsonDecode(respStr);
      return json['success'] == true;
    } catch (e) {
      return response.statusCode == 200;
    }
  }

  void pickFile(String key) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: key == 'file' ? FileType.custom : FileType.image,
      allowedExtensions: key == 'file'
          ? ['pdf']
          : null, // Seulement PDF pour les fichiers
    );

    if (result != null && result.files.single.path != null) {
      final platformFile = result.files.single;
      // Read bytes for preview if it's a cover image
      if (key == 'cover' && platformFile.path != null) {
        final file = File(platformFile.path!);
        final bytes = await file.readAsBytes();
        setState(() {
          formData[key] = platformFile;
          coverPreviewBytes = bytes;
        });
      } else {
        setState(() {
          formData[key] = platformFile;
        });
      }
    } else if (result != null && result.files.single.bytes != null) {
      // Handle web platform (file picker returns bytes on web)
      final platformFile = result.files.single;
      setState(() {
        formData[key] = platformFile;
        if (key == 'cover' && platformFile.bytes != null) {
          coverPreviewBytes = platformFile.bytes;
        }
      });
    }
  }

  void _handleSubmit() async {
    // Valider tous les champs requis avant de soumettre
    if (!_validateCurrentStep()) {
      setState(() => isSubmitting = false);
      return;
    }

    setState(() => isSubmitting = true);
    final selectedPlan = plans.firstWhere(
      (p) => p['id'] == formData['plan'],
      orElse: () => plans[0],
    );
    final isPaidPlan = selectedPlan['price'] != '0 FCFA';
    final selectedAmount =
        int.tryParse(
          selectedPlan['price'].replaceAll('.', '').replaceAll(' FCFA', ''),
        ) ??
        0;

    bool needPayment = false;

    if (widget.bookToEdit != null && widget.bookToEdit!['id'] != null) {
      if (isPaidPlan &&
          (oldPlanAmount == null || selectedAmount != oldPlanAmount)) {
        needPayment = true;
      }
    } else {
      if (isPaidPlan) {
        needPayment = true;
      }
    }

    if (needPayment) {
      final paid = await processPublicationPayment(
        selectedAmount,
        selectedPlan['name'],
      );
      if (!paid) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement non effectué ou publication non validée.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Si publié, tu peux afficher un message ou continuer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Livre publié avec succès après paiement !'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onNavigate('dashboard');
      setState(() => isSubmitting = false);
      return;
    }
    bool success;
    if (widget.bookToEdit != null && widget.bookToEdit!['id'] != null) {
      success = await updateBook({
        ...formData,
        'id': widget.bookToEdit!['id'],
        'user_id': widget.user.id,
      });
    } else {
      success = await submitBook({...formData, 'user_id': widget.user.id});
    }

    setState(() => isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Livre soumis avec succès ! Vous recevrez une confirmation par email.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      widget.onNavigate('dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la soumission. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    if (widget.bookToEdit != null && formData['title'].isEmpty) {
      final book = widget.bookToEdit!;
      formData['title'] = book['title'] ?? '';
      formData['genre'] = book['genre'] ?? '';
      formData['language'] = book['language'] ?? '';
      formData['summary'] = book['summary'] ?? '';
      formData['plan'] = book['plan'] ?? '';
      formData['authorBio'] = book['author_bio'] ?? '';
      formData['authorLinks'] = book['author_links'] ?? '';
      formData['excerpt'] = book['excerpt'] ?? '';
      formData['quote'] = book['quote'] ?? '';
      formData['priceType'] = book['price_type'] ?? 'gratuit';
      formData['price'] = book['price']?.toString() ?? '';
    }
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
                  fontSize: 24,
                  fontFamily: "PBold",
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous devez être connecté pour publier un livre.',
                style: TextStyle(
                  fontFamily: "PRegular",
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => widget.onNavigate('login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontFamily: "PRegular", color: Colors.white),
                ),
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
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 200),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 32),
          child: Column(
            children: [
              _buildProgressSteps(isMobile: isMobile),
              SizedBox(height: isMobile ? 16 : 32),
              _buildFormContent(isMobile: isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 24),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = currentStep >= step['number'];
          final isCompleted = currentStep > step['number'];

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: isMobile ? 28 : 40,
                        height: isMobile ? 28 : 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFF97316)
                              : const Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFF97316)
                                : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : step['icon'],
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF6B7280),
                          size: isMobile ? 16 : 20,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      if (!isMobile ||
                          MediaQuery.of(context).size.width >= 640) ...[
                        Text(
                          'Étape ${step['number']}',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 13,
                            fontFamily: "PBold",
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? const Color(0xFFF97316)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          step['title'],
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 12,
                            color: isActive
                                ? const Color(0xFFF97316)
                                : const Color(0xFF9CA3AF),
                            fontFamily: "PRegular",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: isMobile ? 24 : 48,
                    height: 2,
                    color: isCompleted
                        ? const Color(0xFFF97316)
                        : const Color(0xFFD1D5DB),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormContent({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _renderStep(isMobile: isMobile),
          SizedBox(height: isMobile ? 16 : 32),
          _buildNavigationButtons(isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _renderStep({required bool isMobile}) {
    switch (currentStep) {
      case 1:
        return _buildStep1(isMobile: isMobile);
      case 2:
        return _buildStep2(isMobile: isMobile);
      case 3:
        return _buildStep3(isMobile: isMobile);
      case 4:
        return _buildStep4(isMobile: isMobile);
      default:
        return Container();
    }
  }

  Widget _buildStep1({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du livre',
          style: TextStyle(
            fontSize: isMobile ? 18 : 24,
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildTextField(
          label: 'Titre du livre *',
          value: formData['title'],
          onChanged: (value) {
            setState(() {
              formData['title'] = value;
            });
          },
          fontSize: isMobile ? 13 : 15,
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildDropdown(
          label: 'Thématique *',
          value: formData['genre'],
          items: themes,
          onChanged: (value) {
            setState(() {
              formData['genre'] = value ?? '';
            });
          },
          fontSize: isMobile ? 13 : 15,
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Text(
          "Type du Livre *",
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontFamily: "PBold",
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: formData['priceType'],
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'gratuit', child: Text('Gratuit')),
                  DropdownMenuItem(value: 'payant', child: Text('Payant')),
                ],
                onChanged: (value) {
                  setState(() {
                    formData['priceType'] = value!;
                    if (value == 'gratuit') formData['price'] = '';
                  });
                },
              ),
            ),
            if (formData['priceType'] == 'payant')
              SizedBox(width: isMobile ? 8 : 24),
            if (formData['priceType'] == 'payant')
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix du livre (FCFA) *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      formData['price'] = value;
                    });
                  },
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildTextField(
          label: 'Description *',
          value: formData['summary'],
          onChanged: (value) {
            setState(() {
              formData['summary'] = value;
            });
          },
          maxLines: isMobile ? 4 : 6,
          hintText: 'Décrivez votre livre en quelques paragraphes...',
          fontSize: isMobile ? 13 : 15,
        ),
      ],
    );
  }

  Widget _buildStep2({required bool isMobile}) {
    String? fileName;
    if (formData['file'] != null) {
      if (formData['file'] is String) {
        fileName = formData['file'];
      } else if (formData['file'] is PlatformFile) {
        fileName = (formData['file'] as PlatformFile).name;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fichier du livre',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildFileUpload(
          title: 'Télécharger votre manuscrit',
          subtitle: 'Format accepté: PDF uniquement (max 50MB)',
          icon: Icons.upload_file,
          onTap: () => pickFile('file'),
          fileName: fileName,
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildInfoBox(
          title: 'Conseils pour votre manuscrit:',
          items: [
            'Assurez-vous que votre texte est bien formaté',
            'Vérifiez l\'orthographe et la grammaire',
            'Incluez une table des matières si nécessaire',
            'Le fichier ne doit pas dépasser 50MB',
          ],
          color: const Color(0xFFEFF6FF),
        ),
      ],
    );
  }

  Widget _buildStep3({required bool isMobile}) {
    String? fileName;
    if (formData['file'] != null) {
      if (formData['file'] is String) {
        fileName = formData['file'];
      } else if (formData['file'] is PlatformFile) {
        fileName = (formData['file'] as PlatformFile).name;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Couverture du livre',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        isMobile
            ? Column(
                children: [
                  _buildFileUpload(
                    title: 'Télécharger la couverture',
                    subtitle: 'Format recommandé: 1500x2500px, JPG/PNG',
                    icon: Icons.image,
                    onTap: () => pickFile('cover'),
                    fileName: fileName,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            formData['cover'] != null &&
                                coverPreviewBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  coverPreviewBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Aperçu de la couverture',
                                    style: TextStyle(
                                      fontFamily: "PBold",
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFileUpload(
                      title: 'Télécharger la couverture',
                      subtitle: 'Format recommandé: 1500x2500px, JPG/PNG',
                      icon: Icons.image,
                      onTap: () => pickFile('cover'),
                      fileName: fileName,
                    ),
                  ),
                  if (MediaQuery.of(context).size.width >= 1024) ...[
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aperçu en direct',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "PBold",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child:
                                    formData['cover'] != null &&
                                        coverPreviewBytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          coverPreviewBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Color(0xFF6B7280),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Aperçu de la couverture',
                                            style: TextStyle(
                                              fontFamily: "PBold",
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildInfoBox(
          title: 'Conseils pour une couverture réussie:',
          items: [
            'Utilisez des couleurs contrastées pour le titre',
            'Assurez-vous que le titre soit lisible en petit format',
            'Évitez les images trop chargées',
            'Respectez les dimensions recommandées',
          ],
          color: const Color(0xFFFEF3C7),
        ),
      ],
    );
  }

  Future<bool> processPublicationPayment(int amount, String planName) async {
    try {
      final user = widget.user;

      // Récupérer la devise et le pays sélectionnés par l'utilisateur
      final prefs = await SharedPreferences.getInstance();
      final selectedCurrency = prefs.getString('currency') ?? 'XOF';
      final selectedCountry = prefs.getString('country') ?? 'Bénin';

      // Prépare les données à envoyer à moneroo_publish_init.php
      final Map<String, dynamic> payload = {
        'amount': amount,
        'currency': selectedCurrency,
        'country': selectedCountry,
        'description': 'Publication plan $planName',
        'email': user.email ?? '',
        'first_name': user.name.split(' ').first,
        'last_name': user.name.split(' ').length > 1
            ? user.name.split(' ').sublist(1).join(' ')
            : '',
        'user_id': user.id,
        'plan': planName,
        // Ajoute ici tous les champs nécessaires à la publication :
        'title': formData['title'],
        'genre': formData['genre'],
        'language': formData['language'],
        'summary': formData['summary'],
        'authorBio': formData['authorBio'],
        'authorLinks': formData['authorLinks'],
        'excerpt': formData['excerpt'],
        'quote': formData['quote'],
        'priceType': formData['priceType'],
        'price': formData['price'],
        // Ajoute d'autres champs si besoin
        'return_url': 'https://takaafrica.com',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/moneroo_publish_init.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);

      if (data['checkout_url'] != null && data['transaction_ref'] != null) {
        final url = data['checkout_url'];
        final transactionRef = data['transaction_ref'];

        // Ouvre la page de paiement Moneroo
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

          // Polling pour vérifier la publication (toutes les 2 secondes)
          bool published = false;
          int retry = 0;
          while (!published && retry < 60) {
            // max 2 minutes
            await Future.delayed(const Duration(seconds: 2));
            final pollResp = await http.get(
              Uri.parse(
                '$baseUrl/taka_api_publish_status.php?transaction_ref=$transactionRef',
              ),
            );
            final pollData = jsonDecode(pollResp.body);
            if (pollData['status'] == 'published') {
              published = true;
              break;
            }
            retry++;
          }
          return published;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Erreur Moneroo: $e');
      return false;
    }
  }

  // Future<bool> processPublicationPayment(int amount, String planName) async {
  //       try {
  //         final user = widget.user;
  //         final response = await http.post(
  //           Uri.parse('$baseUrl/moneroo_init.php'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({
  //             'amount': amount,
  //             'currency': 'XOF',
  //             'description': 'Publication plan $planName',
  //             'email': user.email ?? '',
  //             'first_name': user.name.split(' ').first,
  //             'last_name': user.name.split(' ').length > 1 ? user.name.split(' ').sublist(1).join(' ') : '',
  //             'user_id': user.id.toString(),
  //             'plan_id': planName,
  //             'return_url': 'https://takaafrica.com',
  //           }),
  //         );
  //         final data = jsonDecode(response.body);

  //         if (data['checkout_url'] != null) {
  //           final url = data['checkout_url'];
  //           if (await canLaunchUrl(Uri.parse(url))) {
  //             await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //             // Tu peux ajouter ici un polling pour vérifier le paiement si besoin
  //             return true;
  //           } else {
  //             return false;
  //           }
  //         } else {
  //           return false;
  //         }
  //       } catch (e) {
  //         print('Erreur Moneroo: $e');
  //         return false;
  //       }
  //     }

  Widget _buildStep4({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir votre plan de publication',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.w700,
            fontFamily: "PBold",
            color: Colors.black,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: plans.map((plan) {
            final isSelected = formData['plan'] == plan['id'];
            final double width = isMobile
                ? double.infinity
                : (MediaQuery.of(context).size.width -
                          2 * (isMobile ? 8 : 200) -
                          24) /
                      2.3;
            return SizedBox(
              width: isMobile ? double.infinity : width,
              child: GestureDetector(
                onTap: () => setState(() => formData['plan'] = plan['id']),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF97316)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          plan['name'],
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 18,
                            fontFamily: "PBold",
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Center(
                        child: Text(
                          plan['price'] == "0 FCFA" ? "Gratuit" : plan['price'],
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 22,
                            fontFamily: "PBold",
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF97316),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 16),
                      ...((plan['features'] as List<String>).map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 14,
                                    fontFamily: "PRegular",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep5({required bool isMobile}) {
    String? coverName;
    if (formData['authorPhoto'] != null) {
      if (formData['authorPhoto'] is String) {
        coverName = formData['authorPhoto'];
      } else if (formData['authorPhoto'] is PlatformFile) {
        coverName = (formData['authorPhoto'] as PlatformFile).name;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil auteur',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo de profil',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildFileUpload(
                    title: '',
                    subtitle: '',
                    icon: Icons.person,
                    onTap: () => pickFile('authorPhoto'),
                    fileName: coverName,
                    compact: true,
                    preview:
                        (formData['authorPhoto'] != null &&
                            formData['authorPhoto'] is PlatformFile &&
                            (formData['authorPhoto'] as PlatformFile).bytes !=
                                null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              (formData['authorPhoto'] as PlatformFile).bytes!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Biographie *',
                    value: formData['authorBio'],
                    onChanged: (value) => formData['authorBio'] = value,
                    maxLines: 4,
                    hintText:
                        'Parlez-nous de vous, votre parcours, vos inspirations...',
                    fontSize: 13,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Liens (réseaux sociaux, site web)',
                    value: formData['authorLinks'],
                    onChanged: (value) => formData['authorLinks'] = value,
                    maxLines: 2,
                    hintText:
                        'https://facebook.com/monprofil\nhttps://twitter.com/moncompte\nhttps://monsite.com',
                    fontSize: 13,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (MediaQuery.of(context).size.width >= 1024) ...[
                    SizedBox(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo de profil',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "PBold",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildFileUpload(
                            title: '',
                            subtitle: '',
                            icon: Icons.person,
                            onTap: () => pickFile('authorPhoto'),
                            fileName: coverName,
                            compact: true,
                            preview:
                                (formData['authorPhoto'] != null &&
                                    formData['authorPhoto'] is PlatformFile &&
                                    (formData['authorPhoto'] as PlatformFile)
                                            .bytes !=
                                        null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      (formData['authorPhoto'] as PlatformFile)
                                          .bytes!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 32),
                  ],
                  Expanded(
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Biographie *',
                          value: formData['authorBio'],
                          onChanged: (value) => formData['authorBio'] = value,
                          maxLines: 6,
                          hintText:
                              'Parlez-nous de vous, votre parcours, vos inspirations...',
                        ),
                        SizedBox(height: 24),
                        _buildTextField(
                          label: 'Liens (réseaux sociaux, site web)',
                          value: formData['authorLinks'],
                          onChanged: (value) => formData['authorLinks'] = value,
                          maxLines: 3,
                          hintText:
                              'https://facebook.com/monprofil\nhttps://twitter.com/moncompte\nhttps://monsite.com',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildStep6({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Textes de promotion',
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildTextField(
          label: 'Extrait du livre *',
          value: formData['excerpt'],
          onChanged: (value) => formData['excerpt'] = value,
          maxLines: isMobile ? 4 : 8,
          hintText:
              'Copiez un passage captivant de votre livre (2-3 paragraphes)...',
          fontSize: isMobile ? 13 : 15,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          'Cet extrait sera affiché sur la page de présentation de votre livre',
          style: TextStyle(
            fontSize: isMobile ? 11 : 14,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildTextField(
          label: 'Citation marquante',
          value: formData['quote'],
          onChanged: (value) => formData['quote'] = value,
          maxLines: isMobile ? 2 : 3,
          hintText:
              'Une phrase ou citation qui résume l\'essence de votre livre...',
          fontSize: isMobile ? 13 : 15,
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          'Cette citation sera utilisée pour les promotions sur les réseaux sociaux',
          style: TextStyle(
            fontSize: isMobile ? 11 : 14,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildSummaryBox(isMobile: isMobile),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    String? hintText,
    double fontSize = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: "PBold",
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(fontSize: fontSize, fontFamily: "PRegular"),
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFF97316), width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    double fontSize = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: "PBold",
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: value.isEmpty ? null : value,
          onChanged: onChanged,
          style: TextStyle(
            fontFamily: "PRegular",
            fontSize: fontSize,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xFFF97316), width: 2),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: "PRegular",
                      color: Colors.black,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFileUpload({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    String? fileName,
    bool compact = false,
    Widget? preview,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 24 : 32),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFD1D5DB),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            if (preview != null)
              preview
            else
              Icon(
                icon,
                size: compact ? 32 : 48,
                color: const Color(0xFF9CA3AF),
              ),
            if (!compact) ...[
              SizedBox(height: 16),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "PRegular",
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "PRegular",
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                compact ? 'Choisir' : 'Choisir un fichier',
                style: TextStyle(fontFamily: "PRegular", color: Colors.white),
              ),
            ),
            if (fileName != null) ...[
              SizedBox(height: 16),
              Text(
                '✓ $fileName',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "PBold",
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontFamily: "PRegular",
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox({required bool isMobile}) {
    final selectedPlan = plans.firstWhere(
      (plan) => plan['id'] == formData['plan'],
      orElse: () => {'name': 'Non sélectionné'},
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Récapitulatif de votre soumission',
            style: TextStyle(
              fontSize: isMobile ? 13 : 16,
              fontFamily: "PBold",
              fontWeight: FontWeight.w500,
              color: Color(0xFF14532D),
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titre: ${formData['title'].isEmpty ? 'Non renseigné' : formData['title']}',
                    ),
                    Text(
                      'Genre: ${formData['genre'].isEmpty ? 'Non renseigné' : formData['genre']}',
                    ),
                    Text(
                      'Langue: ${formData['language'].isEmpty ? 'Non renseigné' : formData['language']}',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plan: ${selectedPlan['name']}'),
                    Text(
                      'Fichier: ${formData['file'] != null ? '✓ Ajouté' : '✗ Manquant'}',
                    ),
                    Text(
                      'Couverture: ${formData['cover'] != null ? '✓ Ajoutée' : '✗ Manquante'}',
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

  Widget _buildNavigationButtons({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.only(top: isMobile ? 12 : 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: currentStep > 1 ? _prevStep : null,
            icon: const Icon(Icons.arrow_back),
            label: Text(
              'Précédent',
              style: TextStyle(
                fontFamily: "PRegular",
                fontSize: isMobile ? 13 : 15,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: currentStep > 1
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF9CA3AF),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: isMobile ? 8 : 12,
              ),
            ),
          ),
          if (currentStep < 4)
            ElevatedButton.icon(
              onPressed: _nextStep,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                'Suivant',
                style: TextStyle(
                  fontFamily: "PRegular",
                  fontSize: isMobile ? 13 : 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 24,
                  vertical: isMobile ? 8 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Soumettre mon livre',
                      style: TextStyle(fontSize: isMobile ? 13 : 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                        vertical: isMobile ? 8 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 1:
        // Étape 1 : Informations du livre
        if (formData['title']?.toString().trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez remplir le titre du livre'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        if (formData['genre']?.toString().trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner une thématique'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        if (formData['language']?.toString().trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner une langue'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        if (formData['summary']?.toString().trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez remplir la description du livre'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        if (formData['priceType']?.toString().trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Veuillez sélectionner le type de livre (gratuit/payant)',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        // Si payant, vérifier que le prix est rempli
        if (formData['priceType'] == 'payant' &&
            (formData['price']?.toString().trim().isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez saisir le prix du livre'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;

      case 2:
        // Étape 2 : Fichier du livre
        if (formData['file'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez télécharger le fichier du livre (PDF)'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;

      case 3:
        // Étape 3 : Couverture
        if (formData['cover'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez télécharger la couverture du livre'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;

      case 4:
        // Étape 4 : Plan de publication
        if (formData['plan']?.toString().trim().isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner un plan de publication'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _nextStep() {
    if (currentStep < 4) {
      // Valider les champs de l'étape actuelle avant de passer à la suivante
      if (_validateCurrentStep()) {
        setState(() => currentStep++);
      }
    }
  }

  void _prevStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    }
  }
}
