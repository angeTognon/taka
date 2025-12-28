# Guide de Déploiement Laravel sur Hostinger

## 📋 Prérequis
- Accès FTP/SFTP à votre compte Hostinger
- Accès au panneau de contrôle Hostinger (hPanel)
- Base de données MySQL créée sur Hostinger

---

## 🚀 ÉTAPE 1 : Préparer le projet localement

### 1.1 Créer un fichier .env pour la production
```bash
# Dans votre terminal, copiez .env.example vers .env.production
cp .env.example .env.production
```

### 1.2 Exclure les fichiers inutiles
Créez un fichier `.deployignore` (ou utilisez `.gitignore`) pour exclure :
- `node_modules/`
- `.git/`
- `.env` (on créera un nouveau sur le serveur)
- `storage/logs/*` (garder le dossier, vider les fichiers)
- `vendor/` (on réinstallera sur le serveur)
- Tests et fichiers de développement

### 1.3 Optimiser pour la production
```bash
# Dans le terminal, à la racine du projet Laravel
cd /Users/koffiangetognon/Documents/Taka/my-app

# Installer les dépendances (si pas déjà fait)
composer install --no-dev --optimize-autoloader

# Optimiser le cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 📦 ÉTAPE 2 : Créer l'archive ZIP

### Option A : Via Terminal (Mac/Linux)
```bash
cd /Users/koffiangetognon/Documents/Taka

# Créer un ZIP en excluant certains dossiers
zip -r my-app-deploy.zip my-app/ \
  -x "my-app/node_modules/*" \
  -x "my-app/.git/*" \
  -x "my-app/.env" \
  -x "my-app/storage/logs/*" \
  -x "my-app/vendor/*" \
  -x "*.DS_Store"
```

### Option B : Via Interface Graphique
1. Ouvrez le Finder
2. Naviguez vers `/Users/koffiangetognon/Documents/Taka/my-app`
3. Sélectionnez tous les fichiers et dossiers SAUF :
   - `node_modules/`
   - `.git/`
   - `.env`
   - `vendor/` (si présent)
4. Clic droit → "Compresser X éléments"
5. Renommez l'archive en `my-app-deploy.zip`

---

## 📤 ÉTAPE 3 : Uploader sur Hostinger

### 3.1 Via FTP/SFTP (Recommandé)
1. **Connectez-vous à FileZilla ou Cyberduck**
   - Hôte : `ftp.votre-domaine.com` ou l'IP fournie par Hostinger
   - Utilisateur : Votre nom d'utilisateur FTP
   - Mot de passe : Votre mot de passe FTP
   - Port : 21 (FTP) ou 22 (SFTP)

2. **Naviguez vers le dossier public**
   - Chemin typique : `/public_html/` ou `/domains/votre-domaine.com/public_html/`

3. **Uploader le fichier ZIP**
   - Glissez-déposez `my-app-deploy.zip` dans le dossier public_html

4. **Extraire l'archive**
   - Via le gestionnaire de fichiers Hostinger (hPanel)
   - Ou via SSH : `unzip my-app-deploy.zip`

### 3.2 Via hPanel (Gestionnaire de fichiers)
1. Connectez-vous à hPanel
2. Allez dans "Gestionnaire de fichiers"
3. Naviguez vers `public_html`
4. Cliquez sur "Uploader" et sélectionnez votre ZIP
5. Une fois uploadé, cliquez droit sur le ZIP → "Extraire"

---

## 🔧 ÉTAPE 4 : Organiser les fichiers sur le serveur

### Structure recommandée pour Hostinger :
```
/home/u123456789/domains/votre-domaine.com/
├── public_html/          (Point d'entrée web)
│   ├── index.php         (Point d'entrée Laravel)
│   ├── .htaccess
│   └── assets/           (CSS, JS, images)
└── laravel/              (Racine du projet Laravel)
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── public/            (Contenu déplacé vers public_html)
    ├── resources/
    ├── routes/
    ├── storage/
    └── vendor/
```

### 4.1 Déplacer les fichiers
```bash
# Via SSH (si disponible) ou via gestionnaire de fichiers
cd /home/u123456789/domains/votre-domaine.com/public_html

# Extraire le ZIP si pas déjà fait
unzip my-app-deploy.zip -d ../laravel

# Déplacer le contenu de public/ vers public_html
mv ../laravel/my-app/public/* .
mv ../laravel/my-app/public/.* . 2>/dev/null || true

# Créer un lien symbolique vers storage (si nécessaire)
# Ou copier le dossier storage
```

---

## ⚙️ ÉTAPE 5 : Configuration de l'environnement

### 5.1 Créer le fichier .env
```bash
# Via SSH ou gestionnaire de fichiers
cd /home/u123456789/domains/votre-domaine.com/laravel/my-app

# Copier .env.example vers .env
cp .env.example .env
```

### 5.2 Modifier le fichier .env
Éditez le fichier `.env` avec les informations de votre serveur :

```env
APP_NAME="TAKA"
APP_ENV=production
APP_KEY=base64:VOTRE_CLE_GENEREE
APP_DEBUG=false
APP_URL=https://votre-domaine.com

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=u123456789_nom_base
DB_USERNAME=u123456789_user
DB_PASSWORD=votre_mot_de_passe

# Configuration de la session (si nécessaire)
SESSION_DRIVER=file
SESSION_LIFETIME=120

# Cache
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
```

### 5.3 Générer la clé d'application
```bash
# Via SSH
cd /home/u123456789/domains/votre-domaine.com/laravel/my-app
php artisan key:generate
```

---

## 📊 ÉTAPE 6 : Configuration de la base de données

### 6.1 Créer la base de données (via hPanel)
1. Allez dans hPanel → "Bases de données MySQL"
2. Créez une nouvelle base de données
3. Créez un utilisateur et associez-le à la base
4. Notez les identifiants

### 6.2 Exécuter les migrations
```bash
# Via SSH
cd /home/u123456789/domains/votre-domaine.com/laravel/my-app
php artisan migrate --force
```

---

## 📦 ÉTAPE 7 : Installer les dépendances

### 7.1 Installer Composer (si pas déjà installé)
```bash
# Vérifier si Composer est installé
composer --version

# Si non, installer via SSH
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
```

### 7.2 Installer les dépendances PHP
```bash
cd /home/u123456789/domains/votre-domaine.com/laravel/my-app
composer install --no-dev --optimize-autoloader
```

---

## 🔐 ÉTAPE 8 : Configurer les permissions

### 8.1 Permissions des dossiers
```bash
# Via SSH
cd /home/u123456789/domains/votre-domaine.com/laravel/my-app

# Permissions pour storage et bootstrap/cache
chmod -R 775 storage bootstrap/cache
chown -R u123456789:u123456789 storage bootstrap/cache
```

---

## 🌐 ÉTAPE 9 : Configuration du serveur web

### 9.1 Modifier le fichier index.php dans public_html
Le fichier `index.php` doit pointer vers le bon chemin :

```php
<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Ajuster ce chemin selon votre structure
require __DIR__.'/../laravel/my-app/vendor/autoload.php';

$app = require_once __DIR__.'/../laravel/my-app/bootstrap/app.php';

$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
)->send();

$kernel->terminate($request, $response);
```

### 9.2 Créer/modifier .htaccess dans public_html
```apache
<IfModule mod_rewrite.c>
    <IfModule mod_negotiation.c>
        Options -MultiViews -Indexes
    </IfModule>

    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect Trailing Slashes If Not A Folder...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_URI} (.+)/$
    RewriteRule ^ %1 [L,R=301]

    # Send Requests To Front Controller...
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [L]
</IfModule>
```

---

## ✅ ÉTAPE 10 : Vérifications finales

### 10.1 Optimiser Laravel
```bash
cd /home/u123456789/domains/votre-domaine.com/laravel/my-app

# Cache de configuration
php artisan config:cache

# Cache des routes
php artisan route:cache

# Cache des vues
php artisan view:cache
```

### 10.2 Tester le site
1. Visitez `https://votre-domaine.com`
2. Vérifiez que le site s'affiche correctement
3. Testez les fonctionnalités principales

---

## 🐛 Résolution de problèmes courants

### Erreur 500
- Vérifiez les permissions : `chmod -R 775 storage bootstrap/cache`
- Vérifiez les logs : `storage/logs/laravel.log`
- Vérifiez que `APP_DEBUG=false` en production

### Erreur "No application encryption key"
```bash
php artisan key:generate
```

### Erreur de base de données
- Vérifiez les identifiants dans `.env`
- Vérifiez que la base de données existe
- Vérifiez les permissions de l'utilisateur MySQL

### Assets (CSS/JS) ne se chargent pas
- Vérifiez que les fichiers sont dans `public_html`
- Vérifiez les chemins dans vos vues Blade

---

## 📝 Notes importantes

1. **Ne jamais commit le .env** en production
2. **APP_DEBUG doit être false** en production
3. **Vérifier les permissions** régulièrement
4. **Sauvegarder régulièrement** la base de données
5. **Utiliser HTTPS** (certificat SSL via Hostinger)

---

## 🔄 Mise à jour future

Pour mettre à jour le site :
1. Faites les modifications localement
2. Testez en local
3. Créez un nouveau ZIP (excluant vendor, node_modules)
4. Uploader et extraire
5. Via SSH : `composer install --no-dev --optimize-autoloader`
6. `php artisan migrate` (si nouvelles migrations)
7. `php artisan config:cache && php artisan route:cache && php artisan view:cache`

---

## 📞 Support

En cas de problème :
- Consultez les logs : `storage/logs/laravel.log`
- Contactez le support Hostinger
- Vérifiez la documentation Laravel : https://laravel.com/docs/deployment

