#!/bin/bash

# Script de déploiement pour Hostinger
# Usage: ./deploy.sh

echo "🚀 Préparation du déploiement Laravel..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "artisan" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis la racine du projet Laravel${NC}"
    exit 1
fi

# Nom du fichier de déploiement
DEPLOY_FILE="../my-app-deploy-$(date +%Y%m%d-%H%M%S).zip"

echo -e "${YELLOW}📦 Création de l'archive...${NC}"

# Créer l'archive en excluant les fichiers inutiles
zip -r "$DEPLOY_FILE" . \
  -x "node_modules/*" \
  -x ".git/*" \
  -x ".gitignore" \
  -x ".env" \
  -x ".env.*" \
  -x "storage/logs/*" \
  -x "storage/framework/cache/*" \
  -x "storage/framework/sessions/*" \
  -x "storage/framework/views/*" \
  -x "vendor/*" \
  -x "*.DS_Store" \
  -x ".idea/*" \
  -x ".vscode/*" \
  -x "tests/*" \
  -x "phpunit.xml" \
  -x ".phpunit.result.cache" \
  -x "DEPLOYMENT_GUIDE.md" \
  -x "deploy.sh"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archive créée avec succès: $DEPLOY_FILE${NC}"
    echo -e "${YELLOW}📤 Vous pouvez maintenant uploader ce fichier sur Hostinger${NC}"
    echo ""
    echo "Prochaines étapes:"
    echo "1. Connectez-vous à votre compte Hostinger"
    echo "2. Allez dans le gestionnaire de fichiers"
    echo "3. Naviguez vers public_html"
    echo "4. Uploadez le fichier: $(basename $DEPLOY_FILE)"
    echo "5. Extrayez l'archive"
    echo "6. Suivez les instructions dans DEPLOYMENT_GUIDE.md"
else
    echo -e "${RED}❌ Erreur lors de la création de l'archive${NC}"
    exit 1
fi
