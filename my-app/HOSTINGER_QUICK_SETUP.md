# 🚀 Configuration Rapide Hostinger - Guide Étape par Étape

## 📦 Après avoir uploadé et extrait votre ZIP

### ÉTAPE 1 : Structure des dossiers

Votre structure devrait ressembler à ceci :

```
/home/u123456789/domains/votre-domaine.com/
│
├── public_html/              ← Votre site web (accessible publiquement)
└── my-app/                   ← Dossier extrait (à renommer en "laravel")
    ├── app/
    ├── public/
    ├── ...
```

### ÉTAPE 2 : Renommer le dossier

1. Dans le gestionnaire de fichiers Hostinger
2. Clic droit sur `my-app` → **Renommer**
3. Renommez en : `laravel`

### ÉTAPE 3 : Déplacer le contenu de `public/` vers `public_html/`

1. Ouvrez le dossier : `laravel/public/`
2. **Sélectionnez TOUS les fichiers et dossiers** (Ctrl+A ou Cmd+A)
3. **Coupez** (Ctrl+X ou Cmd+X)
4. Remontez et allez dans `public_html/`
5. **Collez** (Ctrl+V ou Cmd+V)

Vous devriez maintenant avoir :
- `public_html/index.php`
- `public_html/.htaccess`
- `public_html/css/`, `public_html/js/`, `public_html/images/`, etc.
- `laravel/public/` est maintenant vide (ou presque)

### ÉTAPE 4 : Modifier `public_html/index.php`

1. Ouvrez `public_html/index.php` dans l'éditeur de fichiers
2. Remplacez tout le contenu par :

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

if (file_exists($maintenance = __DIR__.'/../laravel/storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__.'/../laravel/vendor/autoload.php';

/** @var Application $app */
$app = require_once __DIR__.'/../laravel/bootstrap/app.php';

$app->handleRequest(Request::capture());
```

3. **Sauvegardez**

### ÉTAPE 5 : Créer le fichier `.env`

1. Allez dans le dossier `laravel/`
2. Créez un nouveau fichier nommé : `.env`
3. Copiez ce contenu et adaptez-le :

```env
APP_NAME="TAKA"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://votre-domaine.com

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=u123456789_votre_base
DB_USERNAME=u123456789_votre_user
DB_PASSWORD=votre_mot_de_passe

SESSION_DRIVER=file
SESSION_LIFETIME=120
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
```

4. **Important :** Remplacez :
   - `votre-domaine.com` par votre vrai domaine
   - `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` par vos vraies informations (trouvables dans hPanel → Bases de données MySQL)

### ÉTAPE 6 : Installer les dépendances (via SSH ou Terminal Hostinger)

Si vous avez accès SSH :

```bash
cd ~/domains/votre-domaine.com/laravel
composer install --no-dev --optimize-autoloader
php artisan key:generate
```

Si vous n'avez PAS accès SSH :
- Utilisez le "Terminal" dans hPanel (si disponible)
- Ou contactez le support Hostinger pour activer SSH/Composer

### ÉTAPE 7 : Configurer les permissions (via SSH)

```bash
cd ~/domains/votre-domaine.com/laravel
chmod -R 775 storage bootstrap/cache
```

### ÉTAPE 8 : Générer la clé d'application (via SSH)

```bash
cd ~/domains/votre-domaine.com/laravel
php artisan key:generate
```

### ÉTAPE 9 : Exécuter les migrations (via SSH)

```bash
cd ~/domains/votre-domaine.com/laravel
php artisan migrate --force
```

### ÉTAPE 10 : Optimiser pour la production (via SSH)

```bash
cd ~/domains/votre-domaine.com/laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### ÉTAPE 11 : Tester

1. Visitez : `https://votre-domaine.com`
2. Vérifiez que le site s'affiche
3. Testez quelques fonctionnalités

---

## 🔍 Résolution de problèmes

### Erreur 500 ?

1. Vérifiez les permissions : `chmod -R 775 storage bootstrap/cache`
2. Vérifiez les logs : `laravel/storage/logs/laravel.log`
3. Vérifiez que `.env` existe et est bien configuré
4. Vérifiez que `APP_KEY` n'est pas vide (lancez `php artisan key:generate`)

### Erreur "No application encryption key" ?

```bash
cd ~/domains/votre-domaine.com/laravel
php artisan key:generate
```

### Erreur de base de données ?

1. Vérifiez les identifiants dans `.env`
2. Créez la base de données dans hPanel si nécessaire
3. Vérifiez que l'utilisateur a les bons droits

### Les assets (CSS/JS/images) ne se chargent pas ?

1. Vérifiez que les fichiers sont bien dans `public_html/`
2. Vérifiez les permissions des dossiers

---

## ✅ Checklist finale

- [ ] Dossier `laravel/` créé
- [ ] Contenu de `laravel/public/` déplacé vers `public_html/`
- [ ] `public_html/index.php` modifié avec les bons chemins
- [ ] Fichier `.env` créé dans `laravel/` avec les bonnes informations
- [ ] `composer install` exécuté
- [ ] `php artisan key:generate` exécuté
- [ ] Permissions sur `storage/` et `bootstrap/cache/` configurées (775)
- [ ] `php artisan migrate` exécuté
- [ ] Caches optimisés (`config:cache`, `route:cache`, `view:cache`)
- [ ] Site testé et fonctionnel

---

## 📞 Besoin d'aide ?

- Vérifiez les logs : `laravel/storage/logs/laravel.log`
- Contactez le support Hostinger
- Consultez `DEPLOYMENT_GUIDE.md` pour plus de détails

