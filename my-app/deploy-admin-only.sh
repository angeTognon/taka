#!/bin/bash

# Script pour uploader UNIQUEMENT la partie admin (sans toucher au reste)
# Usage: ./deploy-admin-only.sh

# Configuration
SERVER="u914969601@194.164.74.243"
SSH_PORT="65002"
SERVER_BASE="/home/u914969601/domains/takaafrica.com"
LOCAL_BASE="/Users/koffiangetognon/Documents/Taka/my-app"

echo "🚀 Upload de la partie Admin uniquement..."
echo "=========================================="
echo ""

if [ ! -d "$LOCAL_BASE" ]; then
    echo "❌ Erreur: Le dossier $LOCAL_BASE n'existe pas"
    exit 1
fi

# 1. Upload du contrôleur Admin
echo "📤 1. Upload du contrôleur TakaAdminController..."
echo "------------------------------------------------"
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/app/Http/Controllers/TakaAdminController.php" \
    "$SERVER:$SERVER_BASE/laravel/app/Http/Controllers/"

# 2. Upload des vues admin
echo ""
echo "📤 2. Upload des vues admin (login.blade.php et index.blade.php)..."
echo "------------------------------------------------------------------"
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/resources/views/admin/" \
    "$SERVER:$SERVER_BASE/laravel/resources/views/admin/"

# 3. Upload des routes (web.php - inclut les routes admin)
echo ""
echo "📤 3. Upload du fichier routes/web.php (routes admin incluses)..."
echo "----------------------------------------------------------------"
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/routes/web.php" \
    "$SERVER:$SERVER_BASE/laravel/routes/"

# 4. Vider le cache
echo ""
echo "🔧 4. Vidage du cache Laravel..."
echo "--------------------------------"
ssh -p $SSH_PORT $SERVER << 'ENDSSH'
cd /home/u914969601/domains/takaafrica.com/laravel

# Vider le cache
php artisan view:clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear

echo "✅ Cache vidé avec succès"
ENDSSH

echo ""
echo "✅ Upload de la partie Admin terminé !"
echo ""
echo "📋 Fichiers uploadés :"
echo "  ✓ app/Http/Controllers/TakaAdminController.php"
echo "  ✓ resources/views/admin/index.blade.php"
echo "  ✓ resources/views/admin/login.blade.php"
echo "  ✓ routes/web.php"
echo ""
echo "🎯 Prochaines étapes :"
echo "  1. Tester la page admin : https://takaafrica.com/admin/login"
echo "  2. Se connecter avec admin@gmail.com / Taka2025#"
echo "  3. Vérifier que tout fonctionne correctement"
echo ""

