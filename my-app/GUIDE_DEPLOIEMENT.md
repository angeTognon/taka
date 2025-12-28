# Guide de Déploiement Laravel - TAKA

Ce guide vous explique comment déployer votre application Laravel sur un serveur de production.

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :

- **PHP 8.2 ou supérieur** avec les extensions suivantes :
  - BCMath PHP Extension
  - Ctype PHP Extension
  - cURL PHP Extension
  - DOM PHP Extension
  - Fileinfo PHP Extension
  - JSON PHP Extension
  - Mbstring PHP Extension
  - OpenSSL PHP Extension
  - PCRE PHP Extension
  - PDO PHP Extension
  - Tokenizer PHP Extension
  - XML PHP Extension

- **Composer** installé globalement
- **Node.js** et **npm** (pour compiler les assets)
- **MySQL** ou **MariaDB** (base de données)
- **Nginx** ou **Apache** (serveur web)
- **SSL Certificate** (pour HTTPS - recommandé)

---

## 🚀 Étapes de Déploiement

### 1. Préparer le serveur

#### 1.1 Connexion au serveur
```bash
ssh utilisateur@votre-serveur.com
```

#### 1.2 Installer les dépendances système
```bash
# Sur Ubuntu/Debian
sudo apt update
sudo apt install php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-mbstring \
    php8.2-xml php8.2-curl php8.2-zip php8.2-gd php8.2-bcmath \
    mysql-server nginx composer nodejs npm git

# Sur CentOS/RHEL
sudo yum install php82 php82-php-cli php82-php-fpm php82-php-mysql \
    php82-php-mbstring php82-php-xml php82-php-curl php82-php-zip \
    php82-php-gd php82-php-bcmath mysql-server nginx composer nodejs npm git
```

---

### 2. Transférer les fichiers du projet

#### 2.1 Option A : Via Git (Recommandé)
```bash
# Sur le serveur
cd /var/www
git clone https://votre-repo.git taka
cd taka/my-app
```

#### 2.2 Option B : Via SCP/SFTP
```bash
# Depuis votre machine locale
scp -r my-app utilisateur@votre-serveur.com:/var/www/taka/
```

#### 2.3 Option C : Via rsync
```bash
# Depuis votre machine locale
rsync -avz --exclude 'node_modules' --exclude 'vendor' \
    --exclude '.git' --exclude 'storage/logs/*' \
    my-app/ utilisateur@votre-serveur.com:/var/www/taka/my-app/
```

---

### 3. Configuration de l'application

#### 3.1 Installer les dépendances PHP
```bash
cd /var/www/taka/my-app
composer install --optimize-autoloader --no-dev
```

#### 3.2 Créer le fichier .env
```bash
cp .env.example .env
nano .env
```

#### 3.3 Configurer le fichier .env
Modifiez les valeurs suivantes dans `.env` :

```env
APP_NAME=TAKA
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://takaafrica.com

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nom_de_votre_base
DB_USERNAME=nom_utilisateur_db
DB_PASSWORD=mot_de_passe_db

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

#### 3.4 Générer la clé d'application
```bash
php artisan key:generate
```

---

### 4. Configuration de la base de données

#### 4.1 Créer la base de données MySQL
```bash
mysql -u root -p
```

Dans MySQL :
```sql
CREATE DATABASE nom_de_votre_base CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'nom_utilisateur_db'@'localhost' IDENTIFIED BY 'mot_de_passe_db';
GRANT ALL PRIVILEGES ON nom_de_votre_base.* TO 'nom_utilisateur_db'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 4.2 Exécuter les migrations
```bash
php artisan migrate --force
```

#### 4.3 (Optionnel) Charger les données de test
```bash
php artisan db:seed --force
```

---

### 5. Compiler les assets frontend

#### 5.1 Installer les dépendances Node.js
```bash
npm install
```

#### 5.2 Compiler les assets pour la production
```bash
npm run build
```

---

### 6. Configuration des permissions

#### 6.1 Définir les permissions correctes
```bash
# Définir le propriétaire (remplacez www-data par votre utilisateur web)
sudo chown -R www-data:www-data /var/www/taka/my-app

# Permissions pour les dossiers
sudo find /var/www/taka/my-app -type d -exec chmod 755 {} \;

# Permissions pour les fichiers
sudo find /var/www/taka/my-app -type f -exec chmod 644 {} \;

# Permissions spéciales pour storage et bootstrap/cache
sudo chmod -R 775 /var/www/taka/my-app/storage
sudo chmod -R 775 /var/www/taka/my-app/bootstrap/cache
```

---

### 7. Configuration du serveur web (Nginx)

#### 7.1 Créer la configuration Nginx
```bash
sudo nano /etc/nginx/sites-available/taka
```

#### 7.2 Configuration Nginx recommandée
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name takaafrica.com www.takaafrica.com;
    
    # Redirection vers HTTPS (décommentez après avoir configuré SSL)
    # return 301 https://$server_name$request_uri;
    
    root /var/www/taka/my-app/public;
    index index.php index.html;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Optimisations
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;
}
```

#### 7.3 Activer le site
```bash
sudo ln -s /etc/nginx/sites-available/taka /etc/nginx/sites-enabled/
sudo nginx -t  # Vérifier la configuration
sudo systemctl reload nginx
```

---

### 8. Configuration SSL (HTTPS) avec Let's Encrypt

#### 8.1 Installer Certbot
```bash
sudo apt install certbot python3-certbot-nginx
```

#### 8.2 Obtenir le certificat SSL
```bash
sudo certbot --nginx -d takaafrica.com -d www.takaafrica.com
```

#### 8.3 Renouvellement automatique
Certbot configure automatiquement le renouvellement. Vérifiez avec :
```bash
sudo certbot renew --dry-run
```

---

### 9. Optimisations Laravel pour la production

#### 9.1 Optimiser l'autoloader
```bash
composer install --optimize-autoloader --no-dev
```

#### 9.2 Mettre en cache la configuration
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### 9.3 Optimiser les performances
```bash
php artisan optimize
```

---

### 10. Configuration des queues (si nécessaire)

Si votre application utilise des queues, configurez un worker :

#### 10.1 Créer un service systemd
```bash
sudo nano /etc/systemd/system/taka-queue.service
```

Contenu :
```ini
[Unit]
Description=TAKA Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/taka/my-app/artisan queue:work --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
```

#### 10.2 Activer et démarrer le service
```bash
sudo systemctl enable taka-queue
sudo systemctl start taka-queue
```

---

### 11. Configuration du scheduler Laravel (si nécessaire)

Si vous utilisez le scheduler Laravel :

#### 11.1 Ajouter la tâche cron
```bash
sudo crontab -e -u www-data
```

Ajoutez cette ligne :
```
* * * * * cd /var/www/taka/my-app && php artisan schedule:run >> /dev/null 2>&1
```

---

### 12. Sécurité

#### 12.1 Vérifier les permissions
```bash
# S'assurer que .env n'est pas accessible publiquement
chmod 600 /var/www/taka/my-app/.env
```

#### 12.2 Configurer le pare-feu
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

#### 12.3 Désactiver l'affichage des erreurs en production
Vérifiez que dans `.env` :
```env
APP_DEBUG=false
```

---

### 13. Tests de vérification

#### 13.1 Vérifier que l'application fonctionne
```bash
# Tester depuis le serveur
curl http://localhost
```

#### 13.2 Vérifier les logs
```bash
tail -f /var/www/taka/my-app/storage/logs/laravel.log
```

#### 13.3 Vérifier les erreurs Nginx
```bash
sudo tail -f /var/log/nginx/error.log
```

---

## 🔄 Mise à jour de l'application

Pour mettre à jour l'application après un déploiement :

```bash
cd /var/www/taka/my-app

# Mettre à jour le code
git pull origin main  # ou votre branche

# Mettre à jour les dépendances
composer install --optimize-autoloader --no-dev
npm install
npm run build

# Exécuter les migrations
php artisan migrate --force

# Nettoyer et recréer les caches
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Recréer les caches optimisés
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Redémarrer les services si nécessaire
sudo systemctl restart php8.2-fpm
sudo systemctl restart nginx
```

---

## 🐛 Dépannage

### Problème : Erreur 500
- Vérifiez les logs : `tail -f storage/logs/laravel.log`
- Vérifiez les permissions : `ls -la storage/ bootstrap/cache`
- Vérifiez la configuration : `php artisan config:clear && php artisan config:cache`

### Problème : Assets non chargés
- Recompilez les assets : `npm run build`
- Vérifiez que `APP_URL` dans `.env` correspond à votre domaine

### Problème : Base de données
- Vérifiez les credentials dans `.env`
- Testez la connexion : `php artisan tinker` puis `DB::connection()->getPdo();`

### Problème : Permissions
```bash
sudo chown -R www-data:www-data /var/www/taka/my-app
sudo chmod -R 775 /var/www/taka/my-app/storage
sudo chmod -R 775 /var/www/taka/my-app/bootstrap/cache
```

---

## 📝 Checklist de déploiement

- [ ] PHP 8.2+ installé avec toutes les extensions
- [ ] Composer installé
- [ ] Node.js et npm installés
- [ ] Base de données MySQL créée
- [ ] Fichier `.env` configuré
- [ ] `APP_KEY` généré
- [ ] Migrations exécutées
- [ ] Assets compilés (`npm run build`)
- [ ] Permissions configurées
- [ ] Nginx configuré et actif
- [ ] SSL configuré (HTTPS)
- [ ] Caches optimisés
- [ ] Queues configurées (si nécessaire)
- [ ] Scheduler configuré (si nécessaire)
- [ ] Pare-feu configuré
- [ ] Application testée et fonctionnelle

---

## 🔗 Ressources utiles

- [Documentation Laravel](https://laravel.com/docs)
- [Documentation Nginx](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Documentation PHP-FPM](https://www.php.net/manual/fr/install.fpm.php)

---

## 💡 Notes importantes

1. **Ne jamais commiter le fichier `.env`** - Il contient des informations sensibles
2. **Toujours utiliser HTTPS en production** - Pour la sécurité des données
3. **Sauvegarder régulièrement la base de données** - Utilisez des scripts de sauvegarde automatique
4. **Surveiller les logs** - Pour détecter les problèmes rapidement
5. **Mettre à jour régulièrement** - PHP, Laravel, et les dépendances pour la sécurité

---

Bon déploiement ! 🚀






