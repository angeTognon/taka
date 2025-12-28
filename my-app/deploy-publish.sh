#!/bin/bash

# Script pour déployer publish.blade.php sur le serveur Hostinger
# Usage: ./deploy-publish.sh

# Configuration
SERVER="u914969601@194.164.74.243"
SSH_PORT="65002"
SERVER_BASE="/home/u914969601/domains/takaafrica.com"
LOCAL_BASE="/Users/koffiangetognon/Documents/Taka/my-app"

echo "🚀 Déploiement de publish.blade.php sur le serveur..."
echo "==================================================================="
echo ""

# Vérifier que le fichier local existe
if [ ! -f "$LOCAL_BASE/resources/views/publish.blade.php" ]; then
    echo "❌ Erreur: Le fichier $LOCAL_BASE/resources/views/publish.blade.php n'existe pas"
    exit 1
fi

# 1. Upload du fichier
echo "📤 Upload de publish.blade.php..."
echo "------------------------------------------------------------"

rsync -avz -e "ssh -p $SSH_PORT" \
    "$LOCAL_BASE/resources/views/publish.blade.php" "$SERVER:$SERVER_BASE/laravel/resources/views/"

if [ $? -eq 0 ]; then
    echo "✅ Fichier uploadé avec succès"
else
    echo "❌ Erreur lors de l'upload"
    exit 1
fi

# 2. Configuration des permissions et cache
echo ""
echo "🔧 Configuration des permissions et cache..."
echo "----------------------------------------------"
ssh -p $SSH_PORT $SERVER << 'ENDSSH'
cd /home/u914969601/domains/takaafrica.com/laravel

# Permissions sur le fichier
chmod 644 resources/views/publish.blade.php

# Vider le cache des vues
php artisan view:clear

echo "✅ Permissions et cache configurés"
ENDSSH

echo ""
echo "✅ Déploiement terminé avec succès !"
echo ""
echo "📋 Vérification :"
echo "  1. Vérifier que le site fonctionne : https://takaafrica.com/publish"
echo "  2. Tester la publication d'un livre"
echo ""
