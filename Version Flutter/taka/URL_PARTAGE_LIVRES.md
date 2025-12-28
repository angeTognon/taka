# Système d'URLs Partageables pour les Livres TAKA

## 📚 Description

Chaque livre sur la plateforme TAKA dispose maintenant d'une URL unique et partageable. Vous pouvez partager directement le lien d'un livre avec d'autres personnes, qui seront redirigées vers la page de détails de ce livre.

## 🔗 Format des URLs

Les URLs des livres suivent le format suivant :

```
https://votre-domaine.com/nom-du-livre
```

Le nom du livre est automatiquement converti en "slug" :
- Les espaces sont remplacés par des tirets `-`
- Les caractères accentués sont normalisés (é → e, à → a, etc.)
- Les caractères spéciaux sont supprimés
- Tout est en minuscules

**Exemples :**
- `https://taka.com/contrat-matrimonial` - Pour le livre "Contrat Matrimonial"
- `https://taka.com/sameen` - Pour le livre "Sameen"
- `https://taka.com/douce-folie-tome-1` - Pour le livre "Douce Folie Tome 1"

## 🎯 Comment utiliser

### Pour l'utilisateur final

1. **Accéder à un livre** : Cliquez sur "Détails" depuis la page d'accueil ou d'exploration
2. **Partager le livre** : Cliquez sur l'icône de partage (🔗) dans la barre supérieure
3. **Le lien est copié** : Un message de confirmation s'affiche et l'URL est dans votre presse-papiers
4. **Partager** : Collez l'URL dans un email, message, réseaux sociaux, etc.

### Pour les développeurs

#### Structure du code

1. **Backend - API** (`taka_api_book_detail.php`)
   - Endpoint pour récupérer les détails d'un livre par son slug (nom)
   - URL : `{baseUrl}/taka_api_book_detail.php?slug={nom-du-livre}`
   - Retourne : JSON avec les informations du livre
   - Utilise une fonction PHP pour normaliser et comparer les slugs

2. **Frontend - Détection d'URL** (`main.dart`)
   - Détecte les URLs avec le nom du livre au démarrage
   - Charge automatiquement les données du livre depuis l'API
   - Affiche la page de détails du livre

3. **Interface de partage** (`book_detail_screen.dart`)
   - Bouton de partage dans l'AppBar
   - Fonction `_titleToSlug()` pour convertir le titre en slug
   - Génère l'URL du livre avec le nom normalisé
   - Copie l'URL dans le presse-papiers
   - Affiche une notification de succès

## ⚙️ Configuration du serveur

### Pour Apache (avec .htaccess)

Le fichier `.htaccess` est déjà configuré dans `/web/.htaccess` :

```apache
RewriteEngine On

# Route admin
RewriteRule ^takaadmin$ /index.html [L,QSA]

# Toutes les autres routes (livres, etc.)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ /index.html [L,QSA]
```

**Assurez-vous que :**
- Le module `mod_rewrite` est activé
- `AllowOverride All` est configuré dans votre VirtualHost

### Pour Nginx

Utilisez la configuration dans `nginx.conf.example` :

```nginx
# Route admin
location /takaadmin {
    try_files $uri /index.html;
}

# Toutes les autres routes redirigent vers index.html
location / {
    try_files $uri $uri/ /index.html;
}
```

## 🚀 Déploiement

### 1. Backend (PHP)

Uploadez le fichier `taka_api_book_detail.php` sur votre serveur :

```bash
# Via FTP/SFTP, placez-le à la racine ou dans le dossier API
/public_html/taka_api_book_detail.php
```

### 2. Frontend (Flutter Web)

Compilez et déployez votre application Flutter Web :

```bash
# Compiler l'application
flutter build web --release

# Déployer le contenu du dossier build/web sur votre serveur
# Assurez-vous que le fichier .htaccess est bien copié
```

### 3. Configuration serveur

**Pour Apache :**
- Le fichier `.htaccess` sera automatiquement pris en compte
- Vérifiez que `mod_rewrite` est activé

**Pour Nginx :**
- Ajoutez la configuration de `nginx.conf.example` à votre fichier de configuration
- Redémarrez Nginx : `sudo systemctl restart nginx`

## 🧪 Tests

### Tester localement

1. Lancez l'application en mode web :
```bash
flutter run -d chrome
```

2. Accédez à un livre et cliquez sur partager

3. Testez l'URL copiée en l'ouvrant dans un nouvel onglet

### Tester en production

1. Accédez à : `https://votre-domaine.com/contrat-matrimonial` (remplacez par le nom d'un livre existant)
2. La page de détails du livre devrait s'afficher
3. Si erreur 404, vérifiez la configuration du serveur

## 📊 Cas d'usage

1. **Marketing** : Partagez des livres sur les réseaux sociaux avec un lien direct
2. **Email** : Envoyez des recommandations de livres par email
3. **Affiliation** : Les affiliés peuvent partager des liens directs vers des livres
4. **SEO** : Chaque livre a une URL unique pour le référencement
5. **Partage social** : Les utilisateurs peuvent partager leurs livres préférés

## 🔍 SEO et Métadonnées

Pour améliorer le SEO, vous pouvez ajouter des balises meta dynamiques dans `index.html` en utilisant un script côté serveur (PHP/Node.js) pour générer les métadonnées Open Graph basées sur l'ID du livre dans l'URL.

**Exemple de métadonnées à ajouter :**
```html
<meta property="og:title" content="Titre du livre - TAKA">
<meta property="og:description" content="Description du livre...">
<meta property="og:image" content="URL de la couverture">
<meta property="og:url" content="https://taka.com/livre/123">
```

## 🐛 Dépannage

### L'URL ne fonctionne pas (erreur 404)

**Cause** : Le serveur web ne redirige pas correctement vers `index.html`

**Solution** :
- Vérifiez que `.htaccess` est bien uploadé (Apache)
- Vérifiez la configuration Nginx
- Vérifiez que `mod_rewrite` est activé (Apache)

### Le livre ne se charge pas

**Cause** : L'API ne retourne pas les données

**Solution** :
- Vérifiez que `taka_api_book_detail.php` est accessible
- Testez directement : `{baseUrl}/taka_api_book_detail.php?slug=contrat-matrimonial`
- Vérifiez les logs du serveur PHP
- Vérifiez la connexion à la base de données

### Le bouton de partage ne fait rien

**Cause** : Problème avec le presse-papiers

**Solution** :
- Sur HTTPS, le presse-papiers fonctionne automatiquement
- Sur HTTP (développement local), certains navigateurs bloquent l'accès
- Utilisez HTTPS même en développement ou testez sur un navigateur qui le permet

## 📝 Notes techniques

- Les URLs utilisent le **nom du livre** normalisé (slug)
- Le slug est généré automatiquement : espaces → tirets, accents supprimés, minuscules
- La détection d'URL se fait au démarrage de l'application
- L'API compare les slugs normalisés pour trouver le bon livre
- Les données du livre sont chargées dynamiquement depuis l'API
- Le système fonctionne en mode SPA (Single Page Application)
- **Avantage SEO** : URLs lisibles et descriptives

## 🎨 Personnalisation

Vous pouvez personnaliser :
- La fonction de génération de slug (modifier `_titleToSlug()` dans `book_detail_screen.dart` et `titleToSlug()` dans `taka_api_book_detail.php`)
- Le message de confirmation de copie (modifier `book_detail_screen.dart`)
- L'icône de partage (modifier `book_detail_screen.dart`)
- Les routes à exclure de la détection de livres (modifier `main.dart` ligne 184)

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifiez les logs du serveur web
2. Vérifiez les logs PHP (errors.log)
3. Utilisez la console développeur du navigateur (F12)
4. Testez l'API directement avec l'URL complète

---

**Créé pour la plateforme TAKA - Plateforme panafricaine d'ebooks**


