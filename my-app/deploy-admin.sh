#!/bin/bash

# Script pour déployer le projet Laravel sur le serveur Hostinger
# Usage: ./deploy-admin.sh

# Configuration
SERVER="u914969601@194.164.74.243"
SSH_PORT="65002"
SERVER_BASE="/home/u914969601/domains/takaafrica.com"
LOCAL_BASE="/Users/koffiangetognon/Documents/Taka/my-app"

echo "🚀 Déploiement du projet Laravel sur le serveur..."
echo "=================================================="
echo ""

# Vérifier que le dossier local existe
if [ ! -d "$LOCAL_BASE" ]; then
    echo "❌ Erreur: Le dossier $LOCAL_BASE n'existe pas"
    exit 1
fi

# 1. Upload des fichiers Laravel (excluant vendor, node_modules, etc.)
echo "📤 1. Upload des fichiers Laravel..."
echo "-----------------------------------"
rsync -avz -e "ssh -p $SSH_PORT" \
    --exclude='vendor/' \
    --exclude='node_modules/' \
    --exclude='.git/' \
    --exclude='storage/framework/cache/*' \
    --exclude='storage/framework/sessions/*' \
    --exclude='storage/framework/views/*' \
    --exclude='storage/logs/*' \
    --exclude='bootstrap/cache/*' \
    --exclude='.env' \
    --exclude='.env.production' \
    --exclude='.env.local' \
    --exclude='database/database.sqlite' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='deploy*.sh' \
    --exclude='upload*.sh' \
    --exclude='*.md' \
    --exclude='composer.json.backup' \
    --exclude='composer-prod.json' \
    --exclude='phpunit.xml' \
    --exclude='tests/' \
    --exclude='.phpunit.result.cache' \
    "$LOCAL_BASE/" "$SERVER:$SERVER_BASE/laravel/"

# 2. Upload des fichiers publics (images)
echo ""
echo "📤 2. Upload des fichiers publics (images)..."
echo "--------------------------------------------"
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/public/images/" "$SERVER:$SERVER_BASE/public_html/images/"

# 3. Configuration des permissions et cache
echo ""
echo "🔧 3. Configuration des permissions et cache..."
echo "----------------------------------------------"
ssh -p $SSH_PORT $SERVER << 'ENDSSH'
cd /home/u914969601/domains/takaafrica.com/laravel

# Permissions storage et bootstrap/cache
chmod -R 775 storage bootstrap/cache
chown -R u914969601:u914969601 storage bootstrap/cache

# S'assurer que les dossiers nécessaires existent
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Permissions sur les nouveaux dossiers
chmod -R 775 storage bootstrap/cache

# Vider le cache
php artisan view:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo "✅ Permissions et cache configurés"
ENDSSH

echo ""
echo "✅ Déploiement terminé avec succès !"
echo ""
echo "📋 Prochaines étapes :"
echo "  1. Vérifier que le site fonctionne sur https://takaafrica.com"
echo "  2. Tester la page admin : https://takaafrica.com/admin/login"
echo "  3. Vérifier les nouvelles fonctionnalités"
echo ""

