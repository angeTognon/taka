# 📁 Organisation des Dossiers sur Hostinger

## 🎯 Recommandation : Structure Standard (Plus Sécurisée)

Cette structure est recommandée car elle garde le code source hors de `public_html`, ce qui est plus sécurisé.

### Structure finale sur le serveur :

```
/home/u123456789/domains/votre-domaine.com/
│
├── public_html/                    ← Point d'entrée web (URL racine)
│   ├── index.php                   ← Point d'entrée Laravel (modifié)
│   ├── .htaccess                   ← Configuration Apache
│   ├── css/                        ← Assets CSS
│   ├── js/                         ← Assets JS
│   ├── images/                     ← Images du site
│   └── (autres fichiers publics)
│
└── laravel/                        ← Racine du projet Laravel
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── database/
    ├── public/                     ← (vide, tout déplacé vers public_html)
    ├── resources/
    ├── routes/
    ├── storage/
    ├── vendor/                     ← Installé via composer
    ├── .env                        ← Fichier de configuration
    ├── artisan
    ├── composer.json
    └── ...
```

---

## 📋 ÉTAPES DÉTAILLÉES

### Étape 1 : Extraire l'archive sur le serveur

1. Connectez-vous à hPanel (Hostinger)
2. Allez dans "Gestionnaire de fichiers"
3. Naviguez vers `/domains/votre-domaine.com/` (pas `public_html`)
4. Uploadez votre fichier ZIP (`my-app-deploy-XXXXXX.zip`)
5. Clic droit sur le ZIP → "Extraire"

Vous aurez maintenant :
```
/domains/votre-domaine.com/
└── my-app/                         ← Contenu extrait
    ├── app/
    ├── public/
    ├── ...
```

### Étape 2 : Renommer et réorganiser

#### Option A : Via le gestionnaire de fichiers Hostinger

1. **Renommer le dossier extrait** :
   - Renommez `my-app` en `laravel`

2. **Déplacer le contenu de `public/` vers `public_html/`** :
   - Ouvrez `laravel/public/`
   - Sélectionnez TOUS les fichiers et dossiers (sauf `.htaccess` si déjà présent)
   - Coupez-les (Ctrl+X ou Cmd+X)
   - Naviguez vers `public_html/`
   - Collez-les (Ctrl+V ou Cmd+V)

3. **Vérifier** :
   - `public_html/index.php` doit exister
   - `public_html/.htaccess` doit exister
   - `laravel/public/` devrait être vide (ou presque)

#### Option B : Via SSH (si disponible)

```bash
# Se connecter via SSH
ssh u123456789@votre-domaine.com

# Naviguer vers le répertoire du domaine
cd ~/domains/votre-domaine.com

# Renommer le dossier extrait
mv my-app laravel

# Déplacer le contenu de public vers public_html
mv laravel/public/* public_html/
mv laravel/public/.* public_html/ 2>/dev/null || true

# Vérifier
ls -la public_html/
ls laravel/public/
```

### Étape 3 : Modifier `public_html/index.php`

Le fichier `public_html/index.php` doit pointer vers le dossier `laravel/`.

Ouvrez `public_html/index.php` et modifiez les chemins :

**AVANT :**
```php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
```

**APRÈS :**
```php
require __DIR__.'/../laravel/vendor/autoload.php';
$app = require_once __DIR__.'/../laravel/bootstrap/app.php';
```

**Fichier complet `public_html/index.php` :**
```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../laravel/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../laravel/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../laravel/bootstrap/app.php';

$app->handleRequest(Request::capture());
```

### Étape 4 : Créer le fichier `.env` dans `laravel/`

1. Via le gestionnaire de fichiers :
   - Naviguez vers `laravel/`
   - Créez un nouveau fichier nommé `.env`
   - Copiez le contenu de `.env.example` (si présent)
   - Modifiez avec vos informations

2. Via SSH :
```bash
cd ~/domains/votre-domaine.com/laravel
cp .env.example .env
nano .env  # ou utilisez l'éditeur de fichiers Hostinger
```

### Étape 5 : Installer les dépendances

```bash
cd ~/domains/votre-domaine.com/laravel
composer install --no-dev --optimize-autoloader
```

### Étape 6 : Configurer les permissions

```bash
cd ~/domains/votre-domaine.com/laravel
chmod -R 775 storage bootstrap/cache
```

---

## 🔄 ALTERNATIVE : Structure Simplifiée (Tout dans public_html)

Si vous préférez une structure plus simple (moins sécurisée mais plus facile) :

### Structure :

```
/home/u123456789/domains/votre-domaine.com/
└── public_html/                    ← Tout le projet ici
    ├── app/
    ├── bootstrap/
    ├── config/
    ├── public/                     ← Contenu accessible web
    │   ├── index.php
    │   ├── .htaccess
    │   └── assets/
    ├── routes/
    ├── storage/
    ├── vendor/
    ├── .env
    └── ...
```

### Configuration Apache (.htaccess dans public_html)

Vous devrez modifier `.htaccess` pour rediriger vers `public/` :

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    
    # Redirect to public folder
    RewriteCond %{REQUEST_URI} !^/public/
    RewriteRule ^(.*)$ /public/$1 [L]
</IfModule>
```

**⚠️ Note :** Cette méthode est moins sécurisée car tout le code est dans `public_html`.

---

## ✅ VÉRIFICATIONS FINALES

### Vérifier que tout est en place :

1. ✅ `public_html/index.php` existe et pointe vers `laravel/`
2. ✅ `public_html/.htaccess` existe
3. ✅ `laravel/.env` existe et est configuré
4. ✅ `laravel/vendor/` existe (après `composer install`)
5. ✅ Permissions correctes sur `laravel/storage/` et `laravel/bootstrap/cache/`

### Tester :

1. Visitez `https://votre-domaine.com`
2. Vérifiez que la page d'accueil s'affiche
3. Testez quelques fonctionnalités

---

## 🛠️ COMMANDES UTILES

### Via SSH :

```bash
# Voir la structure
cd ~/domains/votre-domaine.com
tree -L 2  # Si disponible, ou utilisez ls -la

# Vérifier les permissions
ls -la laravel/storage/
ls -la laravel/bootstrap/cache/

# Voir les logs en cas d'erreur
tail -f laravel/storage/logs/laravel.log

# Régénérer les caches
cd laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 🎯 RÉSUMÉ VISUEL

```
📁 domains/votre-domaine.com/
│
├── 📁 public_html/           ← Accessible via https://votre-domaine.com
│   ├── 📄 index.php          ← Point d'entrée (pointe vers ../laravel/)
│   ├── 📄 .htaccess
│   └── 📁 images/            ← Assets publics
│
└── 📁 laravel/               ← Code source (non accessible directement)
    ├── 📁 app/
    ├── 📁 config/
    ├── 📁 storage/
    ├── 📁 vendor/            ← Après composer install
    └── 📄 .env               ← Configuration
```

---

## ⚠️ IMPORTANT

- **Ne jamais** mettre `.env` dans `public_html`
- **Ne jamais** exposer `vendor/`, `storage/`, `config/` directement
- Toujours vérifier que `APP_DEBUG=false` en production
- Utiliser HTTPS (certificat SSL via Hostinger)

