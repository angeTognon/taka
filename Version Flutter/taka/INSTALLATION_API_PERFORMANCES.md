# Installation de l'API des Performances

## Fichier créé
- `taka_api_author_performance.php` - API pour récupérer les données de performance des auteurs

## Instructions d'installation

### 1. Télécharger le fichier sur votre serveur
Téléchargez le fichier `taka_api_author_performance.php` vers le même répertoire que vos autres fichiers API sur votre serveur (probablement à l'adresse configurée dans `baseUrl`).

### 2. Vérifier la connexion à la base de données
Le fichier utilise automatiquement votre fichier `db.php` existant pour la connexion à la base de données. Assurez-vous que :
- Le fichier `db.php` est dans le même répertoire que `taka_api_author_performance.php`
- Le fichier `db.php` crée une connexion `$conn` (variable standard)

### 3. Vérifier que la table `books` existe
L'API utilise la table `books` avec les colonnes suivantes :
- `user_id` - ID de l'auteur
- `rating` - Note du livre (pour calculer la moyenne)
- `sales` - Nombre de ventes
- `readers` - Nombre de lecteurs

### 4. Tester l'API
Accédez à l'URL suivante dans votre navigateur :
```
https://votre-domaine.com/taka_api_author_performance.php?user_id=1
```

Vous devriez obtenir une réponse JSON comme :
```json
{
  "success": true,
  "averageRating": 4.5,
  "completionRate": 0.78
}
```

## Modifications apportées dans le code Flutter

Les modifications suivantes ont été apportées dans `lib/screens/dashboard_screen.dart` :

1. **Ajout d'une variable d'état pour les performances** :
   - `performanceData` - Stocke la note moyenne et le taux d'achèvement

2. **Nouvelle fonction `fetchPerformanceData()`** :
   - Récupère les données de performance depuis l'API
   - Appelée automatiquement au chargement de la page

3. **Mise à jour du widget `_buildSidebar()`** :
   - Affiche maintenant les données dynamiques au lieu de valeurs statiques
   - La note moyenne est calculée depuis la base de données
   - Le taux d'achèvement est calculé en fonction du ratio lecteurs/ventes

## Fonctionnalités

### Section Performances
- ✅ **Note moyenne** : Calculée automatiquement à partir de tous les livres de l'auteur
- ✅ **Taux d'achèvement** : Calculé en fonction du nombre de lecteurs par rapport aux ventes

### Section Évolution des ventes
- ✅ Utilise déjà l'API `taka_api_author_sales_chart.php` pour afficher les données réelles
- ✅ Les données sont mises à jour automatiquement au chargement de la page

## Dépannage

### Erreur "Erreur de connexion à la base de données"
- Vérifiez que les paramètres de connexion sont corrects
- Vérifiez que votre serveur MySQL est en ligne

### Erreur "ID utilisateur invalide"
- Assurez-vous de passer un `user_id` valide dans l'URL

### Les données ne s'affichent pas
- Vérifiez que la table `books` contient des données pour cet auteur
- Ouvrez la console du navigateur pour voir s'il y a des erreurs réseau
- Vérifiez que l'URL de l'API est correcte dans votre configuration `baseUrl`

