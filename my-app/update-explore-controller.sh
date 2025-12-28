#!/bin/bash

# Script pour mettre à jour ExploreController.php sur le serveur
# Usage: ./update-explore-controller.sh

echo "🔄 Mise à jour de ExploreController.php sur le serveur..."

# Configuration
SERVER="u914969601@194.164.74.243"
PORT="65002"
LOCAL_FILE="/Users/koffiangetognon/Documents/Taka/my-app/app/Http/Controllers/ExploreController.php"
REMOTE_PATH="~/domains/takaafrica.com/laravel/app/Http/Controllers/ExploreController.php"

# Vérifier que le fichier local existe
if [ ! -f "$LOCAL_FILE" ]; then
    echo "❌ Erreur: Le fichier local n'existe pas: $LOCAL_FILE"
    exit 1
fi

# Copier le fichier sur le serveur
echo "📤 Upload du fichier..."
scp -P $PORT "$LOCAL_FILE" "$SERVER:$REMOTE_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Fichier uploadé avec succès"
    
    # Vider les caches
    echo "🧹 Nettoyage des caches..."
    ssh -p $PORT $SERVER "cd ~/domains/takaafrica.com/laravel && php artisan config:clear && php artisan route:clear"
    
    if [ $? -eq 0 ]; then
        echo "✅ Caches vidés avec succès"
        echo ""
        echo "🎉 Mise à jour terminée !"
        echo "🌐 Visitez: https://takaafrica.com/explore"
    else
        echo "⚠️  Le fichier a été uploadé, mais erreur lors du nettoyage des caches"
        echo "   Connectez-vous manuellement et exécutez: php artisan config:clear && php artisan route:clear"
    fi
else
    echo "❌ Erreur lors de l'upload du fichier"
    exit 1
fi

