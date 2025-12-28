#!/bin/bash

# Script pour déployer BookController et BookHelper, puis vider le cache des routes
# Usage: ./deploy-book-routes.sh

# Configuration
SERVER="u914969601@194.164.74.243"
SSH_PORT="65002"
SERVER_BASE="/home/u914969601/domains/takaafrica.com"
LOCAL_BASE="/Users/koffiangetognon/Documents/Taka/my-app"

echo "🚀 Déploiement des fichiers pour les pages de détails de livres..."
echo "==================================================================="
echo ""

# Vérifier que les fichiers locaux existent
if [ ! -f "$LOCAL_BASE/app/Http/Controllers/BookController.php" ]; then
    echo "❌ Erreur: BookController.php n'existe pas"
    exit 1
fi

if [ ! -f "$LOCAL_BASE/app/Helpers/BookHelper.php" ]; then
    echo "❌ Erreur: BookHelper.php n'existe pas"
    exit 1
fi

if [ ! -f "$LOCAL_BASE/routes/web.php" ]; then
    echo "❌ Erreur: web.php n'existe pas"
    exit 1
fi

# 1. Upload des fichiers
echo "📤 Upload des fichiers..."
echo "------------------------------------------------------------"

# BookController
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/app/Http/Controllers/BookController.php" "$SERVER:$SERVER_BASE/laravel/app/Http/Controllers/"

# BookHelper (créer le dossier Helpers s'il n'existe pas)
ssh -p $SSH_PORT $SERVER "mkdir -p $SERVER_BASE/laravel/app/Helpers"
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/app/Helpers/BookHelper.php" "$SERVER:$SERVER_BASE/laravel/app/Helpers/"

# Routes
rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/routes/web.php" "$SERVER:$SERVER_BASE/laravel/routes/"

if [ $? -eq 0 ]; then
    echo "✅ Fichiers uploadés avec succès"
else
    echo "❌ Erreur lors de l'upload"
    exit 1
fi

# 2. Configuration et cache
echo ""
echo "🔧 Configuration des permissions et vidage du cache..."
echo "----------------------------------------------"
ssh -p $SSH_PORT $SERVER << 'ENDSSH'
cd /home/u914969601/domains/takaafrica.com/laravel

# Permissions
chmod 644 app/Http/Controllers/BookController.php
chmod 644 app/Helpers/BookHelper.php
chmod 644 routes/web.php

# Vider TOUS les caches Laravel
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

# Recharger l'autoloader Composer (au cas où BookHelper n'était pas chargé)
composer dump-autoload --no-interaction --quiet

echo "✅ Permissions et cache configurés"
ENDSSH

echo ""
echo "✅ Déploiement terminé avec succès !"
echo ""
echo "📋 Vérification :"
echo "  1. Vérifier que les routes fonctionnent : https://takaafrica.com"
echo "  2. Tester une page de détail de livre"
echo ""
