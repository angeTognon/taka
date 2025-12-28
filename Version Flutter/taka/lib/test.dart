import 'package:flutter/material.dart';

void main() {
  runApp(BrocoApp());
}

class BrocoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BROCO - Communauté Gastronomique',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: BrocoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BrocoHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec navigation
            _buildHeader(),
            
            // Section "Nous sommes BROCO"
            _buildNousSommesBroco(),
            
            // Section "Un monde de saveurs et de rencontres"
            _buildMondeSaveurs(),
            
            // Section "Pour les particuliers" et "Pour les professionnels"
            _buildParticuliersProfessionnels(),
            
            // Section "Une aventure collective"
            _buildAventureCollective(),
            
            // Section "Ils parlent de nous"
            _buildIlsParlentDeNous(),
            
            // Section "Nous contacter"
            _buildNousContacter(),
            
            // Section "Rejoignez le mouvement"
            _buildRejoignezMouvement(),
            
            // Section finale "NOUS SOMMES BROCO"
            _buildNousSommesBrocoFinal(),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo BROCO
          Text(
            'BROCO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50), // Vert
            ),
          ),
          
          // Navigation
          Row(
            children: [
              _buildNavItem('APPLICATION (PRÉSENTATION)'),
              SizedBox(width: 20),
              _buildNavItem('POUR QUI?'),
              SizedBox(width: 20),
              _buildNavItem('AVENTURE'),
              SizedBox(width: 20),
              _buildNavItem('COIN PRESSE'),
              SizedBox(width: 20),
              _buildNavItem('CONTACT'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildNousSommesBroco() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Row(
        children: [
          // Texte à gauche
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 36, color: Colors.black),
                    children: [
                      TextSpan(text: 'Nous sommes '),
                      TextSpan(
                        text: 'BROCO',
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'BROCO est une communauté gastronomique qui unit les particuliers et les professionnels autour d\'une passion commune : le goût. Notre application rassemble l\'énergie du terroir local en un seul endroit.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 30),
                // Boutons App Store
                Row(
                  children: [
                    _buildAppStoreButton('Télécharger dans l\'App Store'),
                    SizedBox(width: 15),
                    _buildAppStoreButton('DISPONIBLE SUR Google Play'),
                  ],
                ),
              ],
            ),
          ),
          
          // Image et éléments visuels à droite
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                // Smartphone avec interface
                Container(
                  width: 200,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Nous sommes BROCO',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.map,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chapeau de chef stylisé
                Positioned(
                  right: 20,
                  top: 50,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE0E6), // Rose clair
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Petits chapeaux de chef
                Positioned(
                  right: 10,
                  bottom: 100,
                  child: Column(
                    children: [
                      Icon(Icons.restaurant, size: 20, color: Colors.grey[400]),
                      SizedBox(height: 5),
                      Icon(Icons.restaurant, size: 20, color: Colors.grey[400]),
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

  Widget _buildMondeSaveurs() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.eco, size: 40, color: Colors.grey[400]),
              Expanded(
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 32, color: Colors.black),
                        children: [
                          TextSpan(text: 'Un monde de '),
                          TextSpan(
                            text: 'saveurs et de rencontres.',
                            style: TextStyle(color: Color(0xFF4CAF50)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'BROCO connecte les passionnés de gastronomie, des particuliers aux chefs, artisans et producteurs. Une seule plateforme pour découvrir, partager et s\'inspirer.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Actions clés
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionCircle('Découvrir', Icons.explore),
                        _buildActionCircle('Partager', Icons.share),
                        _buildActionCircle('Vivre l\'aventure', Icons.explore_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.local_drink, size: 40, color: Colors.grey[400]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCircle(String text, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildParticuliersProfessionnels() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Row(
        children: [
          // Section Particuliers
          Expanded(
            child: Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pour les particuliers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Réservez facilement des ateliers, découvrez les acteurs de la gastronomie locale et partagez vos découvertes avec la communauté.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Gratuit et sans engagement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 20),
          
          // Section Professionnels
          Expanded(
            child: Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pour les professionnels',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'BROCO est votre vitrine digitale pour les métiers de la gastronomie.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 15),
                  
                  // Version gratuite
                  Text(
                    'Version gratuite',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    '• Visibilité du profil\n• Mise en avant produits/événements',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  
                  SizedBox(height: 10),
                  
                  // Version premium
                  Text(
                    'Version premium',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    '• Proposer cours/ateliers\n• Gérer réservations/paiements\n• Abonnements exclusifs',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAventureCollective() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Row(
        children: [
          Icon(Icons.eco, size: 40, color: Colors.grey[400]),
          Expanded(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 32, color: Colors.black),
                    children: [
                      TextSpan(text: 'Une aventure '),
                      TextSpan(
                        text: 'collective',
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'BROCO est plus qu\'une application, c\'est un mouvement. Chacun, des chefs étoilés aux simples gourmets, a sa place pour partager, découvrir et inspirer. Vivre la gastronomie plutôt que la consommer.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Icon(Icons.local_drink, size: 40, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildIlsParlentDeNous() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Row(
        children: [
          Icon(Icons.eco, size: 40, color: Colors.grey[400]),
          Expanded(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 32, color: Colors.black),
                    children: [
                      TextSpan(text: 'Ils parlent de '),
                      TextSpan(
                        text: 'nous',
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'BROCO attire l\'attention des médias. Téléchargez nos communiqués de presse, lisez les articles et découvrez comment la presse couvre notre aventure.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Téléchargez nos logos de presse, photos officielles et communiqués de presse PDF.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Icon(Icons.eco, size: 40, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildNousContacter() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            'Nous contacter',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Vous avez des questions, des idées ou souhaitez rejoindre l\'aventure BROCO ? N\'hésitez pas à nous contacter. Nous vous répondrons rapidement.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          
          // Formulaire de contact
          Container(
            width: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Envoyer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejoignezMouvement() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Color(0xFFFFE0E6), // Rose clair
      ),
      child: Row(
        children: [
          Icon(Icons.eco, size: 40, color: Colors.grey[400]),
          Expanded(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 32, color: Colors.black),
                    children: [
                      TextSpan(text: 'Rejoignez le '),
                      TextSpan(
                        text: 'mouvement.',
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Que vous soyez particulier ou professionnel, découvrez ce que BROCO peut vous offrir. Téléchargez l\'application et explorez les goûts, terroirs et talents locaux.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Icon(Icons.local_drink, size: 40, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildNousSommesBrocoFinal() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Row(
        children: [
          Icon(Icons.eco, size: 40, color: Colors.grey[400]),
          Expanded(
            child: Column(
              children: [
                Text(
                  'NOUS SOMMES BROCO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                // Boutons App Store finaux
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAppStoreButton('Télécharger dans l\'App Store'),
                    SizedBox(width: 15),
                    _buildAppStoreButton('DISPONIBLE SUR Google Play'),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.eco, size: 40, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildAppStoreButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(40),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Réseaux sociaux
              Row(
                children: [
                  Icon(Icons.camera_alt, size: 24, color: Colors.grey[600]),
                  SizedBox(width: 15),
                  Icon(Icons.business, size: 24, color: Colors.grey[600]),
                ],
              ),
              
              // Liens footer
              Row(
                children: [
                  Text('Particuliers | ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Professionnels | ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Presse | ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Contact | ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Mentions légales | ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('Politique de confidentialité', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              
              // Description
              Expanded(
                child: Text(
                  'BROCO est une application gastronomique suisse qui connecte particuliers et professionnels. Découvrez des cours de cuisine, ateliers culinaires, producteurs locaux, expériences gastronomiques et rejoignez une communauté conviviale et passionnée.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
