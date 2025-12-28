import 'package:flutter/material.dart';
import 'package:taka2/screens/faq_lecteur.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Support général';

  final List<String> _categories = [
    'Support général',
    'Support auteur',
    'Support lecteur',
    'Problème technique',
    'Question commerciale',
    'Partenariat',
    'Presse et médias',
  ];

  @override
  Widget build(BuildContext context) {
          final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:  Text(
          'Nous Contacter',
          style: TextStyle(
            fontFamily: "PBold",
            fontWeight: FontWeight.w700,
            fontSize: isMobile?17: 20,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile?17:150,vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[500]!, Colors.orange[600]!],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'Contactez l\'équipe TAKA',
                    style: TextStyle(
                      fontSize:isMobile?15: 24,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nous sommes là pour vous aider 24h/24, 7j/7',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "PRegular",
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick contact methods
            Row(
              children: [
                Expanded(
                  child: _buildQuickContactCard(
                    'WhatsApp',
                    '+229 0197147572',
                    Icons.chat,
                    Colors.green,
                    () {
                      // Open WhatsApp
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickContactCard(
                    'Email',
                    'contact@takaafrica.com',
                    Icons.email,
                    Colors.blue,
                    () {
                      // Open email
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Contact form
            Container(
              padding: const EdgeInsets.all(20.0),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Envoyez-nous un message',
                      style: TextStyle(
                        fontSize: isMobile?14 : 20,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
            
                    // Category dropdown
                     Text(
                      'Catégorie',
                      style: TextStyle(
                        fontSize: isMobile?14 :16,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style:  TextStyle(
                              fontFamily: "PRegular",

                              fontSize: isMobile?14 : 14
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Name field
                     Text(
                      'Nom complet',
                      style: TextStyle(
                        fontSize:isMobile?14 :  16,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Votre nom complet',
                        hintStyle: const TextStyle(fontFamily: "PRegular"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      style: const TextStyle(fontFamily: "PRegular",fontSize: 14),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Email field
                    Text(
                      'Adresse email',
                      style: TextStyle(
                        fontSize: isMobile?14 : 16,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'votre@email.com',
                        hintStyle: const TextStyle(fontFamily: "PRegular"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      style: const TextStyle(fontFamily: "PRegular",fontSize: 14),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Subject field
                     Text(
                      'Sujet',
                      style: TextStyle(
                        fontSize: isMobile?14 : 16,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Résumé de votre demande',
                        hintStyle: const TextStyle(fontFamily: "PRegular"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      style: const TextStyle(fontFamily: "PRegular",fontSize: 14),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un sujet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
            
                    // Message field
                     Text(
                      'Message',
                      style: TextStyle(
                        fontSize:isMobile?14 :  16,
                        fontFamily: "PBold",
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre demande en détail...',
                        hintStyle: const TextStyle(fontFamily: "PRegular"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      style: const TextStyle(fontFamily: "PRegular",fontSize: 14),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre message';
                        }
                        if (value.length < 10) {
                          return 'Le message doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
            
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: "PBold",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        child:  Text(
                          'Envoyer le message',
                          style: TextStyle(
                            fontFamily: "PBold",
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile?14 : 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Other contact methods
            Container(
              padding: const EdgeInsets.all(20.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Autres moyens de nous contacter',
                    style: TextStyle(
                      fontSize:isMobile?14 :  18,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactMethod(
                    Icons.location_on,
                    'Adresse',
                    'TAKA AFRICA\nParakou, Bénin',
                    Colors.red,
                  ),
                  _buildContactMethod(
                    Icons.phone,
                    'Téléphone',
                    '+229 0197147572',
                    Colors.green,
                  ),
                  _buildContactMethod(
                    Icons.schedule,
                    'Horaires',
                    'Support 24h/24, 7j/7\nRéponse sous 2h en moyenne',
                    Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // FAQ link
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 32,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(height: 12),
                   Text(
                    'Consultez notre FAQ',
                    style: TextStyle(
                      fontSize: isMobile?14 : 18,
                      fontFamily: "PBold",
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trouvez rapidement des réponses aux questions les plus fréquentes',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "PRegular",
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FAQLecteurPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle:  TextStyle(
                        fontFamily: "PBold",
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile?14 : 16,
                      ),
                    ),
                    child: const Text(
                      'Voir la FAQ',
                      style: TextStyle(
                        fontFamily: "PBold",
                        color: Colors.white,
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

  Widget _buildQuickContactCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
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
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "PBold",
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontFamily: "PRegular",
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String content, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:  TextStyle(
                    fontSize:14 ,
                    fontFamily: "PBold",
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "PRegular",
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Message envoyé avec succès ! Nous vous répondrons sous 2h.',
            style: TextStyle(fontFamily: "PRegular"),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'Support général';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}